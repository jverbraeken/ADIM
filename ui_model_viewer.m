function fig = ui_model_viewer(varargin)
% UI_MODEL_VIEWER: interactive viewer for a PCA model.
%
% NOTE: this is not user-level function. You must call either shape_viewer,
% texture_viewer or appearance_viewer to view a shape, texture or
% combined-appearance PCA model.
%
% See: shape_viewer, texture_viewer or appearance_viewer.
%
% A. Suinesiaputra

% create figure
sz = get(0,'ScreenSize');
width = 600;
height = 600;
x0 = 0;
y0 = 0;

fig = figure('Position',[0.5*(sz(3)-width) 0.5*(sz(4)-height) width height],...
    'Name','Model Viewer','NumberTitle','off','DoubleBuffer','on','MenuBar','none',...
    'WindowButtonMotionFcn',{@mouse_move},'WindowButtonUpFcn',{@mouse_released});
h = guidata(fig);
h.fig = fig;

% create axes
h.ax = axes('Position',[0 0 1 1],'Box','on','Color','k',...
    'ButtonDownFcn',{@mouse_pressed});

h.txt1 = uicontrol('Style','text','Units','pixel','Position',[10 10 80 20],...
    'ForegroundColor','g','BackgroundColor','k','String','',...
    'HorizontalAlignment','left');
h.txt2 = uicontrol('Style','text','Units','pixel','Position',[90 10 170 20],...
    'ForegroundColor','g','BackgroundColor','k','String','',...
    'HorizontalAlignment','left');
h.btn_pressed = 0;
h.last_pos = [0 0];
h.pivot = [0 0];
h.init = @init_window;

% create menu
mf = uimenu('Label','File');
uimenu('Parent',mf,'Label','Close','Callback','close(gcf)');
ms = uimenu('Label','Settings');
uimenu('Parent',ms,'Label','Reset','Callback',{@reset_view});
uimenu('Parent',ms,'Label','Model settings','Callback',{@model_settings});

h.cur_texture = [];
h.cur_shape = [];
h.draw_fcn = '';

% some initial states
h.pcx = 1;                       % principal mode in x axes
h.pcy = 2;                       % principal mode in y axes
h.limit = {'-3*sqrt(s)', '3*sqrt(s)'};
h.pclim = zeros(4);
h.lock_plausible = 1;            % show only plausible shape
h.sensitivity = [1.0 1.0];       % units on x and y axis movement
h.limit_reached = [0 0];         % just to tag whether a limit has been reached

% some initial properties
h.shape_style = {'Color','c','LineWidth',1,'LineStyle','-','Marker','none'};

% save figure handle
guidata(h.fig,h);


% -------------------------------------------------------------------------
function init_window(h)
% called by external function to call some initializations

% get guidata
h = guidata(h.fig);

% compute limit
h.pclim = compute_limit(h);

% call draw
h = feval(h.draw_fcn,h,0,0);
set_info(h,[0 0]);

% save guidata
guidata(h.fig,h);


% -------------------------------------------------------------------------
function set_info(h,p)
% set info text

sinfo1 = sprintf('pc %d = %.4f',h.pcx,p(1));
sinfo2 = sprintf('pc %d = %.4f',h.pcy,p(2));
if( p(1) <= h.pclim(1,1) || p(1) >= h.pclim(1,2) ) colx = 'r'; else colx = 'g'; end
if( p(2) <= h.pclim(2,1) || p(2) >= h.pclim(2,2) ) coly = 'r'; else coly = 'g'; end
set(h.txt1,'String',sinfo1,'ForegroundColor',colx);
set(h.txt2,'String',sinfo2,'ForegroundColor',coly);


% -------------------------------------------------------------------------
function mouse_pressed(hObject,eventdata)
% called whenever mouse button is pressed

% get guidata
h = guidata(hObject);

% set pivot, text visible & string = h.last_pos
pos = get(h.ax,'CurrentPoint');
h.pivot = pos(1,1:2) .* h.sensitivity;
set_info(h,h.last_pos);

% set button pressed
h.btn_pressed = 1;
guidata(h.fig,h);


% -------------------------------------------------------------------------
function mouse_move(hObject,eventdata)
% called whenever mouse is moved over the figure

dont_draw = 0;

% get guidata
h = guidata(hObject);
if( isempty(h) ) return; end;

% do action if button is pressed
if( h.btn_pressed )
    % get position
    pos = get(h.ax,'CurrentPoint');
    newpos = h.last_pos + pos(1,1:2) .* h.sensitivity - h.pivot;
    
    if( h.lock_plausible )
        on_edge(1) = newpos(1) <= h.pclim(1,1) || newpos(1) >= h.pclim(1,2);
        on_edge(2) = newpos(2) <= h.pclim(2,1) || newpos(2) >= h.pclim(2,2);
        
        if( ~any(h.limit_reached) || all(~on_edge) )
            h.limit_reached = on_edge;
            if( any(h.limit_reached) ) h.tmp_pos = newpos; end;
        else
            dont_draw = 1;
        end
    end
    
    % draw shape
    if( isa(h.draw_fcn,'function_handle') && ~dont_draw )
        h = feval(h.draw_fcn,h,newpos(1),newpos(2));
        set_info(h,[newpos(1) newpos(2)]);
    end
    
    guidata(h.fig,h);
end


% -------------------------------------------------------------------------
function mouse_released(hObject,eventdata)
% called whenever mouse button is released

% get guidata
h = guidata(hObject);

% set text visibility & button press property
h.btn_pressed = 0;

% save pivot as the last distance
pos = get(h.ax,'CurrentPoint');
pos = pos(1,1:2).* h.sensitivity - h.pivot;

if( h.lock_plausible )
    on_edge(1) = pos(1) <= h.pclim(1,1) || pos(1) >= h.pclim(1,2);
    on_edge(2) = pos(2) <= h.pclim(2,1) || pos(2) >= h.pclim(2,2);
    if( all(~on_edge) ) 
        h.last_pos = h.last_pos + pos; 
    else 
        h.last_pos = h.tmp_pos;
    end
else
    h.last_pos = h.last_pos + pos;
end

guidata(h.fig,h);


% -------------------------------------------------------------------------
function lim = compute_limit(h)
% compute limit values for each principal components

% set minimum
if( ischar(h.limit{1}) )
    fmin = inline(h.limit{1},'s');
    lim(1,1) = feval(fmin,h.M.var(h.pcx));
    lim(2,1) = feval(fmin,h.M.var(h.pcy));
else
    lim(1,1) = h.limit{1};
    lim(2,1) = h.limit{1};
end

% set maximum
if( ischar(h.limit{2}) )
    fmax = inline(h.limit{2},'s');
    lim(1,2) = feval(fmax,h.M.var(h.pcx));
    lim(2,2) = feval(fmax,h.M.var(h.pcy));
else
    lim(1,2) = h.limit{2};
    lim(2,2) = h.limit{2};
end



% -------------------------------------------------------------------------
function reset_view(hObject,eventdata)
% reset view to mean shape

% get guidata
h = guidata(hObject);

% reset
h.pivot = [0 0];
h.last_pos = [0 0];
h.btn_pressed = 0;

% draw
if( isa(h.draw_fcn,'function_handle') )
    h = feval(h.draw_fcn,h,0,0);
    set_info(h,[0 0]);
end

% save guidata
guidata(h.fig,h);



% -------------------------------------------------------------------------
function model_settings(hObject,eventdata)
% called whenever the model settings menu is clicked

% get guidata
h = guidata(hObject);

newset = ui_model_settings(h);
if( ~isempty(newset) )
    % set variables
    h.b(:) = 0;
    h.pcx = newset.pcx;
    h.pcy = newset.pcy;
    h.limit = newset.limit;
    h.pclim = compute_limit(h);
    h.sensitivity = newset.sensitivity;
    h.lock_plausible = newset.lock_plausible;
    
	% save guidata
	guidata(h.fig,h);
	
	% reset view
	reset_view(hObject);
end