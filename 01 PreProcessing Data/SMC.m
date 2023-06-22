clc;close all;clear all;


P_load = load('Data_LoadPowerDemand7000.mat'); % from power_demand_calculation.m
P_load = P_load.data/10;

% duration = 701;
% P_dclink = P_load(1:duration,:)/1000; % kilowatt, from excel

filename = 'Default Dataset (2).csv';
P_dclink = readtable(filename);
P_dclink = table2array(P_dclink(:,2));

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

P_GSmax = 80; % maximum genset power
P_GS1 = 0.125*P_GSmax; % low-mid efficiency genset power threshold
P_GS2 = 0.6*P_GSmax; % mid-high efficiency genset power threshold

P_batmax = 70; % kW
P_batmin = -40;

SOC_min = 20;
SOC_SM1 = 50;
SOC_SM2 = 60;
SOC_SM3 = 70;
SOC_SM4 = 80;
SOC_max = 90;

for t = 1:duration
    if SOC(t,1) <= SOC_min
        SOC(t,1) = SOC_min;
    elseif SOC(t,1) >= SOC_max
        SOC(t,1) = SOC_max;
    end

    if SOC(t,1) <= SOC_SM1
        % P_bat < 0; % charge battery
     
