function nn = BPTT(output, nodes, nn)

numSequence = size(output,1);
numLayer = length(nn.option.netDim)-1; %1st layer<->2nd layer, 2nd layer<->3rd layer, etc.
deltaContext = zeros(1, nn.option.numHidden); % empty array - There is no error propagating from last context nodes

deltaNN = nn.layer; % nn.layer: two weight cells -> each cell has that each layer-layer weight info

for ii = 1:numLayer
    deltaNN{ii}.W = zeros(size(nn.layer{ii}.W)); % empty arrays
    deltaNN{ii}.b = zeros(size(nn.layer{ii}.b)); % empty array
end

for ii = numSequence:-1:1 %Backpropagate from end to beginning
    for jj = numLayer:-1:1 %Same
        if jj==numLayer %each time step's weight to output layer
            dOut = feval(nn.option.dActivation, nodes{ii, end}); %derivative of activation function
            delta = nodes{ii,end}(1:size(output,2))-output(ii,:); %error d - y
            delta = dOut.*delta;  %epsilon
        elseif jj == numLayer - 1 %where recurrency resides
            dOut = feval(nn.option.dActivation, nodes{ii,jj+1}); %derivative of activation function df_l+1/dx_l+1
            delta = dOut.*(delta*nn.layer{jj+1}.W' + deltaContext); %dOut * weight = derivative df_l+1/dx_l     
        elseif jj~=numLayer %remaining layers
            dOut = feval(nn.option.dActivation, nodes{ii,jj+1}); %derivative of activation function df_l+1/dx_l+1
            delta = dOut.*(delta*nn.layer{jj+1}.W'); %dOut * weight = derivative df_l+1/dx_l
        end
        
        deltaW = nodes{ii,jj}'*delta;
        deltab = sum(delta,1);
        
        deltaNN{jj}.W = deltaNN{jj}.W - nn.option.learningRate*deltaW; %stack updates
        deltaNN{jj}.b = deltaNN{jj}.b - nn.option.learningRate*deltab; %stack updates
    end
    
    % Get the delta of context node
    deltaContext = delta*nn.layer{1}.W(end-nn.option.numHidden+1:end,:)';
end

for ii = 1:numLayer
    nn.layer{ii}.W = nn.layer{ii}.W + deltaNN{ii}.W; %update weights
    nn.layer{ii}.b = nn.layer{ii}.b + deltaNN{ii}.b; %update bias
end
end