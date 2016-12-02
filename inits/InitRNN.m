%% Set option
% mode 1: Jordan-like RNN
% mode 2: Jordan RNN
nn.mode = 1;

nn.option.learningRate = 0.005; 
nn.option.maxIter = 350; 
nn.option.numContext = 25; % Only used for Jordan-like RNN, Jordan type will determine # of context nodes by itself
nn.option.numInput =  size(dataPer_list{1}{1},1)+nn.option.numContext; 
nn.option.numOutput = size(dataPer_list{1}{2},1)+nn.option.numContext; 

nn.option.netDim = [nn.option.numInput 25 25 nn.option.numOutput]; 
% nn.option.netDim means a structure of RNN. 
% The length of this variable means the number of layers.
% Each value means the number of neurons in each layer.

nn.option.activation = @sigmoid; 
nn.option.dActivation = @dSigmoid; 

% You can change this option to @htan, @dHtan. 
% If you want to know how it works, search "feval" function in matlab. 

%% Initialization
nn.layer = initializeNN(nn.option.netDim); 