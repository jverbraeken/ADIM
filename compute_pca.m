function pcs = compute_pca(X,varargin)
% COMPUTE_PCA: calculate the principal component analysis.
%
%   pcs = compute_pca(X);
%   pcs = compute_pca(X,'arg1',val1,...);
%
% Input: X = raw data in column vectors, i.e.: columns are observations and rows are
%            dimension.
% Output: 
%   pcs = a structure that contains:
%     pcs.phi  = the principal component matrix,
%     pcs.b    = the b vector,
%     pcs.var  = variances, and
%     pcs.mean = the mean vector.
%
% The linear model is described as: X = Xm + pcs.phi * pcs.b;
%
% Optional arguments:
%   - 'remove_mean', 0 | 1. Default is 1.
%     If remove_mean = 1, then the data will be extracted its mean first before
%     calculating PCA. Otherwise PCA is calculated directly from X.
%     If this option is set to 0, then the pcs.mean will be a zero vector.
%   - 'reduce', 0<numeric<=1. Default is 1.
%     Reduce dimension such that the total variance that is explained by
%     the model is the value * 100%. E.g. if the value = 0.8, then the
%     PCA model captures 80% variance of the data.
%
% A. Suinesiaputra - LKEB 2005

% default values
remove_mean = 1;
reduce_by = 1;

% optional arguments
for i=1:2:length(varargin)
    if( strcmpi(varargin{i},'remove_mean') ) remove_mean = varargin{i+1};
    elseif( strcmpi(varargin{i},'reduce') ) reduce_by = varargin{i+1};
    else error('Unknown option is found.'); end
end

% check reduce value
if( reduce_by <= 0 || reduce_by > 1 ) error('Invalid value for the ''reduce'' option.'); end

[ndim,ndata] = size(X);

% check removing mean
if( remove_mean )
    pcs.mean = mean(X,2);
    X = X - pcs.mean*ones(1,ndata);
else
    pcs.mean = zeros(size(X,1),1);
end

% rank of x
rank = min(ndim,ndata-1);

% SVD
[U,latent,pcs.phi] = svd(X'./sqrt(ndata-1),0);

% projection
pcs.b = pcs.phi' * X;

% give latent only its diagonal
pcs.var = diag(latent).^2;

% calculate the remaining of eigenvalues if rank < ndim
if( rank < ndim )
   pcs.var = [pcs.var(1:rank); zeros(ndim-rank,1)];
   pcs.b(rank+1:end,:) = 0;
end

% reduce dimension
if( reduce_by < 1 )
    
    % calculate the explained variance
    pct_expl = cumsum(pcs.var / sum(pcs.var));
    idx = find(pct_expl <= reduce_by);
    
    % indexing
    pcs.phi = pcs.phi(:,idx);
    pcs.b = pcs.b(idx,:);
    pcs.var = pcs.var(idx);
    
end