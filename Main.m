%*************************************************************
% NEURO-ROBOTICS TERM PROJECT
% TITLE: Autonomous robot in a maze environment using RNN
% AUTHOR: Chansol Hong, ByungSoo Ko, and Oh Chul Kwon, implemented on Michal Kramarczyk's original work.
% DATE: Fall semester 2016, KAIST
%*************************************************************

% Instructions
% DO NOT run the whole code, use CTRL+ENTER to run consecutive subsections.
% Change parameters in the Init file.
% For changing test maze go to 'running with perceptron for different route'
% subsection and change maze name .

%% Initialization
clc;
clear all;

% Select a neural network type (1 = RNN, 2 = MLP)
nn_type = 1;
% nn_type = 2;

% Select a data collection method (1 = static route, 2 = tunnel drive, 3 =
% wall follow, 4 = mode4)
mode = 1;

% Add paths
addpath('functions/');
addpath('mazeLib/');
addpath(genpath('data'));
addpath('inits/');
addpath('scripts/');

if nn_type == 1
    addpath(genpath('RNN'));
else
    addpath('mlp/');
end

%Define strategies
strategies = {'StaticRoute' 'TunnelDrive' 'WallFollow' 'mode4'};
%StaticRoute: driving static route
%TunnelDrive: simple algorithm - tunnel driving
%WallFollow: simple algorithm - following LEFT wall
%mode4: what about making a good name?

%Number of sensors on robot
sensor_num = 7;

%Sensor angle for leftmost sensor x (rightmost sensor's angle will be -x, others will be evenly spread between two sensors)
sensor_ang = pi/2;

%Initialize the robot
InitRobot;

%Fetch the maze files
maze_files = dir('mazeLib/*.xlsx');
num_of_maze=size(maze_files,1);

%% Want some seed? %%
rng(1)

%% Iterate through maze files to get multiple dataset
count = 1; %count the number of mazes used in creating dataset
% num_of_maze = 9;
for ii=1:9 %1:num_of_maze is for using all mazes, by changing the range, selected mazes can be used.
    close all;
    %Initialize the robot
    InitRobot;
    
    %generate maze
    clear maze
    maze = GenerateMaze(maze_files(ii).name);
    
    %Record the initial laser readings
    [hist, lHist, gHist] = InitialLaserRead(robot, maze);
    vel = [0;0]; %Robot is always initially halt
    HistoryUpdate;
    
    %Run the selected strategy
    run(strategies{mode});
    
    Simulation(poseHist, laserHist, gtHist, maze, robot, collision, goal, Ts, 1);
    
    dataPer_list{count} = {[laserHist(1:end-1,:); gtHist(:,:)] velHist};
    count = count + 1;
end

% Save the dataset as a mat file
save('data/path_data/dataPer_list.mat', 'dataPer_list');

%% Train the network using RNN

% Initialize RNN
InitRNN

% dataPer_list{1} = dataPer;

% Train RNN
tic
[nn, MSE, nodes] = trainRNN(dataPer_list, nn);
toc

% Show training result
figure(2);
plot(MSE);
title('Learning curve');
xlabel('Epochs');
ylabel('MSE');

% Save the network
save('data/nn_data/trainedRNN.mat', 'nn');

%% Train the network using MLP

% Concatenate All Dataset - Only for MLP, not RNN
dataPer = cell(1,2);
for ii=1:size(dataPer_list,2)
    dataPer{1} = [dataPer{1} dataPer_list{ii}{1}];
    dataPer{2} = [dataPer{2} dataPer_list{ii}{2}];
end

% Initialize MLP
InitMLP;

% Train MLP
tic
[wIn, wHid, wOut, MSEav3] = MlpTrain(dataPer, wIn1Init, w12Init, w2OutInit, mlpParam);
toc

% Show training result
figure(2);
plot(MSEav3);
title('Learning curve');
xlabel('Epochs');
ylabel('MSE');

% Save the network
save('data/nn_data/trainedMLP.mat', 'wIn', 'wHid', 'wOut', 'MSEav3', 'mlpParam');

%% Load a trained RNN network if necessary
load('data/nn_data/trainedRNN.mat');

%% Load a trained MLP network if necessary
load('data/nn_data/trainedMLP.mat');

%% Test the trained network using RNN
maze = GenerateMaze('maze5.xlsx');

% Chansol Hong - planning to make InitRobot() function to do this easily
robot  = struct('pose', [7; -8; 3*pi/4] ,'param',[5; 2; 2], 'size', [1.5, 1], 'laserAngles', -sensor_ang:2*sensor_ang/(sensor_num - 1):sensor_ang, 'goal',[-7.25; 7.6; 0.3]);
poseHist = [];
laserHist = [];
velHist = [];
gtHist = [];
collision = 0;
goal = 0;

[hist, lHist, gHist] = InitialLaserRead(robot, maze);
vel = [0;0]; %Robot is always initially halt
HistoryUpdate;

context = zeros(1, nn.option.numContext);

check = 0;
while(~collision && ~goal)
  %     disp('Step: ')
%     disp(check)
%     disp(hist )
    check = check + 1;
    [vOut, context] = nnSingleFF([laserHist(1:end-1,end)' gtHist(:,end)'], context, nn);
    v = vOut' > 0.5;
    
    [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, v, maze, Ts, 1);
    HistoryUpdate;
end  
    
%% Test the trained network using MLP
maze = GenerateMaze('maze5.xlsx');

% Chansol Hong - planning to make InitRobot() function to do this easily
robot  = struct('pose', [7; -8; 3*pi/4] ,'param',[5; 2; 2], 'size', [1.5, 1], 'laserAngles', -sensor_ang:2*sensor_ang/(sensor_num - 1):sensor_ang, 'goal',[-7.25; 7.6; 0.3]);
poseHist = [];
laserHist = [];
velHist = [];
gtHist = [];
collision = 0;
goal = 0;

[hist, lHist, gHist] = InitialLaserRead(robot, maze);
vel = [0;0]; %Robot is always initially halt
HistoryUpdate;

while(~collision && ~goal)
    vOut = MlpRun([laserHist(1:end-1,end); gtHist(:,end)], wIn, wHid, wOut, mlpParam);
    v = round(vOut);
    
    if v == [0;0]
        if vOut(1) > vOut(2)
            v = [1;0];
        else
            v = [0;1];
        end
    end
    
    [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, v, maze, Ts, 1);
    HistoryUpdate;
    
end

%% Run a simulation using data obtained from a NN

%Simulation of the route
Simulation(poseHist, laserHist, gtHist, maze, robot, collision, goal, Ts, 1);