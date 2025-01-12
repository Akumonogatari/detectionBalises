%% Test d'un dossier complet et de la fonction triangleEstimation ou colorEstimation

clear;close all;clc;


direction = 'West';
folder = "dataset/"+ direction(1)  +"/";
files = dir(folder + "*.jpg");


compt = 0;
for i = 1:length(files)
    
    I = imread(strcat(folder,files(i).name));

    % disp(files(i).name);
    
    mask = beaconMask(I);
    esti = triangleEstimation(mask,I);
    disp(esti);
    if esti == string(direction)
        compt = compt + 1;
    end
end

disp(compt/length(files)*100 + "% of the images are correctly classified as "+ direction +" (" + compt + "/"+ length(files)+ ")");



%% Test MonoImage

clear;close all;clc;
img = imread('dataset/N/Y79Jt8c.jpg');

mask = beaconMask(img);

colorEstimation(mask, img)
triangleEstimation(mask, img)

%% Test par cross validation

clear;close all;clc;

img = imread('dataset/E/7F08T3Y.jpg');

[result, consistency] = doubleEstimation(img);

disp("The result is : " + result + ", with inter-algorithms consistency : " + consistency );

fprintf("\nIf the consitency is 'true' then both the algorithms got the same results else both the results are visible and the first is the triangleMethod result and the second is the colorMethod result");



%% Clearing
clear;close all;clc;