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

%% Boite englobante de la balise
studied_area =  bsxfun(@times, image, cast(mask, 'like', image));

boundingBoxMask = regionprops(mask, 'BoundingBox');

% fusionner les boîtes englobantes
maxX = 0; maxY = 0; minX = 100000; minY = 100000;
for i = 1:length(boundingBoxMask)
    maxX = max(maxX, boundingBoxMask(i).BoundingBox(1) + boundingBoxMask(i).BoundingBox(3));
    maxY = max(maxY, boundingBoxMask(i).BoundingBox(2) + boundingBoxMask(i).BoundingBox(4));
    minX = min(minX, boundingBoxMask(i).BoundingBox(1));
    minY = min(minY, boundingBoxMask(i).BoundingBox(2));
end

boundingBoxMask = [minX, minY + 0.22*(maxY - minY), maxX - minX, (maxY - minY)*0.78];


%% Détection des boites englobantes des zones jaunes
% hsv pour détecter le jaune

ihsv = rgb2hsv(studied_area);
% isoler les couleurs jaunes / oranges
yellow_mask = (ihsv(:,:,1) > 0.05 & ihsv(:,:,1) < 0.17) & (ihsv(:,:,2) > 0.30 & ihsv(:,:,3) > 0.25);
yellow_mask = imclose(yellow_mask,strel('disk',2));

% Supprimer tous les objets avec une surface plus petite que 15% du plus grand
r = regionprops(yellow_mask, 'Area');

areas = cat(1, r.Area);
yellow = bwareaopen(yellow_mask, fix(max(areas)*0.25));

% Si il reste plus de 2 objets jaunes augmenter le seuil de suppression
r = regionprops(yellow, 'BoundingBox');
if (length(r ) > 2)
    yellow = bwareaopen(yellow_mask, fix(max(areas)*0.35));
end

figure;
subplot(1,2,1);imshow(studied_area,[]); title('Original Image');

r = regionprops(yellow, 'BoundingBox');

% Extraire les valeurs de BoundingBox
boundingBoxes = cat(1, r.BoundingBox);

% Trier par coordonnée y
[~, idx] = sort(boundingBoxes(:, 2), 'ascend');
r = r(idx);

% Afficher les boîtes englobantes en vert
for i = 1:length(r)
    rectangle('Position', r(i).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 2);
end

% Vérifier si les boîtes englobantes se chevauchent ou sont trop proches les unes des autres (regarder uniquement l'axe y)
% si c'est le cas, les fusionner

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

% afficher les boîtes englobantes
for i = 1:length(r)
    rectangle('Position', r(i).BoundingBox, 'EdgeColor', 'y', 'LineWidth', 2);
end

subplot(1,2,1);
for i = 1:length(r)
    rectangle('Position', r(i).BoundingBox, 'EdgeColor', 'y', 'LineWidth', 2);
end

%% Classification

rectangle('Position', boundingBoxMask, 'EdgeColor', 'b', 'LineWidth', 2);

% dessiner les lignes de limites

% dessiner les lignes horizontales de limites
line([0, width(image)], [boundingBoxMask(2) + (boundingBoxMask(4)/3), boundingBoxMask(2) + (boundingBoxMask(4)/3)], 'Color', 'b', 'LineWidth', 2);

line([0,width(image)], [boundingBoxMask(2) + (boundingBoxMask(4)*2/3) , boundingBoxMask(2) + (boundingBoxMask(4)*2/3)], 'Color', 'r', 'LineWidth', 2);

tiers_haut = [boundingBoxMask(2), boundingBoxMask(2) + (boundingBoxMask(4)*35/100)];
tiers_median = [boundingBoxMask(2) + (boundingBoxMask(4)*35/100) ...
                , boundingBoxMask(2) + (boundingBoxMask(4)*65/100)];
tiers_bas = [boundingBoxMask(2) + (boundingBoxMask(4)*65/100) ...
                , boundingBoxMask(2) + (boundingBoxMask(4))];

% Vérifier s'il y a 1 ou 2 zones jaunes
if (isscalar(r))
    % Vérifier si la zone jaune est en haut, en bas ou au milieu de la balise
    yellowBox = r(1).BoundingBox;

    y_inc_top = yellowBox(2);
    y_inc_bottom = yellowBox(2) + yellowBox(4);

    % Calcul de l'intersection avec chaque tiers
    proportion_haut = max(0, min(y_inc_bottom, tiers_haut(2)) - max(y_inc_top, tiers_haut(1)));
    proportion_median = max(0, min(y_inc_bottom, tiers_median(2)) - max(y_inc_top, tiers_median(1)));
    proportion_bas = max(0, min(y_inc_bottom, tiers_bas(2)) - max(y_inc_top, tiers_bas(1)));

    % Identifier le tiers principal
    [~, tier_principal] = max([proportion_haut, proportion_median, proportion_bas]);

    % Afficher les résultats
    tiers = {'South', 'East', 'North'};
    direction = tiers{tier_principal};
else
    direction = "West";
    
end

end
