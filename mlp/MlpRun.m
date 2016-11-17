function [yOutput] = MlpRun(input, wIn, wHid, wOut, mlpParam)

alpha = mlpParam.alpha;
yOutput = [];
%%


    
    %for i = 1:length(input)

        % FORWARD PROPAGATION

            x = [1; input];

            % hidden layer 1

            locFieldHid1 = wIn'*x;
            yHidden1 = sig(locFieldHid1,alpha);  
            
            % hidden layer 2

            locFieldHid2 = wHid'*[1; yHidden1];
            yHidden2 = sig(locFieldHid2,alpha); 

            % output layer

            locFieldOut = wOut'*[1; yHidden2];
            yOut = sig(locFieldOut,alpha);  
            
            yOutput = [yOutput yOut];
           
   % end
    


end

