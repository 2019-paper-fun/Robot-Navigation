%INITIALIZATION
%   robot.pose - pose of the robot [x; y; theta]
%   robot.param - robot parameters [wheels separation; wheel1 radius; wheel2 radius]
%   robot.size - size of robot's body [length; width]
%   robot.laseAngles - angles of the lasers; [rightmost to leftmost]
%   robot.goal = the goal! [x, y, goal radius]

%initialize robot
G=randi([-900,900], 1,2)./100;
robot  = struct('pose', [9;-9; 3*pi/4] ,'param',[5; 2; 2], 'size', [1.5, 1], 'laserAngles', -sensor_ang:2*sensor_ang/(sensor_num - 1):sensor_ang, 'goal',[-7.25; 7.6; 0.3]);

%initialize history
poseHist = [];
laserHist = [];
velHist = [];
gtHist = [];
          
%other parameters
collision = 0;
goal = 0;
Ts = 0.01;
