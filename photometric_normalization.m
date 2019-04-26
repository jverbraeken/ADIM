function Gn = photometric_normalization(G,varargin)
% PHOTOMETRIC_NORMALIZATION: perform normalization to the intensity/gray-level vectors
% such that they are invariant under global illumination.
%
%   Gn = photometric_normalization(G)
%
% Input: G = the texture vectors
% Output:
%   - Gn = the normalized texture vectors, and
%
% Optional arguments:
% 1. 'init_mean', 0<=integer<=number_of_shapes. Default is 1.
%    How to select the initial estimate of the mean shape. The value must
%    be non-negative integer less than the number of shapes, which
%    indicates a particular shape as the initial mean shape. If this value 
%    is 0, then the shape is selected randomly.
%    Note: the initial mean shape influences the final pose of the aligned
%          shapes.
% 2. 'limit', numeric. Default is 1e-5.
%    Limit value to determine the convergence in the alignment iterations.
%
% A. Suinesiaputra - LKEB 2005

% default values
init_mean = 1;
conv_limit = 1e-5;

% get optional arguments
for i=1:2:length(varargin)
    if( strcmpi(varargin{i},'init_mean') ) init_mean = varargin{i+1};
    elseif( strcmpi(varargin{i},'limit') ) conv_limit = varargin{i+1};
    else error('Unknown option is found.'); end
end

m = size(G,1);

% pick the first estimate, scaled and offset
if( init_mean==0 ) init_mean = floor(1 + (size(G,2)-1)*rand(1));  end % randomly selected
gmean_cur = G(:,init_mean);
gmean_cur = gmean_cur - mean(gmean_cur);
gmean_cur = gmean_cur ./ std(gmean_cur);

gmean_prev = gmean_cur;

% initialization
converge = 0;
iter = 1;
while( ~converge )
    
    % calculate alpha & beta for each G
    alpha = G' * gmean_cur;
    beta = sum(G)/m;
    
    % calculate Gnorm
    Gn = (G - ones(m,1)*beta) ./ (ones(m,1)*alpha');
    
    % estimate the current mean from Gn
    gmean_cur = mean(Gn,2);
    gmean_cur = gmean_cur ./ std(gmean_cur);
    
    % check convergence
    D = norm(gmean_prev-gmean_cur)^2;
    converge = D < conv_limit;
    if( ~converge )
        gmean_prev = gmean_cur;
    end
    
    disp(sprintf('Iteration %d passed.',iter));
    iter = iter+1;
end
