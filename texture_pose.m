function U = texture_pose(gim,gmean)
% TEXTURE_POSE: calculate the texture transformation U needed to transform a
% texture vector in image frame (gim) onto model frame represented by the mean
% texture vector (gmean) of the model.
%
%   U = texture_pose(gim,gmean);
%
% Input:
%   - gim is a texture vector in image frame,
%   - gmean is the mean texture vector from PCA model of texture vectors.
%
% Output:
%   - U is [u1 u2]' texture transformation.
%
% NOTE:
% The relationship between the texture in the image frame (gim) and in the model
% frame (gm) is given as follows.
%           gim = (1+u1)*gm + u2
%           gm = (gim-u2) / (1+u1)
%
% A. Suinesiaputra - LKEB 2005

% check size
if( ~isequal(size(gim),size(gmean)) )
    error('Dimension of gim and gmean are not equal.');
end

% check variance
if( var(gmean)~=1 ) gmean = gmean ./ std(gmean); end

% calculate u1 & u2
u1 = gim'*gmean - 1;
u2 = sum(gim)/length(gim);

% output U
U = [u1 u2]';