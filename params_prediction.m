function Rc = params_prediction(shape_model,texture_model,app_model,Ws,files,Sorig,mask,varargin)
% PARAMS_PREDICTION: perform the Fixed Jacobian Matrix Estimation to build the
% appearance parameter predictors in the AAM search.
%
%   Rc = params_prediction(SM,TM,AM,Ws,files,shapes,mask);
%   Rc = params_prediction(SM,TM,AM,Ws,files,shapes,mask,'opt1',val1,'arg2',val2,...);
%
% Input:
%   - SM = the shape PCA model,
%   - TM = the texture PCA model,
%   - AM = the appearance PCA model,
%   - Ws = weighting matrix to scale shape parameters in the appearance
%     modeling,
%   - files = cell string of training shapes' filenames,
%   - shapes = the training shape matrix, and
%   - mask = mask from mean shape used to do the intensity sampling.
%
% Output:
%   - Rc = NxM matrix of pose parameters prediction, where M = length of texture
%     vector and N = number of appearance parameters.
%
% Optional arguments:
%   - 'mdoel_disp', array. Defines model displacement.
%     Default = [-0.5 -0.25 0.25 0.5] times variance.
%   - 'select', indices. Select which training shapes to include.
%     Default is to use all training shapes.
%     NOTE: it might be slow to compute these predictors using all training
%     shapes.
%
% A. Suinesiaputra - LKEB 2005

% default values
img_open_fcn = inline('double(imread(f))','f');
idx = 1:size(shape_model.b,2);          % which shapes to be included from the model
dc = [-0.5 -0.25 0.25 0.5] ;            % model displacement of its variances

% get optional argument
for i=1:2:length(varargin)
    if( strcmpi(varargin{i},'model_disp') ) dc = varargin{i+1};
    elseif( strcmpi(varargin{i},'select') ) idx = varargin{i+1};
    else error('Unknown option.'); end
end

m = length(texture_model.mean);         % number of elements in the texture vectors
nparams = size(app_model.b,1);          % number of model parameters
nx = length(dc) * nparams;              % column in G
nshapes = length(idx);                  % number of training shapes included

Qg = texture_model.phi * app_model.phi((size(shape_model.phi,2)+1):end,:);
Qs = shape_model.phi * inv(Ws) * app_model.phi(1:size(shape_model.phi,2),:);

% create dc experiment matrix
C = zeros(nparams,nx);
for ci=1:nparams
    C(ci,((ci-1)*length(dc))+1:ci*length(dc)) = dc .* sqrt(app_model.var(ci));
end

Rc = zeros(nparams,m);
for k=1:nshapes
    
    i = idx(k);
    disp(sprintf('Model prediction from training shape #%d.',i));

    % read image
    warning off;
    img = feval(img_open_fcn,files{i});
    warning on;
    
    % get model parameter
    c0 = app_model.b(:,i);
    
    G = [];

    for j=1:nx
        
        % reconstruct shape vector for the training shape i with dc + c0
        xm = shape_model.mean + Qs * (c0 + C(:,j));
        
        % reconstruct texture vector for the training shape i with dc + c0
        gm = texture_model.mean + Qg * (c0 + C(:,j));
        
        % find pose of xm to the original shape
        pose = shape_pose(xm,Sorig(:,i),'output','struct')';
        P = [pose.sx pose.sy pose.tx pose.ty]';
        
        % transform by dT then by P
        xim = transform_shapes(xm,P);
        
        % intensity sampling
        pts = thin_plate_spline(shape_model.mean,xim,mask);
        gim = intensity_sampling(img,pts);
        
        % normalized gim into gs
        u = texture_pose(gim,texture_model.mean);
        gs = (gim - u(2)) / (1 + u(1));
	
        % put the difference in the j-th column of G
        G = [G  gs-gm];
        
    end
    % calculate R
    R = C*pinv(G);

    % update Rt
    Rc = R + Rc;
end

% take an average
Rc = Rc ./ nshapes;