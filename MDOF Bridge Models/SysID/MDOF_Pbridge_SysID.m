%% Modelo Puente Peatonal SysID
% Alexis Contreras R.
% Pedestrian Bridge-Capacity

% %% Inicializar
% clear variables
% close all
% clc

%% Imput del Modelo
% E = 450*10^3*10^3; % 200GPa = E9 Pa(N/m2) = E6 kN/m2                        % Modulo de young del material del puente
% b = 5; % m                                                                  % Ancho de losa de puente
% h = 2; % m                                                                  % Espesor de losa de puente
I = 1/12*h*b^3; % m4                                                        % Inercia de la sección del puente 
A = b*h; % m2                                                               % Area de la sección puente
% rho_vol = 20; % kg/m3                                                       % Densidad volumétrica del puente
rho_lin = rho_vol*A; % kg/m                                                 % Densidad lineal del puente

%% EDM Modos Asumidos
% Aplicar método de modos asumidos a las propiedades de la viga equivalente
% que genera la respuesta del puente en estudio
% Me*ddq(t) + Ce*dq(t) Ke*q(t) = Ge*Pe
[Me,Ke,Ce,Ge] = assumedModes_beam_V2(psi,E,I,rho_lin,A,L,zrmodal);          % assumedModes_beam_V2 está optimizado para realizar menos pasos innecesarios 

%% Espacio Estado - Puente 
% Modelo de viga equivalente queda representado en SpaceState
[As,Bs,Cs,Ds] = SpaceState_bridge_DisplOnly(cant_modos,Me,Ke,Ce,Ge);
modelo = ss(As,Bs,Cs,Ds);
%% Simulación puente
% Simulación del puente para la carga equivalente peatonal sinusoidal Pe

% Ejecutar simulación
out = sim('Bridge_simu_SysID');                                             % Ejecución de modelo simulink para puente

%% Desplazamientos
% Discretizando 
% u_bridge = out.q.Data*psi.';
% [mdesp,ndesp] = size(u_bridge);                                           % mdesp = tiempos, ndesp = 1
% Desplazamiento máximo                                                  % Utilizando las particiones de x, determinamos el desplazamiento máximo del puente SIN TMD
% max_desp = max(double(subs(u_bridge,x,L/2)));

% Solo considerando el primer modo, el mayor desplazamiento ocurre en L/2,
% como la forma modal psi_1(L/2) es 1, entonces el desplazamiento en metros
% no es máx que q_1(t), se busca el máximo en el tiempo no mas

max_desp = max(out.q.Data);