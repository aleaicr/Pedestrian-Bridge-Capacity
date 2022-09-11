%% Simulación 1 Carro, N personas
% Se obtiene la respuesta máxima de 1 carro (1GDL) con N personas arriba
% que ejercen fuerzas horizontales al caminar, 


%% Inicialziar
clear variables
close all
clc

%% Cantidad máxima de peatones
n_max = 20;

%% Propiedades Sistema 1GDL
m = 1; % kg                                                                 % Masa del carro
k = 1; % N/m                                                                % Rigidez resorte
c = 1; % N/(m/s)                                                            % Amortiguamiento

%% Propiedades de peatones
% Fuerza de peatón i ->   F = G_i * sin(freq_i*t)

% Amplitud sinusoide
mu_G = 10; % N
sigma_G = 1; % N
G_vect = normrnd(mu_G,sigma_G,[n_max,1]);

% Frecuencias sinusoide
mu_freq = 1.8; % hz
sigma_freq = 0.5; % hz
freq_vect = normrnd(mu_freq,sigma_freq,[n_max,1]);

% Desfase sinusoide                                                         % Es uniforme, no tiene porqué haber una distribución normal
desfase_vect = 2*pi*rand(n_max,1);                                          % Quizás podría ser solamente entre 0 y pi/2

% Las fuerzas de cada peatón son:
% F_i(t) = G_i*sin(freq_i *t + desfase_i)

%% Mostrar en tabla 
tabla = table();
tabla.Peaton = (1:1:n_max)';
tabla.Amplitud = G_vect;
tabla.Frecuencia = freq_vect;
tabla.Desfase = desfase_vect;
disp(tabla)
clear tabla

%% Vector de fuerzas
t_init = 0;
t_final = 1800;
t_step = 0.1;
t_vect = (t_init:t_step:t_final)';
syms t;
F_vect = G_vect.*sin(freq_vect*t+desfase_vect);
figure
fplot(F_vect)

%% Representación espacio estado
% de 1GDL -> carrito
% dx = Ax + Bp,  x = [u,du], p = sum(G_i sin(omega_i t + phi_i))
A = [0 1; -k/m -c/m];
B = [0; 1];
C = [1 0; 0 1; -k/m -c/m];
D = [0; 0; 0];

%% Simulación

% for n = 1:n_max
%     Tadd = Tadd_vect(n);
%     G = G_vect(n);
%     freq = freq_vect(n);
%     desfase = desfase_vect(n);
% end