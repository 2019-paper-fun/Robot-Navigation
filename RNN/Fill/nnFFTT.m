function nodes = nnFFTT(input, nn)

numSequence = size(input,1); %data length
nodes = cell(numSequence, length(nn.option.netDim)); %expanded network
context = zeros(1, nn.option.numContext); %initial context node values
% disp('A call of nnFF')
for ii = 1:numSequence
    %     disp('seq')
    %     disp(ii)
    nodes{ii,1} = [input(ii, :) context]; %First layer values are fed from true values
    %     disp(nodes{ii,1})
    
    for jj = 1:length(nn.option.netDim)-1 %Propagating through layers in one sequence
        %         disp('layer')
        %         disp(jj)
        temp = nodes{ii,jj}*nn.layer{jj}.W+nn.layer{jj}.b; %Propagate to next layer
        %         if (jj ~= length(nn.option.netDim) - 1) %Except Last Layer
        nodes{ii,jj+1} = feval(nn.option.activation, temp); %Activation Function
        %         else
        %             nodes{ii,jj+1} = temp; %For output layer there is no activation function
        %         end
    end
    
    %     disp(nodes{ii,1})
    %     disp(nodes{ii,2})
    %     disp(nodes{ii,3})
    %     pause()
    
    context = nodes{ii,end}(end-nn.option.numContext+1:end); %Get the context node output value - To be used as next seq's input node
    
    %     disp(nodes{ii,end})
    %     disp(context)
    %     pause
    
end
% disp('End of nnFF')

end