function X = ui_load_var(varargin)
% UI_LOAD_VAR: load variable from base or from file.
%
%   X = ui_load_var(opt1,val1,...);
%
% Optional arguments:
%   - 'filter', 'var_type'.
%     var_type can be string or cell of strings.
%   - 'figure', figure_handle. Default is to create a new figure (modal).
%   - 'position', array. Default is [0 0 1 1].
%     Unit can be normalized or pixels.
%   - 'strict', 0 | 1. Default is 0.
%     If strict is set to 1, then the loaded variable from file must have the same type as
%     one of the filter. Otherwise no checking is performed.
%
% Author: Avan Suinesiaputra - LKEB 2005

% default option
filter = {};
fig = [];
pos = [0 0 1 1];
h.strict = 0;

% get optional arguments
for i=1:2:length(varargin)
    if( strcmpi(varargin{i},'filter') ) filter = varargin{i+1};
    elseif( any(strcmpi(varargin{i},{'fig','figure'})) ) fig = varargin{i+1};
    elseif( any(strcmpi(varargin{i},{'pos','position'})) ) pos = varargin{i+1};
    elseif( strcmpi(varargin{i},'strict') ) h.strict = varargin{i+1};
    else error('Unknown option is found.'); end
end

% check filter
if( ischar(filter) ) filter = {filter};
elseif( ~iscell(filter) ) error('Filter must be a string or cell of string.'); end

h.ismodal = isempty(fig);

if( h.ismodal )

	% create new figure
	sz = get(0,'ScreenSize');
	width = 300;
	height = 70;
    x0 = 0;
    y0 = 0;
	
	fig = figure('Position',[0.5*(sz(3)-width) 0.5*(sz(4)-height) width height],...
        'ResizeFcn',str2func('resize'),'Name','Load a variable','NumberTitle','off',...
        'WindowStyle','modal','Resize','off');
    bgcolor = get(fig,'Color');
    
else
    if( ~ishandle(fig) ) error('Figure is not a handle.'); end
    
    % check position either pixels or normalized
    if( all(pos)<1 ) % normalized
        figpos = get(fig,'Position');
        pos = pos .* [figpos(3) figpos(4) figpos(3) figpos(4)];
    end
    
    x0 = pos(1);
    y0 = pos(2);
    width = pos(3);
    height = pos(4);
    
    h.frame = uicontrol('Style','frame','Unit','pixels','Position',[x0 y0 width height],...
        'Tag','ui_load_var');
    bgcolor = get(h.frame,'BackgroundColor');
end

% set text
txt = 'Select variable: ';
h.txt = uicontrol('Style','text','String',txt,'Units','characters','BackgroundColor',bgcolor,...
    'HorizontalAlignment','left','Position',[0 0 length(txt)+1 1],'Tag','ui_load_var');
set(h.txt,'Units','pixels');
p = get(h.txt,'Position');
set(h.txt,'Position',[x0+10 y0+height-13-p(4) p(3:4)]);
p = get(h.txt,'Position');

% set popupmenu
v = evalin('base','whos');
if( isempty(v) ) 
    v = []; 
    vars = {''}; 
elseif( isempty(filter) )
    vars = {v.name}';
else
    idx = [];
    for i=1:length(filter) 
        idx = [idx find(strcmp({v.class},filter{i}))];
    end
    if( isempty(idx) ) vars = {''}; else vars = {v(idx).name}'; end
end
h.vars = uicontrol('Style','popupmenu','String',vars,'Units','pixels','BackgroundColor','w',...
    'Position',[x0+10+p(3) y0+height-10-p(4) 100 p(4)],'Tag','ui_load_var');
p = get(h.vars,'Position');
h.filter = filter;

% set from file button
h.bfromfile = uicontrol('Style','pushbutton','String','from file...','Units','pixels',...
    'Position',[x0+10+p(1)+p(3) y0+height-30 80 20],'Tag','ui_load_var');

% set OK / Cancel button
h.bok = uicontrol('Style','pushbutton','String','OK','Units','pixels',...
    'Position',[x0+width-120 y0+height-60 50 20],'Tag','ui_load_var');
h.bcancel = uicontrol('Style','pushbutton','String','Cancel','Units','pixels',...
    'Position',[x0+width-60 y0+height-60 50 20],'Tag','ui_load_var');

% bok is disable if list of variables are empty
if( length(vars)==1 && isempty(vars{1}) ) set(h.bok,'Enable','off'); end

% add handles to guidata
h.fig = fig;
h.X = [];
hfig = guidata(fig);
hfig.ui_load_var = h;
guidata(fig,hfig);

% set callbacks
set([h.bok h.bcancel],'Callback',{@okcancel_callback});
set(h.bfromfile,'Callback',{@select_file_callback});

if( h.ismodal ) % wait for ok/cancel
	% wait for ok/cancel
	uiwait(fig);
	if( ishandle(fig) ) 
        h = guidata(fig);
        X = h.ui_load_var.X;
        close(fig);
	else X = []; end
else
    X = [h.frame h.txt h.vars h.bfromfile h.bok h.bcancel];
end


function okcancel_callback(hObject,eventdata)
% ---------------------------------------------------
% callback function for OK/CANCEL button

% get handles
h = guidata(hObject);

if( strcmpi(get(hObject,'String'),'OK') )  % get variable pointed
    v = get(h.ui_load_var.vars,'String');
    v = v{get(h.ui_load_var.vars,'Value')};
    if( ~isempty(v) )
        h.ui_load_var.X = evalin('base',v);
        guidata(h.ui_load_var.fig,h);
    end
end

if( h.ui_load_var.ismodal )
    uiresume(h.ui_load_var.fig); 
end


function select_file_callback(hObject,eventdata)
% ---------------------------------------------------
% select file function for OK/CANCEL button

[fname,path] = uigetfile({'*.mat','MAT-files (*.mat)'; '*.*','All files (*.*)'});

% get handles
h = guidata(hObject);

if( fname )
    X = importdata(strcat(path,fname));

    if( h.ui_load_var.strict )
        % perform checking
        if( iscellstr(h.ui_load_var.filter) )
            for i=1:length(h.ui_load_var.filter) oktype(i) = isa(X,h.ui_load_var.filter{i}); end
        else
            oktype = isa(X,h.ui_load_var.filter);
        end
        
        if( all(~oktype) )
            errordlg('Variable type is invalid.','Invalid type');
            return;
        end
    end
    
    h.ui_load_var.X = X;
    guidata(h.ui_load_var.fig,h);
    if( h.ui_load_var.ismodal ) uiresume(h.ui_load_var.fig); end
end