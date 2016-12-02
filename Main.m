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

% Select a neural network type (1 = RNN, 2 = MLP)
nn_type = 1;
% nn_type = 2;

% Select a data collection method (1 = static route, 2 = tunnel drive, 3 =
% wall follow, 4 = mode4)
mode = 4;

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

%Fetch the maze files
maze_files = dir('mazeLib/*.xlsx');
num_of_maze=size(maze_files,1);

%% Iterate through maze files to get multiple dataset
% How many iterations per run?
iterations = 13;

% Load the dataset from a mat file
load('data/path_data/dataPer_list.mat');
% dataPer_list = {};
% maze_history = zeros(1,num_of_maze);

% Copy the original
temp_list = dataPer_list;

count = length(temp_list); % Count the number of data exist in the dataset

dataPer_list = cell(1, count + iterations);
for iter = 1:count
    dataPer_list{iter} = temp_list{iter}; % Copy back the original data
end

count = count + 1; % Increment the pointer for cell

for ii=1:iterations
    fprintf('Iteration %d: Trying to gather Data #%d\n', ii, count);
    close all;
    %Initialize the robot
    InitRobot;
    
    %generate maze
    clear maze
    
    maze_number = randi(num_of_maze); % randomly select a map
    
    maze = GenerateMaze(maze_files(maze_number).name);
    fprintf('Gather data in %s\n', maze_files(maze_number).name);
    
    % find the random goal position which is on the line of two points (a,b), (c,d)
    wall_detector = -pi+0.01:2*pi/360:pi;
    ok = 0;
    while (~ok) % try to find a goal position that is reachable
        ag = maze{1}(1,length(maze{1})-1);
        bg = maze{1}(2,length(maze{1})-1);
        cg = maze{2}(1,length(maze{2})-1);
        dg = maze{2}(2,length(maze{2})-1);
        
        robot.goal(1) = ag+(cg-ag)*rand(1,1); % to make the goal far away from wall
        robot.goal(2) = ((bg-dg)/(ag-cg))*(robot.goal(1)-ag)+bg;
        
        % detect a wall closest to the goal
        min_dist = 100; % a large number
        for k=1:length(wall_detector)
            for i=1:length(maze)
                for j=1:(length(maze{i})-1)
                    % vertical line elimination
                    if maze{i}(1,j)==maze{i}(1,j+1)
                        maze{i}(1,j) = maze{i}(1,j)+10e-10;
                    end
                    measTmp = LaserMeas([robot.goal(1); robot.goal(2); wall_detector(k)], maze{i}(:,j), maze{i}(:,j+1));
                    if  measTmp < min_dist
                        min_dist = measTmp;
                    end
                end
            end
        end
        
        % if closest wall is far enough, you can pass
        if (min_dist > 1.5*robot.size(2)/2)
            ok = 1;
        end
    end
    
    %Record the initial laser readings
    [hist, lHist, gHist] = InitialLaserRead(robot, maze);
    vel = [0;0]; %Robot is always initially halt
    HistoryUpdate;
    
    %Run the selected strategy
    run(strategies{mode});
    
    if (goal)
        disp('Goal Reached')
        maze_history(maze_number) = maze_history(maze_number) + 1;
        dataPer_list{count} = {[laserHist(1:end-1,:); gtHist(:,:)] velHist};
        count = count + 1;
    else
        disp('Collision!')
        %         Simulation(poseHist, laserHist, gtHist, maze, robot, collision, goal, Ts, 1);
        %         pause;
    end
    
end

% Remove empty cells due to failure
dataPer_list = dataPer_list(1,1:count-1);

% Save the dataset as a mat file
save('data/path_data/dataPer_list.mat', 'dataPer_list', 'maze_history');

%% Special Function to Save a Backup! %%
xxxxxxxxxx
save('data/path_data/dataPer_list_backup.mat', 'dataPer_list', 'maze_history');
xxxxxxxxxx

%% Train the network using RNN

% Load the dataset from a mat file
load('data/path_data/dataPer_list.mat');

% Transform the dataset so that laser nodes are not much greather than goal nodes
for i = 1:length(dataPer_list)
    dataPer_list{i}{1}(1:7,:) = dataPer_list{i}{1}(1:7,:)/30; %Lasers [0 30] -> [0 1]
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
save('data/nn_data/trainedRNN.mat', 'nn');

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
maze = GenerateMaze('maze13.xlsx');

% Chansol Hong - planning to make InitRobot() function to do this easily
InitRobot

% find the random goal position which is on the line of two points (a,b), (c,d)
wall_detector = -pi+0.01:2*pi/360:pi;
ok = 0;
while (~ok) % try to find a goal position that is reachable
    ag = maze{1}(1,length(maze{1})-1);
    bg = maze{1}(2,length(maze{1})-1);
    cg = maze{2}(1,length(maze{2})-1);
    dg = maze{2}(2,length(maze{2})-1);
    
    robot.goal(1) = ag+(cg-ag)*rand(1,1); % to make the goal far away from wall
    robot.goal(2) = ((bg-dg)/(ag-cg))*(robot.goal(1)-ag)+bg;
    
    % detect a wall closest to the goal
    min_dist = 100; % a large number
    for k=1:length(wall_detector)
        for i=1:length(maze)
            for j=1:(length(maze{i})-1)
                % vertical line elimination
                if maze{i}(1,j)==maze{i}(1,j+1)
                    maze{i}(1,j) = maze{i}(1,j)+10e-10;
                end
                measTmp = LaserMeas([robot.goal(1); robot.goal(2); wall_detector(k)], maze{i}(:,j), maze{i}(:,j+1));
                if  measTmp < min_dist
                    min_dist = measTmp;
                end
            end
        end
    end
    
    % if closest wall is far enough, you can pass
    if (min_dist > 1.5*robot.size(2)/2)
        ok = 1;
        disp('Good')
    end
end

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

%Simulation of the route
Simulation(poseHist, laserHist, gtHist, maze, robot, collision, goal, Ts, 1);

%% Test the trained network using MLP
maze = GenerateMaze('maze2.xlsx');

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