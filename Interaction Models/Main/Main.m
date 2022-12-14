%% Continuos Beam and Pedestrians Walking
% Alexis Contreras R.

% Comentarios
%

%% Inicilizar
clear variables
close all
clc

%%  Inputs
% Inputs Generales
n_sim = 1;                                                                  % Cantidad de simulaciones a realizar (cantidad de veces que se seleccionarán n peatones)
bp_name = 'Bridge_Properties.mat';                                          % Nombre del archivo que contiene los datos del puente
sim_name = 'PedBridge_sim.slx';                                             % Nombre del Simulink para ejecutar la simulación
n_modos = 3;                                                                % Cantidad de modos asumidos para la respuesta dinámica de la viga equivalente
x_parts = 10;                                                               % Cantidad de puntos para calcular el desplazamiento máximo

% Cantidad de peatones
n_min = 1;                                                                  % Primer peatones es 1, si quiero ir de 100 a 200, parto del 101, no del 100
n_max = 20;                                                                 % Cantidad máxima de peatones
n_step = 1;                                                                 % Cuantos peatones van en "cada peatón"/grupo (fijar como 1, no se puede juntar con lel modelo de Belykh et al 2017

% Distribución normal Masa (Johnson et al 2008)
mu_m = 71.81;  % kg                                                         % Media de la distribución de masa
sigma_m = 14.89; % kg                                                       % Desviación estándar de la distribución de masa

% Distribución normal Velocidad (Pachi & Ji, 2005)
mu_v = 1.3; % m/s                                                           % Media
sigma_v = 0.13; % m/s                                                        % Desviación estándar

% Distribución normal Frecuencia (Pachi & Ji 2005)
mu_freq = 1.8; % hz                                                         % Media                                                       
sigma_freq = 0.11;  % hz                                                    % Desviación estándar

% Distribución normal Propiedades de Modelo de Belykh et al 2017
% ai
mu_ai = 1;
sigma_ai = 0.1;
% lambda_i
mu_lambdai = 1;
sigma_lambdai = 0.1;

% Tiempo de incorporación, distribución uniforme
Tadd_min = 0; % sec                                                         % Tiempo de añadir mínimo
Tadd_max = 5; % sec                                                         % Tiempo de añadir máximo (que espera el peatón i para incorporarse)

% Tiempo de simulación
t_inicial = 0;                                                              % Tiempo inicial de simulación
t_step = 1/1000;                                                            % Paso temporal de simulación
t_extra = 10;                                                               % Tiempo extra de simulación después de que entra el último peatón

%% Data
BP = load(bp_name);                                                         % Cargar datos del puente
x_vals = (BP.L/x_parts:BP.L/x_parts:L-BP.L/x_parts).';                      % Vector con todos los puntos para evaluar el desplazamiento en el puente
psi_xvals = sinModalShapes_xvals(n_modos,BP.L,x_vals);                      % Matriz con todas las formas modales evaluadas en x_vals

% Generar matrices State-Space
As = BP.As;
Bs = BP.Bs;
Cs = BP.Cs;
Ds = BP.Ds;

% Ejecutar simulaciones
for s = 1:n_sim
    % Generar propiedades aleatorias para cada peatón
    [mi,vi,fi,wi,ai,lambdai,side,Tadd_cum,pos,psi_posi] = NewPedestrianProperties(n_min,n_max,n_step,L,mu_m,sigma_m,mu_v,sigma_v,mu_freq,sigma_freq,mu_ai,sigma_ai,mu_lambdai,sigma_lambdai,Tadd_min,Tadd_max,t_step,t_extra,n_modos);

    % Tiempo máximo de simulación
    t_final = Tadd_cum(end) + t_extra;                                      % Tiempo final de simulación
    t_vect = (t_inicial:t_step:t_final).';                                  % Vector de todos los tiempos
    t_length = length(t_vect);                                              % Cantidad de pasos temporales

    % Ejecutar simulaciones
    out = sim(sim_name);                                                    % realizar la simulación, se obtiene la respuesta del puente
    
    % Vector de tiempo
    t_vect = out.tout.Data(:,1);                                            % Vector de tiempo utilizado en la simulación (igual a t_vect anterior)

    % Componer desplazamiento real para las posiciones x_vals
    y_bridge = genToPhys(psi_xvals,q,x_vals);                               % out.q.Data es la matriz de respuesta en coordenadas generalizadas
end

