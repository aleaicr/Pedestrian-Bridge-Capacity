%% PROYECTO DINAMICA AVANZADA
% Alexis Contreras R. - Constanza Escalona P.
% Dinámica Estructural Avanzada - 2022(1)
% Escenario 0: Puente sin TMD

% Este script y simulink asociado, actualmente soportan solo dos modos.

% Verificar que en Pe_vect_generator.m se tienen los mismos parámetros que
% se desean acá, correr el archivo (Pe_vect_generator.m) para que genere el
% archivo que se carga en esta simulación (Pe_vect_data.mat). También,
% habría que corregir líneas 159 y 160 si se desean más modos (Pe1_vect_sim
% y Pe2_vect_sim).

% La simulación se realiza en archivo Bridge_TMD_simu_E0.slx

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

% Propiedades TMD
% Ktmd_max = 200000;                                                         % Valor máximo de la rigidez del TMD
% Ktmd_step = 100;                                                           % Paso de la rigidez del TMD
% Ktmd_vect = 50:Ktmd_step:Ktmd_max;                                          % Vector con las rigideces del TMD a evaluar
%  
% porcMtmd_max = 0.5;                                                         % Porcentaje máximo de la masa del TMD en función del peso del puente (Mtmd = 30% Mpuente)
% porcMtmd_step = 0.05;                                                       % Paso de aumento del porncetaje de masa del TMD
% porcMtmd_vect = 0.05:porcMtmd_step:porcMtmd_max;                            % Vector con los porcentajes de masa del TMD a evaluar
% 
% ctmd = 0.01;                                                                % Amortiguamiento del TMD

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

% Forma modal (se almacena en structs)
% psi_n = sin(n*pi*x/L)

psis = struct();                                                            % Inicializar struct     
psi = sym(zeros(1,cant_modos));
for n = 1:cant_modos
    nameVal = strcat('psi',string(n));                                      % Nombre de variable
    psis.(nameVal) = sin(n*pi*x/L);                                         % Forma modal de cada modo
    psi(n) = sin(n*pi*x/L);
end

% % fplot modos
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

% Graficar 
% Para ver que son cinemáticamente admisibles

% Condición 1: cumplir con las condiciones de borde geométricas.
% Condición 2: Funciones continuas y suaves.
% Graficar los modos asumidos, psi
% figure
% hold on
% fplot(psi1,[0 L])
% fplot(psi2,[0 L])
% hold off
% xlabel('x'), ylabel('\psi (x)'), legend('\psi_1','\psi_2')
% grid on

% Condición 3: Debe poseer derivadas de orden mayor. 
% Graficar derivadas espaciales, dpsi
% figure
% hold on
% fplot(dpsi(1),[0 L])
% fplot(dpsi(2),[0 L])
% hold off
% xlabel('x'), ylabel('$\dot{\psi} (x)$','Interpreter','latex'), legend('$\dot{\psi_1}$','$\dot{\psi_2}$','Interpreter','latex')
% grid on

% Condición 4: Deben formar una base.
% Test de ortogonalidad
% test = int(psi1*psi2,x,0,L);    

%% EDM
% Me*ddq(t) + Ke*q(t) = Pe

%% Matriz de masa equivalente
% Me = Mviga
Me = double(int(rho_lin*A*(psi).'*psi,x,0,L));

%% Matriz de rigidez equivalente
% Energía potencial de deformación del puente (viga equivalente)
Ke = double(int(E*I*(ddpsi).'*ddpsi,x,0,L));

%% Fuerza externa equivalente 
% Fuerza peatonal (sinusoide) igual en todo el largo representa que todas
% las personas están sincronizadas
Pe = int(P*psi.',x,0,L);                                                     % Fuerza externa equivalente 
Ge = eye(cant_modos,cant_modos);                                             % Matriz de influencia de Pe (exictación), 2x2

%% Matriz de amortiguamiento equivalente
% Energí­a potencial de deformación del puente (viga equivalente)

% Ce = double(int(xi*(psi)'*psi,x,0,L)); 
% Esta fórmula es para amortiguadores físicos, no es proporcional ni 
% inherente a la estructura necesariamente
 
% % Amortiguamiento de Rayleigh (No ocupar)
% [Phi, lambda] = eig(Ke,Me);                                                 % Problema de valores y vectores propios
% wr = diag(lambda.^0.5);                                                     % Frecuencia de cada modo                                                           % Periodo de cada modo
% Mr = Phi'*Me*Phi;
% Kr = Phi'*Ke*Phi;
% 
% % Utilizando solo los dos primeros modos
% syms alfa beta
% sol = solve(zrmodal(1) - 1/2*(alfa/wr(1) + beta*wr(1)),zrmodal(2) - 1/2*(alfa/wr(2) + beta*wr(2)));
% alfa = double(sol.alfa);
% beta = double(sol.beta);
% clear sol
% % Componer Ce
% Cr = alfa*Mr + beta*Kr;                                                     % alfa es mucho mayor que beta, mucha participación de la masa (cuidado con sobreestimar)
% Ce = alfa*Me + beta*Ke;

% Amortiguamiento proporcional modal
% zrmodal: tiene todos los amortiguamientos que se quieren para cada modo
[~, lambda] = eig(Ke,Me);                                                   % Problema de valores y vectores propios
wn = sqrt(diag(lambda));  
Phi = eye(cant_modos);
Ce = (Me*Phi)*diag(2*zrmodal.*wn./Me).*(Me*Phi).';    % Esto es C

% Cmododal = Phi'*C*Phi                             % Esto es Cr
[Phi, lambda] = eig(Ke,Me);                                                 % Problema de valores y vectores propios
Ce2 = (Me*Phi)*diag(2*zrmodal.*wn./Me).*(Me*Phi).';    % Esto es C

%% Participación modal
% gammae = diag(Me^-1*Ge);    % No está listo, o malo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% OBTENER PARTICIPACIÓN MODAL DE CADA MODO %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Espacio Estado - Puente 
% Respuesta del sistema dinámico uilizando Integracion Directa 

% Ecuacion de Estado 
% dx(t) = As*x(t) + Bs*u(t), donde x(t) = [q1(t) q2(t) dq1(t) dq2(t)] y u(t) = Pe(t) 
As = [zeros(cant_modos) eye(cant_modos); -Me\Ke -Me\Ce];                    % Matriz de estados, 4x4
Bs = [zeros(cant_modos); Me\Ge];                                             % Matriz de influencia de excitacion pe1(t), 4x1

% Ecuacion de Respuesta 
% y = Cs*x + Ds*p(t), donde y = [q1(t); q2(t); dq1; dq2(t);  ddq1(t); ddq2(t)]
Cs = [eye(cant_modos) zeros(cant_modos) ; zeros(cant_modos) eye(cant_modos); -Me\Ke -Me\Ce]; % Matriz de estados, 6x4
Ds = [zeros(cant_modos) ; zeros(cant_modos); Me\Ge];                         % Matriz de influencia de excitacion pe1(t), 6x1

% Condiciones Iniciales
x0 = 0;                                                                     % Reposo

% M
modelo = ss(As,Bs,Cs,Ds);
% bode(modelo)
% eig(modelo_sin_tmd)
damp(modelo)
% modelo

%% Simulación puente
% Simulación del puente para la carga equivalente peatonal sinusoidal Pe

% Cargar los valores de Pe_vect para la simulación
% Fijarse en que tienen los valores de tiempo, Omega, L coherentes con los
% que están en archivo Pe_vect_generator.m
Pe_vect = [];

Pe_vect_sim = [t_vect Pe_vect];
% id est [0 Pe1 Pe2; 0.1 Pe1 Pe2; 0.2....];

% Ejecutar simulación
out = sim('Bridge_simu_E0');                                                % Ejecución de modelo simulink para puente

%% Desplazamientos
% Discretizando 
u_bridge = out.q.Data.*psi;
% u_bridge = out.q.Data(:,1)*psi(1,1) + out.q.Data(:,2)*psi(1,2); % u(x,t) SIN TMD
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