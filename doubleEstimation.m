function [result, consistency] = doubleEstimation(image)

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