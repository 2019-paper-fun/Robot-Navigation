%% Set option
nn.option.subset_length = 25; %In each epoch, only a small segment of each sequence is trained
nn.option.learningRate = 0.0005;
nn.option.maxIter = 100000;

nn.option.numHidden = 25;
nn.option.numInput =  size(dataPer_list{1}{1},1)+nn.option.numHidden;
nn.option.numOutput = size(dataPer_list{1}{2},1);
nn.option.netDim = [nn.option.numInput 25 nn.option.numHidden nn.option.numOutput];
% nn.option.netDim means a structure of RNN.
% The length of this variable means the number of layers.
% Each value means the number of neurons in each layer.

nn.option.activation = @sigmoid;
nn.option.dActivation = @dSigmoid;

% If you want to know how it works, search "feval" function in matlab.

%% Initialization
nn.layer = initializeNN(nn.option.netDim); %initialize the weights and biases