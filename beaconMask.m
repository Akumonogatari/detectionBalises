function mask = beaconMask(img)
% This function takes an image as input and returns the mask with the beacon detection
% input : the image
% output : the mask of the beacon

figure;
subplot(2,2,1); imshow(img); title('Original Image');

%% Masque de couleur jaune

ihsv = rgb2hsv(img);
% isoler les couleurs jaunes / oranges
% seuils 
yellow = (ihsv(:,:,1) > 0.05 & ihsv(:,:,1) < 0.17) & (ihsv(:,:,2) > 0.25 & ihsv(:,:,3) > 0.25);

% figure; imshow(yellow, []); title('Yellow Mask');

grayImg = img(:,:,3);
grayImg(grayImg > 80) = 255;

% grayImg = imgaussfilt(grayImg, 2);

[m, n] = size(grayImg);

% thresholded = clusteredImg == min(centers);
thresholded = yellow;
thresholded_opened = imopen(thresholded, strel('disk', 3));
thresholded_opened = bwareaopen(thresholded_opened,  fix(m*n/2000) );
thresholded_opened = imclearborder(thresholded_opened);

if (sum(thresholded_opened(:)) == 0)
    thresholded_opened = thresholded;
    thresholded_opened = bwareaopen(thresholded_opened,  50 );
end

subplot(2,2,2);
imshow(yellow, []);
title('First yellow mask');


%% Seuillage du gradient sur la composante bleu
% Obtenir l'axe y de la première valeur non nulle du masque jaune
[~, col] = find(thresholded_opened, 1, 'first');
[~, col2] = find(thresholded_opened, 1, 'last');

% gradient
grad = abs(imgradient(grayImg, 'sobel'));

grad = grad > max(grad(:)) * 0.01;
grad = imclose(grad, strel('disk', 4));
grad = imopen(grad, strel('line', 3,0));

grad(:, 1:col-30) = 0;
grad(:, col2+30:end) = 0;

%% Reconstruction par dilatation
% Reconstruction par dilatation de l'image segmentée
mask = imreconstruct(thresholded_opened,grad | thresholded_opened);


%% Suppression des objets non pertinents
% Redétection des objets jaunes pour supprimer des potentiels minis objets externes (bouées, etc)
studied_area =  bsxfun(@times, img, cast(mask, 'like', img));

ihsv = rgb2hsv(studied_area);
% isoler les couleurs jaunes / oranges
yellow_mask = (ihsv(:,:,1) > 0.05 & ihsv(:,:,1) < 0.17) & (ihsv(:,:,2) > 0.20 & ihsv(:,:,3) > 0.20);

% Supprimer tous les objets avec une surface plus petite que 40% de la plus grande
r = regionprops(yellow_mask, 'Area');
areas = cat(1, r.Area);
yellow = bwareaopen(yellow_mask, fix(max(areas)*0.4));

r = regionprops(yellow, 'BoundingBox', 'Area');
if (length(r) > 1)
    boundingBoxes = cat(1, r.BoundingBox);

    % Trier par coordonnée x
    [~, idx] = sort(boundingBoxes(:, 1), 'ascend');
    r = r(idx);

    % Vérifier si les boîtes englobantes sont trop éloignées les unes des autres (regarder uniquement l'axe x)
    % si c'est le cas, supprimer la plus petite
    for i = 1:length(r)
        for j = i+1:length(r)
            if ( (r(i).BoundingBox(1) + r(i).BoundingBox(3)*3) < r(j).BoundingBox(1))
                if (r(i).Area < r(j).Area)
                    % supprimer la plus petite du jaune en utilisant la boîte englobante
                    yellow(fix(r(i).BoundingBox(2)):fix(r(i).BoundingBox(2)+r(i).BoundingBox(4)), ...
                        fix(r(i).BoundingBox(1)):fix(r(i).BoundingBox(1)+r(i).BoundingBox(3))) = 0;
                else
                    yellow(fix(r(j).BoundingBox(2)):fix(r(j).BoundingBox(2)+r(j).BoundingBox(4)), ...
                        fix(r(j).BoundingBox(1)):fix(r(j).BoundingBox(1)+r(j).BoundingBox(3))) = 0;
                end
            end
        end
    end
end

yellow_dilated = imdilate(yellow,strel("rectangle",[150,5]));

mask = imreconstruct(yellow_dilated,mask);

%% Amélioration de la détection des triangles

es_ligne = zeros(150,1);
es_ligne(1:75) = 1;

mask = imdilate(mask,es_ligne);

mask = imreconstruct(mask,grad | thresholded_opened);

subplot(2,2,3); imshow(grad, []); title('Gradient Image');
subplot(2,2,4); imshow(mask, []); title('Gradient & Segmented Image bouché');

end
