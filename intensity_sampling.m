function g = intensity_sampling(img,pts,varargin)
% INTENSITY_SAMPLING: perform sampling of intensity pixels given a set of
%                     points.
%
%   g = intensity_sampling(img,pts);
%
% Input:
%   - img is either an image matrix or an absolute path of a filename.
%   - pts is Mx2 coordinate sampling points.
%
% Output:
%   - g is a texture vector.
%
% Optional arguments:
%   - 'open_fcn', a function handle.
%     Determine how to open the image file if the first argument is a filename.
%     Default: the dicomread function to open a DICOM file.
%
% A. Suinesiaputra - LKEB 2005

% default values
open_fcn = inline('double(imread(f))','f');   % open dicom file

% get optional arguments
for i=1:2:length(varargin)
    if( strcmpi(varargin{i},'open_fcn') ) 
        open_fcn = varargin{i+1};
        if( ~isa(open_fcn,'function_handle') )
            error('Value for the ''open_fcn'' argument is not a FUNCTION_HANDLE type.');
        end
    else error('Unknown option.'); end
end

if( ischar(img) )  % the first argument is a filename
	% open file
	try
        warning off;
        img = feval(open_fcn,img);
        warning on;
	catch
        error('Cannot open/find the MRI file.');
        return;
	end
end
% check img
if( ~isnumeric(img) || ndims(img)~=2 ) error('Invalid type of image.'); end

% check pts
if( size(pts,2)~=2 ) error('The set of points must be in 2D coordinate.'); end

% rounding
pts = round(pts);

% sampling
try
    % REMEMBER X & Y are swapped in the image file !!
    % PTS starts from 0 and Y is reversed !!
    g = diag(img(pts(:,2)+1,pts(:,1)+1));
catch
    error('Sampling error. Coordinate points might be outside the image.');
    return;
end