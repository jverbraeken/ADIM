function pts = create_mask(x,varargin)
% CREATE_MASK: create a mask of a shape data.
%
%   pts = create_mask(x)
%   pts = create_mask(x,'opt1','val1',...)
%
% where: 
%   - x is a shape vector.
%   - pts is Nx2 coordinates of the mask
%
% Available options:
%   - 'extent'
%     To set how much extent of the mask from the outermost contour.
%     Default is by scaling to 1.1
%   - 'density'
%     To set how many sampling points per dimension.
%     Default is [50 50], i.e. 50 points for x and y dimension.
%
% IMPORTANT:
%     To get a correct mask, use only the outermost contour of a shape.
%
% A. Suinesiaputra - LKEB 2004

% check shape
if( size(x,2) > 1 ) error('x must be a vector.'); end

% default values
extval = 1.1;
density = [50 50];

% get options
for i=1:2:length(varargin)
    if( strcmp(varargin{i},'extent') ) extval = varargin{i+1};
    elseif( strcmp(varargin{i},'density') ) density = varargin{i+1};
    else error(sprintf('Unknown options %s',varargin{i})); end
end

% find the convex hull configuration
xmean = mean(reshape(x,2,[]),2);
x0 = reshape(x-repmat(xmean,size(x,1)/2,1),2,[]);
k = convhull(x0(1,:),x0(2,:));

% scale X to the extent value
xt = extval * x0(:,k) + xmean*ones(1,length(k));

% create grid data
xgrid = linspace(min(xt(1,:)),max(xt(1,:)),density(1));
ygrid = linspace(min(xt(2,:)),max(xt(2,:)),density(2));
[Gx,Gy] = meshgrid(xgrid,ygrid);

% select grid points that are inside the poligon xt
ip = inpolygon(Gx,Gy,[xt(1,:) xt(1,1)],[xt(2,:) xt(2,1)]);
in = find(ip>0);

pts = [Gx(in) Gy(in)];