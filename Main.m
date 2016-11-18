%*************************************************************
% NEURO-ROBOTICS TERM PROJECT
% TITLE: Autonomous robot in a maze environment using RNN
% AUTHOR: Chansol Hong, ByungSoo Ko, and Oh Chul Kwon, implemented on Michal
% Kramarczyk's original work.
% DATE: Fall semester 2016, KAIST
%*************************************************************

% Instructions
% DO NOT run the whole code, use CTRL+ENTER to run consecutive subsections.
% Change parameters in the Init file.
% For changing test maze go to 'running with perceptron for different route'
% subsection and change maze name .

clc;
clear all;

%Define strategies
strategies = {'StaticRoute' 'TunnelDrive' 'WallFollow' 'mode4'};
%StaticRoute: driving static route
%TunnelDrive: simple algorithm - tunnel driving
%WallFollow: simple algorithm - following LEFT wall
%mode4: what about making a good name?

%Fetch the maze files
maze_files = dir('mazeLib/*.xlsx');
num_of_maze=size(maze_files,1);

%Iterate through maze files to get multiple dataset
for ii=1:num_of_maze
    close all;
    %initialization
    Init;
    
    %generate maze
    clear maze
    maze = GenerateMaze(maze_files(ii).name);
    
    %Record the initial laser readings
    [hist, lHist, gHist] = InitialLaserRead(robot, maze);
    vel = [0;0]; %Robot is always initially halt
    HistoryUpdate;
    
    %Run the selected strategy
    run(strategies{mode});
    
    %     Simulation(poseHist, laserHist, gtHist, maze, robot, collision, goal, Ts, 1);
    
    dataPer_list{ii} = {[laserHist(1:end-1,:); gtHist(:,:)] velHist};
end

% Save the dataset as a mat file
% save dataset.mat dataPer_list

%% Concatenate All Dataset - Only for MLP, not RNN
dataPer = cell(1,2);
for ii=1:size(dataPer_list,2)
    dataPer{1} = [dataPer{1} dataPer_list{ii}{1}];
    dataPer{2} = [dataPer{2} dataPer_list{ii}{2}];
end

%% Train the network
[wIn, wHid, wOut, MSEav3] = MlpTrain(dataPer, wIn1Init, w12Init, w2OutInit, mlpParam);

figure(2);
plot(MSEav3);
title('Learning curve');
xlabel('Epochs');
ylabel('MSE');

%% Test the trained network
maze = GenerateMaze('maze.xlsx');

robot  = struct('pose', [7; -8; 3*pi/4] ,'param',[5; 2; 2], 'size', [1.5, 1], 'laserAngles', -sensor_ang:2*sensor_ang/(sensor_num - 1):sensor_ang, 'goal',[-6.25;6.6]);
poseHist = [];
laserHist = [];
velHist = [];
gtHist = [];
collision = 0;
goal = 0;

[hist, lHist, gHist] = InitialLaserRead(robot, maze);
vel = [0;0]; %Robot is always initially halt
HistoryUpdate;

check = 0;
while(~collision && ~goal)
    disp('Step: ')
    disp(check)
    disp(hist )
    check = check + 1;
    vOut = MlpRun([laserHist(1:end-1,end); gtHist(:,end)], wIn, wHid, wOut, mlpParam);
    v = round(vOut);
    
    if v == [0;0]
        if vOut(1) > vOut(2)
            v = [1;0];
        else
            v = [0;1];
        end
    end
    
    [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, v, maze, Ts);
    HistoryUpdate;
    
end

%Simulation of the route
Simulation(poseHist, laserHist, gtHist, maze, robot, collision, goal, Ts, 1);