function nn = nnBPTT(output, nodes, nn)

numSequence = size(output,1)-1;
numLayer = length(nn.option.netDim)-1; %1st layer<->2nd layer, 2nd layer<->3rd layer
deltaContext = zeros(1, nn.option.numContext); % empty array - There is no error propagating from context nodes

deltaNN = nn.layer; % nn.layer: two weight cells -> each cell has that each layer-layer weight info

% disp('BPTT begins')
% disp('Current Node data!')
% disp(nodes{1})
% disp(nodes{2})
% disp(nodes{3})

for ii = 1:numLayer
    deltaNN{ii}.W = zeros(size(nn.layer{ii}.W)); % empty arrays
    deltaNN{ii}.b = zeros(size(nn.layer{ii}.b)); % empty array
end

for ii = numSequence:-1:1 %Backpropagate from end to beginning
    %     disp('seq')
    %     disp(ii);
    for jj = numLayer:-1:1 %Same
        %         disp('layer')
        %         disp(jj);
        if jj==numLayer %each time step's weight to output layer
            dOut = feval(nn.option.dActivation, nodes{ii, end}(1:2)); %derivative of activation function
            delta = [nodes{ii,end}(1:size(output,2))-output(ii,:) deltaContext]; %error d - y
            delta = [dOut ones(1,nn.option.numContext)].*delta;  %epsilon
            %             delta = [nodes{ii,end}(1:size(output,2))-output(ii,:) deltaContext]; %error signal epsilon at output node, 1 x (output size + context size)
        elseif jj~=numLayer %remaining layers
            dOut = feval(nn.option.dActivation, nodes{ii,jj+1}); %derivative of activation function df_l+1/dx_l+1
            delta = dOut.*(delta*nn.layer{jj+1}.W'); %dOut * weight = derivative df_l+1/dx_l
        end
        
        %          disp('epsilon')
        %          disp(delta)
        
        deltaW = nodes{ii,jj}'*delta;
        deltab = sum(delta,1);
        
        deltaNN{jj}.W = deltaNN{jj}.W - nn.option.learningRate*deltaW;
        deltaNN{jj}.b = deltaNN{jj}.b - nn.option.learningRate*deltab;
        
        %         disp('weight update')
        %         disp(deltaNN{jj}.W)
        %         disp('bias update')
        %         disp(deltaNN{jj}.b)
    end
    
    % Calculate deltaContext
    dOut = feval(nn.option.dActivation, nodes{ii,1});
    delta = dOut.*(delta*nn.layer{1}.W');
    deltaContext = delta(end-nn.option.numContext+1:end);
end

for ii = 1:numLayer
    nn.layer{ii}.W = nn.layer{ii}.W + deltaNN{ii}.W;
    nn.layer{ii}.b = nn.layer{ii}.b + deltaNN{ii}.b;
end

% disp('BPTT ends')
% pause

end