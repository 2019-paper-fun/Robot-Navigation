function  dY = dHtan(Y)
% derivative of tanh function
% Y is not scalar. 

% Y is output of htan, not input
dY = 1 - Y.^2; % derivative of tanh is 1 - tanh^2
end

