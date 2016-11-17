function out = sigDer(v, alpha)
    out = alpha*exp(-alpha*v)./(1+exp(-alpha*v)).^2;
end