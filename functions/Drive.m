function [poseHist, laserHist, velHist, gtHist, collision, goal] = Drive(robot, dist, vel, maze, ts, is_test)
%DRIVE Driving the robot forward
%   Inputs:
%       - robot: robot structure
%       - dist: distance to be driven [1x1]
%       - vel: velocity of the robot [2x1]
%       - maze: maze coordinates {[2xn]xm}
%       - Ts: sampling time [1x1]
%       - is_test: if test, 1. 0 otherwise.
%
% Always use 'HistoryUpdate' script after running this function

if nargin < 6
    is_test = 0;
end

maxLaserRange = 30;
poseHist = [];
laserHist = [];
velHist = [];
gtHist = [];
a = robot.size(1);  % robot length
b = robot.size(2);  % robot width
collision = 0;
goal = 0;

while(dist>0 && ~collision && ~goal)
    % POSITION UPDATE AND POSITION HISTORY
    
    % update position
    robot.pose=KinUpdate(robot.pose,robot.param,ts,vel);
    % save history of the route
    poseHist=[poseHist robot.pose];
    
    % LASER HISTORY
    
    % laser pose
    laserAngleAdd = robot.laserAngles;
    
    xPose = robot.pose(1)+((a-b)/2+b/2)*cos(robot.pose(3));
    yPose = robot.pose(2)+((a-b)/2+b/2)*sin(robot.pose(3));
    
    laserPose = [];
    for i=1:length(laserAngleAdd)
        laserPose = [laserPose [xPose; yPose; robot.pose(3)+laserAngleAdd(i)]];
    end
    %         laserPoseC = [xPose; yPose; robot.pose(3)+laserAngleAdd(1)];
    %         laserPoseR = [xPose; yPose; robot.pose(3)+laserAngleAdd(2)];
    %         laserPoseL = [xPose; yPose; robot.pose(3)+laserAngleAdd(3)];
    laserPoseGoal = [xPose; yPose; atan2(robot.goal(2) - yPose, robot.goal(1) - xPose)];
    
    laserPose = [laserPose laserPoseGoal];
    bestLaserMeas = ones(length(laserPose),1)*maxLaserRange;
    
    % distance of lasers from the walls
    for k=1:length(laserPose)
        for i=1:length(maze)
            for j=1:(length(maze{i})-1 )
                
                % vertical line elimination
                if maze{i}(1,j)==maze{i}(1,j+1)
                    maze{i}(1,j) = maze{i}(1,j)+10e-10;
                end
                
                measTmp = LaserMeas(laserPose(:,k), maze{i}(:,j), maze{i}(:,j+1));
                
                if  measTmp < bestLaserMeas(k);
                    bestLaserMeas(k) = measTmp;
                end
                
            end
        end
    end
    
    if bestLaserMeas(1) < b/2 || bestLaserMeas(length(bestLaserMeas)/2) < 0.3 || bestLaserMeas(end - 1) < b/2
        collision = 1;
        %         else
        %          if(   abs(xPose-robot.goal(1))<0.6&&    abs( yPose-robot.goal(2))<0.6);
        %              collision = 1;
        %          end
    end
    
    bestLaserMeas(end) = min(bestLaserMeas(end), sqrt((laserPose(1,end)-robot.goal(1))^2 + (laserPose(2,end)-robot.goal(2))^2));
    
    laserHist = [laserHist bestLaserMeas];
    velHist = [velHist vel];
    relativeAngle = laserPoseGoal(3) - robot.pose(3); %To be consistant with other laser angles -> +: goal is on left, -: goal is on right
    if relativeAngle > pi
        relativeAngle = relativeAngle - 2*pi;
    else if relativeAngle < pi
            relativeAngle = relativeAngle + 2*pi;
    end
    gtHist = [gtHist [relativeAngle; bestLaserMeas(end) == sqrt((laserPose(1,end)-robot.goal(1))^2 + (laserPose(2,end)-robot.goal(2))^2)]];
    
    % STOPING CRITERION
    
    % goal is met when the goal is within robot.goal(3) distance away from the sensor
    dis_to_goal = sqrt((laserPose(1,end)-robot.goal(1))^2 + (laserPose(2,end)-robot.goal(2))^2);
    if is_test
        if dis_to_goal < robot.goal(3)
            goal = 1;
        end
    else
        if (dis_to_goal < 0.1)
            goal = 1;
        end
    end
    % if(   abs(xPose-robot.goal(1))<0.6&&    abs( yPose-robot.goal(2))<0.6);
    %                   goal = 1;
    %                 end
    
    % calculate distance - stoping criterion
    dist=dist-abs((vel(1)*robot.param(2)/2+vel(2)*robot.param(3)/2)*ts);
    
end

end


