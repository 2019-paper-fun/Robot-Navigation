function [robot] = GenerateRandGoal( robot, maze )
%GenerateStartNGoal - Generate a random goal at the end of maze
%   robot: robot
%   maze: maze

% find a random goal position which is on the line of two points (a,b), (c,d)
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

end
