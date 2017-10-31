function morphed_im = morph(im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac)
%% morph: produces a warp between two images
% INPUT:
%        im1 - H1 × W1 × 3 matrix representing the first image. 
%        im2 - H2 × W2 × 3 matrix representing the second image.
%        im1_pts - N × 2 matrix representing correspondences coordinates in first image.
%        im2_pts - N × 2 matrix representing correspondences coordinates in sec- ond image.
%        warp_frac -  1xM parameter to control shape warping.
%        dissolve_frac: 1xM parameter to control cross-dissolve.
% OUTPUT:
%        morphed_im - M element cell array, each element represents morphed image.
%
% Last Edited: Jiani Li

M = length(warp_frac);

% meshgrid map
[height1,width1,d] = size(im1);
[height2,width2,d] = size(im2);

% 
v_im1 = zeros(height1*width1,d);
v_im2 = zeros(height2*width2,d);
for i = 1:d
    im_channel = im1(:,:,i);
    v_im1(:,i) = im_channel(:);
    im_channel = im2(:,:,i);
    v_im2(:,i) = im_channel(:);
end

    
%% triangulation
% create intermediate
mid_pts = (im1_pts + im2_pts)./2;
% generate Delaunay triangulation
tri = delaunayTriangulation(mid_pts(:,1),mid_pts(:,2));

morphed_im = cell(M,1);

for f = 1:M
    
    % calculate the size of morphed_im
    height = round(height1*(1-warp_frac(f)) + height2*warp_frac(f));
    width = round(width1*(1-warp_frac(f)) + width2*warp_frac(f));

    [X,Y] = meshgrid(1:width,1:height);
    vX = X(:);
    vY = Y(:);

    morphed_im1 = zeros(height*width,d);
    morphed_im2 = zeros(height*width,d);


    %% decide which triangle each pixel in the warped image lies in
    % warped points positions
    current_pts = im1_pts .* (1-warp_frac(f)) + im2_pts .* (warp_frac(f));


    %% find which triangle are the pixels in
    T = tsearchn(current_pts,tri,[vX vY]);


    %% morphing 
    numTri = size(tri,1);
    for tn = 1: numTri  % for each triangle

        % find all points inside current triangle
        pix_ind = (T == tn);       % assume m points are selected
        pix_coord = [ vX(pix_ind)' ;
                      vY(pix_ind)' ;
                      ones(1,sum(pix_ind))];

        % calculate the barycentric coordinates for points in current triangle
        v = tri(tn,:); 
        triangle_cur= [current_pts(v(1),1) current_pts(v(2),1) current_pts(v(3),1);
                      current_pts(v(1),2) current_pts(v(2),2) current_pts(v(3),2);
                      1 1 1];
        bc_coord = triangle_cur \ pix_coord;

        % find corresponding point coordinates in two source images
        triangle_1 = [im1_pts(v(1),1) im1_pts(v(2),1) im1_pts(v(3),1);
                      im1_pts(v(1),2) im1_pts(v(2),2) im1_pts(v(3),2);
                      1 1 1];     
        triangle_2 = [im2_pts(v(1),1) im2_pts(v(2),1) im2_pts(v(3),1);
                      im2_pts(v(1),2) im2_pts(v(2),2) im2_pts(v(3),2);
                      1 1 1]; 

        srcpts1 = (triangle_1 * bc_coord)';   
        srcpts1(:,1) = srcpts1(:,1) ./ srcpts1(:,3);
        srcpts1(:,2) = srcpts1(:,2) ./ srcpts1(:,3);
        srcpts1 = int32(srcpts1);
        srcpts1 = (srcpts1(:,1)-1)*height1 + srcpts1(:,2);

        srcpts2 = (triangle_2 * bc_coord)';
        srcpts2(:,1) = srcpts2(:,1) ./ srcpts2(:,3);
        srcpts2(:,2) = srcpts2(:,2) ./ srcpts2(:,3);
        srcpts2 = int32(srcpts2);
        srcpts2 = (srcpts2(:,1)-1)*height2 + srcpts2(:,2);

        % fill in the color for morphed image by blending colors of two images
        morphed_im1(pix_ind,:) = v_im1(srcpts1,:);
        morphed_im2(pix_ind,:) = v_im2(srcpts2,:);

    end

    morphed_im1 = reshape(morphed_im1,height,width,d);
    morphed_im2 = reshape(morphed_im2,height,width,d);
    morphed_im1 = uint8(morphed_im1);
    morphed_im2 = uint8(morphed_im2);

    morphed_im{f} = morphed_im1 * (1-dissolve_frac(f)) + morphed_im2 * dissolve_frac(f);

end


end

