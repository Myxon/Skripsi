clc;close all;clear;


P_load = load('Data_LoadPowerDemand7000.mat'); % from power_demand_calculation.m
P_load = P_load.data/10;

duration = length(P_load);
% duration = 701;
P_dclink_x = P_load(1:duration,:)/1000; % kilowatt, from excel
P_GS_x = zeros(duration,1); % watt
P_reg_x = zeros(duration,1); % kilowatt

SOC_min = 20; % Percentage
SOC_max = 90; % Percentage
SOC_x = SOC_max*ones(duration,1); % Percentage

P_bat = zeros(duration,1);
I_bat = zeros(duration,1);
drv_I_bat = zeros(duration,1);
int_I_bat = zeros(duration,1);

U_oc = 300; % volt
R_bat = 0.3; % ohm
C_bat = 8; % Ah

mu_P_GSdem = strings(duration,1);
mu_P_reg = strings(duration,1);

% hold on
for t = 1:duration

    %% DC Link Power Balance

    % P_dclink = -150:150; % kilowatt
    
    minm = -150;%round(min(P_dclink_x));
    maxm = 150;%round(max(P_dclink_x));
    P_dclink = minm:maxm;
    len = length(P_dclink);

    mu_P_dclink_ng = zeros(len,1);
    mu_P_dclink_nl = zeros(len,1);
    mu_P_dclink_lw = zeros(len,1);
    mu_P_dclink_me = zeros(len,1);
    mu_P_dclink_hg = zeros(len,1);

    X = round(P_dclink_x(t,1));

    [NG, mu_P_dclink_ng] = fuzzyfun(X,minm,minm,minm,11,15,maxm);
    [NL, mu_P_dclink_nl] = fuzzyfun(X,minm,11,15,26,30,maxm);
    [LW, mu_P_dclink_lw] = fuzzyfun(X,minm,26,30,48,52,maxm);
    [ME, mu_P_dclink_me] = fuzzyfun(X,minm,48,52,65,69,maxm);
    [HG, mu_P_dclink_hg] = fuzzyfun(X,minm,65,69,maxm,maxm,maxm);

    
    mu = [NG, NL, LW, ME, HG];
    switch max(mu)
    case NG
        mu_P_dclink(t,1) = "NG";
    case NL
        mu_P_dclink(t,1) = "NL";
    case LW
        mu_P_dclink(t,1) = "LW";
    case ME
        mu_P_dclink(t,1) = "ME";
    case HG
        mu_P_dclink(t,1) = "HG";
    end

    clear minm maxm len X NG NL LW ME HG

    %% Genset Power

    % minm = min(P_dclink_x);
    % maxm = max(P_dclink_x);
    % P_dclink = minm:1000:maxm;
    % len = length(P_dclink);

    % X = round(P_dclink_x(t,1))

    % P_GS = 0:150; %kiloWatt
    minm = 0;%min(P_GS_x);
    maxm = 150;%max(P_GS_x);
    P_GS = minm:maxm;
    len = length(P_GS);

    mu_P_GS_vl = zeros(len,1);
    mu_P_GS_lw = zeros(len,1);
    mu_P_GS_me = zeros(len,1);
    mu_P_GS_hg = zeros(len,1);
    mu_P_GS_vh = zeros(len,1);

    X = round(P_GS_x(t,1));

    [VL, mu_P_GS_vl] = fuzzyfun(X,minm,minm,minm,19,21,maxm);
    [LW, mu_P_GS_lw] = fuzzyfun(X,minm,19,21,50,53,maxm);
    [ME, mu_P_GS_me] = fuzzyfun(X,minm,50,53,85,88,maxm);
    [HG, mu_P_GS_hg] = fuzzyfun(X,minm,85,88,106,109,maxm);
    [VH, mu_P_GS_vh] = fuzzyfun(X,minm,106,109,maxm,maxm,maxm);

    % figure(2)

    % hold on
    % plot(P_GS, mu_P_GS_vl);
    % plot(P_GS, mu_P_GS_lw);
    % plot(P_GS, mu_P_GS_me);
    % plot(P_GS, mu_P_GS_hg);
    % plot(P_GS, mu_P_GS_vh);
    % hold off

    mu = [VL, LW, ME, HG, VH];

    switch max(mu)
    case VL
        mu_P_GS(t,1) = "VL";
    case LW
        mu_P_GS(t,1) = "LW";
    case ME
        mu_P_GS(t,1) = "ME";
    case HG
        mu_P_GS(t,1) = "HG";
    case VH
        mu_P_GS(t,1) = "VH";
    end

    clear minm maxm len X VL LW ME HG VH

    %% Regeneration Capability

    % P_reg = -2:70; %kilowatt
    minm = -2;%min(P_reg_x);
    maxm = 70;%max(P_reg_x);
    P_reg = minm:maxm;
    len = length(P_reg);

    mu_P_reg_vl = zeros(len,1);
    mu_P_reg_lw = zeros(len,1);
    mu_P_reg_me = zeros(len,1);

    X = round(P_reg_x(t,1));

    [VL, mu_P_reg_vl] = fuzzyfun(X,minm,minm,minm,0,1,maxm);
    [LW, mu_P_reg_lw] = fuzzyfun(X,minm,0,1,23,24,maxm);
    [ME, mu_P_reg_me] = fuzzyfun(X,minm,23,24,maxm,maxm,maxm);

    % figure(3)

    % hold on
    % plot(P_reg, mu_P_reg_vl);
    % plot(P_reg, mu_P_reg_lw);
    % plot(P_reg, mu_P_reg_me);
    % hold off

    mu = [VL, LW, ME];

    switch max(mu)
    case VL
        mu_P_reg(t,1) = "NL";
    case LW
        mu_P_reg(t,1) = "LW";
    case ME
        mu_P_reg(t,1) = "ME";
    end

    clear minm maxm len X VL LW ME

    %% State of Charge

    % SOC = 0:100; %
    minm = 0;%min(SOC_x);
    maxm = 100;%max(SOC_x);
    SOC = minm:maxm;
    len = length(SOC);

    mu_SOC_vl = zeros(len,1);
    mu_SOC_lw = zeros(len,1);
    mu_SOC_me = zeros(len,1);
    mu_SOC_hg = zeros(len,1);

    X = round(SOC_x(t,1));

    [VL, mu_SOC_vl] = fuzzyfun(X,minm,minm,minm,60,61,maxm);
    [LW, mu_SOC_lw] = fuzzyfun(X,minm,60,61,65,70,maxm);
    [ME, mu_SOC_me] = fuzzyfun(X,minm,65,70,75,85,maxm);
    [HG, mu_SOC_hg] = fuzzyfun(X,minm,75,85,maxm,maxm,maxm);

    % figure(4)

    % hold on
    % plot(SOC, mu_SOC_vl);
    % plot(SOC, mu_SOC_lw);
    % plot(SOC, mu_SOC_me);
    % plot(SOC, mu_SOC_hg);
    % hold off

    mu = [VL, LW, ME, HG];

    switch max(mu)
    case VL
        mu_SOC(t,1) = "VL";
    case LW
        mu_SOC(t,1) = "LW";
    case ME
        mu_SOC(t,1) = "ME";
    case HG
        mu_SOC(t,1) = "HG";
    end

    clear minm maxm len X VL LW ME HG



    %% Fuzzy Logic Rules

    % DC Link HG

    mu_regcap = "NL";


    switch mu_P_dclink(t,1)

    case "HG"

        switch mu_SOC(t,1)
        case "VL"
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "VH";
            case "LW"
                mu_P_GSdem(t,1) = "VH";
            case "ME"
                mu_P_GSdem(t,1) = "VH";
            case "HG"
                mu_P_GSdem(t,1) = "VH";
            case "VH"
                mu_P_GSdem(t,1) = "VH";
            end
        case "LW"
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "HG";
            case "LW"
                mu_P_GSdem(t,1) = "HG";
            case "ME"
                mu_P_GSdem(t,1) = "HG";
            case "HG"
                mu_P_GSdem(t,1) = "HG";
            case "VH"
                mu_P_GSdem(t,1) = "VH";
            end
        case "ME"
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "ME";
            case "LW"
                mu_P_GSdem(t,1) = "ME";
            case "ME"
                mu_P_GSdem(t,1) = "ME";
            case "HG"
                mu_P_GSdem(t,1) = "HG";
            case "VH"
                mu_P_GSdem(t,1) = "HG";
            end
        case 'HG'
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "LW";
            case "LW"
                mu_P_GSdem(t,1) = "LW";
            case "ME"
                mu_P_GSdem(t,1) = "ME";
            case "HG"
                mu_P_GSdem(t,1) = "ME";
            case "VH"
                mu_P_GSdem(t,1) = "ME";
            end
        end

    case "ME"

        switch mu_SOC(t,1)
        case "VL"
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "HG";
            case "LW"
                mu_P_GSdem(t,1) = "HG";
            case "ME"
                mu_P_GSdem(t,1) = "HG";
            case "HG"
                mu_P_GSdem(t,1) = "HG";
            case "VH"
                mu_P_GSdem(t,1) = "VH";
            end
        case "LW"
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "ME";
            case "LW"
                mu_P_GSdem(t,1) = "ME";
            case "ME"
                mu_P_GSdem(t,1) = "ME";
            case "HG"
                mu_P_GSdem(t,1) = "HG";
            case "VH"
                mu_P_GSdem(t,1) = "VH";
            end
        case "ME"
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "LW";
            case "LW"
                mu_P_GSdem(t,1) = "LW";
            case "ME"
                mu_P_GSdem(t,1) = "ME";
            case "HG"
                mu_P_GSdem(t,1) = "HG";
            case "VH"
                mu_P_GSdem(t,1) = "HG";
            end
        case 'HG'
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "VL";
            case "LW"
                mu_P_GSdem(t,1) = "LW";
            case "ME"
                mu_P_GSdem(t,1) = "LW";
            case "HG"
                mu_P_GSdem(t,1) = "ME";
            case "VH"
                mu_P_GSdem(t,1) = "ME";
            end
        end

    case "LW"

        switch mu_SOC(t,1)
        case "VL"
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "ME";
            case "LW"
                mu_P_GSdem(t,1) = "ME";
            case "ME"
                mu_P_GSdem(t,1) = "ME";
            case "HG"
                mu_P_GSdem(t,1) = "HG";
            case "VH"
                mu_P_GSdem(t,1) = "VH";
            end
        case "LW"
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "LW";
            case "LW"
                mu_P_GSdem(t,1) = "LW";
            case "ME"
                mu_P_GSdem(t,1) = "ME";
            case "HG"
                mu_P_GSdem(t,1) = "HG";
            case "VH"
                mu_P_GSdem(t,1) = "VH";
            end
        case "ME"
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "VL";
            case "LW"
                mu_P_GSdem(t,1) = "LW";
            case "ME"
                mu_P_GSdem(t,1) = "ME";
            case "HG"
                mu_P_GSdem(t,1) = "ME";
            case "VH"
                mu_P_GSdem(t,1) = "ME";
            end
        case 'HG'
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "VL";
            case "LW"
                mu_P_GSdem(t,1) = "LW";
            case "ME"
                mu_P_GSdem(t,1) = "LW";
            case "HG"
                mu_P_GSdem(t,1) = "LW";
            case "VH"
                mu_P_GSdem(t,1) = "LW";
            end
        end

    case "NL"

        switch mu_SOC(t,1)
        case "VL"
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "LW";
            case "LW"
                mu_P_GSdem(t,1) = "LW";
            case "ME"
                mu_P_GSdem(t,1) = "ME";
            case "HG"
                mu_P_GSdem(t,1) = "ME";
            case "VH"
                mu_P_GSdem(t,1) = "ME";
            end
        case "LW"
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "LW";
            case "LW"
                mu_P_GSdem(t,1) = "LW";
            case "ME"
                mu_P_GSdem(t,1) = "ME";
            case "HG"
                mu_P_GSdem(t,1) = "ME";
            case "VH"
                mu_P_GSdem(t,1) = "ME";
            end
        case "ME"
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "VL";
            case "LW"
                mu_P_GSdem(t,1) = "LW";
            case "ME"
                mu_P_GSdem(t,1) = "LW";
            case "HG"
                mu_P_GSdem(t,1) = "LW";
            case "VH"
                mu_P_GSdem(t,1) = "LW";
            end
        case 'HG'
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "VL";
            case "LW"
                mu_P_GSdem(t,1) = "NL";
            case "ME"
                mu_P_GSdem(t,1) = "NL";
            case "HG"
                mu_P_GSdem(t,1) = "NL";
            case "VH"
                mu_P_GSdem(t,1) = "NL";
            end
        end

    case "NG"

        switch mu_SOC(t,1)
        case "VL"
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "VL";
                mu_regcap(t,1) = "LW";
            case "LW"
                mu_P_GSdem(t,1) = "LW";
                mu_regcap(t,1) = "ME";
            case "ME"
                mu_P_GSdem(t,1) = "ME";
                mu_regcap(t,1) = "HG";
            case "HG"
                mu_P_GSdem(t,1) = "ME";
                mu_regcap(t,1) = "HG";
            case "VH"
                mu_P_GSdem(t,1) = "ME";
                mu_regcap(t,1) = "HG";
            end
        case "LW"
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "VL";
                mu_regcap(t,1) = "LW";
            case "LW"
                mu_P_GSdem(t,1) = "LW";
                mu_regcap(t,1) = "ME";
            case "ME"
                mu_P_GSdem(t,1) = "ME";
                mu_regcap(t,1) = "HG";
            case "HG"
                mu_P_GSdem(t,1) = "ME";
                mu_regcap(t,1) = "HG";
            case "VH"
                mu_P_GSdem(t,1) = "ME";
                mu_regcap(t,1) = "HG";
            end
        case "ME"
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "NL";
                mu_regcap(t,1) = "NL";
            case "LW"
                mu_P_GSdem(t,1) = "VL";
                mu_regcap(t,1) = "ME";
            case "ME"
                mu_P_GSdem(t,1) = "LW";
                mu_regcap(t,1) = "HG";
            case "HG"
                mu_P_GSdem(t,1) = "LW";
                mu_regcap(t,1) = "HG";
            case "VH"
                mu_P_GSdem(t,1) = "LW";
                mu_regcap(t,1) = "HG";
            end
        case 'HG'
            switch mu_P_GS(t,1)
            case "VL"
                mu_P_GSdem(t,1) = "NL";
                mu_regcap(t,1) = "NL";
            case "LW"
                mu_P_GSdem(t,1) = "NL";
                mu_regcap(t,1) = "NL";
            case "ME"
                mu_P_GSdem(t,1) = "NL";
                mu_regcap(t,1) = "NL";
            case "HG"
                mu_P_GSdem(t,1) = "NL";
                mu_regcap(t,1) = "NL";
            case "VH"
                mu_P_GSdem(t,1) = "NL";
                mu_regcap(t,1) = "NL";
            end
        end
    
    end

    t
    disp("mu_P_dclink = " + mu_P_dclink(t,1));
    disp("mu_SOC = " + mu_SOC(t,1));
    disp("mu_P_GS = " + mu_P_GS(t,1));
    disp("mu_P_GSdem = " + mu_P_GSdem(t,1));

    if mu_P_GSdem(t,1) == "NL" & P_GS_x(t,1) > 0
        P_GS_x(t,1) = 0;
    elseif mu_P_GSdem(t,1) == "VL"
        P_GS_x(t,1) = 15;
    elseif mu_P_GSdem(t,1) == "LW"
        P_GS_x(t,1) = 40;
    elseif mu_P_GSdem(t,1) == "ME"
        P_GS_x(t,1) = 70;
    elseif mu_P_GSdem(t,1) == "HG"
        P_GS_x(t,1) = 100;
    elseif mu_P_GSdem(t,1) == "VH"
        P_GS_x(t,1) = 120;
    end

    
    P_bat(t,1) = P_dclink_x(t,1) - P_GS_x(t,1);
    I_bat(t,1) = (U_oc - sqrt(U_oc^2 - 4*R_bat*P_bat(t,1)))/(2*R_bat);

    if t > 1 & t < duration
        drv_I_bat(t,1) = I_bat(t,1) - I_bat(t-1,1);
        int_I_bat(t,1) = int_I_bat(t-1,1) + drv_I_bat(t,1);
        SOC_x(t+1,1) = SOC_x(t,1) - 1/C_bat*0.98*int_I_bat(t,1);
    end

    % scatter(t,)
end    
% figure(1)

% hold on
% plot(P_dclink, mu_P_dclink_ng);
% plot(P_dclink, mu_P_dclink_nl);
% plot(P_dclink, mu_P_dclink_lw);
% plot(P_dclink, mu_P_dclink_me);
% plot(P_dclink, mu_P_dclink_hg);
% hold off




t = 1:duration;
numPlot = 3;

subplot(numPlot,1,1);
plot(t, P_dclink_x);
title('P_{dclink}');

subplot(numPlot,1,2);
plot(t, P_GS_x);
title('P_{GS}');

subplot(numPlot,1,3);
plot(t, SOC_x);
title('SOC');
