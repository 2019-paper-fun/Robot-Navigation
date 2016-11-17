function [x,y] = LineCross(l1, l2)
%LINECROSS Returns x and y coordinate of the point where lines cross
%   l1, l2 - vector of a and b values [2x1]
%
%   [X,Y] = LINECROSS([a1; b1],[a2; b2])

a1 = l1(1); b1 = l1(2);
a2 = l2(1); b2 = l2(2);

x = -(b1-b2)/(a1-a2);
y = a1*x+b1;

end

