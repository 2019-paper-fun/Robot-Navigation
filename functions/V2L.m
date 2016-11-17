function [a,b] = V2L(x,y,alpha)
%V2L Calculates a and b coefficients on a line created by a vector
%   Inputs: x,y - vector's foothold, alpha - vectors angle from OX
%
%   [A,B] = V2L(x,y,alpha)

if wrapTo2Pi(alpha) == pi/2 || wrapTo2Pi(alpha) == 3*pi/2
    alpha = alpha+0.0000001;
end

a = tan(alpha);
b = y - a*x;

end

