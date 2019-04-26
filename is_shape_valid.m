function b = is_shape_valid(X)
% IS_SHAPE_VALID: true if X is a valid planar shape configuration.
%
%   b = is_shape_valid(X)
%
% Input:  X should be a matrix
% Output: true or false
%
% A. Suinesiaputra - LKEB 2005

np = size(X,1);
dim = length(size(X));
b = isnumeric(X) && dim==2 && mod(np,2)==0;