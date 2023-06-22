vel = Data.TrainSpeed.mat;
alt = Data.TrackAltitude.mat;
dis = Data.DistanceTravelled.mat;
cvr = Data.CurveRadius.mat;

duration = length(vel);

d_dis = zeros(duration,1);
d_alt = zeros(duration,1);
acc = zeros(duration,1);

F_a = zeros(duration,1);
F_r = zeros(duration,1);
F_g = zeros(duration,1);
F_c = zeros(duration,1);
F_b = zeros(duration,1);

mps_kmh = 3.6;
kmh_mps = 1/mps_kmh;

if t > 0

d_dis(t) = dis(t) - dis(t-1);
d_alt(t) = alt(t) - alt(t-1);

theta(t) = asin(d_alt(t)/d_dis(t));

% equivalent train mass

Mtare = 70400;
Mpass = 3080;
ceq = 0.05;

Mv = (1+ceq)*Mtare + Mpass;

g = 9.81;

% acceleration force

acc(t) = vel(t) - vel(t-1);
F_a(t) = Mv*acc(t);

% rolling resistance

F_r(t) = 3.6*(0.1*vel(t)^2 + 22.3*vel(t) + 1001);

% grade resistance

F_g(t) = Mv*g*sin(theta(t));

% curve resistance

if 0 < cvr(t) < 272
    F_c(t) = 0.03*Mv;
elseif cvr < 2000
    F_c(t) = 6.5*Mv/(cvr(t) - 55);
end

% brake disc resistance

n_bs = 24;
v0 = 100*kmh_mps;

F_b(t) = n_bs*(3.16*(vel(t)/v0)^2 + 4.33*(vel(t)/v0));

% traction force

F_tr(t) = F_a(t) + F_r(t) + F_g(t) + F_c(t) + F_b(t);

% maximum traction force

F_trmax(t) = (7.5/(44 + 3.6*vel(t)) + 0.161) * Mv*g*cos(theta(t));

if abs(F_tr(t)) >= F_trmax(t)
    if F_tr(t) < 0
        F_tr(t) = -F_trmax(t);
    else
        F_tr(t) = F_trmax(t);
    end
end

% wheel torque and speed

diameter_w = 0.86;

T_w(t) = F_tr(t)*diameter_w/2;
w_w(t) = 2*vel(t)/diameter_w;

% axle gear

eta_ag = 0.97;
i_ag = 1.7218;

if T_w(t) < 0
    T_EM(t) = (T_w(t)*eta_ag)/i_ag;
else
    T_EM(t) = T_w(t)/(eta_ag*i_ag);
end

w_EM(t) = w_w(t)*i_ag;

% electric motor

eta_EM = 0.88;

if T_EM(t) < 0
    P_EM(t) = T_EM(t)*w_EM(t)*eta_EM;
else
    P_EM(t) = T_EM(t)*w_EM(t)/eta_EM;
end

% electrical auxiliary

P_auxconst = 45000;
P_auxconst_stop = 9000;

if abs(vel(t) - 0.1) <= 0
    P_aux(t) = P_auxconst_stop;
else
    P_aux(t) = P_auxconst + 0.01*abs(P_EM(t));
end

% power demand

P_dem(t) = P_EM(t) + P_aux(t);



































































end