function [nn, MSE, nodes] = trainRNN(dataset, nn)
% trainNN  train neural network
% IMPORTANT: input and output are actually transposed version of dataPer!!!!

MSE = zeros(1, nn.option.maxIter);
for ii = 1:nn.option.maxIter
    disp('Iteration: ')
    disp(ii)
    index = randperm(length(dataset));       %random perm index
    for jj = 1:length(dataset)
        % Fetch data
        iput = dataset{index(jj)}{1}';
        oput = dataset{index(jj)}{2}';
        % Get a subset of data
        last = length(iput) - nn.option.subset_length + 1;
        begin = randi(last);
        
        % Trim data
        iput = iput(begin:begin+nn.option.subset_length-1,:);
        oput = oput(begin:begin+nn.option.subset_length-1,:);
        
        % Feed-forward Through Time
        nodes = FFTT(iput, nn);
        
        % Back-propagation Through Time
        nn = BPTT(oput, nodes, nn);
        
        % Get an error in current iteration.
        result = zeros(size(oput));
        for kk = 1:size(nodes,1)
            result(kk,:) = nodes{kk,end}(1:2);
        end
        
        MSE(ii) = MSE(ii) + sum((result(:)-oput(:)).^2)/size(oput,1);
    end
    MSE(ii) = MSE(ii)/length(dataset);
    disp('MSE: ')
    disp(MSE(ii))
end