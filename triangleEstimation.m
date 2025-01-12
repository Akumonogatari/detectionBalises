function result = triangleEstimation (mask,image)
% This function takes the mask of the beacon and the image and returns the direction of the beacon
% For this it take the 22 first % of the bounding box to isolate the triangles and then check the 
% sum of the 4 quarters. The quarter with the highest sum is widest part of each triangle.
%
% Parameters:
%  mask: the mask of the beacon
%  image: the image
% Returns:
%  direction: the direction of the beacon

studied_area =  bsxfun(@times, image, cast(mask, 'like', image));
figure;subplot(1,2,1);imshow(studied_area);

boundingBoxTriangles = regionprops(mask, 'BoundingBox');

for i =1 : length(boundingBoxTriangles)
    rectangle('Position',boundingBoxTriangles(i).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
end

% fusion des bounding boxes
maxX = 0; maxY = 0; minX = 100000; minY = 100000;
for i = 1:length(boundingBoxTriangles)
    maxX = max(maxX, boundingBoxTriangles(i).BoundingBox(1) + boundingBoxTriangles(i).BoundingBox(3));
    maxY = max(maxY, boundingBoxTriangles(i).BoundingBox(2) + boundingBoxTriangles(i).BoundingBox(4));
    minX = min(minX, boundingBoxTriangles(i).BoundingBox(1));
    minY = min(minY, boundingBoxTriangles(i).BoundingBox(2));
end

heigth = (maxY - minY)*0.22;
boundingBoxTriangles = [minX, minY , maxX - minX, heigth ];

rectangle('Position',boundingBoxTriangles, 'EdgeColor', 'g', 'LineWidth', 2);

triangles = imcrop(studied_area,boundingBoxTriangles);

subplot(1,2,2); imshow(triangles);title("triangles");


% Calculs des quarts de triangles
q1 = imcrop(mask, [minX,minY,maxX - minX, fix(heigth*1/4)]);
q2 = imcrop(mask, [minX,minY + fix(heigth*1/4),maxX - minX, fix(heigth*1/4)]);
q3 = imcrop(mask, [minX,minY + fix(heigth*2/4),maxX - minX, fix(heigth*1/4)]);
q4 = imcrop(mask, [minX,minY + fix(heigth*3/4),maxX - minX, fix(heigth*1/4)]);

figure;
subplot(2,2,1); imshow(q1);title("q1");
subplot(2,2,3); imshow(q2);title("q2");
subplot(2,2,2); imshow(q3);title("q3");
subplot(2,2,4); imshow(q4);title("q4");


sum1 = sum(q1(:));
sum2 = sum(q2(:));
sum3 = sum(q3(:));
sum4 = sum(q4(:));

% classification

if (sum1 > sum2)
    if (sum3 > sum4)
        result = "South";
    else
        result = "West";
    end
else
    if (sum3 > sum4)
        result = "East";
    else 
        result = "North";
    end 
end
end