function [length] = calculatelength(m, resistance)
    length = 0;
    for i = 1:resistance
        length = length + m(i, 1);
    end
end
