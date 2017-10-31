%% Generate full morphing video between two images
% 
% Last Edited: Jiani LI


%% initialization
clear;

nFrame = 60;  % number of frames (including the starting and the ending image)


%% load images
imgA = imread('imageA.png');
imgB = imread('imageB.png');
[heightA, widthA, d] = size(imgA);
[heightB, widthB, d] = size(imgB);


%% load or select corresponding points
if exist('imageA_pts.mat','file') > 0 && exist('imageB_pts.mat','file') > 0
    load('imageA_pts.mat');
    load('imageB_pts.mat');
else
    [imgA_pts,imgB_pts] = click_correspondences(imgA,imgB);
    imgA_pts = double(imgA_pts);
    imgB_pts = double(imgB_pts);
    save('imageA_pts.mat','imgA_pts');
    save('imageB_pts.mat','imgB_pts');
end 



method = 0;% default method

warp_frac = 0:(1/(nFrame-1)):1; warp_frac(nFrame) = 1;
dissolve_frac = warp_frac;

if method == 1
    %% triangulation method
    
    % create video object
    vid_tri = VideoWriter('facemorphing_triangulation.avi');
    open(vid_tri);
    
    % create morphed image
    morphed_images = morph(imgA,imgB,imgA_pts,imgB_pts,warp_frac,dissolve_frac);


else
    %% TPS method
    % create video object
    vid_tri = VideoWriter('facemorphing_tps.avi');
    open(vid_tri);
      
    % create morphed image
    morphed_images = morph_tps_wrapper(imgA,imgB,imgA_pts,imgB_pts,warp_frac,dissolve_frac);
       
end

% pad images and write into the video
h_max = max(heightA,heightB);
w_max = max(widthA,widthB);
%%
for i = 1:nFrame
    currFrame = morphed_images{i};
    [height,width,d] = size(currFrame);
    padh_pre = floor((h_max - height)/2);
    padh_post = ceil((h_max - height)/2);
    padw_pre = floor((w_max - width)/2);
    padw_post = ceil((w_max - width)/2);
    currFrame = padarray(currFrame,[padh_pre padw_pre 0],0,'pre');
    currFrame = padarray(currFrame,[padh_post padw_post 0],0, 'post');
    writeVideo(vid_tri,currFrame);

end
    
% Close the file.
close(vid_tri);   


