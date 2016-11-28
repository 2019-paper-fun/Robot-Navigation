a = robot.size(1);  % robot length
b = robot.size(2);  % robot width
[hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1; 1], maze, Ts); % go front at the initial pose
HistoryUpdate;

while(~collision && ~goal)
    
    xPose = robot.pose(1)+((a-b)/2+b/2)*cos(robot.pose(3));
    yPose = robot.pose(2)+((a-b)/2+b/2)*sin(robot.pose(3));

    if(gtHist(2,end)==0) % goal is invisible
        if laserHist(4, end)<4
            if( laserHist(5,end) <laserHist(3,end))
                [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1; 0], maze, Ts);
                HistoryUpdate;
                
            else
                [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [0; 1], maze, Ts);
                HistoryUpdate;
            end
            
        elseif laserHist(6,end)<2.3
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1; 0], maze, Ts);
            HistoryUpdate;
            
        elseif laserHist(2,end)<2.3
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [0; 1], maze, Ts);
            HistoryUpdate;
            
        elseif laserHist(7,end)<2.1
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1; 0], maze, Ts);
            HistoryUpdate;
            
        elseif laserHist(1,end)<2.1
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [0; 1], maze, Ts);
            HistoryUpdate;
            
        else
            
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [0.5; 0.5], maze, Ts);
            HistoryUpdate;
            
        end
        
        
    elseif(gtHist(2,end)==1)
        
        if laserHist(5,end)<1.4
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1; 0], maze, Ts);
            HistoryUpdate;
            
        elseif laserHist(3,end)<1.4
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [0; 1], maze, Ts);
            HistoryUpdate;
            
        elseif laserHist(6,end)<1
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1; 0], maze, Ts);
            HistoryUpdate;
            
        elseif laserHist(2,end)<1
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [0; 1], maze, Ts);
            HistoryUpdate;
            
        elseif laserHist(7,end)<0.9
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1; 0], maze, Ts);
            HistoryUpdate;
            
        elseif laserHist(1,end)<0.9
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [0; 1], maze, Ts);
            HistoryUpdate;
            
        else % if there is no obstacle on the front
            
            
            relativeAngle = atan2(robot.goal(2) - yPose, robot.goal(1) - xPose) - robot.pose(3); %To be consistant with other laser angles -> +: goal is on left, -: goal is on right
            if relativeAngle > pi
                relativeAngle = relativeAngle - 2*pi;
            elseif relativeAngle < -pi
                relativeAngle = relativeAngle + 2*pi;
            end
            
            if     relativeAngle<0
                [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1;0], maze, Ts);
                HistoryUpdate;
                
            elseif relativeAngle>0%go left
                [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [0; 1], maze, Ts);
                HistoryUpdate;
                
            elseif relativeAngle==0 % go front
                [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1; 1], maze, Ts);
                HistoryUpdate;
                
            end
        end
    end
    
    
end