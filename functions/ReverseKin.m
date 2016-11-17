function v = ReverseKin(V,omega, robot)
%REVERSEKIN Translates robot's linear and angular velocity to wheels
%velocity

v(2) = (V-omega*robot.param(1))/(robot.param(2));
v(1) = (V - robot.param(2)*v(2)/2)*(2/robot.param(2));

end

