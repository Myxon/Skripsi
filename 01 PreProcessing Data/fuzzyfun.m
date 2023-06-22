function [FV, mu] = fuzzyfun(X,minm, a, b, c, d, maxm)
    % a = (a - minm)/(maxm - minm)*(150-(-150)) + (-150);
    % b = (b - minm)/(maxm - minm)*(150-(-150)) + (-150);
    % c = (c - minm)/(maxm - minm)*(150-(-150)) + (-150);
    % d = (d - minm)/(maxm - minm)*(150-(-150)) + (-150);
    for i = minm:maxm
        j = i - minm + 1;
        if a == minm & i <= b
            mu(j) = 1.00;
            continue;
        end
        if i <= a
            mu(j) = 0.00;
        elseif i > a & i <= b
            mu(j) = (i-a) * 1.00/(b-a);
        elseif i <= c
            mu(j) = 1.00;
        elseif i > c & i <= d
            mu(j) = 1.00 - (i-c) * 1.00/(d-c);
        else
            mu(j) = 0.00;
        end
    end
    
    FV = mu(X - minm + 1);
end    