%This is an obsolete script -> used when # of distance laser sensors = 3

[hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1; 1], maze, Ts);
HistoryUpdate;

while(~collision && ~goal)
    if laserHist(2,end)>2*laserHist(3,end)
        v = [1; 0];
        [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, v, maze, Ts);
        HistoryUpdate;
    elseif laserHist(3,end)>2*laserHist(2,end)
        v = [0; 1];
        [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, v, maze, Ts);
        HistoryUpdate;
    else
        v = [1; 1];
        [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, v, maze, Ts);
        HistoryUpdate;
    end
    
end