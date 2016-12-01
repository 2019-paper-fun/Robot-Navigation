function [] = DrawMaze(maze_files, maze_id)
% A function just for visualizing maze
hold off
maze = GenerateMaze(maze_files(maze_id).name); % Fetch the map data

for i = 1:length(maze) % Draw it
    plot(maze{i}(1,:), maze{i}(2,:), 'k');
    hold on;
end

axis([ -11.5, 11.5, -11.5, 11.5]);
axis equal; grid off; ax = gca; ax.XTick = -10:1:10; ax.YTick = -10:1:10;
end