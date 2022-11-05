%% System Identification for Pedestrian Bridge
% Alexis Contreras R.
% Pedestrian Bridge Capacity

% Búsqueda de parámetros para "identificación de sistema" simplificado,
% igualando lo máximo posible la frecuencia y el desplazamiento, 6rad/sec y
% 5cm respectivamente para el London's Millenium Bridge

%% Inicializar
clear variables
close all
clc

%% Inputs
E_min = 200*10^3*10^3;
E_max = 600*10^3*10^3;
b_min = 1;
b_max = 5;
h_min = 0.2;
h_max = 2;
rho_vol_min = 20;
rho_vol_max = 200;

omega = 0;
omega_obj = 6; % rad/seg
error_omega = 0.2;

disp = 0;
disp_obj = 0.05; % 5cm
error_disp = 0.003;

count = 0;
count_limit = 1000;

%% Búsqueda de parámetros
while abs(omega - omega_obj) < error_omega && abs(disp - disp_obj) < error_disp
    E = randi([E_min E_max]);
    b = randi([b_min b_max]);
    h = randi([h_min h_max]);
    rho_vol = randi([rho_vol_min rho_vol_max]);
    run MDOF_Pbridge_SysID.m
    dampFunct = damp(modelo);
    omega = dampFunct(1);
    disp = max_desp;
    count = count + 1;
    if count == count_limit                                                 % Para que no se quede pegado
        break
    end
end

%% Mostrar parámetros
tabla = table();
tabla.E = E;
tabla.b = b;
tabla.h = h;
tabla.rhovol = rho_vol;
disp(tabla)
clear tabla