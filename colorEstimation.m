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

boundingBoxMask = regionprops(mask, 'BoundingBox');

% fusion the bounding boxes
maxX = 0; maxY = 0; minX = 100000; minY = 100000;
for i = 1:length(boundingBoxMask)
    maxX = max(maxX, boundingBoxMask(i).BoundingBox(1) + boundingBoxMask(i).BoundingBox(3));
    maxY = max(maxY, boundingBoxMask(i).BoundingBox(2) + boundingBoxMask(i).BoundingBox(4));
    minX = min(minX, boundingBoxMask(i).BoundingBox(1));
    minY = min(minY, boundingBoxMask(i).BoundingBox(2));
end

boundingBoxMask = [minX, minY + 0.22*(maxY - minY), maxX - minX, (maxY - minY)*0.78];



% hsv to detect yellow

ihsv = rgb2hsv(studied_area);
% isolate yellow / orange colors()
yellow_mask = (ihsv(:,:,1) > 0.05 & ihsv(:,:,1) < 0.17) & (ihsv(:,:,2) > 0.30 & ihsv(:,:,3) > 0.25);
yellow_mask = imclose(yellow_mask,strel('disk',2));


% Delete every object with a smaller area the 15% of the biggest one
r = regionprops(yellow_mask, 'Area');
areas = cat(1, r.Area);
yellow = bwareaopen(yellow_mask, fix(max(areas)*0.15));


% Si il reste plus de 2 objets jaunes augmenter le seuil de suppression

if (length(yellow )>2)
    yellow = bwareaopen(yellow_mask, fix(max(areas)*0.25));
end

figure;
subplot(1,2,1);imshow(studied_area,[]); title('Original Image');






r = regionprops(yellow, 'BoundingBox');

% Extract BoundingBox values
boundingBoxes = cat(1, r.BoundingBox);

% Sort by y coordinate
[~, idx] = sort(boundingBoxes(:, 2), 'ascend');
r = r(idx);

% Show the bounding boxes in green
for i = 1:length(r)
    rectangle('Position', r(i).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 2);
end


% Check if the bounding boxes overlap or are too close of each others (only look for the y axis)
% if so, fusion them

for i = 1:length(r)
    for j = i+1:length(r)
        if ( (r(i).BoundingBox(2) + (r(i).BoundingBox(4)*1.25) ) > r(j).BoundingBox(2))
            
            x_right = max(r(i).BoundingBox(1) + r(i).BoundingBox(3), r(j).BoundingBox(1) + r(j).BoundingBox(3)) - r(i).BoundingBox(1);
            y_bottom = max(r(i).BoundingBox(2) + r(i).BoundingBox(4), r(j).BoundingBox(2) + r(j).BoundingBox(4)) - r(i).BoundingBox(2);
            
            r(i).BoundingBox = [min(r(i).BoundingBox(1), r(j).BoundingBox(1)), r(i).BoundingBox(2), x_right, y_bottom];
            
            r(j).BoundingBox = [0, 0, 0, 0];
        end
    end
end

subplot(1,2,2);imshow(yellow,[]); title('Yellow Mask');
r = r(~arrayfun(@(x) all(x.BoundingBox == 0), r));

% show the boundings boxes
for i = 1:length(r)
    rectangle('Position', r(i).BoundingBox, 'EdgeColor', 'y', 'LineWidth', 2);
end

subplot(1,2,1);
for i = 1:length(r)
    rectangle('Position', r(i).BoundingBox, 'EdgeColor', 'y', 'LineWidth', 2);
end

rectangle('Position', boundingBoxMask, 'EdgeColor', 'b', 'LineWidth', 2);

% draw the limis lines 

% draw the horizontals limits lines
line([0, width(image)], [boundingBoxMask(2) + (boundingBoxMask(4)*2/6), boundingBoxMask(2) + (boundingBoxMask(4)*2/6)], 'Color', 'b', 'LineWidth', 2);

line([0,width(image)], [boundingBoxMask(2) + (boundingBoxMask(4)*4/6) , boundingBoxMask(2) + (boundingBoxMask(4)*4/6)], 'Color', 'r', 'LineWidth', 2);


% Check if there is 1 or 2 yellow areas
if (isscalar(r))
    % Check if the yellow area is on the top, bottom or middle, of the beacon
    topBox = r(1).BoundingBox;
        
    if (topBox(2) + (topBox(4)/2) < boundingBoxMask(2) + (boundingBoxMask(4)*2/6))
        direction = "South";
    else;if(topBox(2)+ (topBox(4)/2) < boundingBoxMask(2) + (boundingBoxMask(4)*4/6))
            direction = "East";
            
        else
            direction = "North";
        end
    end
else
    direction = "West";
    
end

end