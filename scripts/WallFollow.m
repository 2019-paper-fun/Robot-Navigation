[hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1; 1], maze, Ts);
HistoryUpdate;
    
    while(~collision && ~goal)

        if laserHist(3,end) < 1.5 || laserHist(1,end) < 3 
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1; 0], maze, Ts);
             HistoryUpdate;
        elseif laserHist(3,end)>2
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [0; 1], maze, Ts);
             HistoryUpdate;
        else
            [hist, lHist, vel, gHist, collision, goal] = Drive(robot, 0.1, [1; 1], maze, Ts);
             HistoryUpdate;
        end
        
    end