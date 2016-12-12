function [] = DrawMaze(maze_files, maze_goal, maze_id)
% A function just for visualizing maze
maze = GenerateMaze(maze_files(maze_id).name); % Fetch the map data

f1 = figure();
f1.Position = [0 0 600 600];

for i = 1:length(maze) % Draw it
    plot(maze{i}(1,:), maze{i}(2,:), 'k');
    hold on;
end

% A unit circle data
cir = 1:359;
cir_x = cos(cir);
cir_y = sin(cir);

plot(0.3*cir_x + maze_goal{maze_id}(1,1), 0.3*cir_y + maze_goal{maze_id}(1,2), 'g');
for i = 2:3
    plot(0.3*cir_x + maze_goal{maze_id}(i,1), 0.3*cir_y + maze_goal{maze_id}(i,2), 'b');
end

plot(9+0.5*cir_x, -9+0.5*cir_y, 'color', [1 0.5 0]);

axis([ -11.5, 11.5, -11.5, 11.5]);
axis equal; grid off; ax = gca; ax.XTick = -10:1:10; ax.YTick = -10:1:10;
title(sprintf('Maze %d', maze_id), 'fontsize', 17);

end