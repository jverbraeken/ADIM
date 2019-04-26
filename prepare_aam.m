% PREPARE_AAM: a script to prepare all shape, texture and apperance model for
% the AAM matching procedure.
%   data = short-axis MRI
%
% A. Suinesiaputra - LKEB 2005

disp('MODEL BUILDING');
startup;

disp('Importing shortaxes.mat.');
S = importdata('shortaxes.mat');

disp('Shape alignment');
Sa = align_all_shapes(S);

disp('Compute PCA of the shape data with 98% total variance.');
shape_m = compute_pca(Sa,'reduce',0.98);

disp('Texture sampling.');
fnames = importdata('samri_data/mri_sa.txt');
[G,mask] = generate_texture_samples(shape_m.mean,S,fnames,'path','samri_data');

disp('Photometric normalization.');
Gn = photometric_normalization(G);

disp('Compute PCA of the texture data with 98% total vairance.');
texture_m = compute_pca(Gn,'reduce',0.98);

disp('Calculate combined appearance model.');
Ws = sqrt(sum(texture_m.var) / sum(shape_m.var));
app_m = compute_pca([Ws*shape_m.b; texture_m.b],'remove_mean',0,'reduce',0.98);


disp('Compute pose regressions');
Rt=pose_prediction(shape_m,texture_m,app_m,Ws,fnames,S,mask);
save Rt50.mat Rt;

disp('Compute model parameter regressions');
Rc=params_prediction(shape_m,texture_m,app_m,Ws,fnames,S,mask);
save Rc50.mat Rc;

aam_matching2;