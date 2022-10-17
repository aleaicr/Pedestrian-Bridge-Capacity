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
wi = 0.73;
lambdai = 0.23;

% Registro de desplazamientos
Registro = 'RSN77_SFER.txt';
ddyi = 10*load(Registro);
dt = 0.01;

% Tiempos registro
t_inicial = 0;
t_step = dt;
keep_steps = 0;
t_final = t_step*(length(ddyi) - 1 + keep_steps);
t_vect = (t_inicial:t_step:t_final)'; %4175

% Tiempos simulación
t_inicial_simu = 0;
t_step_simu = 1/1000;
keep_steps_simu = 0;
tsf_secs = 45; % 45 segundos de simulación deseo
tsf = t_step_simu^-1*tsf_secs;
t_final_simu = t_step_simu*(tsf - 1 + keep_steps);
t_vect_simu = (t_inicial_simu:t_step_simu:t_final_simu)';

%% Simulación
ddyi_sim = [t_vect [ddyi ; zeros(keep_steps,1)]];

out = sim("vdPWalker_Belykh_etal_2017.slx");
despl = out.simout.Data;

syms x
figure
plot(t_vect,ddyi/60,'Color','r')
hold on
plot(t_vect_simu,despl,'Color','k')
fplot(sin(wi*x-1.1)/50)
hold off
xlabel('Tiempo (t) [sec]')
ylabel('Desplazamiento (y escalados)')
legend(Registro, 'vdPWalkerBelykh2017', 'Función Seno')
