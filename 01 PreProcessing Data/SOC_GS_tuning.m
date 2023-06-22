clc, close all

% dynamic programming

dmf = 0; % fuel mase consumption rate depending on split factor (U)
t = 1; % time step in seconds
U = 0; % split factor for each time
N = 0; % urban route length in ?

J = sum(dmf*t);

P_bt(i) = U(i)*P_dem(i);
P_gs(i) = (1-U(i))*P_dem(i);
