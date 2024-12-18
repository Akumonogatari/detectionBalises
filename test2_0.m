clear;close all;clc;


folder = "dataset/S/";
files = dir(folder + "*.jpg");


for i = 1:length(files)
    img = imread(strcat(folder,files(i).name));

    mask = beaconMask(img);

end
