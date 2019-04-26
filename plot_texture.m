function h = plot_texture(X,g,varargin)
% PLOT_TEXTURE: plot a patch given points and intensity values for each
% point.
%
%   h = plot_texture(X,g);
%
% Input:
%   - X is Nx2 matrix of points.
%   - g is N length of gray-level/intensity vector for each point.
%
% Output:
%   - h is graphic object handles to the patch.
%
% A. Suinesiaputra - LKEB 2005

% check size of X and g
if( ~isequal(size(X,1),length(g)) ) error('Length of the intensity vector is not equal with the number of points.'); end

% create triangles
tri = delaunay(X(:,1),X(:,2));

% plot surface
h = patch('Faces',tri,'Vertices',X,'FaceVertexCData',g,'FaceColor','interp','EdgeColor','interp');

% set properties
colormap(gray);
set(gcf,'Color','k');
set(gca,'Visible','off');
axis ij;