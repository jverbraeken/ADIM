function Y = transform_shapes(X,T,varargin)
% TRANSFORM_SHAPES: transform a shape X with a transformation matrix T
%
%   Y = transform_shapes(X,T);
%
% Input:
%   - X is a shape vector/matrix. It must follow the 2D planar shape
%     configuration, i.e. [x1 y1 x2 y2 ... xN yN]' for each column.
%   - T is a 3x3 transformation matrix or 1x4 vector
%     If T is 3x3 matrix, then T is defined as
%                  [ 1+sx  -sy tx ]
%              T = [  sy  1+sx ty ]
%                  [   0    0   1 ],
%     where:
%        sx = s*cos(theta) - 1,
%        sy = s*sin(theta),
%     then X is transformed by translation of [tx ty]' and rotated by angle
%     theta and scaled by factor s.
%     If T is 1x4 vector, then T = [sx sy tx ty] or T = [tx ty scale angle], depends on
%     the format, option. See the format option below.
%
% Output:
%   - Y is the transformed shape vector/matrix and it follows the 2D planar
%     shape configuration form.
%
% Optional arguments:
%   - 'invert', 0 | 1. Default 0.
%     If invert is 1, then the matrix T is inverted to perform the inverse transformation
%     of T on X. Thus Y = inv(T) * X;
%   - 'format', 'linear' | 'non-linear'. Default is 'linear'.
%     This option only applies if T is a vector.
%     This option defines what are the element of the vector T.
%     If format = linear, then T = [sx sy tx ty].
%     If format = non-linear, then T = [tx ty scale angle].
%
% A. Suinesiaputra - LKEB 2005

% default
invert = 0;
vformat = 'linear';

% get optional arguments
for i=1:2:length(varargin)
    if( strcmpi(varargin{i},'invert') ) invert = varargin{i+1};
    elseif( strcmpi(varargin{i},'format') ) vformat = varargin{i+1};
    else error('Unknown option.'); end
end

% change T if it is 1x4 vector
if( rank(T)==1 )
    if( strcmpi(vformat,'linear') )
        T = [1+T(1) -T(2) T(3); T(2) 1+T(1) T(4); 0 0 1];
    elseif( strcmpi(vformat,'non-linear') )
        sx = T(3)*cos(T(4)) - 1;
        sy = T(3)*sin(T(4));
        T = [1+sx -sy T(1); sy 1+sx T(2); 0 0 1];
    else error('Unknown vector format of T.'); end
end

if( invert ) T = inv(T); end

% get number of points and number of shapes
npts = size(X,1)/2;
nshapes = size(X,2);

% transform matrix X into 2D cartesian coordinate
X = reshape(X,2,npts,[]);

% transform each shape of X
Z = ones(1,npts);
for i=1:nshapes
    v = T * [X(:,:,i); Z];
    Y(:,i) = reshape(v(1:2,:),[],1);
end