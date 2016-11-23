%initializing MLP

%architecture and parameters    
mlpParam  = struct('moment', 0.5 ,'alpha', 0.5, 'eta', 0.05, 'epoch', 100);
mlpArch = struct('inputs', sensor_num + 2, 'hidden1', 25, 'hidden2', 25, 'outputs', 2);
%weights init
wIn1Init = -0.1 + (0.1+0.1)*rand(mlpArch.inputs+1,mlpArch.hidden1);
w12Init = -0.1 + (0.1+0.1)*rand(mlpArch.hidden1+1,mlpArch.hidden2);
w2OutInit = -0.1 + (0.1+0.1)*rand(mlpArch.hidden2+1,mlpArch.outputs); 