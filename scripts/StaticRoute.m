%for j=1:length(distAndVel) 

    for i=1:size(distAndVel{j},2)
            if (~collision && ~goal)
                [hist, lHist, vel, gHist, collision, goal] = Drive(robot, distAndVel{j}(1,i), distAndVel{j}(2:3,i), maze, Ts);
                HistoryUpdate;
            end
    end
    
%end