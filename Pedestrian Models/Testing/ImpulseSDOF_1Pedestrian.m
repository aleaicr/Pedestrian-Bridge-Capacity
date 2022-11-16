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
wi = 0.75;                          %
lambdai = 0.23;                     %
omega_sinusoide = 2*pi*0.9;         %
ampl_sinusoide = 1/20;              %
ped_mass = 70;                      % kg

% Bridge (Marcheggiani & Lenci 2010)
Mbridge = 113000;                   % kg
Kbridge  = 4730;                    % kN/m                                  % 4730000 kg/s2 = 4730 kN/m
Cbridge = 11;                       % kN/(m/s)                              % 11000 kg/s = 11 kN/(m/s)

%% Space-State SDOF BRIDGE
% x = Ax+Bp , p = ypp 
% y = Cx+Dp , y = [u;up;upp]
A = [0 1; -Kbridge/Mbridge -Cbridge/Mbridge];
B = [0; -ped_mass/Mbridge];

C = [1 0; 0 1; -Kbridge/Mbridge -Cbridge/Mbridge];
D = [0;0;-ped_mass/Mbridge];

modelo = ss(A,B,C,D);

% Simulación Impulso

t_inicial = 0;
t_step = 1/10000;
keep_steps = 0;
t_final = 200;
t_vect = (t_inicial:t_step:t_final)';
step_time_impulse = 0.1;
