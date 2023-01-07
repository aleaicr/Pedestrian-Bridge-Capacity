%% MDOF Pedestrian Bridge Model
% Alexis Contreras R.

% Verificar que en Pe_vect_generator.m se tienen los mismos parámetros que
% se desean para el modelo, correr el archivo (Pe_vect_generator.m) para que genere el
% archivo que se carga en esta simulación (Pe_vect_data.mat). Verificar
% sobre todoe el tiempo inicial, y el paso temporal, deben ser iguales.
% Verificar también las propiedades, deben ser las mismas

% La simulación se realiza en archivo Bridge_simu_E0.slx

%% Inicializar
clear variables
close all
clc

%% Imput del Modelo
tic
E = 4.9379*10^8; % 200GPa = E9 Pa(N/m2) = E6 kN/m2                             % Modulo de young del material del puente, desde SysID
b = 1.9955; % m                                                             % Ancho de losa de puente, desde SysID
h = 0.32905; % m                                                              % Espesor de losa de puente, desde SysID
rho_vol = 5.667; % kg/m3                                                   % Densidad volumétrica de masa del puente, desde SysID
I = 1/12*h*b^3; % m4                                                        % Inercia de la sección del puente 
A = b*h; % m2                                                               % Area de la sección puente
rho_lin = rho_vol*A; % kg/m                                                 % Densidad lineal del puente
L = 144; % m                                                                % Largo del tramo del puente a analizar
frec = 1.8; % hz                                                            % Frecuencia con que una persona da un paso (izquierdo o derecho), source: Pachi & Ji 2004
Omega = 2*pi*frec/2; % rad/sec                                              % Frecuencia circular del caminar de las personas (horizontal es la mitad de vertical)
Ppm = 5.6;  % personas/m                                                    % Personas por metro lineal, source: Dallard P. et al 2001
Pv_singlePerson = 0.686; % kN/persona                                       % Fuerza Vertical del caminar, persona de masa 70kg
Pv = Ppm*Pv_singlePerson; %kN/m                                             % Fuerza vertical por grupo de personas en un metro lineal
porc_P0 = 0.15; % Fhorizontal = 15%*Fvertical                               % Porcentaje de la fuerza vertical que corresponde a la fuerza horizontal
Po = porc_P0*Pv; % kN/m                                                     % Fuerza horizontal aplicada por las personas
Mpuente = rho_lin*L; % 50377.709 % kg                                       % Masa del puente                                
cant_modos = 2;                                                             % Cantidad de modos de vibrar a considerar                         
xi = 0.7/100;                                                                 % Razón de amortiguamiento (será igual para todos los modos), source: Dallard P. et al 2001
zrmodal = xi*ones(cant_modos,1);                                            % Vector de razones de amortiguamiento para cada modo

syms x % t                                                                    

% Discretización del puente
cant_particiones = 4;                                                       % Cantidad de particiones para discretizar el puente
x_vals = 0:L/cant_particiones:L;                                            % Discretización del puente

% % Fuerzas peatonales
% P = Po*sin(Omega*t);                                                        % Carga horizontal distribuida en el puente

% Parámetros simulaciones
t_init = 0;                                                                 % Tiempo inicial de la simulación
t_final = 40;                                                               % Tiempo final de la simulación
t_step = 1/10;                                                              % Paso temporal de la simulación

t_vect = (t_init:t_step:t_final)';
t_length = length(t_vect);

% Condiciones iniciales para simulación
% Si El puente no tiene excitación pero tiene condiciones iniciales
% x0 = [q1_0; q2_0; dq1_0; dq2_0], son los estados
% x0 = [1/20; 1/20; 0; 0];
x0 = 0;                                                                     % Reposo

%% Modos asumidos
psi = sym(zeros(1,cant_modos));
for n = 1:cant_modos
%     psi_string{n} = string(sprintf("sin(%.0fpi*x/L)",n));
    psi(n) = sin(n*pi*x/L);
end

% % Graficar modos
% figure
% fplot(psi)
% xlim([0 L])
% legend(string(psi_string));                                                % psi_string sale desde arriba, hay que descomentarlo si se quiere graficar
% xlabel('Posición en puente [m]')
% ylabel('Forma modal')
% title('Formas Modales de viga equivalente')

% % Derivadas
% dpsi = diff(psi,x);
% ddpsi = diff(dpsi,x);

%% EDM Modos Asumidos
% Aplicar método de modos asumidos a las propiedades de la viga equivalente
% que genera la respuesta del puente en estudio
% Me*ddq(t) + Ce*dq(t) Ke*q(t) = Ge*Pe
[Me,Ke,Ce,Ge] = assumedModes_beam_V2(psi,E,I,rho_lin,A,L,zrmodal);

%% Espacio Estado - Puente 
% Modelo de viga equivalente queda representado en SpaceState
[modelo,As,Bs,Cs,Ds] = SpaceState_bridge(cant_modos,Me,Ke,Ce,Ge);

% Mostrar propiedades del modelo
damp(modelo)

%% Simulación puente
% Simulación del puente para la carga equivalente peatonal sinusoidal Pe

% Excitación
Pevect_data = load('Pe_vect_data.mat');
Pe_vect_sim = [t_vect Pevect_data.Pe_vect(1:t_length,:)];                   % Cortamos para el tiempo que se quiere simular
% Pe_vect contiene [Pe1 Pe2](100x2)

% Ejecutar simulación
out = sim('Bridge_simu');                                                   % Ejecución de modelo simulink para puente

%% Desplazamientos
% Discretizando 
u_bridge = sum(out.q.Data*psi.',2);                                                % Malo, porq hay que sumar los modos

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



