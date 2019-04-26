function shape_viewer(shape_model)
% SHAPE_VIEWER: a GUI to view PCA model capabilities to generate a shape.
%
%   shape_viewer(shape_model);
%
% Input: shape_model is a PCA structure.
%
% A. Suinesiaputra - LKEB 2005

% default values

% get optional arguments

% check model
if( ~isfield(shape_model,'phi') || ~isfield(shape_model,'b') || ...
        ~isfield(shape_model,'var') || ~isfield(shape_model,'mean') )
    error('Model is not valid. See help compute_pca for further information to create a model.');
end

% call ui_model_viewer and set draw_shape
hfig = ui_model_viewer;
h = guidata(hfig);
h.M = shape_model;
h.draw_fcn = @draw_shape;
h.b = zeros(size(shape_model.b,1),1);
guidata(h.fig,h);
feval(h.init,h);


% -------------------------------------------------------------------------
function Xr = reconstruct(Xm,Phi,b)
% reconstruct a shape from given mean shape, principal components and b
% vector

Xr = Xm*ones(1,size(b,2)) + Phi * b;



% -------------------------------------------------------------------------
function hout =  draw_shape(h,x,y)
% draw shape in the axes

% set current axes and reset
axes(h.ax);

% delete current shape if any
delete(h.cur_shape);

% reconstruct a shape based on the current b vector and draw it in the axes
h.b(h.pcx) = x;
h.b(h.pcy) = y;
Xr = reconstruct(h.M.mean,h.M.phi,h.b);

% set color to red if shape is not plausible
plausible = x>h.pclim(1,1) && x<h.pclim(1,2) && y>h.pclim(2,1) && y<h.pclim(2,2);
if( plausible ) lcolor = 'c'; else lcolor = 'r'; end

h.cur_shape = plot_shapes(Xr,h.shape_style{:},'Color',lcolor);
set_axes_limit(h);

hout = h;


% -------------------------------------------------------------------------
function set_axes_limit(h)
% set axes limit based on the current principal components

axes(h.ax);

b = zeros(length(h.b),4);
b(h.pcx,1:2) = h.pclim(1,:);
b(h.pcy,3:4) = h.pclim(2,:);

% get min & max coordinate value
Sr = reconstruct(h.M.mean,h.M.phi,b);
minval = min(Sr(:))-0.05;
maxval = max(Sr(:))+0.05;

% set axes properties
set(h.ax,'XLim',[minval maxval],'YLim',[minval maxval]);

