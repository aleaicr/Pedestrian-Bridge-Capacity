%% Generador de parámetros aleatorios
% Genera un archivo cargable (load) de propiedades aleatorias de los
% peatones

%% Comentarios
% TRANSFORMAR A FUNCIÓN PARA IMPLEMENTAR EN SIMULACIONES

%% Inicializar
clear variables
close all
clc

%% Inputs
n_min = 1;                                                                  % Primer peatones es 1, si quiero ir de 100 a 200, parto del 101, no del 100
n_max = 50;
n_step = 1;                                                                 % Cuantos peatones van en "cada peatón"/grupo

mu_m = 80;  % kg                                                            % Media de la distribución de masa
sigma_m = 15; % kg                                                          % Desviación estándar de la distribución de masa
mu_v = 5; % km/h                                                            % Media
sigma_v = 2; % km/h                                                         % Desviación estándar
mu_freq = 1.8; % hz                                                         % Media                                                       
sigma_freq = 0.8;  % hz                                                     % Desviación estándar
Tadd_min = 0;
Tadd_max = 5;

%% Peatones y grupos
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
%     np = np;
else
    group_or_ped = grupos;
    np = ng;
end

%% Velocidad
v_vect = normrnd(mu_v,sigma_v,[np,1]);

%% Tiempo para añadir
% Tiempo que se demora para añadir al peatón i
Taddvectprima = randi([Tadd_min,Tadd_max],[np-1,1]);
Tadd_vect = [0;Taddvectprima];

% Acumulado (stairs)
Tadd_cum = cumsum(Tadd_vect);

%% Lado para añadir
% Desde que lado del puente entra la persona Lado 1 (x=0) o Lado 2 (x=L)
side = randi([1,2],[np,1]);

%% Mostrar tabla
tabla = table();
if n_step == 1
    tabla.Peaton = peatones;
else
    tabla.Grupo = num_grupo;
end
tabla.Velocidad = v_vect;
tabla.lado = side;
tabla.Tadd = Tadd_cum;
disp(tabla)                                                                 % Se muestra tabla
clear tabla

%% Guardar en archivo .mat
% Guardamos las propiedades creadas

matObj = matfile('rPedestrianProperties.mat');
matObj.Properties.Writable = true;
matObj.v = v_vect;
matObj.Side = side;
matObj.Taddacum = Tadd_cum;
clear matObj
