function Pt = thin_plate_spline(xs,xt,Ps)
% THIN_PLATE_SPLINE: it is a warping technique described by Fred L. Bookstein
% in Principal Warps: Thin Plate Splines and the decomposition of deformations, 
% IEEE Trans. on PAMI, vol 11, no 6, june 1999, pp 567-585
%
%   Pt = thin_plate_spline(xs,xt,Ps);
%
% Input:
%   - xs is the source shape vector,
%   - xt is the target shape vector,
%   - Ps is Mx2 matrix of grid points to be warped.
%
% Output:
%   - Pt is Mx2 matrix of the warped grid points.
%
% NOTE:
%  1. xs and xt must folow the 2D planar shape configuration: [x1 y2 .. xN yN]'.
%  2. Ps and Pt consists of cartesian coordinate points for each row.
%
% Author: Edward Valstar
% Modified by: A. Suinesiaputra - LKEB 2005

% check size
if( ~isequal(size(xs),size(xt)) )
    error('Source and target shapes have different size.');
end
if( size(Ps,2)~=2 ) error('Grid points must in 2D space.'); end

% convert xs & xt into 2D matrix
xs = reshape(xs,2,[])';
xt = reshape(xt,2,[])';

% create P
n = size(xs,1);
P = [ones(n,1) xs];

% create K
K = calc_U(P,P);

% create L
L = [K P; P' zeros(3)];

% create V & Y
Y = [xt' zeros(size(xt,2),3)]';

% create W and a1, ax and ay
W = (inv(L) * Y)';

% from the mesh Xin
% create distance of each Ps to the Xin
m = size(Ps,1);
D = calc_U(xs,Ps);

E(1,:) = sum(repmat(W(1,1:n)',1,m) .* D,1);
E(2,:) = sum(repmat(W(2,1:n)',1,m) .* D,1);

A = repmat(W(:,n+1),1,m) + repmat(W(:,n+2),1,m) .* [Ps(:,1) Ps(:,1)]' + ...
    repmat(W(:,n+3),1,m) .* [Ps(:,2) Ps(:,2)]';

Pt = (A + E)';

% Subfunction calc_U
function R = calc_U(X,Y)
% From the Bookstein's paper:
%    U(r) = r^2 * log(r^2)
%    where: r = |X - Y| (distance between two points: x & y)
%
% The input X and Y are coordinate points and
% The output R is NxM of the result U, where N and M are the number of
% points in X and Y resp.

nx = size(X,1);
ny = size(Y,1);

warning off;

Rx = repmat(X,[1,1,ny]);
Ry = permute(repmat(Y,[1,1,nx]),[3 2 1]);

R = squeeze(sqrt(sum((Rx - Ry).^2,2)));
R = R.^2 .* log(R.^2);

idx = isnan(R(:));
R(idx) = 0;

warning on;