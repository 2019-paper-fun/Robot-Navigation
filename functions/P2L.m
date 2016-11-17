function [a,b] = P2L(x1,x2)
%P2L Calculates a and b coefficients on a line crossing two points
%   x1, x2 - points [2x1]
%
%   [A,B] = P2L([5;4],[4;2])


if x1(1)==x2(1)
    x2(1) = x2(1)+10e-10;
end

a = (x1(2)-x2(2))/(x1(1)-x2(1));
b = x1(2)-a*x1(1);

end

