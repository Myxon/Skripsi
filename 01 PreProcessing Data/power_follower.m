clc;close all;clear;


P_load = load('Data_LoadPowerDemand7000.mat'); % from power_demand_calculation.m
P_load = P_load.data/10;

duration = 701;
P_dclink = P_load(1:duration,:)/1000; % kilowatt, from excel

% filename = 'Default Dataset (2).csv';
% P_dclink = readtable(filename);
% P_dclink = table2array(P_dclink(:,2));

duration = length(P_dclink);
P_GS = zeros(duration,1); % watt
P_reg = zeros(duration,1); % kilowatt
SOC = 90*ones(duration,1); % Percentage

P_bat = zeros(duration,1);
P_bat_plot = zeros(duration,1);
I_bat = zeros(duration,1);
drv_I_bat = zeros(duration,1);
int_I_bat = zeros(duration,1);

U_oc = 300; % volt
R_bat = 0.3; % ohm
C_bat = 8; % Ah

P_GSmax = 70; % maximum genset power
P_GSeff = 0.75*P_GSmax; % efficient genset power

P_batmax = 70; % kW
P_batmin = -40;

SOC_max = 90;
SOC_min  = 20;

state = zeros(duration,1);

cont = 0;
for t = 1:duration
    if cont == 0
        P_GS(t,1) = P_dclink(t,1);
        P_bat(t,1) = P_dclink(t,1) - P_GS(t,1);
        P_bat_plot(t,1) = P_bat(t,1);
        if P_dclink(t,1) >= P_GSeff
            cont = 1;
        end
    
    elseif P_dclink(t,1) < P_batmin %1
        state(t,1) = 1;
        P_bat(t,1) = P_batmin;
        P_GS(t,1) = 0;
        P_bat_plot(t,1) = P_bat(t,1);
    elseif P_dclink(t,1) >= P_batmin & P_dclink(t,1) < 0 %2
        state(t,1) = 2;
        P_bat(t,1) = P_batmin;
        P_GS(t,1) = P_dclink(t,1) - P_bat(t,1);
        P_bat_plot(t,1) = P_bat(t,1);
    elseif P_dclink(t,1) >= 0 & P_dclink(t,1) < P_GSeff + P_batmin %3
        state(t,1) = 3;
        P_bat(t,1) = P_batmin;
        P_GS(t,1) = P_dclink(t,1) - P_bat(t,1);
        P_bat_plot(t,1) = P_bat(t,1);
    elseif P_dclink(t,1) >= P_GSeff + P_batmin & P_dclink(t,1) < P_GSeff %4
        state(t,1) = 4;
        P_GS(t,1) = P_GSeff;
        P_bat(t,1) = P_dclink(t,1) - P_GS(t,1);
        P_bat_plot(t,1) = P_bat(t,1);
    elseif P_dclink(t,1) >= P_GSeff & P_dclink(t,1) < P_GSmax %5
        state(t,1) = 5;
        P_GS(t,1) = P_GSeff;
        P_bat(t,1) = P_dclink(t,1) - P_GS(t,1);
        P_bat_plot(t,1) = P_bat(t,1);
    elseif P_dclink(t,1) >= P_GSmax & P_dclink(t,1) < P_GSeff + P_batmax %6
        state(t,1) = 6;
        P_GS(t,1) = P_GSeff;
        P_bat(t,1) = P_dclink(t,1) - P_GS(t,1);
        P_bat_plot(t,1) = P_bat(t,1);
    elseif P_dclink(t,1) >= P_GSeff + P_batmax & P_dclink(t,1) < P_GSmax + P_batmax %7
        state(t,1) = 7;
        P_GS(t,1) = P_GSmax;
        P_bat(t,1) = P_dclink(t,1) - P_GS(t,1);
        P_bat_plot(t,1) = P_bat(t,1);
    elseif P_dclink(t,1) >= P_GSmax + P_batmax %8
        state(t,1) = 8;
        P_GS(t,1) = P_GSmax;
        P_bat(t,1) = P_batmax;
        P_bat_plot(t,1) = P_bat(t,1);
    end

    % if P_GS(t,1) < 0
    %     P_GS(t,1) = 0;
    % end

    I_bat(t,1) = (U_oc - sqrt(U_oc^2 - 4*R_bat*P_bat(t,1)))/(2*R_bat);

    % if t > 1 & t < duration
    %     drv_I_bat(t,1) = I_bat(t,1) - I_bat(t-1,1);
    %     int_I_bat(t,1) = int_I_bat(t-1,1) + drv_I_bat(t,1);
    %     SOC(t+1,1) = SOC(t,1) - 1/C_bat*0.98*int_I_bat(t,1);
    %     if SOC(t,1) > SOC_max | SOC(t,1) < SOC_min
    %         P_bat(t,1) = 0;
    %         P_bat_plot(t,1) = P_bat(t,1);
    %         I_bat(t,1) = (U_oc - sqrt(U_oc^2 - 4*R_bat*P_bat(t,1)))/(2*R_bat);
    %         drv_I_bat(t,1) = I_bat(t,1) - I_bat(t-1,1);
    %         int_I_bat(t,1) = int_I_bat(t-1,1) + drv_I_bat(t,1);
    %         SOC(t+1,1) = SOC(t,1) - 1/C_bat*0.98*int_I_bat(t,1);
    %     end
    % end
end

P_sup = P_bat + P_GS;

hold on
plot(1:duration, P_batmin*ones(1,duration),'--');
plot(1:duration, 0*ones(1,duration),'--');
plot(1:duration, (P_GSeff - P_batmin)*ones(1,duration),'--');
plot(1:duration, P_GSeff*ones(1,duration),'--');
plot(1:duration, P_GSmax*ones(1,duration),'--');
plot(1:duration, (P_GSeff + P_batmax)*ones(1,duration),'--');
plot(1:duration, (P_GSmax + P_batmax)*ones(1,duration),'--');
plot(1:duration,P_dclink,'LineWidth',2);  
plot(1:duration,P_sup);      
plot(1:duration,P_GS);    
plot(1:duration,P_bat_plot);    
% plot(1:duration,SOC);    

legend('P_{batmin}','','','P_{GSeff}','P_{GSmax}','','','P_{dclink}','P_{sup}','P_{GS}','P_{bat}');
% legend('P_{dclink}','P_{sup}','P_{GS}','P_{bat}','SOC');
hold off