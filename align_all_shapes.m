function Sa = align_all_shapes(S,varargin)
% ALIGN_ALL_SHAPES: shape alignment
%
%   Sa = align_all_shapes(S,varargin);
%
% Input:  S = unaligned shapes
% Output: 
%   - Sa = aligned shapes
%
% Optional arguments:
% 1. 'init_mean', 0<=integer<=number_of_shapes. Default is 1.
%    How to select the initial estimate of the mean shape. The value must
%    be non-negative integer less than the number of shapes, which
%    indicates a particular shape as the initial mean shape. If this value 
%    is 0, then the shape is selected randomly.
%    Note: the initial mean shape influences the final pose of the aligned
%          shapes.
% 2. 'tangent_projection', 0 | 1. Default is 1.
%    Perform tangent projection after shape alignment. Projection to tangent space is used
%    in modeling to eliminate non-linear variations.
% 3. 'limit', numeric. Default is 1e-5.
%    Limit value to determine the convergence in the alignment iterations.
%
% NOTE: the input S must be a 2D shape configuration where each column is a
% shape vector and the shape vector has this following configuration:
%   [x1 y1 x2 y2 ... xN yN] where N = number of landmark points
%
% Ref.: T.F. Cootes and C.J. Taylor, "Statistical Models of Appearance for
% Computer Vision", Ch. 4.2 Aligning The Training Set, http://www.isbe.man.ac.uk, 
% Oct. 2001.
%
% A. Suinesiaputra - LKEB 2005

% check S first
if( ~is_shape_valid(S) ) error('Input is not a valid 2D shape matrix.'); end

% default values
init_mean = 1;
proj_tangent = 1;
conv_limit = 1e-5;

% get optional arguments
for i=1:2:length(varargin)
    if( strcmpi(varargin{i},'init_mean') ) init_mean = varargin{i+1};
    elseif( strcmpi(varargin{i},'tangent_projection') ) proj_tangent = varargin{i+1};
    elseif( strcmpi(varargin{i},'limit') ) conv_limit = varargin{i+1};
    else error('Unknown option is found.'); end
end

% get some properties
[npts, nshapes] = size(S);

% check optional arguments for error
if( ~isnumeric(init_mean) && init_mean<0 && init_mean>nshapes )
    error('Invalid ''init_mean'' option value');
end

% translate each example so that its centre of gravity is its origin.
S3 = reshape(S,2,[],nshapes);
Sc = squeeze(mean(S3,2));
T = repmat(Sc,npts/2,1);
S0 = S-T;

% choose one example as an inital estimate of the mean shape and scale
% so that norm of it is 1.
if( init_mean==0 ) init_mean = floor(1 + (nshapes-1)*rand(1));  end % randomly selected
x0 = S0(:,init_mean);
x0 = x0 ./ norm(x0);

% initial iteration values
converge = 0;
x_prev_est = x0;
x_curr_est = x0;

while( ~converge )
    
    % align S0 into the current estimate of shape (x_curr_est)
    Sa = align_2shapes(x_curr_est,S0);
    
    % projection to the tangent space
    if( proj_tangent )
        dot_v = (Sa' * x_curr_est)';
        Sa = Sa ./ repmat(dot_v,npts,1);
    end
    
    % estimate the current mean shape from the aligned shape Sa
    x_curr_est = mean(Sa,2);

    % apply constraint, align the current mean shape to x0, and normalized x1, s.t. |x1|=1
    x_curr_est = align_2shapes(x0,x_curr_est);
    x_curr_est = x_curr_est ./norm(x_curr_est);
    
    % check convergence, i.e. the distance D < 1e-5
    D = norm(x_prev_est-x_curr_est)^2;
    if (D < conv_limit)
        converge = 1;
    else
        % repeat the iteration by assigning Sa into S0
        S0=Sa;
        x_prev_est = x_curr_est;
    end;
    
end;
