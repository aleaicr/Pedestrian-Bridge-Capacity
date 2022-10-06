%% Generador de parámetros aleatorios
% Genera un archivo cargable (load) de propiedades aleatorias de los
% peatones

%% Comentarios
% TRANSFORMAR A FUNCIÓN PARA IMPLEMENTAR EN SIMULACIONES

%% Inicializar
clear variables
close all
clc

%% Peatones y grupos
n_min = 1;                                                                  % Primer peatones es 1, si quiero ir de 100 a 200, parto del 101, no del 100
n_max = 40;
n_step = 5;                                                                 % Cuantos peatones van en "cada peatón"/grupo

peatones = (n_min:1:n_max)';
grupos = ((n_min-1)+n_step:n_step:n_max)';                                 
np = length(peatones);
ng = length(grupos);                                                        % Cantidad de grupos o peatones
num_grupo = (1:1:ng)';
grupo_stairs = (n_min:n_step:n_max)';

% Comentarios consola
fprintf('Cantidad de peatones n_max = %.0f \n',n_max)
fprintf('Tamaño grupo n_step = %.0f \n',n_step)
fprintf('Cantidad de grupos = %.0f \n \n',ng)

% Vamos a ver grupos o peatones?
if n_step == 1
    group_or_ped = peatones;
else
    group_or_ped = grupos;
end

%% Masa
mu_m = 80;  % kg                                                            % Media de la distribución de masa
sigma_m = 15; % kg                                                          % Desviación estándar de la distribución de masa

if n_step == 1                                                              % Valores aleatorios de masa para 'n' peatones
    m_vect = n_step*normrnd(mu_m,sigma_m,[np,1]);  
else
    m_vect = n_step*normrnd(mu_m,sigma_m,[ng,1]);  
end

%% Velocidad
mu_v = 5; % km/h                                                            % Media
sigma_v = 2; % km/h                                                         % Desviación estándar

if n_step == 1                                                              % Vector
    v_vect = normrnd(mu_v,sigma_v,[np,1]); 
else
    v_vect = normrnd(mu_v,sigma_v,[ng,1]); 
end

%% Frecuencia caminar
mu_freq = 1.8; % hz                                                         % Media                                                       
sigma_freq = 0.8;  % hz                                                     % Desviación estándar

if n_step == 1                                                              % Vector
    freq_vect = normrnd(mu_freq,sigma_freq,[np,1]); 
else
    freq_vect = normrnd(mu_freq,sigma_freq,[ng,1]); 
end

%% Tiempo para añadir
% Tiempo que se demora para añadir al peatón i
Tadd_min = 0;
Tadd_max = 10;
if n_step == 1
    Taddvectprima = randi([Tadd_min,Tadd_max],[np-1,1]);
else
    Taddvectprima = randi([Tadd_min,Tadd_max],[ng-1,1]);
end
Tadd_vect = [0;Taddvectprima];

%% Lado para añadir
% Desde que lado del puente entra la persona Lado 1 (x=0) o Lado 2 (x=L)
if n_step == 1
    side = randi([1,2],[np,1]);
else
    side = randi([1,2],[ng,1]);
end

%% Mostrar tabla

tabla = table();
if n_step == 1
    tabla.Peatones = peatones;
else
    tabla.Grupo = num_grupo;
end
tabla.Tadd = Tadd_vect;
tabla.lado = side;
tabla.Masa = m_vect;
tabla.Velocidad = v_vect;
tabla.Frecuencia = freq_vect;
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
grid on
legend('Masa','Velocidad','Frecuencia','Tadd')

%% Figura Peatones en puente vs tiempo

Tadd_cum = cumsum(Tadd_vect);
figure
if n_step == 1
    stairs(Tadd_cum,peatones)
else
    stairs(Tadd_cum,grupos)
end
ylim([0,n_max])
% xlim([0,Tadd_cum(ng)])
grid on
xlabel('tiempo (t) [sec]')
ylabel('Cantidad de peatones en puente')
title('Cantidad de peatones simultáneamente en el puente')

%% Guardar en archivo .mat
% Guardamos las propiedades creadas

matObj = matfile('rnd_pedestrian_properties.mat');
matObj.Properties.Writable = true;

matObj.n_min = n_min;                                                       % Quizás sea más rápido dejar todo en un struct?
matObj.n_max = n_max;
matObj.nGroup = n_step;
matObj.Tadd = Tadd_vect;
matObj.freq = freq_vect;
matObj.v = v_vect;
matObj.m = m_vect;
matObj.Taddacum = Tadd_cum;
clear matObj

%% Eliminar variables que ya no me sirven
% O se podría definir la misma variable mu y sigma en cada parámetro y solo
% borrar mu y sigma (clear mu sigma)

%% Solo Load
% Dejamos solo las variables que nos importan
clear variables
load('rnd_pedestrian_properties.mat')
