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
E_min = 200*10^3*10^3;
E_max = 700*10^3*10^3;
b_min = 0.2;
b_max = 5;
h_min = 0.2;
h_max = 2;
rho_vol_min = 1;
rho_vol_max = 20;

% Objetivos
omega_obj = 6; % rad/seg
error_omega = 0.2;

displ_obj = 0.05; % 5cm
error_disp = 0.002;

% Iniciar
omega = 0;
displ = 0;
count = 0;
count_limit = 1000;



%% No clear
L = 144; % m                                                                % Largo del tramo del puente a analizar
frec = 1.8; % hz                                                            % Frecuencia con que una persona da un paso (izquierdo o derecho)
Omega = 2*pi*frec/2; % rad/sec                                              % Frecuencia circular del caminar de las personas (horizontal es la mitad de vertical)
Ppm = 5.6;  % personas/m                                                    % Personas por metro lineal
Pv_singlePerson = 0.686; % kN/persona                                       % Fuerza Vertical del caminar
Pv = Ppm*Pv_singlePerson; %kN/m                                             % Fuerza vertical por grupo de personas en un metro lineal
porc_P0 = 0.15; % Fhorizontal = 15%*Fvertical                               % Porcentaje de la fuerza vertical que corresponde a la fuerza horizontal
Po = porc_P0*Pv; % kN/m                                                     % Fuerza horizontal aplicada por las personas
% Mpuente = rho_lin*L; % 50377.709 % kg                                       % Masa del puente                                
cant_modos = 2;                                                             % Cantidad de modos de vibrar a considerar                         
xi = 7/100;                                                                 % Razón de amortiguamiento (será igual para todos los modos)
zrmodal = xi*ones(cant_modos,1);                                            % Vector de razones de amortiguamiento para cada modo

syms x t

% Discretización del puente
cant_particiones = 4;                                                      % Cantidad de particiones para discretizar el puente
x_vals = 0:L/cant_particiones:L;                                            % Discretización del puente

% Fuerzas peatonales
P = Po*sin(Omega*t);                                                        % Carga horizontal distribuida en el puente

% Parámetros simulaciones
t_init = 0;                                                                 % Tiempo inicial de la simulación
t_final = 40;                                                               % Tiempo final de la simulación
t_step = 1/10;                                                              % Paso temporal de la simulación

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
while and(abs(omega - omega_obj) > error_omega, abs(displ - displ_obj) > error_disp)
    % Variables aleatorias
    E = (E_max - E_min)*rand('double') + E_min;
    b = (b_max - b_min)*rand('double') + b_min;
    h = (h_max - h_min)*rand('double') + h_min;
    rho_vol = (rho_vol_max - rho_vol_min)*rand('double') + rho_vol_min;

    % Ejecutar modelo
    run MDOF_Pbridge_SysID.m
    
    % Guardar parámetros
    dampFunct = damp(modelo);
    omega = dampFunct(1);   % rad/sec
    displ = max_desp;   % m
    fprintf('omega %.2f rad/s; displ %.2f cm \n\n',omega,displ*100);
    
    % Auxiliar para impedir loop infinito
    count = count + 1;
    if count == count_limit                                                 % Para que no se quede pegado
        break
    end
end



%% Mostrar parámetros
fprintf('\n\n')
tabla = table();
tabla.omega_rad_s = omega;
tabla.displ_cm = displ*100;
tabla.count = count;
disp(tabla)

tabla = table();
tabla.E = E;
tabla.b = b;
tabla.h = h;
tabla.rhovol = rho_vol;
disp(tabla)
clear tabla