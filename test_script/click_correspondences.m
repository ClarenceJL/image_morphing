function [im1_pts, im2_pts] = click_correspondences(im1,im2)
%% click_correspondence: manually chose corrsponding feature points for two images
% INPUT:
%        im1 - H1 × W1 × 3 matrix representing the first image. 
%        im2 - H2 × W2 × 3 matrix representing the second image.
% OUTPUT:
%        im1_pts: N × 2 matrix representing correspondences coordinates in first image.
%        im2_pts: N × 2 matrix representing correspondences coordinates in sec- ond image.
%
% Last Edited: Jiani Li, Oct/09/2016

% select corresponding points (non-image corners)
disp('When finish selecting, close window directly');
disp('Notice: This function automatically select the four corners');

[im1_pts,im2_pts] = cpselect(im1,im2,'Wait', true);

% select four corners of the images
[height1,width1,d] = size(im1);
[height2,width2,d] = size(im2);

corners1 = [1 1; width1 1; 1 height1; width1 height1];
corners2 = [1 1; width2 1; 1 height2; width2 height2];
       
im1_pts = int32([im1_pts; corners1]);
im2_pts = int32([im2_pts; corners2]);



end

