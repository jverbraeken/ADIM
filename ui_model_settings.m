function s = ui_model_settings(h)
% called whenever the model settings menu is clicked
% this is an internal function
%
% A. Suinesiaputra - LKEB 2005

% create another figure (modal)
sz = get(0,'ScreenSize');
width = 300;
height = 400;

title = 'Model Settings';
fig = figure('Position',[0.5*(sz(3)-width) 0.5*(sz(4)-height) width height],...
    'Name',title,'NumberTitle','off','DoubleBuffer','on','MenuBar','none',...
    'WindowStyle','modal','Resize','off');
fcol = get(fig,'Color');

uiwd = 20;
txtwd = 18;
uipad = 10;

% principal components
str = 'Principal components: x = ';
strwd = length(str)*5;
uicontrol('Parent',fig,'Style','text','String',str,'HorizontalAlignment','left',...
    'Position',[uipad height-uipad-uiwd strwd txtwd],'BackgroundColor',fcol);
hd.pcx = uicontrol('Parent',fig,'Style','edit','String',num2str(h.pcx),'Tag','pcx',...
    'HorizontalAlignment','right','Position',[uipad+strwd height-uipad-uiwd 30 uiwd],...
    'BackgroundColor','w');
x = uipad+strwd+30+uipad;
str = ' y = ';
strwd = length(str)*5;
uicontrol('Parent',fig,'Style','text','String',str,'HorizontalAlignment','left',...
    'Position',[x height-uipad-uiwd strwd txtwd],'BackgroundColor',fcol);
hd.pcy = uicontrol('Parent',fig,'Style','edit','String',num2str(h.pcy),'Tag','pcy',...
    'HorizontalAlignment','right','Position',[x+strwd height-uipad-uiwd 30 uiwd],...
    'BackgroundColor','w');

% min & max
str = strcat('Set minimun and maximum variance. It can be a constant value or a function',...
    '. For a function, create a univariate function with variable ''s''.');
strht = 50;
y = height-2*uipad-uiwd-strht;
uicontrol('Parent',fig,'Style','text','String',str,'Max',2,'Min',0,...
    'Position',[uipad y width-2*uipad strht],...
    'HorizontalAlignment','left','BackgroundColor',fcol);

str = 'Min. = '; strwd = length(str)*5;
uicontrol('Parent',fig,'Style','text','String',str,'HorizontalAlignment','left',...
    'Position',[uipad y-uipad-txtwd strwd txtwd],'BackgroundColor',fcol);
if( ischar(h.limit{1}) ) str = h.limit{1}; else str = num2str(h.limit{1}); end
hd.min = uicontrol('Parent',fig,'Style','edit','String',str,'HorizontalAlignment','left',...
    'Position',[2*uipad+strwd y-uipad-txtwd width-3*uipad-strwd uiwd],...
    'BackgroundColor','w');

str = 'Max. = '; strwd = length(str)*5;
uicontrol('Parent',fig,'Style','text','String',str,'HorizontalAlignment','left',...
    'Position',[uipad y-2*uipad-2*txtwd strwd txtwd],'BackgroundColor',fcol);
if( ischar(h.limit{2}) ) str = h.limit{2}; else str = num2str(h.limit{2}); end
hd.max = uicontrol('Parent',fig,'Style','edit','String',str,'HorizontalAlignment','left',...
    'Position',[2*uipad+strwd y-2*uipad-2*txtwd width-3*uipad-strwd uiwd],...
    'BackgroundColor','w');

% lock max/min
hd.lock = uicontrol('Parent',fig,'Style','checkbox','String','show only plausible shape',...
    'Value',h.lock_plausible,'Position',[uipad y-3*uipad-2*txtwd-uiwd width-2*uipad uiwd],...
    'BackgroundColor',fcol,'HorizontalAlignment','left');

% sensitivity
y = y - 4*uipad-2*txtwd-uiwd;
uicontrol('Parent',fig,'Style','text','String','Sensitivity: x =','HorizontalAlignment','left',...
    'Position',[uipad y-uiwd 70 txtwd],'BackgroundColor',fcol);
hd.sen_x = uicontrol('Parent',fig,'Style','edit','String',num2str(h.sensitivity(1)),'Tag','sen_x',...
    'HorizontalAlignment','right','Position',[2*uipad+70 y-uiwd 30 uiwd],...
    'BackgroundColor','w');
uicontrol('Parent',fig,'Style','text','String','y =','HorizontalAlignment','left',...
    'Position',[3*uipad+110 y-uiwd 20 txtwd],'BackgroundColor',fcol);
hd.sen_y = uicontrol('Parent',fig,'Style','edit','String',num2str(h.sensitivity(2)),'Tag','sen_x',...
    'HorizontalAlignment','right','Position',[4*uipad+130 y-uiwd 30 uiwd],...
    'BackgroundColor','w');

% ok & button cancel
uicontrol('Parent',fig,'Style','pushbutton','String','Cancel',...
    'Position',[width-uipad-80 uipad 80 uiwd],'Callback',{@ui_model_settings_okcancel});
uicontrol('Parent',fig,'Style','pushbutton','String','OK',...
    'Position',[width-2*uipad-160 uipad 80 uiwd],'Callback',{@ui_model_settings_okcancel});

% set dialog data
hd.ok = 0;
guidata(fig,hd);

s = [];

% modal
uiwait(fig);

% get settings
if( ~ishandle(fig) ) return; end
hd = guidata(fig);
if( hd.ok )
    
    % get principal components
    pcx = str2num(get(hd.pcx,'String'));
    pcy = str2num(get(hd.pcy,'String'));
    
    if( isempty(pcx) || isempty(pcy) )
        errordlg('Invalid value for the principal component axis.');
        s = [];
        close(fig);
        return;
    end
    
    if( pcx < 1 || pcx > size(h.M.phi,2) )
        errordlg('Principal component of axes x is out of range.');
        s = [];
        close(fig);
        return;
    end
    if( pcy < 1 || pcy > size(h.M.phi,2) )
        errordlg('Principal component of axes y is out of range.');
        s = [];
        close(fig);
        return;
    end
    if( pcx == pcy )
        errordlg('You cannot have the same principal modes for both axis.');
        s = [];
        close(fig);
        return;
    end
    
    
    s.pcx = pcx;
    s.pcy = pcy;
    
    % get limit
    mins = get(hd.min,'String');
    maxs = get(hd.max,'String');
    if( isempty(str2num(mins)) ) s.limit{1} = mins; else s.limit{1} = str2num(mins); end
    if( isempty(str2num(maxs)) ) s.limit{2} = maxs; else s.limit{2} = str2num(maxs); end
    
    % get sensitivity
    s.sensitivity(1) = str2num(get(hd.sen_x,'String'));
    s.sensitivity(2) = str2num(get(hd.sen_y,'String'));
    
    % get lock
    s.lock_plausible = get(hd.lock,'Value');
    
end
close(fig);


function ui_model_settings_okcancel(hObject,eventdata)
% called when ok / cancel button is pressed

if( strcmpi(get(hObject,'String'),'ok') )
    h = guidata(hObject);
    h.ok = 1;
    guidata(hObject,h);
end
uiresume(get(hObject,'Parent'));
