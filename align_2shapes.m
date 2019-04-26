function [Sa,Tr] = align_2shapes(x,Sx)
% ALIGN_2SHAPES: align a set of shapes to a shape reference, using approach explained at
%                appendix B [Cootes]
%
%   Sa = align_2shapes(x,Sx);
%   [Sa,Tr] = align_2shapes(x,Sx);
%
% Input: 
%   - x = reference shape vector.
%   - Sx = a set of shapes to be aligned onto x.
%
% Output: 
%   - Sa = the aligned shapes
%   - Tr = a pose parameter matrix that consists of 2 fields:
%        Tr.sc = scaling parameters, and
%        Tr.th = rotation parameters.
%
% NOTES: 
% 1. All shapes (x and Sx) must be a 2D shape configuration where each column is a
%    shape vector and the shape vector has this following configuration:
%    [x1 y1 x2 y2 ... xN yN] where N = number of landmark points
% 2. All shapes must have been translated to the origin.
%
% A. Suinesiaputra - LKEB 2005

% dimension and number of shapes
[d,n_shape] = size(Sx);

% get norm of each shape in Sx
norm2_Sx = [];
for i=1:n_shape
    norm2_Sx = [norm2_Sx; norm(Sx(:,i))^2];
end;

% calculate scalar a & b
as = (Sx' * x) ./ norm2_Sx;
bs = Sx' * (reshape((reshape(x,2,[])' * [0 -1; 1 0])',[],1)) ./ norm2_Sx;

% compute the transformation for each shape
Sa=[];
for i=1:n_shape
    Sa = [Sa reshape([as(i) -bs(i); bs(i) as(i)] * reshape(Sx(:,i),2,[]), [],1)];
end;

Tr.sc = sqrt(as.^2 + bs.^2);
Tr.th = atan(bs ./ as);
