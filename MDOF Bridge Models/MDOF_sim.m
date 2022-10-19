%% PROYECTO DINAMICA AVANZADA
% Alexis Contreras R.
% Pedestrian Bridge Capacity
% MODELO PUENTE

% Verificar que en Pe_vect_generator.m se tienen los mismos parámetros que
% se desean acá, correr el archivo (Pe_vect_generator.m) para que genere el
% archivo que se carga en esta simulación (Pe_vect_data.mat).

% La simulación se realiza en archivo Bridge_simu_E0.slx

%% Inicializar
clear variables
close all
clc

%% Imput del Modelo
tic
E = 430*10^3*10^3; % 200GPa = E9 Pa(N/m2) = E6 kN/m2                        % Modulo de young del material del puente
b = 4.5; % m                                                                % Ancho de losa de puente
h = 1; % m                                                                  % Espesor de losa de puente
I = 1/12*h*b^3; % m4                                                        % Inercia de la sección del puente 
A = b*h; % m2                                                               % Area de la sección puente
rho_vol = 1; % kg/m3                                                        % Densidad volumétrica del puente
rho_lin = rho_vol*A; % kg/m                                                 % Densidad lineal del puente
L = 144; % m                                                                % Largo del tramo del puente a analizar
frec = 1.8; % hz                                                            % Frecuencia con que una persona da un paso (izquierdo o derecho)
Omega = 2*pi*frec/2; % rad/sec                                              % Frecuencia circular del caminar de las personas (horizontal es la mitad de vertical)
Ppm = 15;  % personas/m                                                     % Personas por metro lineal
Pv_singlePerson = 1; % kN/persona                                           % Fuerza Vertical del caminar
Pv = Ppm*Pv_singlePerson; %kN/m                                             % Fuerza vertical por grupo de personas en un metro lineal
porc_P0 = 0.15; % Fhorizontal = 15%*Fvertical                               % Porcentaje de la fuerza vertical que corresponde a la fuerza horizontal
Po = porc_P0*Pv; % kN/m                                                     % Fuerza horizontal aplicada por las personas
Mpuente = rho_lin*L; % 50377.709 % kg                                       % Masa del puente                                
xi = 1/100;
cant_modos = 5;                                                             % Cantidad de modos de vibrar a considerar                         
zrmodal = xi*diag(ones(cant_modos));                                        % Vector

syms x t                                                                    
% viga -> E,rho,I,A,L
% x: posición para función de forma (0 < x < L)

% Discretización del puente
cant_particiones = 10;                                                      % Cantidad de particiones para discretizar el puente
x_vals = 0:L/cant_particiones:L;                                            % Discretización del puente

% Fuerzas peatonales
P = Po*sin(Omega*t);                                                        % Carga horizontal distribuida en el puente

% Parámetros simulaciones
t_init = 0;                                                                 % Tiempo inicial de la simulación
t_final = 30;                                                               % Tiempo final de la simulación
t_step = 1/1000;                                                            % Paso temporal de la simulación

t_vect = (t_init:t_step:t_final)';
t_length = length(t_vect);

%% Modos asumidos
% psi_n = sin(n*pi*x/L)

psi = sym(zeros(1,cant_modos));
for n = 1:cant_modos
    psi(n) = sin(n*pi*x/L);
end

% % Graficar modos
% figure
% fplot(psi)
% xlim([0 L])
% legend(string(psi));
% xlabel('Posición en puente [m]')
% ylabel('Forma modal')
% title('Formas Modales')

% Derivadas
dpsi = diff(psi,x);
ddpsi = diff(dpsi,x);


%% EDM Modos Asumidos
% Me*ddq(t) + Ce*dq(t) Ke*q(t) = Ge*Pe
[Me,Ke,Ce,Pe,Ge,wn] = assumedModes_beam(psi,E,I,rho,A,L,zrmodal,P);

%% Espacio Estado - Puente 
% Respuesta del sistema dinámico uilizando Integracion Directa 
[modelo,As,Bs,Cs,Ds] = SpaceState_bridge(cant_modos,Me,Ke,Ce,Ge);

% Condiciones Iniciales
x0 = 0;                                                                     % Reposo

% Mostrar propiedades del modelo
damp(modelo)

%% Simulación puente
% Simulación del puente para la carga equivalente peatonal sinusoidal Pe

% Como el puente parte sin excitación, el vector Pe_vect solo son zeros
% para cada peatón

Pe_vect = [];
Pe_vect_sim = [t_vect Pe_vect];
% id est [0 Pe1 Pe2; 0.1 Pe1 Pe2; 0.2....];

% Ejecutar simulación
out = sim('Bridge_simu_E0');                                                % Ejecución de modelo simulink para puente

%% Desplazamientos
% Discretizando 
u_bridge = out.q.Data.*psi;
% [mdesp,ndesp] = size(u_bridge);                                           % mdesp = tiempos, ndesp = 1

% Desplazamiento máximo
max_desp = 0;
for j = 1:length(x_vals)                                                    % Utilizando las particiones de x, determinamos el desplazamiento máximo del puente SIN TMD
    desplpuente_en_x = max(double(subs(u_bridge,x,x_vals(j))));
    if abs(desplpuente_en_x) > max_desp
        max_desp = abs(desplpuente_en_x);                                   % Se guarda el desplazamiento 
    end
end

fprintf('El desplazamiento máximo que experimenta el puente es despl_max = %.2f metros (%.2f cm)\n',max_desp,max_desp*100)

toc