% Calculates geometric mean radius for use in spherical heat transfer
% script

function [area] = A_GM(outerRadius, innerRadius)
    area = sqrt(((4*pi)^2)*((outerRadius^2)*(innerRadius^2)));
end