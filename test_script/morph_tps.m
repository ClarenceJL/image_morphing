function morphed_im = morph_tps(im_source, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, ctr_pts, sz)
%% morphtps: transform all the pixels in image (B) by the TPS model, and read back the pixel value in image (A) directly.
% INPUT:
%        im_source - Hs × Ws × 3 matrix representing the source image. 
%        a1_x, ax_x, ay_x, w_x - the parameters solved when doing est_tps in the x direction.
%        a1_y, ax_y, ay_y, w_y - the parameters solved when doing est_tps in the y direction.
%        ctr_pts - N × 2 matrix, each row representing corresponding point position (x, y) in source image.
%        sz - 1 × 2 vector representing the target image size (Ht, Wt). 
% OUTPUT:
%        morphed_im - Ht × Wt × 3 matrix representing the morphed image.
%
% Last Edited: Jiani Li

[Hs,Ws,c] = size(im_source);
v_im_source = zeros(Hs*Ws,c);
for i = 1:c
    channel = im_source(:,:,i);
    v_im_source(:,i) = channel(:);
end

Ht = sz(1); Wt = sz(2);

[X,Y] = meshgrid(1:Wt,1:Ht);
tX = X(:);
tY = Y(:);
M = Wt*Ht;
N = size(ctr_pts,1);

coeff_x = [w_x; ax_x; ay_x; a1_x];
coeff_y = [w_y; ax_y; ay_y; a1_y];

r_sqr = (tX*ones(1,N) - ones(M,1)*(ctr_pts(:,1)')).^2 + ...
        (tY*ones(1,N) - ones(M,1)*(ctr_pts(:,2)')).^2;
zero_ind = (r_sqr == 0);   
K = -r_sqr.*log(r_sqr);
K(zero_ind) = 0;

P = ones(M,3);
P(:,1) = tX;
P(:,2) = tY;

D = [K P];

srcX = int32(D * coeff_x);
srcX(srcX < 1) = 1; srcX(srcX > Ws) = Ws;   % boundary handling
srcY = int32(D * coeff_y);
srcY(srcY < 1) = 1; srcY(srcY > Hs) = Hs;   % boundary handling

src_ind = (srcX - 1) * Hs + srcY;

morphed_im = v_im_source(src_ind,:);

morphed_im = reshape(morphed_im,Ht,Wt,c);

morphed_im = uint8(morphed_im);

end

