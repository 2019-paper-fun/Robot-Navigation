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

% Timestep
Ts = 0.01;

% Select a data collection method (1 = static route, 2 = tunnel drive, 3 =
% wall follow, 4 = mode4)
mode = 4;

% Add paths
addpath('functions/');
addpath('mazeLib/');
addpath(genpath('data'));
addpath('inits/');
addpath('scripts/');
addpath(genpath('RNN/')); % RNN path
addpath('mlp/'); % mlp path

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

%Fetch the maze files
maze_files = dir('mazeLib/*.xlsx');
num_of_maze=size(maze_files,1);

%% Iterate through maze files to get multiple dataset
% How many iterations per run?
iterations = 900 %num_of_maze;

% Load the dataset from a mat file
load('data/path_data/dataPer_list.mat');
%dataPer_list = {};
maze_history = zeros(1,num_of_maze);

% Copy the original
temp_list = dataPer_list;

count = length(temp_list); % Count the number of data exist in the dataset

dataPer_list = cell(1, count + iterations);
for iter = 1:count
    dataPer_list{iter} = temp_list{iter}; % Copy back the original data
end

count = count + 1; % Increment the pointer for cell

for ii=1:iterations
    success = 0;
    while (success ~= 1) % Force the program to collect data until a successful path is made
        fprintf('Iteration %d: Trying to gather Data #%d\n', ii, count);
        close all;
        %Initialize the robot
        InitRobot;
        
        %generate maze
        clear maze
        
        maze_number = 3 %rem(ii,num_of_maze) + 1; %randi(num_of_maze); % randomly select a map
        
        maze = GenerateMaze(maze_files(maze_number).name);
        fprintf('Gather data in %s\n', maze_files(maze_number).name);

        robot = GenerateRandGoal(robot,maze); % find the random goal position       

        %Record the initial laser readings
        [hist, lHist, gHist] = InitialLaserRead(robot, maze);
        vel = [0;0]; %Robot is always initially halt
        HistoryUpdate;
        
        %Run the selected strategy
        run(strategies{mode});
        
        if (goal)
            disp('Goal Reached')
            %SaveFigure(poseHist, laserHist, gtHist, maze, robot, collision, goal, 1, strcat('data',num2str(count))); %Save the figure
            maze_history(maze_number) = maze_history(maze_number) + 1;
            dataPer_list{count} = {[laserHist(1:end-1,:); gtHist(:,:)] velHist};
            count = count + 1;
            success = 1;
        else
            disp('Collision!')
            %         Simulation(poseHist, laserHist, gtHist, maze, robot, collision, goal, Ts, 1);
            %         pause;
        end
    end
end

% Remove empty cells due to failure
dataPer_list = dataPer_list(1,1:count-1);

% Save the dataset as a mat file
save('data/path_data/bsk/dataPer_maze3.mat', 'dataPer_list', 'maze_history');

%% Special Function to Save a Backup! %%
xxxxxxxxxx
save('data/path_data/dataPer_list_backup.mat', 'dataPer_list', 'maze_history');
xxxxxxxxxx

%% Train the network using RNN

% Load the dataset from a mat file
load('data/path_data/bsk/dataPer_maze3.mat');

% Transform the dataset so that laser nodes are not much greather than goal nodes
for i = 1:length(dataPer_list)
    dataPer_list{i}{1}(1:7,:) = dataPer_list{i}{1}(1:7,:)/30; %Lasers [0 30] -> [0 2]
    dataPer_list{i}{1}(8,:) = dataPer_list{i}{1}(8,:)/(2*pi) + 0.5; %Goal angle [-pi pi] -> [0 1]
end

% Initialize RNN
InitRNN

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
save('data/nn_data/bsk/JRNN_maze3_iter1000.mat', 'nn');

%% Train the network using MLP

% Load the dataset from a mat file
load('data/path_data/dataPer_list.mat');

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

goalReached = 0; % The number of time the robot reached to the goal
iterations = 10; % The number of time to test
for ii=1:iterations
    disp('iterations: ')
    disp(ii)
    maze = GenerateMaze('maze01.xlsx');

    InitRobot
    robot = GenerateRandGoal(robot,maze) % find the random goal position

    [hist, lHist, gHist] = InitialLaserRead(robot, maze);
    vel = [0;0]; %Robot is always initially halt
    HistoryUpdate;

    context = zeros(1, nn.option.numContext);

    check = 0;
    while(~collision && ~goal)
        vect = [laserHist(1:end-1,end)' gtHist(:,end)'];
        vect(1:7) = vect(1:7)/30;
        vect(8) = vect(8)/(2*pi) + 0.5;
        [vOut, context] = nnSingleFF(vect, context, nn);
        v = round(vOut');

        if sum(v) == 0
            if vOut(1) > vOut(2)
                v = [1;0];
            else
                v = [0;1];
            end
        end

        [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, v, maze, Ts, 1);
        HistoryUpdate;
    end

    if goal == 1
        goalReached =+ 1;
        disp('goal reached!')
    else
        disp('collision!')
    end
end

sprintf('Reached goal %d times out of %d', goalReached, iterations)
%Simulation of the route
% Simulation(poseHist, laserHist, gtHist, maze, robot, collision, goal, Ts, 1);

%% Save the simulation result if you want
SaveFigure(poseHist, laserHist, gtHist, maze, robot, collision, goal, 1, 'result');

%% Test the trained network using MLP

goalReached = 0; % The number of time the robot reached to the goal
iterations = 10; % The number of time to test
for ii=1:iterations
    disp('iterations: ')
    disp(ii)
    maze = GenerateMaze('maze02.xlsx');

    InitRobot
    robot = GenerateRandGoal(robot,maze) % find the random goal position.

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

    if goal == 1
        goalReached =+ 1;
        disp('goal reached!')
    else
        disp('collision!')
    end
end
sprintf('Reached goal %d times out of %d', goalReached, iterations)
%% Run a simulation using data obtained from a NN

%Simulation of the route
Simulation(poseHist, laserHist, gtHist, maze, robot, collision, goal, Ts, 1);