function texture_viewer(texture_model,mask,varargin)
% TEXTURE_VIEWER: a GUI to view PCA model capabilities to generate a texture.
%
%   texture_viewer(texture_model,mask);
%
% Input: - texture_model is a texture PCA model, 
%        - mask is grid points used to make the intensity sampling
%
% A. Suinesiaputra - LKEB 2005

% default values

% get optional arguments

% check model
if( ~isfield(texture_model,'phi') || ~isfield(texture_model,'b') || ...
        ~isfield(texture_model,'var') || ~isfield(texture_model,'mean') )
    error('Model is not valid. See help compute_pca for further information to create a model.');
end

% call ui_model_viewer and set draw_shape
hfig = ui_model_viewer;
h = guidata(hfig);
h.M = texture_model;
h.mask = mask;
h.draw_fcn = @draw_texture;
h.b = zeros(size(texture_model.b,1),1);
h.sensitivity = [0.4 0.4];
guidata(h.fig,h);
feval(h.init,h);


% -------------------------------------------------------------------------
function Xr = reconstruct(Xm,Phi,b)
% reconstruct a shape from given mean shape, principal components and b
% vector

Xr = Xm*ones(1,size(b,2)) + Phi * b;



% -------------------------------------------------------------------------
function hout =  draw_texture(h,x,y)
% draw texture in the axes

% set current axes and reset
axes(h.ax);

% reconstruct a texture based on the current b vector and draw it in the axes
h.b(h.pcx) = x;
h.b(h.pcy) = y;
Gr = reconstruct(h.M.mean,h.M.phi,h.b);

% only create patch if the cur_texture handle is empty
if( isempty(h.cur_texture) )
    fpres = get(h.ax,'ButtonDownFcn');
    cla reset;
	h.cur_texture = plot_texture(h.mask,Gr);
    axis equal;
    xlim(xlim+[-0.05 0.05]);
	set(h.cur_texture,'ButtonDownFcn',fpres);
else
    set(h.cur_texture,'FaceVertexCData',Gr);
end

hout = h;
