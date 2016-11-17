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
 d = dir('mazeLib/*.xlsx');
 H=size(d,1);
for W=1:H

close all;    
%initialization
Init;

% make subsection

%driving static route
if mode == 1
    j = 3;
    StaticRoute;    

end

%simple algorithm - tunnel driving
if mode==2   
    TunnelDrive;
end

%simple algorithm - following right wall
if mode==3     
    WallFollow;
end

if mode==4     
    mode4;
end

Simulation(poseHist, laserHist, gtHist, maze, robot, collision, goal, Ts, 1);
%%
%training the perceptron

dataPer1{W} = {[laserHist(1:end-1,:); gtHist(:,:)] velHist};
%save dataPer{H}
end
for B=1:H
    
    if B==1
dataPer=dataPer1{1};
    
    
    else
        
      C=[dataPer{1,1}(:,:)      dataPer1{1,B}{1,1}(:,:)     ];
        
        D=[dataPer{1,2}(:,:)     dataPer1{1,B}{1,2}(:,:)       ];
          clear dataPer
          dataPer={C D};
          
        clear C;
        clear D;
    end
end

[wIn, wHid, wOut, MSEav3] = MlpTrain(dataPer, wIn1Init, w12Init, w2OutInit, mlpParam);

figure(2);
plot(MSEav3);   
title('Learning curve');
xlabel('Epochs');
ylabel('MSE');

%% running with perceptron for different route
maze = GenerateMaze('maze6.xlsx');

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