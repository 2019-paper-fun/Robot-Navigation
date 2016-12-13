function layer = initializeNN(netDim)
%% initializeNN - Initialize weights and biases of network

layer = cell(numel(netDim)-1,1); 

for ii = 1:numel(layer)    
    layer{ii}.b = 2*(rand(1, netDim(ii+1))-0.5);     
    layer{ii}.W = 2*(rand(netDim(ii), netDim(ii+1))-0.5); 
end

end