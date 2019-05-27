function [G,mask] = generate_texture_samples(xref,S,fnames,varargin)
% GENERATE_TEXTURE_SAMPLES: given the reference shape and a set of training
% shapes, this function performs the intensity sampling to make a shape free
% patch for each training shape.
%
%   [G,mask] = generate_texture_samples(xref,S,fnames)
%
% Input:
%   - xref is the N-length vector of the reference shape,
%   - S is NxM matrix of M number of training shapes,
%   - fnames is M-length cell array consists of MRI filenames.
%
% Output:
%   - G is PxM grey-level or texture samples.
%   - mask is the mask used to generate grid points inside the xref.
%
% Optional arguments:
%   - 'mask_opts', cell array. Optional arguments that are passed to the
%     create_mask function. See 'help create_mask' for these options.
%   - 'path', a string.
%
% A. Suinesiaputra - LKEB 2005

% check sizes
if( size(xref,1)~=size(S,1) ) error('Mismatch dimension between reference shape and the training shapes.'); end
if( ~iscell(fnames) ) error('The fnames argument must be a cell array of string.'); end
if( size(S,2)~=length(fnames) ) error('The number of filenames in fnames is not equal to the number of shapes'); end

% default values
mask_opts = {};
path = '.';

% get optional arguments
for i=1:2:length(varargin)
    if( strcmpi(varargin{i},'mask_opts') ) mask_opts = varargin{i+1};
    elseif( strcmpi(varargin{i},'path') ) path = varargin{i+1};
    else error('Unknown option.'); end
end

% create mask
mask = create_mask(xref,mask_opts{:});

% iterate for each training shape
for i=1:size(S,2)
    % warping from xref to the shape
    P = thin_plate_spline(xref,S(:,i),mask);
    % intensity sampling
    G(:,i) = intensity_sampling(fnames{i},P);
    % display
    disp(sprintf('Sampling from %s is done.',fnames{i}));
end