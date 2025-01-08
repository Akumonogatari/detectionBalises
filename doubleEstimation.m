function [result, consistency] = doubleEstimation(image)
    % Double estimation of the beacon (triangle and color)
    % input : the image
    % output : the estimation of the beacon and a boolean that indicates if the estimation is consistent
    % If the estimations of the triangle and the color are the same, the estimation is consistent
    % Otherwise, the estimation is not consistent and the result is the two estimations
    % separated by "or". The first should be the triangle estimation and the second the color estimation

    mask = beaconMask(image);

    estiTriangle = triangleEstimation(mask, image);
    estiColor = colorEstimation(mask, image);

    if estiTriangle == estiColor
        result = estiTriangle;
        consistency = true;
    else
        result = estiTriangle + " or " + estiColor;
        consistency = false;
    end

end