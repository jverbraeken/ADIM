function h = plot_appearance(S,G,Xmask,mask,varargin)
% PLOT_APPEARANCE: plot an appearance, given a shape and texture information.
% This function is just basically a combination of calling plot_shapes and plot_texture
% functions.
%
%   h = plot_appearance(S,G,Xmask,mask)
%   h = plot_appearance(S,G,Xmask,mask,'opt1',val1,...)
%
% Input:
%   - S is N length of a shape vector.
%   - G is M length of a texture vector,
%   - mask is a Mx2 matrix of coordinate points that defines the grid points (mask),
%   - Xmask is N length of a shape vector used to create the mask.
%
% Output:
%   - h(1) = handle to the texture patch object, and
%     h(2) = handle to the shape object.
%
% Optional arguments:
%   - All optional arguments of plot_shapes and/or plot_texture are valid.
%
% NOTE: this function only capable to plot a single shape with a single texture vector.
%
% A. Suinesiaputra - LKEB 2005

% warp the mask from Xmask to S
Pt = thin_plate_spline(Xmask,S(:,1),mask);

% create new figure
hf = figure('DoubleBuffer','on');

% plot texture
h(1) = plot_texture(Pt,G,varargin{:});

hold on;

% plot shape
h(2) = plot_shapes(S(:,1),varargin{:});

% set axes
set(gca,'Visible','off');
axis image;