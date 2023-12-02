% defines a 2D cylindrical heat profile for a given number of resistances and
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
% Note that this geometry makes input variables different than cartesian, as a solid
% center does not hold physical reality. As a result, arrays will be
% indexed starting at the third value such that there is empty space inside
% the middle of the sphere, and the boundary condition for temperature
% starts at the first wall. 
% The strategy to solve this will to be to:
% 1. Calculate total resistance. 
%       R = (x length)/(k*A_LM)
%       A_LM = pi*(outerRadius^2-innerRadius^2))/ln((outerRadius^2)/(innerRadius^2));
%       Resistance total = Sum of resistances
% 2. Find temperature at the outermost side. 
%       (T2-T1)/(R_T) = q
%       (bulkTemp2-T2)*h_2*(A_o) = q
%       T2 = (bulkTemp2*h_2*R_T*A_o+T_1)/(A_o*h_2*R_T+1) - albegra is faster than
%       solver
%       Note that:
%           A_o = 2*pi*R_i
% 3. Find q by plugging back into above equation
% 4. Loop through each resistance to find temperature gradient by:
%       T2 = T1-q*R
%       Where R is determined by the x given by the user and the appropriate k (thermal conductivity) and T1 is numerically derived. 
%       This will be done in a nested for loop where each resistance will have a different resistance value

function [x, T] = cylindrical(h2, bulkTemp2, resistanceInfo, Temp1, xStep)

    x = linspace(0, sum(resistanceInfo(:, 1)), 1+sum(resistanceInfo(:, 1))/xStep);
    T = zeros(size(x));
    T(1:(2+resistanceInfo(2, 1)/xStep)) = Temp1;
    T(1) = Temp1;

    % step 1
    totalResistance = 0;
    
    for resistance = 3:size(resistanceInfo, 1) % loops thru rows starting at the third element
        r_o = calculatelength(resistanceInfo, resistance);
        r_i = calculatelength(resistanceInfo, resistance-1);
        totalResistance = totalResistance + resistanceInfo(resistance, 1)/(A_LM(r_o, r_i) * resistanceInfo(resistance, 2)); 
    end
    disp("Total Resistance:")
    disp(totalResistance)

    % step 2
    % using algebra instead of solver for speed
    A_O = 2*pi*sum(resistanceInfo(:, 1));
    Temp2 = (bulkTemp2*h2*totalResistance*A_O+Temp1)./(h2*totalResistance*A_O+1);

    % step 3
    q = (Temp2-Temp1)./totalResistance

    % step 4

    for resistance = 3:(size(resistanceInfo, 1)) % start on the third element, second element k should be zero
    conductivity = resistanceInfo(resistance, 2);
    % this for loop breaks if xstep doesn't evenly divide
        for xval = 2+calculatelength(resistanceInfo, resistance-1)/xStep : 1+calculatelength(resistanceInfo, resistance)/xStep % increment by xStep
            r_o = xval*xStep;
            r_i = (xval-1)*xStep;
            resistanceValue = xStep/(conductivity*A_LM(r_o, r_i));
            T(xval) = T(xval-1)+q*resistanceValue;
        end
    end
end