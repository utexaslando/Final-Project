% defines a 2D cartesian heat profile for a given number of resistances and
% boundary conditions
%
% Input values:
%   h_2: heat transfer coefficient at the rightmost side (float)
%   bulkTemp2: Temperature of the air on the outside of the plate
%   resistances: a matrix of all resistances which contains individual 1x2
%       vectors with the thermal conductivity of the material and length of the
%       material. Expected in form: [length, thermal conductivity (k)]
%   Temp1: Starting temperature of leftmost side
%   xStep: specified x step size
%
% Output values:
%   x: x values
%   T: temp at x values
%
% The strategy to solve this will to be to:
% 1. Calculate total resistance. 
%       R = (x length)/k
%       Resistance total = Sum of resistances
% 2. Find temperature at the rightmost side. 
%       (T1-T2)/(R_T) = q
%       (T2-bulkTemp2)*h_2 = q
%       T2 = (bulkTemp2*h_2*R_T+T_1)/(h_2*R_T+1) - albegra is faster than
%       solver
% 3. Find q by plugging back into above equation
% 4. Loop through each resistance to find temperature gradient by:
%       T2 = T1-q*R_T
%       Where R_T is determined by the x given by the user and the appropriate k (thermal conductivity) and T1 is numerically derived. 
%       This will be done in a nested for loop where each resistance will have a different resistance value

function [x, T] = cartesian(h2, bulkTemp2, resistanceInfo, Temp1, xStep)

    if xStep>sum(resistanceInfo(:, 1))
        error('x Step is larger than length of resistances')
    end
    if sum(resistanceInfo(:, 1))/xStep ~= floor(sum(resistanceInfo(:, 1))./xStep)
        error('xStep does not divide into resistances')
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

    x = linspace(0, sum(resistanceInfo(:, 1)), 1+sum(resistanceInfo(:, 1))/xStep);
    T = zeros(size(x));
    T(1) = Temp1;

    % step 1
    totalResistance = 0;
    
    for resistance = 2:size(resistanceInfo, 1) % loops thru rows
        totalResistance = totalResistance + resistanceInfo(resistance, 1)/resistanceInfo(resistance, 2); 
    end
    disp("Total Resistance:")
    disp(totalResistance)

    % step 2
    % using algebra instead of solver for speed
    
    Temp2 = (bulkTemp2*h2*totalResistance+Temp1)./(h2*totalResistance+1)

    % step 3
    q = (Temp2-Temp1)./totalResistance

    % step 4

    for resistance = 2:(size(resistanceInfo, 1)) % start on the second element
    conductivity = resistanceInfo(resistance, 2);
    resistanceValue = xStep/conductivity;
    % this for loop breaks if xstep doesn't evenly divide
        for xval = 2+calculatelength(resistanceInfo, resistance-1)/xStep : 1+calculatelength(resistanceInfo, resistance)/xStep % increment by xStep
            T(xval) = T(xval-1)+q*resistanceValue;
        end
    end
end