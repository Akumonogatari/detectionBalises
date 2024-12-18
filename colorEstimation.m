function direction = colorEstimation(mask, image)
% This function takes the mask of the beacon and the image and returns the direction of the beacon
% For this it detect the yellow areas and then check if there is 1 or 2 and if they are on the top
% middle or bottom of the beacon
%
% Parameters:
%  mask: the mask of the beacon
%  image: the image
% Returns:
%  direction: the direction of the beacon

studied_area =  bsxfun(@times, image, cast(mask, 'like', image));

% hsv to detect yellow

ihsv = rgb2hsv(studied_area);
% isolate yellow / orange colors()
yellow = (ihsv(:,:,1) > 0.05 & ihsv(:,:,1) < 0.2) & (ihsv(:,:,2) > 0.20 & ihsv(:,:,3) > 0.10);
yellow = bwareaopen(yellow, 500);
yellow = imclose(yellow, strel('disk',10));

boundingBoxMask = regionprops(mask, 'BoundingBox').BoundingBox;

figure;
subplot(1,2,1);imshow(studied_area,[]); title('Original Image');
subplot(1,2,2); imshow(yellow, []); title('Yellow Mask');


r = regionprops(yellow, 'Area', 'BoundingBox');

% Sort r by area
[~, idx] = sort([r.Area], 'descend');
r = r(idx);

% Check if there is 1 or 2 yellow areas
if (length(r) == 1)
    % Check if the yellow area is on the top, bottom or middle, of the beacon
    topBox = r(1).BoundingBox;
    
    if (topBox(2) < boundingBoxMask(2) + boundingBoxMask(4)/8)
        direction = "South";
    else;if(topBox(2) < boundingBoxMask(2) + boundingBoxMask(4)/8 * 3)
            direction = "North";
    
        else
            direction = "East";
        end
    end
else
    direction = "West";
    
end

end