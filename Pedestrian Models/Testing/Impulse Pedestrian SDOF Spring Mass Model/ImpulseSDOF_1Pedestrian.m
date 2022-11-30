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
ai = 1;                                                                   %
fi = 1.8/2;                             % hz                                  % Frecuencia horizontal del caminar
wi = 2*pi*fi;                         % rad/sec                             % 
% wi = 1.2;
lambdai = 0.5;                                                              % 
mi = 70;                                                                    % kg

% Bridge (Marcheggiani & Lenci 2010) % Malos, no cumple ni con frecuencia
% ni amortiguamiento del puente de análisis.
% Mbridge = 113000;                   % kg
% Kbridge  = 4730;                    % kN/m                                  % 4730000 kg/s2 = 4730 kN/m
% Cbridge = 11;                       % kN/(m/s)                              % 11000 kg/s = 11 kN/(m/s)
% wbridge = sqrt(Kbridge/Mbridge);
% xi = Cbridge/(2*Mbridge*wbridge);

% Utilizando datos (Belykh etl al 2021)
Mbridge = 113000;                                                           % kg
Mspan = Mbridge/325*144;                                                    % kg
w = 3.14;                                                                   % rad/sec
Kspan = Mspan*w^2/1000;                                                     % kN/m
xi = 20/100;                                                                 % Mejor ocupar desde fuente Dallard P. et al 2001
Cspan = xi*2*Mspan*w/1000;                                                  % kN/(m/s)

%% Space-State SDOF BRIDGE
% x = Ax+Bp , p = ypp 
% y = Cx+Dp , y = [u;up;upp]
A = [0 1; -Kspan/Mspan -Cspan/Mspan];
B = [0; 1/Mspan];

C = [1 0; 0 1; -Kspan/Mspan -Cspan/Mspan];                                  % y = [q;qp;qpp]
% Cdisp = [1 0];                                                              % y = [q]
% Cdisp_vel = [1 0; 0 1];                                                     % y = [q;qp]
% Cacc = [-Kbridge/Mbridge -Cbridge/Mbridge];                                 % y = [qpp]
% Cdisp_acc = [1 0; -Kbridge/Mbridge -Cbridge/Mbridge];                       % y = [q,qpp]

D = [0;0; 1/Mspan];                                                               % y = [q;qp;qpp]
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
