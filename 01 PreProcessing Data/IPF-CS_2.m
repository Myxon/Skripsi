clc;close all;clear;


P_load = load('Data_LoadPowerDemand7000.mat'); % from power_demand_calculation.m
P_load = P_load.data/10;

% duration = 701;
% P_dclink = P_load(1:duration,:)/1000; % kilowatt, from excel

filename = 'Default Dataset (2).csv';
P_dclink = readtable(filename);
P_dclink = table2array(P_dclink(:,2));

duration = length(P_dclink);
P_GS = zeros(duration,1); % kwatt
P_GS_plot = zeros(duration,1); %kW
P_reg = zeros(duration,1); % kilowatt
SOC = 90*ones(duration,1); % Percentage

P_bat = zeros(duration,1);
I_bat = zeros(duration,1);
drv_I_bat = zeros(duration,1);
int_I_bat = zeros(duration,1);

U_oc = 300; % volt
R_bat = 0.3; % ohm
C_bat = 8; % Ah

P_GSmax = 80; % maximum genset power
P_GS1 = 0.125*P_GSmax; % low-mid efficiency genset power threshold
P_GS2 = 0.6*P_GSmax; % mid-high efficiency genset power threshold

P_batmax = 70; % kW
P_batmin = -40;
SOC_max = 90;
SOC_min = 20;

cont = 0;
for t = 1:duration
    if cont == 0 
        P_bat(t,1) = P_dclink(t,1);
        P_GS(t,1) = P_dclink(t,1) - P_bat(t,1);
        P_GS_plot(t,1) = P_GS(t,1);
        if P_dclink(t,1) >= P_GS2
            cont = 1;
        end
        continue;
    end
    if P_dclink(t,1) > P_GS2
        P_GS(t,1) = P_GS2;
        P_bat(t,1) = P_dclink(t,1) - P_GS(t,1);
        if P_dclink(t,1) > P_GSmax
            P_GS(t,1) = P_GSmax;
            P_bat(t,1) = P_dclink(t,1) - P_GS(t,1);
        end
        if P_bat(t,1) > P_batmax
            P_bat(t,1) = P_batmax;
        end
        P_bat_plot(t,1) = P_bat(t,1) + P_GS(t,1);
    else
        P_GS(t,1) = P_GS2;
        P_bat(t,1) = P_dclink(t,1) - P_GS(t,1);
        if P_bat(t,1) <= P_batmin
            P_bat(t,1) = P_batmin;
            P_GS(t,1) = P_dclink(t,1) - P_bat(t,1);
        end
        P_bat_plot(t,1) = P_bat(t,1);
    end
    if P_GS(t,1) < P_GS1
        P_GS(t,1) = P_GS1;
    end

    I_bat(t,1) = (U_oc - sqrt(U_oc^2 - 4*R_bat*P_bat(t,1)))/(2*R_bat);

    if t > 1 & t < duration
        drv_I_bat(t,1) = I_bat(t,1) - I_bat(t-1,1);
        int_I_bat(t,1) = int_I_bat(t-1,1) + drv_I_bat(t,1);
        SOC(t+1,1) = SOC(t,1) - 1/C_bat*0.98*int_I_bat(t,1);
        if SOC(t,1) > SOC_max
            P_bat(t,1) = 0;
            P_bat_plot(t,1) = P_bat(t,1);
            I_bat(t,1) = (U_oc - sqrt(U_oc^2 - 4*R_bat*P_bat(t,1)))/(2*R_bat);
            drv_I_bat(t,1) = I_bat(t,1) - I_bat(t-1,1);
            int_I_bat(t,1) = int_I_bat(t-1,1) + drv_I_bat(t,1);
            SOC(t+1,1) = SOC(t,1) - 1/C_bat*0.98*int_I_bat(t,1);
        end
    end
end

hold on
plot(1:duration,P_dclink,'LineWidth',3);    
plot(1:duration,P_GS);    
plot(1:duration,P_bat_plot);    
plot(1:duration,SOC);    
legend('P_{dclink}','P_{GS}','P_{bat}','SOC');

