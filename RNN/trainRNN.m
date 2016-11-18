function [nn, MSE, nodes] = trainRNN(input, output, nn)
% trainNN  train neural network
% IMPORTANT: input and output are actually transposed version of dataPer!!!!

MSE = zeros(1, nn.option.maxIter); 
for ii = 1:nn.option.maxIter 
    disp('Iteration: ')
    disp(ii)
    % Feed-forward Through Time
    nodes = nnFFTT(input, nn);
    
    % Back-propagation Through Time
    nn = nnBPTT(output, nodes, nn);
    
    % Get an error in current iteration.
    result = zeros(size(output)); 
    for jj = 1:size(nodes,1)
        result(jj,:) = nodes{jj,end}(1:2);         
    end
    
    MSE(ii) = sum((result(:)-output(:)).^2)/size(output,1);
    
end

end