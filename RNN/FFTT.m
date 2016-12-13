function nodes = FFTT(input, nn)

numSequence = size(input,1); %data length
nodes = cell(numSequence, length(nn.option.netDim)); %expanded network
context = rand(1, nn.option.numHidden); %initial context node values

for ii = 1:numSequence
    nodes{ii,1} = [input(ii, :) context]; %First layer values are fed from true values
    for jj = 1:length(nn.option.netDim)-1 %Propagating through layers in one sequence
        temp = nodes{ii,jj}*nn.layer{jj}.W+nn.layer{jj}.b; %Propagate to next layer
        nodes{ii,jj+1} = feval(nn.option.activation, temp); %Activation Function
    end
    context = nodes{ii,end - 1}(end-nn.option.numHidden+1:end); %Get the context node - To be used as next seq's input node
end
end