function [maze] = GenerateMaze(fileName)
%GENERATEMAZE Generate maze cell array from .xlsx file
%   Input - xlsx file

mazeData = xlsread(fileName);

[row, col, val] = find(mazeData);
mazeData = [row col val];
mazeData = sortrows(mazeData,3);

wallCount = floor(mazeData(end,3)/100);
maze = cell(wallCount + 1,1);

for i=1:wallCount
maze{i,1} = [(mazeData(find(mazeData(:,3)>(i*100) & mazeData(:,3)<((i+1)*100)),2)/5-10)'; -(mazeData(find(mazeData(:,3)>(i*100) & mazeData(:,3)<((i+1)*100)),1)/5-10)'];
end

% World's boundary
maze{wallCount+1,1} = [-10 10 10 -10 -10; -10 -10 10 10 -10];

end

