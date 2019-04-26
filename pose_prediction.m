function Rt = pose_prediction(shape_model,texture_model,app_model,Ws,files,Sorig,mask,varargin)
% POSE_PREDICTION: perform the Fixed Jacobian Matrix Estimation to build the pose
% parameter predictors in the AAM search.
%
%   Rt = pose_prediction(SM,TM,AM,Ws,files,shapes,mask);
%   Rt = pose_prediction(SM,TM,AM,Ws,files,shapes,mask,'opt1',val1,'arg2',val2,...);
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
%   - Rt = 4xm matrix of pose parameters prediction, where m = length of texture
%     vector.
%
% Optional arguments:
%   - 'x_disp', array. Defines the x displacement vector.
%     Default = [-6 -3 -1 1 3 6] pixels.
%   - 'y_disp', array. Defines the y displacement vector.
%     Default = [-6 -3 -1 1 3 6] pixels.
%   - 'scale_disp', array. Defines the scale displacement vector.
%     Default = [0.95 0.97 0.99 1.01 1.03 1.05]
%   - 'angle_disp', array. Defines the angle (rotation) displacement vector.
%     Default = [-5 -3 -1 1 3 5] degrees.
%   - 'select', indices. Select which training shapes to include.
%     Default is to use all training shapes.
%     NOTE: it might be slow to compute these predictors using all training
%     shapes.
%
% A. Suinesiaputra - LKEB 2005

% default values
dtx = [-6 -3 -1 1 3 6];                 % x displacement
dty = [-6 -3 -1 1 3 6];                 % y displacement
ds = [0.95 0.97 0.99 1.01 1.03 1.05];   % scale displacement
dth = [-5 -3 -1 1 3 5];                 % angle displacement in degrees
img_open_fcn = inline('double(imread(f))','f');
idx = 1:size(shape_model.b,2);       % which shapes to be included from the model

% get optional argument
for i=1:2:length(varargin)
    if( strcmpi(varargin{i},'x_disp') ) dtx = varargin{i+1};
    elseif( strcmpi(varargin{i},'y_disp') ) dty = varargin{i+1};
    elseif( strcmpi(varargin{i},'scale_disp') ) ds = varargin{i+1};
    elseif( strcmpi(varargin{i},'angle_disp') ) dth = varargin{i+1};
    elseif( strcmpi(varargin{i},'img_open_fcn') ) img_open_fcn = varargin{i+1};
    elseif( strcmpi(varargin{i},'select') ) idx = varargin{i+1};
    else error('Unknown option.'); end
end
dth = dth * pi/180; % convert to radians

m = length(texture_model.mean);       % number of elements in the texture vectors
nx = length(dtx)+length(dty)+length(ds)+length(dth); % column in G
nshapes = length(idx);                % number of training shapes included
Qg = texture_model.phi * app_model.phi((size(shape_model.phi,2)+1):end,:);
Qs = shape_model.phi * inv(Ws) * app_model.phi(1:size(shape_model.phi,2),:);

% theta experiments
sx = cos(dth) -1;
sy = sin(dth);
dTh = [sx; sy; zeros(2,length(dth))];

Rt = zeros(4,m);

for k=1:nshapes
    
    i = idx(k);
    disp(sprintf('Model prediction from training shape #%d.',i));

    % read image
    warning off;
    img = feval(img_open_fcn, files{i});
    warning on;
    
    % reconstruct shape vector for the training shape i
    xm = shape_model.mean + Qs * app_model.b(:,i);
    
    % reconstruct texture vector for the training shape i
    gm = texture_model.mean + Qg * app_model.b(:,i);
    
    % find pose of xm to the original shape
    pose = shape_pose(xm,Sorig(:,i),'output','struct')';
    P = [pose.sx pose.sy pose.tx pose.ty]';
    
    G = [];

	% create dt experiment matrix
	T = [];
    
    % translation experiments
    % find dtx and dty units
    dtu = abs(transform_shapes([0 0]',[pose.sx pose.sy 1 1],'invert',1));
    dTx = [zeros(2,length(dtx)); dtx .* dtu(1); zeros(1,length(dtx))];
    dTy = [zeros(3,length(dtx)); dty .* dtu(2)];
    
    % scale experiments must be constructed from pose.scale
    ts = (ds .* pose.scale) - pose.scale;
    sx = ds * cos(0) - 1;
    sy = ds * sin(0);
    dS = [sx; sy; zeros(2,length(ds))];
    
    % combine into T
    T = [dS dTh dTx dTy];
    
    for j=1:nx
        
        % transform by dT then by P
        xim = transform_shapes(transform_shapes(xm,T(:,j)),P);
        
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
    R = T*pinv(G);

    % update Rt
    Rt = R + Rt;
end

% take an average
Rt = Rt ./ nshapes;