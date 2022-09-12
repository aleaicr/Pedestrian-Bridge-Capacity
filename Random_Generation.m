%% Generador de parámetros aleatorios
% Se generan vectores con los parámetros de forma aleatoria con una
% distribución normal

%% Inicializar
clear variables
close all
clc

%% Cantidad máxima de peatones
n_max = 100;                                                                 % Cantidad máxima de peatones a considerar
n_vect = (1:1:n_max)';
%% Masa
mu_m = 70;  % kg                                                            % Media de la distribución de masa
sigma_m = 3; % kg                                                           % Desviación estándar de la distribución de masa
m_vect = normrnd(mu_m,sigma_m,[n_max,1]);                                       % Valores aleatorios de masa para 'n' peatones

%% Velocidad
mu_v = 5; % km/h                                                            % Media
sigma_v = 1; % km/h                                                         % Desviación estándar
v_vect = normrnd(mu_v,sigma_v,[n_max,1]);                                       % Vector

%% Frecuencia caminar
mu_freq = 1.8; % hz                                                         % Media                                                       
sigma_freq = 0.5;  % hz                                                     % Desviación estándar
freq_vect = normrnd(mu_freq,sigma_freq,[n_max,1]);                              % Vector

%% Tiempo para añadir
% Tiempo que se demora para añadir al peatón i
Tadd_min = 0;
Tadd_max = 15;
Taddvectprima = randi([Tadd_min,Tadd_max],[n_max-1,1]);
Tadd_vect = [0;Taddvectprima];

%% Lado para añadir
% Desde que lado del puente entra la persona Lado 1 (x=0) o Lado 2 (x=L)
side = randi([1,2],[n_max,1]);

%% Mostrar tabla
tabla = table();
tabla.Peaton = (1:1:n_max)';
tabla.Tadd = Tadd_vect;
tabla.lado = side;
tabla.Masa = m_vect;
tabla.Velocidad = v_vect;
disp(tabla)                                                                 % Se muestra tabla
clear tabla

%% Histogramas
% Para verificar que siguen distribución normal
figure
hold on
histogram(m_vect,'Normalization','pdf');
histogram(v_vect,'Normalization','pdf');
histogram(freq_vect,'Normalization','pdf');
histogram(Tadd_vect,'Normalization','pdf');
hold off
legend('Masa','Velocidad','Frecuencia','Tadd')

%% Eliminar variables que ya no me sirven
% O se podría definir la misma variable mu y sigma en cada parámetro y solo
% borrar mu y sigma (clear mu sigma)