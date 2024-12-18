function mask = beaconMask(img)
% This function takes an image as input and returns the mask with the beacon detection
% input : the image
% output : the mask of the beacon


figure;
subplot(2,2,1); imshow(img); title('Original Image');

ihsv = rgb2hsv(img);
% isolate yellow / orange colors()
yellow = (ihsv(:,:,1) > 0.05 & ihsv(:,:,1) < 0.2) & (ihsv(:,:,2) > 0.20 & ihsv(:,:,3) > 0.10);

% figure; imshow(yellow, []); title('Yellow Mask');


grayImg = img(:,:,3);
grayImg(grayImg > 80) = 255;

% grayImg = imgaussfilt(grayImg, 2);

[m, n] = size(grayImg);

% thresholded = clusteredImg == min(centers);
thresholded = yellow;
thresholded_opened = imopen(thresholded, strel('disk', 3));
thresholded_opened = bwareaopen(thresholded_opened,  fix(m*n/1500) );
thresholded_opened = imclearborder(thresholded_opened);

subplot(2,2,2);
imshow(thresholded_opened, []);
title('Segmented Image');

% Get the y axe of the first not null value of the yellow mask
[row, col] = find(thresholded_opened, 1, 'first');
[row2, col2] = find(thresholded_opened, 1, 'last');

grad = abs(imgradient(grayImg));

grad = grad > max(grad(:)) * 0.01;
grad = imclose(grad, strel('disk', 4));

grad(:, 1:col-30) = 0;
grad(:, col2+30:end) = 0;

% Reconstruction par dilatation de l'image segmentée
mask = imreconstruct(thresholded_opened,grad | thresholded_opened);



subplot(2,2,3); imshow(grad, []); title('Gradient Image');
subplot(2,2,4); imshow(mask, []); title('Gradient & Segmented Image bouché');





end