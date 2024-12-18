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
yellow = imopen(yellow, strel('disk', 5));
yellow = imclose(yellow, strel('disk',10));

boundingBoxMask = regionprops(mask, 'BoundingBox').BoundingBox;

figure;
subplot(1,2,1);imshow(studied_area,[]); title('Original Image');


r = regionprops(yellow, 'BoundingBox');

% Extract BoundingBox values
boundingBoxes = cat(1, r.BoundingBox);

% Sort by y coordinate
[~, idx] = sort(boundingBoxes(:, 2), 'ascend');
r = r(idx);

% Check if the bounding boxes overlap or are too close of each others (only look for the y axis)
% if so, fusion them

for i = 1:length(r)
    for j = i+1:length(r)
        if ( (r(i).BoundingBox(2) + r(i).BoundingBox(4) )*1.5 > r(j).BoundingBox(2))


            r(i).BoundingBox = [min(r(i).BoundingBox(1), r(j).BoundingBox(1)), min(r(i).BoundingBox(2), r(j).BoundingBox(2)), max(r(i).BoundingBox(3), r(j).BoundingBox(3)), max(r(i).BoundingBox(4), r(j).BoundingBox(4))];

            r(j).BoundingBox = [0, 0, 0, 0];
        end
    end
end

r = r(~arrayfun(@(x) all(x.BoundingBox == 0), r));

subplot(1,2,2);imshow(yellow,[]); title('Yellow Mask');
% show the boundings boxes
for i = 1:length(r)
    rectangle('Position', r(i).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
end


% Check if there is 1 or 2 yellow areas
if (length(r) == 1)
    % Check if the yellow area is on the top, bottom or middle, of the beacon
    topBox = r(1).BoundingBox;
    
    if (topBox(2) < boundingBoxMask(2) + boundingBoxMask(4)/5 + boundingBoxMask(4)/5)
        direction = "South";
    else;if(topBox(2) < boundingBoxMask(2) + boundingBoxMask(4)/5 + boundingBoxMask(4)/5*2)
            direction = "East";
            
        else
            direction = "North";
        end
    end
else
    direction = "West";
    
end

end