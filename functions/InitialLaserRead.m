function [poseHist, laserHist, gtHist] = InitialLaserRead(robot, maze)
%Obtain the initial laser readings
%   Inputs:
%       - robot: robot structure
%       - maze: maze coordinates {[2xn]xm}
%
% Always use 'HistoryUpdate' script after running this function

maxLaserRange = 30;
a = robot.size(1);  % robot length
b = robot.size(2);  % robot width

% laser pose
laserAngleAdd = robot.laserAngles;

xPose = robot.pose(1)+((a-b)/2+b/2)*cos(robot.pose(3));
yPose = robot.pose(2)+((a-b)/2+b/2)*sin(robot.pose(3));

poseHist = robot.pose; %The robot does not move initially
laserPose = [];
for i=1:length(laserAngleAdd)
    laserPose = [laserPose [xPose; yPose; robot.pose(3)+laserAngleAdd(i)]];
end
% laserPoseC = [xPose; yPose; robot.pose(3)+laserAngleAdd(1)];
% laserPoseR = [xPose; yPose; robot.pose(3)+laserAngleAdd(2)];
% laserPoseL = [xPose; yPose; robot.pose(3)+laserAngleAdd(3)];
laserPoseGoal = [xPose; yPose; atan2(robot.goal(2) - yPose, robot.goal(1) - xPose)];

laserPose = [laserPose laserPoseGoal];
laserHist = ones(length(laserPose),1)*maxLaserRange;

% distance of lasers from the walls
for k=1:length(laserPose)
    for i=1:length(maze)
        for j=1:(length(maze{i})-1 )
            
            % vertical line elimination
            if maze{i}(1,j)==maze{i}(1,j+1)
                maze{i}(1,j) = maze{i}(1,j)+10e-10;
            end
            
            measTmp = LaserMeas(laserPose(:,k), maze{i}(:,j), maze{i}(:,j+1));
            
            if  measTmp < laserHist(k);
                laserHist(k) = measTmp;
            end
            
        end
    end
end

gtHist = [laserPoseGoal(3); laserHist(end) == sqrt((laserPose(1,end)-robot.goal(1))^2 + (laserPose(2,end)-robot.goal(2))^2)];

laserHist(end) = min(laserHist(end), sqrt((laserPose(1,end)-robot.goal(1))^2 + (laserPose(2,end)-robot.goal(2))^2));