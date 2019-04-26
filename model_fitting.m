function [y_fit,pose] = model_fitting(shape_model, ytarget)
% MODEL_FITTING: Finds the best pose and shape parameters to match a model instance of the shape model to the
%              target shape
%
%   [y,T] = shape_pose(shape_model,xtarget)
%
% Input:
%   - shape_model is a PDM of training shape,
%   - ytarget is a reference shape vector, the target shape vector.
%
% Output:
%   - T is the transformation matrix which best maps an instance of shape_model to shape_target.
%     The form of T depends on the 'output' option. See the 'output' optional
%     argument.
%   - b is the shape parameters
%   The form of T is:
%     T.tx, T.ty, T.scale, T.theta
%
% NOTE: both ytarget and y_fit must contain only 1 shape vector.
%
% A. Suinesiaputra - LKEB 2005
% F. Z. Tala - @HOME 2007


% check shape
if( size(ytarget,2)>1 ) error('xtarget must be a single shape vector.'); end

t = size(shape_model.b,1);

% initialize b to zeroes
b = zeros(size(shape_model.b,1),1);

% initialize previous shape parameter to zeros
prev_b = b;


% initialize previous Pose to zeros
pose = [0;0;0;0];
prev_pose = [0;0;0;0];

plot_shapes(ytarget,'-r.','MarkerSize',16);

y_fit = [];
hold on;

converge = 0;
iter =0;


while( ~converge & (iter <= 50) )

   iter = iter + 1;

   prev_pose = pose;
   prev_b = b;

   % creates an instance of model with b
   x = shape_model.mean + shape_model.phi * b;

   % Find best pose which maps x to ytarget
   T = shape_pose(x,ytarget,'output','struct');
   pose = [T.scale; T.theta; T.tx; T.ty];

   % for viewing only
   xview = reshape( (T.scale) .* [cos(T.theta) -sin(T.theta); sin(T.theta) cos(T.theta)] * reshape(x,2,[]) + repmat([T.tx;T.ty],1,size(x,1)/2),[],1);
   plot_shapes(xview,':m.');
   hold on;

   converge = significant_changes(pose,prev_pose,0.01) & significant_changes(b,prev_b,0.01);

   if (converge) continue;  end;

   % maps ytarget using the inverse tranformation to model frame
   y = reshape( (1/(T.scale)) .* [cos(-T.theta) -sin(-T.theta); sin(-T.theta) cos(-T.theta)] * reshape(ytarget,2,[]) - repmat([T.tx;T.ty],1,size(ytarget,1)/2),[],1);

   % project y to tangent plane of pc.mean
   y = y / (y' * shape_model.mean);

   % update the shape parameter to match to y
   b = shape_model.phi' * (y - shape_model.mean);

   % constraint b vector
   b = constraint_b(b,shape_model.var);


end; % while not converge


%map the model to the image frame
y_fit = reshape( (T.scale) .* [cos(T.theta) -sin(T.theta); sin(T.theta) cos(T.theta)] * reshape(x,2,[]) + repmat([T.tx;T.ty],1,size(x,1)/2),[],1);

plot_shapes(y_fit,'-bo');
hold off;

% end of model_fitting







function b_out = constraint_b(b_in,sigma)
% CONSTRAINT_B: appy constraints to the value of b

for i=1:length(b_in)
   if ( b_in(i) >= 3*sqrt(sigma(i)))
       b_out(i) = 3*sqrt(sigma(i));
   elseif ( b_in(i) <= -3*sqrt(sigma(i)) )
       b_out(i) = -3*sqrt(sigma(i));
   else
       b_out(i) = b_in(i);
   end;

end; %for
b_out = b_out';
%end of constraint_b




function T = significant_changes(x,y,sig_value)
% SIGNIFICANT_CHANGES: returns true if x-y <= significant_value

T = 0;

% check the size of the two vectors x,y
if( ~all(size(x) == size(y)) )
   error('Error significant changes ==> Matrix dimension must agree'); return;
end;

T = all( abs(x-y) <= sig_value);

%end of significant_changes
