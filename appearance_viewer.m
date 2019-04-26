function appearance_viewer(shape_m,texture_m,app_m,mask,Ws,varargin)
% APPEARANCE_VIEWER: a GUI to view PCA model capabilities to generate a shape
% and texture simultaneously using the appearance model.
%
%   appearance_viewer(shape_m,texture_m,app_m,mask,Ws);
%
% Input: 
%   - shape_m is a shape PCA model,
%   - texture_m is a texture PCA model, 
%   - app_m is an appearance PCA model, 
%   - mask is grid points used to make the intensity sampling, and
%   - Ws is a weighting matrix to scale the shape for modeling the appearance.
%
% A. Suinesiaputra - LKEB 2005

% call ui_model_viewer and set draw_appearance
hfig = ui_model_viewer;
h = guidata(hfig);
h.M = app_m;
h.mask = mask;
h.Qg = texture_m.phi * app_m.phi((size(shape_m.phi,2)+1):end,:);
h.Qs = shape_m.phi * inv(Ws) * app_m.phi(1:size(shape_m.phi,2),:);
h.draw_fcn = @draw_appearance;
h.gmean = texture_m.mean;
h.smean = shape_m.mean;
h.b = zeros(size(app_m.b,1),1);
h.cur_texture = [];
h.cur_shape = [];
h.sensitivity = [0.1 0.1];
guidata(h.fig,h);
feval(h.init,h);

% -------------------------------------------------------------------------
function hout = draw_appearance(h,x,y)
% draw appearance in the axes

% set current axes and reset
axes(h.ax);

% reconstruct a texture based on the current b vector and draw it in the axes
h.b(h.pcx) = x;
h.b(h.pcy) = y;
Xr = h.smean + h.Qs * h.b;
Gr = h.gmean + h.Qg * h.b;

% warping
Pt = thin_plate_spline(h.smean,Xr,h.mask);

% only create patch if the cur_texture handle is empty
if( isempty(h.cur_texture) )
    fpres = get(h.ax,'ButtonDownFcn');
    cla reset;
	h.cur_texture = plot_texture(Pt,Gr);
    axis equal;
    xlim(xlim+[-0.05 0.05]);
	set(h.cur_texture,'ButtonDownFcn',fpres);
else
    tri = delaunay(Pt(:,1),Pt(:,2));
    set(h.cur_texture,'FaceVertexCData',Gr,'Faces',tri,'Vertices',Pt);
end

hold on;

% set color to red if shape is not plausible
plausible = x>h.pclim(1,1) && x<h.pclim(1,2) && y>h.pclim(2,1) && y<h.pclim(2,2);
if( plausible ) lcolor = 'c'; else lcolor = 'r'; end

% draw shape
delete(h.cur_shape);
h.cur_shape = plot_shapes(Xr,h.shape_style{:},'Color',lcolor);

hout = h;