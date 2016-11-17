function [wIn, wHid, wOut, MSEav] = MlpTrain(data, wIn, wHid, wOut, mlpParam)
%MlpTrain Trains multilayered perceptron
%   Inputs: x,y - vector's foothold, alpha - vectors angle from OX
%
%   [A,B] = V2L(x,y,alpha)

epoch = mlpParam.epoch;
eta = mlpParam.eta;
alpha = mlpParam.alpha;
moment = mlpParam.moment;

wInPrev = wIn;
wHidPrev = wHid;
wOutPrev = wOut;
    
MSEav = zeros(1,epoch);
    
%%

for i = 1:epoch
    disp('Epoch: ')
    disp(i)
    index = randperm(length(data{1}));       %random perm index
    MSE = 0;
    
    for j = 1:length(data{1})
        r = index(j);

        % FORWARD PROPAGATION

            x = [1; data{1}(:,r)];

            % hidden layer 1

            locFieldHid1 = wIn'*x;
            yHidden1 = sig(locFieldHid1,alpha);  
            
            % hidden layer 2

            locFieldHid2 = wHid'*[1; yHidden1];
            yHidden2 = sig(locFieldHid2,alpha); 

            % output layer

            locFieldOut = wOut'*[1; yHidden2];
            yOut = sig(locFieldOut,alpha);      

            % deriving error

            d = data{2}(:,r);

            e = d - yOut;
            
            MSE = MSE + e'*e;

        % BACKWARD PROPAGATION
        
            %gradient for output layer

            locGradOut = e.*sigDer(locFieldOut,alpha);

            %gradients for hidden layer 2

            locGradHid2 = sigDer(locFieldHid2,alpha).*(wOut(2:end,:)*locGradOut);
            
            %gradients for hidden layer 1

            locGradHid1 = sigDer(locFieldHid1,alpha).*(wHid(2:end,:)*locGradHid2);

            %output weight update out

            wDelta = wOut - wOutPrev;
            wOutPrev = wOut;

            wOut(2:end,:) = wOut(2:end,:) + moment*wDelta(2:end,:) + eta*[yHidden2]*locGradOut';
            
            %output weight update hid 2

            wDelta = wHid - wHidPrev;
            wHidPrev = wHid;

            wHid(2:end,:) = wHid(2:end,:) + moment*wDelta(2:end,:) + eta*[yHidden1]*locGradHid2';

            %input weight update hid 1

            wDelta = wIn - wInPrev;
            wInPrev = wIn;

            wIn = wIn + moment*wDelta + eta*x*locGradHid1';

    end
    
    MSEav(i) = MSE/length(data{1});
end

end

