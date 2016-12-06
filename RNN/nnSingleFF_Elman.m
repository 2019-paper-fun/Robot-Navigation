function [output, context] = nnSingleFF_Elman(input, context, nn)
% A function that foward propagates one time step
% input: the input data for one time step
% context: context node values - must be 0 when time step = 1
% nn: the network of concern
%
% output: the output data for one time step
% context: the modified context node values

nodes = cell(length(nn.option.netDim),1);

nodes{1} = [input context]; %merge input and context channels

for jj = 1:length(nn.option.netDim)-1 %Propagating through layers 
    temp = nodes{jj}*nn.layer{jj}.W+nn.layer{jj}.b; %Propagate to next layer
    
    %         if (jj ~= length(nn.option.netDim) - 1) %Except Last Layer
    nodes{jj+1} = feval(nn.option.activation, temp); %Activation Function
    %         else
    %             nodes{ii,jj+1} = temp; %For output layer there is no activation function
    %         end
end

output = nodes{end}; %Get the output node values
context = nodes{end-1}(end-nn.option.numHidden+1:end); %Get the context node values

%     disp(nodes{ii,end})
%     disp(context)
%     pause

end