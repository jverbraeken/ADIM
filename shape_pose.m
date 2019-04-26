function T  = shape_pose(xsource,xtarget,varargin)
% SHAPE_POSE: Find a matrix that represents the best pose transformation from a
%             shape into another.
%
%   T = shape_pose(xsource,xtarget)
% 
% Input: 
%   - xsource is a shape vector that is going to be transformed into xtarget,
%     the source shape vector.
%   - xtarget is a reference shape vector, the target shape vector.
%
% Output: 
%   - T is the transformation matrix which best maps xsource to xtarget.
%     The form of T depends on the 'output' option. See the 'output' optional
%     argument.
%
% Optional arguments:
%   - 'output', '3x3' | 'struct'. Defined the form of T. Default is '3x3'.
%     If 'output' = '3x3', then T is 3x3 matrix, defined as
%        [ 1+sx  -sy    tx; 
%           sy   1+sx   ty; 
%            0     0    1   ] 
%     where:
%        sx = s*cos(theta) - 1,
%        sy = s*sin(theta),
%        (tx,ty) = translation.
%        theta = rotation angle, and
%        s = scaling factor.
%
%     If 'output' = 'struct', then T is a structure with fields: 
%     T.tx, T.ty, T.scale, T.theta, T.sx and T.sy.
%
% NOTE: both xtarget and xsource must contain only 1 shape vector.
%
% A. Suinesiaputra - LKEB 2005

% check shape
if( size(xtarget,2)>1 ) error('xtarget must be a single shape vector.'); end
if( size(xsource,2)>1 ) error('xsource must be a single shape vector.'); end
if( length(xtarget)~=length(xsource) ) error('xtarget & xsource have different dimension.'); end

% default values
output = '3x3';

% get optional arguments
for i=1:2:length(varargin)
    if( strcmpi(varargin{i},'output') ) 
        output = varargin{i+1};
        if( isempty(find(strcmpi({'3x3','struct'},output))) )
            error('Invalid ''output'' option value.');
        end
    else error('Unknown option.'); end
end

% get the number of points
npts = length(xtarget)/2;

% translation to the origin, source = Tr(:,1) & target = Tr(:,2)
Tr = squeeze(mean(reshape([xsource xtarget],2,npts,[]),2)); 

% translate 2 shapes to the origin
xsource0 = xsource - repmat(Tr(:,1),npts,1);
xtarget0 = xtarget - repmat(Tr(:,2),npts,1);

% call align_2shapes to get scaling and rotation transformation
[Xa,M] = align_2shapes(xtarget0,xsource0);

% construct the transformation matrix
Sx = M.sc * cos(M.th) - 1;
Sy = M.sc * sin(M.th);

if( strcmpi(output,'3x3') )
	T = [1 0 Tr(1,2); 0 1 Tr(2,2); 0 0 1] * ...
        [1+Sx -Sy 0; Sy 1+Sx 0; 0 0 1] * ...
        [1 0 -Tr(1,1); 0 1 -Tr(2,1); 0 0 1];
else
    T.tx = Tr(1,2);
    T.ty = Tr(2,2);
    T.scale = M.sc;
    T.theta = M.th;
    T.sx = Sx;
    T.sy = Sy;
end