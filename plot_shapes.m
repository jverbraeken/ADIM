function h = plot_shapes(S,varargin)
% PLOT_SHAPES: plot 2D shape matrix.
%
%   h = plot_shapes(S);
%   h = plot_shapes(S,LineSpec,'arg1','val1',...);
%   h = plot_shapes(S,'arg1','val1','arg2','val2',...);
%
% Input:  S = shape matrix to plot.
% Output: h = array of handles, each points to each shape plot in the
%             figure.
% Optional arguments are similar with MATLAB's plot command, but with these
% additional arguments:
% 1. 'img_format', 0 | 1. Default = 1.
%    Change axes coordinate into image format. If img_format = 1, then
%    coordinate uses image coordinate system, i.e. origin is at top-left
%    corner. Otherwise uses default coordinate system.
% 2. 'close', 0 | 1. Default = 1.
%    If close = 1, then the shape is drawn as a closed curve. Otherwise it
%    is open.
% 3. 'unique_color', 0 | 1. Default = 0.
%    If unique_color = 1, then all shapes are randomly assigned different
%    color to show unique color for each shape.
%
% Any other valid MATLAB's plot options can be used.
% The default style is: linespec='-b.'
%
% NOTE: the input S must be a 2D shape configuration where each row is a
% shape vector and the shape vector has this following configuration:
%   [x1 y1 x2 y2 ... xN yN] where N = number of landmark points
%
% A. Suinesiaputra - LKEB 2005

% default values
img = 1;          % coordinate as in image (origin at top-left)
close = 1;        % close/open curve
linespec = '-b.'; % default
lwidth = 1;       % default line width
ucolor = 0;       % unique color for each shape

% get optional argument(s)
plot_opts = {};
i=1;
while( i<=length(varargin) )
    if( strcmpi(varargin{i},'img_format') ) img = varargin{i+1};
    elseif( strcmpi(varargin{i},'close') ) close = varargin{i+1};
    elseif( strcmpi(varargin{i},'LineWidth') ) lwidth = varargin{i+1};
    elseif( strcmpi(varargin{i},'unique_color') ) ucolor = varargin{i+1};
    else
        if( i==1 && mod(length(varargin),2)>0 )
            linespec=varargin{i}; i=i+1;
            continue;
        else
            plot_opts = [plot_opts {varargin{i:i+1}}];
        end
    end
    i=i+2;
end
plot_opts = [plot_opts {'LineWidth' lwidth}];

% convert S into 3 dimensional matrix: [shapes points cartesian_coordinate]
[npts, nshapes] = size(S);
S = reshape(S,2,[],nshapes);

% set initial output & axes properties
h = [];
hold on;

% call plot for each shape
for i=1:nshapes
    x = S(:,:,i)';                            % get the shape
    if( close ) x = [x; x(1,:)]; end          % add the first point to the last for close curve
    if( ucolor ) plot_opts = [plot_opts {'Color' rand(1,3)}]; end   % assign unique color
    h = [h plot(x(:,1),x(:,2),linespec,plot_opts{:})]; % plot
end

% set axes if necessary
if( img ) axis ij; end;