function [] = SaveFigure(pose, laserHist, gtHist, maze, robot, collision, goal, plotRoute, path)
%SIMULATION Real-time simulation plotting
%   pose - history of all poses of the robot
%   laserHist - all laser measurements
%   gtHist - ?
%   maze - maze drawing coordinates
%   robot - robot structure
%   collision - collision flag
%   plotRoute - set 1 to plot the route of the robot
%   path - to where this figure is saved

savepath = strcat('data/path_data/figures/', path, '.png');

if nargin < 7 % what is nargin? Number of Arguments in Input - default parameter similar to argc in C
    plotRoute = 0;
end

f1 = figure();
f1.Position = [50 200 650 750];

% A unit circle data
cir = 1:359;
cir_x = cos(cir);
cir_y = sin(cir);


%plotting environment
for i = 1:length(maze)
    plot(maze{i}(1,:), maze{i}(2,:), 'k');
    hold on;
end

%plotting route
if plotRoute
    plot(pose(1,:),pose(2,:));
end

%plot the goal
plot(robot.goal(3)*cir_x + robot.goal(1),robot.goal(3)*cir_y + robot.goal(2),'g');
%plotting robot body
a = robot.size(1);    % robot length
b = robot.size(2);    % robot width

theta = pose(3,end) + pi/4;
robotBody = [pose(1,end)+(sqrt(2)*b/2)*cos(theta)+((a-b)/2)*cos(pose(3,end)) pose(1,end)+(sqrt(2)*b/2)*cos(pi/2-theta)+((a-b)/2)*cos(pose(3,end)) pose(1,end)-(sqrt(2)*b/2)*cos(theta)-((a-b)/2)*cos(pose(3,end)) pose(1,end)-(sqrt(2)*b/2)*cos(pi/2-theta)-((a-b)/2)*cos(pose(3,end)) pose(1,end)+(sqrt(2)*b/2)*cos(theta)+((a-b)/2)*cos(pose(3,end));...
    pose(2,end)+(sqrt(2)*b/2)*sin(theta)+((a-b)/2)*sin(pose(3,end)) pose(2,end)-(sqrt(2)*b/2)*sin(pi/2-theta)+((a-b)/2)*sin(pose(3,end)) pose(2,end)-(sqrt(2)*b/2)*sin(theta)-((a-b)/2)*sin(pose(3,end)) pose(2,end)+(sqrt(2)*b/2)*sin(pi/2-theta)-((a-b)/2)*sin(pose(3,end)) pose(2,end)+(sqrt(2)*b/2)*sin(theta)+((a-b)/2)*sin(pose(3,end))];
plot(robotBody(1,:),robotBody(2,:), 'k');

%plotting laser position
xLaser = pose(1,end)+((a-b)/2+b/2)*cos(pose(3,end));
yLaser = pose(2,end)+((a-b)/2+b/2)*sin(pose(3,end));
plot(xLaser,yLaser,'ok');

%calculate laser to goal angle
gLaserAngle = atan2(robot.goal(2) - yLaser , robot.goal(1) - xLaser);

%plotting laser measurements
for i = 1:size(laserHist,1)-1
    plot([xLaser, xLaser+cos(pose(3,end)+robot.laserAngles(i))*laserHist(i,end)],[yLaser, yLaser+sin(pose(3,end)+robot.laserAngles(i))*laserHist(i,end)],'r');
end

%Goal Tracker
if laserHist(end,end) ~= sqrt((xLaser - robot.goal(1))^2 + (yLaser - robot.goal(2))^2)
    plot([xLaser, xLaser+cos(gLaserAngle)*laserHist(end,end)],[yLaser, yLaser+sin(gLaserAngle)*laserHist(end,end)],'r');
    plot([xLaser+cos(gLaserAngle)*laserHist(end,end), robot.goal(1)],[yLaser+sin(gLaserAngle)*laserHist(end,end), robot.goal(2)],'g--');
else
    plot([xLaser, xLaser+cos(gLaserAngle)*laserHist(end,end)],[yLaser, yLaser+sin(gLaserAngle)*laserHist(end,end)],'b');
end

%plotting robot position and laser readings
rectangle('Position',[-10 11 20 3])
text(-9.8,13.4,'Robot position');
text(-9.8,12.4,['X: ' num2str(pose(1,end))]);
text(-9.8,11.4,['Y: ' num2str(pose(2,end))]);
text(-4.8,13.4,'Laser readings');
text(-4.8,12.4,['Left: ' num2str(laserHist(6,end))]);
text(-4.8,11.4,['Center: ' num2str(laserHist(4,end))]);
text(1.8,12.4,['Right: ' num2str(laserHist(2,end))]);
%     text(1.8,11.4,['Goal Distance: ' num2str(sqrt((xLaser - robot.goal(1))^2 + (yLaser - robot.goal(2))^2))]);
text(1.8,11.4,['Goal Visible: ' num2str(gtHist(2,end))]);
hold off;

% plot parameters
axis([ -11.5, 11.5, -11.5, 11.5]);
axis equal; grid off; ax = gca; ax.XTick = -10:1:10; ax.YTick = -10:1:10;

drawnow;

hold on;
if collision
    plot(xLaser,yLaser,'xr', 'LineWidth', 10, 'MarkerSize', 30);
end

if goal
    plot(xLaser,yLaser,'og', 'LineWidth', 10, 'MarkerSize', 30);
end
hold off;

saveas(gcf,savepath); %save the figure
close; %close the figure

end

