function P = initial_pose(img,xm,varargin);
% INITIAL_POSE: perform interactive positioning to define a pose parameter on a given
% image.
%
%   P = initial_pose(img,xmodel);
%
% Input:
%   - img is an image matrix,
%   - xmodel is a shape in model frame (you can use mean shape for it).
%
% Output:
%   - P = pose parameter in this form: [sx sy tx ty] or [tx ty scale theta] depends on
%         the output format. Default is [sx sy tx ty].
%
% Optional arguments:
%   - 'output', 'linear' or 'non-linear'. Default is 'linear'.
%     Defines the output P format.
%     If output = linear, then P = [sx sy tx ty].
%     If output = 'non-linear', then P = [tx ty scale theta].
%
% A. Suinesiaputra - LKEB 2005

% default values
output_format = 'linear';

% get optional arguments
for i=1:2:length(varargin)
    if( strcmpi(varargin{i},'output') ) output_format = varargin{i+1};
    else error('Unknown option.'); end
end


% create figure
sz = get(0,'ScreenSize');
width = 600;
height = 600;
x0 = 0;
y0 = 0;

title = 'Initial Pose';
fig = figure('Position',[0.5*(sz(3)-width) 0.5*(sz(4)-height) width height],'Color','k',...
    'Name',title,'NumberTitle','off','DoubleBuffer','on','MenuBar','none','Pointer','cross');
h = guidata(fig);
h.fig = fig;

% create axes
h.ax = axes('Position',[0 0 1 1],'Box','on','Color','k');

% draw image
h.im = imagesc(img); colormap(gray); axis image;
hold on;

% info text
h.tx_txt = text(10,10,'Tx:','Color','g','BackgroundColor','none','HorizontalAlignment','left');
h.ty_txt = text(10,20,'Ty:','Color','g','BackgroundColor','none','HorizontalAlignment','left');
h.sc_txt = text(10,30,'Scale:','Color','g','BackgroundColor','none','HorizontalAlignment','left');
h.th_txt = text(10,40,'Theta:','Color','g','BackgroundColor','none','HorizontalAlignment','left');

% set button

h.btn = uicontrol('Style','pushbutton','String','Get','Units','pixels','Position',[10 10 60 20]);

% icons & shapes
h.pivot_icon = [];
h.hshape = [];

% save data
h.tx = 0;
h.ty = 0;
h.scale = 1.0;
h.theta = 0.0;
h.X = xm;
h.btn_pressed = 0;
h.sc_unit = 5.0;
guidata(h.fig,h);

% set current info
set_info(h);

% set callback
set(h.im,'ButtonDownFcn',{@mouse_pressed});
set(h.fig,'WindowButtonMotionFcn',{@mouse_move},'WindowButtonUpFcn',{@mouse_released});
set(h.btn,'Callback','uiresume(gcf);');

% create dialog
P = [];
% modal
uiwait(fig);

% get settings
if( ~ishandle(fig) ) return; end

h = guidata(fig);
if( strcmpi(output_format,'linear') )
    sx = h.scale*cos(h.theta) - 1;
    sy = h.scale*sin(h.theta);
    P = [sx sy h.tx h.ty];
elseif( strcmpi(output_format,'non-linear') )
    P = [h.tx h.ty h.scale h.theta];
else error('Unknown output format.'); end

close(fig);


function set_info(h)
% update info strings
% ----------------------------------------------------------------------------------------

% set info text
set(h.tx_txt,'String',sprintf('Tx: %.2f',h.tx));
set(h.ty_txt,'String',sprintf('Ty: %.2f',h.tx));
set(h.sc_txt,'String',sprintf('Scale: %.2f',h.scale));
set(h.th_txt,'String',sprintf('Theta: %.2f',h.theta));


function mouse_pressed(hObject,eventdata)
% mouse button is pressed on axes
% ----------------------------------------------------------------------------------------

% get guidata
h = guidata(hObject);

% get position, set tx & ty
pos = get(h.ax,'CurrentPoint');
pivot = pos(1,1:2);
h.tx = pivot(1);
h.ty = pivot(2);
h.scale = 1.0;
h.theta = 0.0;

% set icon
if( ishandle(h.pivot_icon) ) delete(h.pivot_icon); end
h.pivot_icon = plot(h.tx,h.ty,'ys','MarkerSize',5,'MarkerFaceColor','y');
% delete shape

if( ishandle(h.hshape) ) delete(h.hshape); end
h.hshape = [];

guidata(h.fig,h);

% set button pressed
h.btn_pressed = 1;
guidata(h.fig,h);

% set info
set_info(h);


function mouse_move(hObject,eventdata)
% mouse move over the figure
% ----------------------------------------------------------------------------------------

% get guidata
h = guidata(hObject);

% check if button is pressed
if( h.btn_pressed )
    % get position
    pos = get(h.ax,'CurrentPoint');
    pivot = pos(1,1:2);
    
    % calculate distance and use it as the scale
    h.scale = h.sc_unit * sqrt(sum((pivot-[h.tx h.ty]).^2))+1.0; % minimum is 1.0
    
    % calculate the angle from the [tx,ty]
    h.theta = atan2(pivot(2)-h.ty,pivot(1)-h.tx);
    
    
    % save data and call set_info
    guidata(h.fig,h);
    set_info(h);
    draw_shape(h);
end


function mouse_released(hObject,eventdata)
% mouse button is released
% ----------------------------------------------------------------------------------------

% get guidata
h = guidata(hObject);

% update button pressed
h.btn_pressed = 0;

% save data
guidata(h.fig,h);



function draw_shape(h)
% draw shape
% ----------------------------------------------------------------------------------------

% transform h.X depends on the current pose
xim = transform_shapes(h.X,[h.tx h.ty h.scale h.theta],'format','non-linear');

% delete current handle of the shape
delete(h.hshape);
h.hshape = plot_shapes(xim,'-y');

% save guidata
guidata(h.fig,h);