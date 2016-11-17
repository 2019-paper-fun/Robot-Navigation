function [lMeas] = LaserMeas(laserPose, p1, p2)
%LASERMEAS Measures distance from laser to the wall
%   lasPose - pose of the laser [3x1]
%   p1, p2 - points creating a line [2x1]
%
%   [lMeas] = LASERMEAS(laserPose, [x1;y1], [x2;y2])

%sorting x and y values

laserPose(3) = wrapTo2Pi(laserPose(3));     %ntest

if p1(1)>p2(1)
    lbx = p2(1); ubx = p1(1);
else
    lbx = p1(1); ubx = p2(1);
end

[a1, b1] = V2L(laserPose(1),laserPose(2),laserPose(3));
[a2, b2] = P2L(p1, p2);

[x,y] = LineCross([a1; b1], [a2; b2]);

lMeas = sqrt((laserPose(1)-x)^2+(laserPose(2)-y)^2);

if (x > ubx || x < lbx) || (laserPose(3)>pi/2 && laserPose(3)<3*pi/2 && x > laserPose(1)) || (~(laserPose(3)>pi/2 && laserPose(3)<3*pi/2) && x < laserPose(1)) || (laserPose(3)==pi/2 && y < laserPose(2)) || (laserPose(3)==3*pi/2 && y > laserPose(2))
    lMeas = 10e+18;
end

end

