%INITIALIZATION
%   robot.pose - pose of the robot [x; y; theta]
%   robot.param - robot parameters [wheels separation; wheel1 radius;
%   wheel2 radius]
%   robot.size - size of robot's body [length; width]
%   robot.laseAngles - angles of the lasers; central, right and left respectively 
%
%   maze - coordinates of points creating maze. Each row of cell array contains
%   x and y coordinates of specific wall
%
%   poseHist & laserHist left empty, expand while running Main.m

addpath('functions/');
addpath('mazeLib/');
addpath('mlp/');
addpath('scripts/');

%Number of Sensors
sensor_num = 7;

%Sensor maximum angle x (sensors are from -x ~ x)
sensor_ang = pi/2;

%initializing robot
%P=randi([-800,800], 2,1)./100;
G=randi([-900,900], 1,2)./100;
robot  = struct('pose', [9;-9; 3*pi/4] ,'param',[5; 2; 2], 'size', [1.5, 1], 'laserAngles', -sensor_ang:2*sensor_ang/(sensor_num - 1):sensor_ang, 'goal',[-7.25;7.6]);

%initializing MLP

%architecture and parameters    
mlpParam  = struct('moment', 0.5 ,'alpha', 0.5, 'eta', 0.05, 'epoch', 1000);
mlpArch = struct('inputs', sensor_num + 2, 'hidden1', 25, 'hidden2', 25, 'outputs', 2);
%weights init
wIn1Init = -0.1 + (0.1+0.1)*rand(mlpArch.inputs+1,mlpArch.hidden1);
w12Init = -0.1 + (0.1+0.1)*rand(mlpArch.hidden1+1,mlpArch.hidden2);
w2OutInit = -0.1 + (0.1+0.1)*rand(mlpArch.hidden2+1,mlpArch.outputs); 

poseHist = [];
laserHist = [];
velHist = [];
gtHist = [];

% z=8;
% h=10;
% K=randi([-7,7], 2,z);
% w=[-10 , 10, 10 ,-10,-10;-10, -10, 10,10,-10];
% 
% for i=1:z
%     
%                
%     maze{i}(1,:)=sort(randi([K(1,i)*100-200, K(1,i)*100+200], 1,2*h)./100,2, 'descend');
%     maze{i}(1,h+1:end)=sort(randi([K(1,i)*100-200, K(1,i)*100+200], 1,h)./100,2, 'ascend');
%     maze{i}(1, 2*h+1)=maze{i}(1,1);
%     maze{i}(2,:)=sort( randi([K(2,i)*100-200,100* K(2,i)+200], 1,2*h+1)./100,2,'descend');
%     maze{i}(2,h+1:2*h)=sort(randi([K(2,i)*100-200, 100*K(2,i)+200], 1,h)./100,2, 'ascend');
%     maze{i}(2, 2*h+1)=maze{i}(2,1);
% end
% maze{z+1}=w;




%initializing route history

distAndVel = {[2 1.3 2 2 0.3 2 2 2 2 2 1 2 2 2 1.5  2 2 0.5 2 2 1 1.5 2 1 2 2 1.5 0.8 3;...   % distance
               1 0   1 1 0   1 1 1 1 1 1 1 1 1 1    1 1 1   0 0 0 1   0 0 1 1 1   0   1;...   % left wheel
               1 1   1 1 1   1 1 1 0 1 1 0 0 0 1    1 1 1   1 1 1 1   1 1 1 1 1   1   1];
              
              [1.5 1 1.5 0.5 2 2 2 2 0.5 1 2 2 1.5 2 2 1 2 2 2 2 2 1.5 1 1.5 1 2 2 2 0.7 3;...
               1   0 1   0   1 1 1 1 1   1 1 1 1   1 1 1 1 1 1 0 0 0   1 0   0 1 1 1 0   1;...
               1   1 1   1   1 1 1 1 1   0 1 0 1   0 0 0 1 1 1 1 1 1   1 1   1 1 1 1 1   1];
               
              [5.5 2.5 4 1.5 2 1 1 2 1.5 4.4 6 7.7 6 0.8 4      % for maze5/ test on maze7
               1   0   1 1   1 1 1 1 1   1   1 0   1 0 1
               1   1   1 0   1 0 1 0 1   0   1 1   1 1 1];
               
              [0.7 4 0.5 2.5 0.5 2 1.5 2 3 1 3.2 4 2.5 1 7 2 3.5 2 2
               0   1   0   1   0 1   0 1 1 1   1 1   0 1 1 1   0 1 1
               1   1   1   1   1 1   1 1 0 1   0 1   1 1 0 1   1 1 0];
               
              [0.8 3 0.7 5 1 2 1 1.5 4.3 4 2.2 2  
               0   1 0   1 0 1 1 1   1   1 0   1
               1   1 1   1 1 1 0 1   0   1 1   1];
               
              [2 1 7 2.2 3 3 2.7 1 6.2 2.5 2.5
               1 0 1 1   1 0 1   1 1   1   0
               1 1 1 0   1 1 0   1 0   1   1]
               
              };     % right wheel
%other parameters
collision = 0;
goal = 0;
mode = 4;
Ts = 0.01;
