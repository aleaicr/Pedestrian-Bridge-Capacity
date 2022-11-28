%% vdPWalker Model Testing

% Alexis Contreras R.
% Pedestrian Bridges Capacity
% https://github.com/aleaicr/Pedestrian-Bridge-Capacity

%% Inicializar
clear variables
close all
clc

%% Inputs
% Pedestrian
ai = 1;                             %  
wi = 0.73;                          % 
lambdai = 0.23;                     % 
mi = 70;                            % kg

% Bridge (Marcheggiani & Lenci 2010)
Mbridge = 113000;                   % kg
Kbridge  = 4730;                    % kN/m                                  % 4730000 kg/s2 = 4730 kN/m
Cbridge = 11;                       % kN/(m/s)                              % 11000 kg/s = 11 kN/(m/s)
wbridge = sqrt(Kbridge/Mbridge);
xi = Cbridge/(2*Mbridge*wbridge);

%% Space-State SDOF BRIDGE
% x = Ax+Bp , p = ypp 
% y = Cx+Dp , y = [u;up;upp]
A = [0 1; -Kbridge/Mbridge -Cbridge/Mbridge];
B = [0; -mi/Mbridge];

C = [1 0; 0 1; -Kbridge/Mbridge -Cbridge/Mbridge];                          % y = [q;qp;qpp]
% Cdisp = [1 0];                                                              % y = [q]
% Cdisp_vel = [1 0; 0 1];                                                     % y = [q;qp]
% Cacc = [-Kbridge/Mbridge -Cbridge/Mbridge];                                 % y = [qpp]
% Cdisp_acc = [1 0; -Kbridge/Mbridge -Cbridge/Mbridge];                       % y = [q,qpp]

D = [0;0;-mi/Mbridge];                                                      % y = [q;qp;qpp]
% Ddisp = 0;                                                                  % y = [q]
% Ddisp_vel = [0; 0];                                                         % y = [q; qp]
% Dacc = -mi/Mbridge;                                                         % y = [qpp]
% Ddisp_acc = [0; -mi/Mbridge];                                               % y = [q; qpp]

% Modelo
modelo = ss(A,B,C,D);

% Simulación Impulso
t_inicial = 0;
t_step = 1/1000;
keep_steps = 0;
t_final = 500;
t_vect = (t_inicial:t_step:t_final)';
step_time_impulse = 0.1;
