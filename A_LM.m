% Calculates logarithmic mean radius for use in cylindrical heat transfer
% script

function [area] = A_LM(outerRadius, innerRadius)
    area = (2*pi*(outerRadius-innerRadius))/log(outerRadius/innerRadius);
end