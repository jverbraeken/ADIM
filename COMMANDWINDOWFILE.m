clear all; close all; clc;

%% Exercise 1.2
% S = gen_rectangles(50);
% S = importdata('shortaxes.mat');
% plot_shapes(S,'Marker','none');
% Sa = align_all_shapes(S);
% Sb = align_all_shapes(S, 'tangent_projection',0);
% Sm = mean(Sa, 2);
% plot_shapes(Sa, '+b');
% hold on;
% plot_shapes(Sb, '.r');
% plot_shapes(Sm, '-k');

%% Exercise 1.3
%  S = importdata('shortaxes.mat');
%  Sa = align_all_shapes(S);
%  pca = compute_pca(Sa, 'reduce', 0.85)
%  pareto(pca.var/sum(pca.var));

 
%% Exercise 1.4
% S = importdata('shortaxes.mat');
% Sa = align_all_shapes(S);
% pca = compute_pca(Sa, 'reduce', 0.98)
% shape_viewer(pca)

%% Exercise 1.5
% S = importdata('shortaxes.mat');
% %plot_shapes(S,'Marker','none');
% Sa = align_all_shapes(S);
% Sm = mean(Sa, 2);
% pts = create_mask(Sm, 'extent',3);
% plot(pts(:,1),pts(:,2),'r.');
% hold on;
% plot_shapes(Sm,'-b');
% pt = thin_plate_spline(Sm,Sa(:,5),pts);
% plot(pts(:,1),pts(:,2),'r.');
% hold on;
% plot_shapes(Sm, '-b');
% figure;
% plot(pt(:,1),pt(:,2),'r.');
% hold on
% plot_shapes(Sa(:,5),'-b');

%% Exercise 1.6
S = importdata('shortaxes.mat');
Sa = align_all_shapes(S);
pca = compute_pca(Sa, 'reduce', 1)
Sm = mean(Sa, 2);
pts = create_mask(Sm, 'extent', 1.1);
fnames = importdata('mri_sa.txt');
G = [];
for i = 1:length(fnames)
    P = thin_plate_spline(pca.mean, S(:,i), pts);
    G(:,i) = intensity_sampling(fnames{i}, P);
    disp(sprintf('Sampling from %s', fnames{i}));
end

%figure;
%plot_texture(pts, G(:,i));

%% Exercise 1.7
Gn = photometric_normalization(G);
figure(1)
plot_texture(pts, G(:,10));
figure(2)
plot_texture(pts, Gn(:,10));
 