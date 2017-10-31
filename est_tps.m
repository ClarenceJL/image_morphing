function [a1,ax,ay,w] = est_tps(ctr_pts, target_value)
%% est_tps: Thin-plate parameter estimation
% INPUT:
%        ctr_pts - N × 2 matrix, each row representing corresponding point position (x, y) in source image.
%        target_value - N × 1 vector representing corresponding point position x or y in target image.
% OUTPUT:
%        a1 - double, TPS parameters. 
%        ax - double, TPS parameters. 
%        ay - double, TPS parameters. 
%        w - N x 1 vector, TPS parameters.
%
% Last Edited: Jiani Li, Oct/09/2016

lambda = 1.00e-12;

N = size(ctr_pts,1);
r_sqr = (ctr_pts(:,1)*ones(1,N) - ones(N,1)*(ctr_pts(:,1)')).^2 + ...
        (ctr_pts(:,2)*ones(1,N) - ones(N,1)*(ctr_pts(:,2)')).^2;

zero_ind = (r_sqr == 0);   
K = - r_sqr.*log(r_sqr);
K(zero_ind) = 0;

P = ones(N,3);
P(:,1:2) = ctr_pts;
O3by3 = zeros(3,3);

D = [K P; P' O3by3];

I = eye(N+3,N+3);

coeff = (D + lambda*I) \ [target_value;0;0;0];

w = coeff(1:end-3);
ax = coeff(end-2);
ay = coeff(end-1);
a1 = coeff(end);


end

