function S = gen_rectangles(N)
% GEN_RECTANGLES: create a set of rectangle shapes with varying aspect ratio.
%
%   S = gen_rectangles(N)
%
% Input:
%   - N is the number of rectangles to be generated.
% 
% Output:
%   - S is the shape matrix of rectangles.
%
% NOTE:
%   1. aspect ratio varies between 0.1 s.d. 2 in N steps.
%   2. orientation is randomly assigned.
%   3. position is randomly assigned.
%
% A. Suinesiaputra - LKEB 2005

ar = linspace(1,5,N);
nshapes = length(ar)-1;
thetas = -pi + 2*pi*rand(1,nshapes);
dx = -5 + 10*rand(1,nshapes);
dy = -5 + 10*rand(1,nshapes);

for i=1:nshapes
    S(:,i) = reshape(([cos(thetas(i)) sin(thetas(i)); -sin(thetas(i)) cos(thetas(i))] * ...
        [0 1 1 0; 0 0 ar(i) ar(i)] + [dx(i); dy(i)] * ones(1,4)),[],1);
end