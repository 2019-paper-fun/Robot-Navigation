[hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1; 1], maze, Ts);
HistoryUpdate;
    
    while(~collision && ~goal)

        if laserHist(6,end) < 2 || laserHist(4,end) < 2
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1; 0], maze, Ts);
             HistoryUpdate;
        elseif laserHist(6,end)>2
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [0; 1], maze, Ts);
             HistoryUpdate;
        else
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1; 1], maze, Ts);
             HistoryUpdate;
        end
        
    end