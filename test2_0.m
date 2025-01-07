clear;close all;clc;


folder = "dataset/E/";
files = dir(folder + "*.jpg");


compt = 0;
for i = 1:length(files)
    
    img = imread(strcat(folder,files(i).name));
    
    mask = beaconMask(img);
    
    esti = colorEstimation(mask, img)
    if esti == "East"
        compt = compt + 1;
    end
end
compt



%%
clear;close all;clc;
img = imread('dataset/E/QO80o8u.jpg');

mask = beaconMask(img);

esti = colorEstimation(mask, img)