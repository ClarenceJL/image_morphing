function morphed_im = morph_tps_wrapper(im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac)
%% morph_tps_wrapper: wrapper for your TPS morphing
% INPUT:
%        im1 - H1 × W1 × 3 matrix representing the first image.
%        im2 - H2 × W2 × 3 matrix representing the second image.
%        im1_pts - N × 2 matrix representing correspondences in the first image. 
%        im2_pts - N × 2 matrix representing correspondences in the second image.
%        warp_frac 1 x M- parameter to control shape warping.
%        dissolve_frac - 1 x M parameter to control cross-dissolve.
% OUTPUT:
%        morphed_im - H2 × W2 × 3 matrix representing the morphed image.
%
% Last Edited: Jiani Li

M = length(warp_frac);

[height1,width1,d] = size(im1);
[height2,width2,d] = size(im2);

morphed_im = cell(M,1);

for f = 1:M
    
    height = round(height1*(1-warp_frac(f)) + height2*warp_frac(f));
    width = round(width1*(1-warp_frac(f)) + width2*warp_frac(f));

    % compute intermediate control points
    itm_pts = im1_pts .* (1-warp_frac(f)) + im2_pts .* (warp_frac(f));

    %%
    sz_itm = [height,width];
    [a1_x1,ax_x1,ay_x1,w_x1] = est_tps(itm_pts, im1_pts(:,1));
    [a1_y1,ax_y1,ay_y1,w_y1] = est_tps(itm_pts, im1_pts(:,2));
    morphed_im1 = morph_tps(im1, a1_x1, ax_x1, ay_x1, w_x1, a1_y1, ax_y1, ay_y1, w_y1, itm_pts, sz_itm);

    [a1_x2,ax_x2,ay_x2,w_x2] = est_tps(itm_pts, im2_pts(:,1));
    [a1_y2,ax_y2,ay_y2,w_y2] = est_tps(itm_pts, im2_pts(:,2));
    morphed_im2 = morph_tps(im2, a1_x2, ax_x2, ay_x2, w_x2, a1_y2, ax_y2, ay_y2, w_y2, itm_pts, sz_itm);


    morphed_im{f} = morphed_im1 * (1-dissolve_frac(f)) + morphed_im2 * dissolve_frac(f);

end



end

