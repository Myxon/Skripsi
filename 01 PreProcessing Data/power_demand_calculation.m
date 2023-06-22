clc; close all; clear all;

%% Data Initialization

% read data

trackProfile = readtable("Train_Track_Profile.xlsx");

t = trackProfile.Time;
dis = trackProfile.Distance;
vel = trackProfile.Speed;
alt = trackProfile.Altitude;
cvr = trackProfile.CurveRad;
cat = trackProfile.CatOn_Off;

duration = length(t);

% vectors initialization

d_dis = zeros(duration,1); % change of distance
d_alt = zeros(duration,1); % change of altitude
theta = zeros(duration,1); % change of angle
acc = zeros(duration,1); % acceleration
F_a = zeros(duration,1); % acceleration force
F_r = zeros(duration,1); % resistance force
F_g = zeros(duration,1); % grade force
F_c = zeros(duration,1); % curve resistance force
F_b = zeros(duration,1); % brake disc force
F_tr = zeros(duration,1); % traction force

% constants

mps_kmh = 3600/1000; % meter per second to kilometer per hour
kmh_mps = 1000/3600; % kilometer per hour to meter per second

Mtare = 70400; % mass of train
Mpass = 3080; % mass of passenger
ceq = 0.05; % train mass equivalence constant
Mv = (1+ceq)*Mtare + Mpass; % equivalent train mass

g = 9.81; % gravitational acceleration (m.s^-2)
n_bs = 24; % number of brake discs, 4 in each axles, 2 axles in each cars, 10 cars
v0 = 100*kmh_mps; % velocity constant
diameter_w = 0.86; % wheel diameter
eta_ag = 0.97; % axle gear efficiency
i_ag = 1.7218; % axle gear ratio
eta_EM = 0.88; % electric motor efficiency
P_auxconst = 45000; % minimum auxiliary dynamic load power 
P_auxconst_stop = 9000; % static load power

%% Loop

for i = 2:duration


d_dis(i,1) = dis(i,1) - dis(i-1,1);
d_alt(i,1) = alt(i,1) - alt(i-1,1);
acc(i,1) = vel(i,1) - vel(i-1,1);
if d_dis(i,1) == 0
    theta(i,1) = 0;
else
    theta(i,1) = asin(d_alt(i,1)/d_dis(i,1));
end

end


%% Power Demand Calculation

for i = 1:duration

    F_a(i,1) = Mv*acc(i,1);
    F_r(i,1) = 3.6*(0.1*vel(i,1)^2 + 2.23*vel(i,1) + 1001);
    F_g(i,1) = Mv*g*sin(theta(i,1));
    F_b(i,1) = n_bs*(3.16*(vel(i,1)/v0)^2 + 4.33*(vel(i,1)/v0));

    if cvr(i,1) <= 272
        F_c(i,1) = Mv*0.03;
    elseif 272 < cvr(i,1) <= 2000
        F_c(i,1) = Mv*6.5/(cvr(i,1) - 55);
    elseif cvr(i,1) > 2000
        F_c(i,1) = 0;
    end

    F_tr(i,1) = F_a(i,1) + F_r(i,1) + F_g(i,1) + F_b(i,1) + F_c(i,1); 

    F_trmax(i,1) = (7.5/(44 + 3.6*vel(i,1)) + 0.161) * Mv*g*cos(theta(i,1));

    if abs(F_tr(i,1)) >= F_trmax(i,1)
        if F_tr(i,1) < 0
            F_tr(i,1) = -F_trmax(i,1);
        else
            F_tr(i,1) = F_trmax(i,1);
        end
    end

    % wheel torque and speed

    T_w(i,1) = F_tr(i,1)*diameter_w/2;
    w_w(i,1) = 2*vel(i,1)/diameter_w;

    % axle gear

    if T_w(i,1) < 0
        T_EM(i,1) = (T_w(i,1)*eta_ag)/i_ag;
    else
        T_EM(i,1) = T_w(i,1)/(eta_ag*i_ag);
    end

    w_EM(i,1) = w_w(i,1)*i_ag;

    % electric motor

    if T_EM(i,1) < 0
        P_EM(i,1) = T_EM(i,1)*w_EM(i,1)*eta_EM;
    else
        P_EM(i,1) = T_EM(i,1)*w_EM(i,1)/eta_EM;
    end

    % electrical auxiiliary load

    if abs(vel(i,1) - 0.1) <= 0
        P_aux(i,1) = P_auxconst_stop;
    else
        P_aux(i,1) = P_auxconst + 0.01*abs(P_EM(i,1));
    end

    % power demand               

    P_dem(i,1) = P_EM(i,1) + P_aux(i,1);
end


% plot

i = 0;
numPlot = 5;

figure(1);

% i = i + 1;
% subplot(numPlot,1,i);
% plot(t,dis);
% i = i + 1;
% subplot(numPlot,1,i);
% plot(t,vel);
% i = i + 1;
% subplot(numPlot,1,i);
% plot(t,acc);
% i = i + 1;
% subplot(numPlot,1,i);
% plot(t,alt);
% i = i + 1;
% subplot(numPlot,1,i);
% plot(t,cvr);
% i = i + 1;
% subplot(numPlot,1,i);
% plot(t,cat);
% i = i + 1;
% subplot(numPlot,1,i);
% plot(t, F_a);
% i = i + 1;
% subplot(numPlot,1,i);
% plot(t, F_r);
% i = i + 1;
% subplot(numPlot,1,i);
% plot(t, theta);
i = i + 1;
subplot(numPlot,1,i);
plot(t, F_g);
i = i + 1;
subplot(numPlot,1,i);
plot(t, F_c);
i = i + 1;
subplot(numPlot,1,i);
plot(t, F_b);
i = i + 1;
subplot(numPlot,1,i);
plot(t, F_tr);
i = i + 1;
subplot(numPlot,1,i);
plot(t,P_dem);





















% Loop end


clc
