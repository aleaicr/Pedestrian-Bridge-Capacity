%% Generar Pe_vect_data
% Alexis Contreras R.
% Generar archivo Pe_vect_data.mat una vez para ejecutar simulación varias
% veces sin esperar esta parte (que se demora)

%% Inicializar
clear variables
close all
clc

%% 
tic
% Inputs del sistema
L = 144; % m                                                                % Largo del tramo del puente a analizar, source: Dallard P. et al
frec = 1.8; % hz                                                            % Frecuencia del caminar de personas, source: Pachi & Ji 2004
Omega = 2*pi*frec/2; % rad/sec                                              % Frecuencia circular del caminar de las personas
Ppm = 5.6;  % personas/m                                                    % Personas por metro lineal, source: Dallard P. et al 2001
Pv_singlePerson = 0.686; % kN/persona                                       % Fuerza Vertical del caminar, masa persona 70kg
Pv = Ppm*Pv_singlePerson; %kN/m                                             % Fuerza vertical por grupo de personas en un metro lineal
porc_P0 = 0.2; % Fhorizontal = 5%*Fvertical                                 % Porcentaje de la fuerza vertical que corresponde a la fuerza horizontal
Po = porc_P0*Pv; % kN/m                                                     % Fuerza horizontal aplicada por las personas
cant_modos = 1;                                                             % Cantidad de modos

% Tiempo de simulación
t_init = 0;                                                                 % Tiempo inicial de la simulación
t_final = 50;                                                              % Tiempo final de la simulación
t_step = 1/100;                                                              % Paso temporal de la simulación

t_vect = (t_init:t_step:t_final)';
t_length = length(t_vect);

% Variables simbólicas
syms x t

% psis = struct();                                                            % Inicializar struct de todos los psi     
psi = sym(zeros(1,cant_modos));
for i = 1:cant_modos
%     nameVal = strcat('psi',string(i));                                      % Nombre de variable
%     psis.(nameVal) = sin(i*pi*x/L);                                         % Forma modal de cada modo
    psi(i) = sin(i*pi*x/L);
end

% Fuerzas peatonales
P = Po*sin(Omega*t);

% Fuerza peatonal equivalente
Pe = int(P*psi',x,0,L);                                                     % Fuerza externa equivalente 

% Formar Pe_vect_sim
Pe_vect = zeros(t_length,cant_modos);                           
for i = 1:t_length
    t_val = t_vect(i);
    Pe_vect(i,:) = subs(Pe,t,t_val);
end

% Guardar propieades
matObj = matfile('Pe_vect_data');
matObj.Properties.Writable = true;
matObj.Pe_vect = Pe_vect;
matObj.time = t_vect;
clear matObj
toc