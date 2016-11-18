%% Recurrent Neural Network
% EE788 ROBOT COGNITION AND PLANNING
% written by You-Min Lee, Yong-Ho Yoo @KAIST, Apr. 2015

%% Sigmoid Run %%
rng(1)
%% Load dataset
addpath(genpath('Fill')); 

%% Set option
nn.option.learningRate = 0.005; 
nn.option.maxIter = 1000; 
nn.option.numContext = 25; 
nn.option.numInput =  size(dataPer{1},1)+nn.option.numContext; 
nn.option.numOutput = size(dataPer{2},1)+nn.option.numContext; 

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


%% Train data

tic
[nn, MSE, nodes] = trainRNN(dataPer{1}', dataPer{2}', nn);
toc

%% Test data
tempData = dataPer{1}';
context = zeros(1, nn.option.numContext);
result = zeros(size(dataPer{2}'));
for step = 1:size(tempData,1)
    input = tempData(step,:);
    [output, context] = nnSingleFF(input,context,nn);
    result(step,:) = output;
end

vels = result > 0.5;

%%
result = zeros(size(data)); 
for ii = 1:size(nodes,1)
    result(ii,:) = nodes{ii,1}(1:2);     
end
result(end,:)=nodes{ii,end}(1:2);

sig_res = result;
sig_MSE = MSE;

%% Plot
figure(1)
plot(dataPer{2}(:,1),dataPer(:,2));
hold on
plot(sig_res(:,1), sig_res(:,2));
legend('Ideal', 'Sigmoid','Location','northwest')

figure(2)
plot(sig_MSE);
legend('Sigmoid')