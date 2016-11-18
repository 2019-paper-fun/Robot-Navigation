function  dY = dSigmoid(Y)
% derivative of sigmoid function
% !! Y is not scalar.

% Y is output of Sigmoid, not input
dY = Y.*(1-Y); % derivative of sigmoid is sigmoid*(1-sigmoid)

end

