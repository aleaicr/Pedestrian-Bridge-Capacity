%% vdPWalker Model Testing

% Alexis Contreras R.
% Pedestrian Bridges Capacity
% https://github.com/aleaicr/Pedestrian-Bridge-Capacity

%% Inicializar
clear variables
close all
clc

%% Inputs
ai = 1;
wi = 2;
lambdai = 1;
omega_sinusoide = 2*pi*0.9;
ampl_sinusoide = 1/20;

% Tiempos registro
t_inicial = 0;
t_step = 1/1000;
keep_steps = 0;
t_final = 40;
t_vect = (t_inicial:t_step:t_final)';

% % Tiempos simulación
% t_inicial_simu = 0;
% t_step_simu = 1/1000;
% keep_steps_simu = 0;
% tsf_secs = 45; % 45 segundos de simulación deseo
% tsf = t_step_simu^-1*tsf_secs;
% t_final_simu = t_step_simu*(tsf - 1 + keep_steps);
% t_vect_simu = (t_inicial_simu:t_step_simu:t_final_simu)';

%% Simulación
% out = sim("vdPWalker_Belykh_etal_2017.slx");
% despl = out.simout.Data;
