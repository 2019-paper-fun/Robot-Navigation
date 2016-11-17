function [ new_pose ] = KinUpdate(pose, robotpar, ts, wheelspeed)
%KINUPDATE Updating the pose of the robot
%   pose            current pose [x, y, theta]
%   robotpar        [ wheelseparation, radius right wheel, radius left wheel ]
%   ts              sample time
%   wheelspeed      [angular velocity LEFT wheel, angular velocity RIGHT wheel ]                

%Extracting values
x=pose(1); y=pose(2); theta=pose(3);
l=robotpar(1)/2; r_l=robotpar(2); r_r=robotpar(3);
omega_l=wheelspeed(1); omega_r=wheelspeed(2);

%inverse rotational matrix
R_inv=[cos(theta), -sin(theta), 0; sin(theta), cos(theta), 0; 0, 0, 1];

%Differential Robot Position ( diff(Epsilon_R) )
JC_inv=[0.5, 0.5, 0; 0, 0, 1; 1/(2*l), -1/(2*l), 0];
pose_R=JC_inv*[r_r*omega_r; r_l*omega_l; 0];

%calculates updated position
new_pose = pose + R_inv*pose_R*ts;

end

