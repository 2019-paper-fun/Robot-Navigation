% To be placed always after 'Drive' function
% Updates following variables:
% VelHist - needed for MLP algorithm
% poseHis - needed for simulation
% laserHist - needed for MLP algorithm
% gtHist - [angle to goal; goal_visible_or_not] 
% robot.pose - sets final robot pose

velHist = [velHist,velHist vel];           
poseHist = [poseHist,poseHist hist];
laserHist = [laserHist,laserHist lHist];
gtHist = [gtHist , gtHist gHist];
robot.pose = poseHist(:,end);