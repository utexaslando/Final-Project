% This script defines a function called heatprofile, where one can input a
% number or resistances and boundary conditions along with a desired
% geometry to get a steady state 2D heat profile.
%
% Input values:
%   h_2: heat transfer coefficient at the rightmost side (float)
%   bulkTemp2: Temperature of the air on the outside of the plate
%   resistances: a matrix of all resistances which contains individual 1x2
%       vectors with the thermal conductivity of the material and length of the
%       material. Expected in form: [length, thermal conductivity (k)]
%   Temp1: Starting temperature of leftmost side
%   xStep: specified x step size
%   geometry: expects a string with desired geometry. Can handle cartesian, spherical, and
%   cylindrical. 

function [] = heatprofile(h2, bulkTemp2, resistanceInfo, Temp1, xStep, geometry)

    if xStep>sum(resistanceInfo(:, 1))
        error('x Step is larger than length of resistances')
    end
    if h2<0
        error('h2 is negative')
    elseif bulkTemp2<0
        error('Bulk temp 2 is negative')
    elseif Temp1<0
        error('Temp 2 is negative')
    elseif xStep<=0
        error('X Step is negative')
    end

    for resistance = 2:size(resistanceInfo, 1)
        if mod(resistanceInfo(resistance, 1), xStep) ~= 0
            error('xStep must divide into every resistance!')
        end
    end

    figure

    if strcmp(geometry, 'cartesian')
        [x, T] = cartesian(h2, bulkTemp2, resistanceInfo, Temp1, xStep);
        plot(x, T)
        title('Cartesian Heat Profile')
    elseif strcmp(geometry, 'spherical')
        [x, T] = spherical(h2, bulkTemp2, resistanceInfo, Temp1, xStep);
        plot(x, T)
        title('Spherical Heat Profile')
    elseif strcmp(geometry, 'cylindrical')
        [x, T] = cylindrical(h2, bulkTemp2, resistanceInfo, Temp1, xStep);
        plot(x, T)
        title('Spherical Heat Profile')
    else
        error('Invalid geometry! Please input "cartesian", "spherical", or "cylindrical"')
    end


    xlabel('X Coordinate')
    ylabel('Temperature')

end