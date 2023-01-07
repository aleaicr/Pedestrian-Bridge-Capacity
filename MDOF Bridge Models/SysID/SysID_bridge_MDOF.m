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
% Rango
% E_min = 3*10^8;   % kN/m2
% E_max = 5.5*10^8;  % kN/m2
% b_min = 1;            % m
% b_max = 10;             % m
% h_min = 0.1;           % m
% h_max = 1;              % m
EI_min = 2.5*10^6;  % kNm2                                                        % Rigidez mínima
EI_max = 4.5833*10^10; % kNm2                                                     % Rigidez máxima

rho_vol_min = 1; % kg/m3
rho_vol_max = 7; % kg/m3
% w = sqrt(48*E*I/L^3/(rho_lin*L))
% k = 48*E*I/L^3
% m = rho_lin*L;

% Objetivos
omega_obj = 3.14;       % rad/seg
error_omega = 0.03;
% displ_obj = 0.05;       % 5 cm = 0.05 m 
% error_disp = 0.03;
acc_obj = 225*10^-3*9.81; % m/s2 (dallard et al 2001)
error_acc = 0.2;

% Iniciar
omega = 0;
displ = 0;
iter = 0;
count_limit = 10000000;

%% No clear
L = 144; % m                                                                % Largo del tramo del puente a analizar
frec = 1.8; % hz                                                            % Frecuencia con que una persona da un paso (izquierdo o derecho)
Omega = 2*pi*frec/2; % rad/sec                                              % Frecuencia circular del caminar de las personas (horizontal es la mitad de vertical)
Ppm = 5.6;  % personas/m                                                    % Personas por metro lineal
Pv_singlePerson = 0.686; % kN/persona                                       % Fuerza Vertical del caminar
Pv = Ppm*Pv_singlePerson; %kN/m                                             % Fuerza vertical por grupo de personas en un metro lineal
porc_P0 = 0.15; % Fhorizontal = 15%*Fvertical                               % Porcentaje de la fuerza vertical que corresponde a la fuerza horizontal
Po = porc_P0*Pv; % kN/m                                                     % Fuerza horizontal aplicada por las personas
cant_modos = 1;                                                             % Cantidad de modos de vibrar a considerar                         
xi = 0.7/100;                                                               % Razón de amortiguamiento (será igual para todos los modos)
zrmodal = xi*ones(cant_modos,1);                                            % Vector de razones de amortiguamiento para cada modo

syms x t

% Discretización del puente
% cant_particiones = 2;                                                      % Cantidad de particiones para discretizar el puente
x_vals = L/2;                                                               % Discretización del puente

% Parámetros simulaciones
t_init = 0;                                                                 % Tiempo inicial de la simulación
t_final = 30;                                                                % Tiempo final de la simulación
t_step = 1/20;                                                              % Paso temporal de la simulación

t_vect = (t_init:t_step:t_final)';
t_length = length(t_vect);

% Condiciones iniciales para simulación
x0 = 0;                                                                     % Reposo

% Modos asumidos
psi = sym(zeros(1,cant_modos));
for n = 1:cant_modos
    psi(n) = sin(n*pi*x/L);
end

% Excitación
Pevect_data = load('Pe_vect_data.mat');
Pe_vect_sim = [t_vect Pevect_data.Pe_vect(1:t_length,:)];                   % Cortamos para el tiempo que se quiere simular

%% Búsqueda de parámetros
for i = 1:count_limit
    iter = iter+1;
    % Parámetros aleatorios
    E = (E_max - E_min)*rand('double') + E_min;
    b = (b_max - b_min)*rand('double') + b_min;
    h = (h_max - h_min)*rand('double') + h_min;
    rho_vol = (rho_vol_max - rho_vol_min)*rand('double') + rho_vol_min;

    % Ejecutar modelo
    run MDOF_Pbridge_SysID.m
    
    % Guardar parámetros
    dampFunct = damp(modelo);
    omega = dampFunct(1);   % rad/sec
%     omega = (48*E*I/L^3/(rho_lin*L))^0.5;
    displ = max_desp;   % m
    acc = max_acc; % m/s2
    fprintf('iteración %.0f; omega %.2f rad/s; displ %.2f cm , acc = %.2f [mili - g] \n\n',iter,omega,displ*100, acc*10^3/9.81)
%     if and(abs(omega - omega_obj) < error_omega, and(abs(displ - displ_obj) < error_disp, abs(acc - acc_obj) < error_acc))
%         break
%     end
    if and(abs(omega - omega_obj) < error_omega,  abs(acc - acc_obj) < error_acc)
        break
    end
end

%% Mostrar resultados
fprintf('\n\n')
tabla = table();
tabla.omega_rad_s = omega;
tabla.displ_cm = displ*100;
tabla.acc_milig = acc*10^3/9.81;
tabla.count = iter;
disp(tabla)

tabla = table();
tabla.E = E;
tabla.b = b;
tabla.h = h;
tabla.rhovol = rho_vol;
disp(tabla)
clear tabla