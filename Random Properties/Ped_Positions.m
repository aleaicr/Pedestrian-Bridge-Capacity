%% Pedestrian Position 
% Alexis Contreras R.
% Pedestrian Bridge Capacity

%% Comentarios

%% Inicializar
clear variables
close all
clc

%% Inputs
n_min = 1;
n_max = 40;
n_step = 1;

mu_v = 1.2;  % m/s                                                            % Media de la distribución de masa
sigma_v = 0.3; % m/s                                                          % Desviación estándar de la distribución de masa
Tadd_min = 0;
Tadd_max = 10;

%% Peatones y grupos
peatones = (n_min:1:n_max)';
grupos = ((n_min-1)+n_step:n_step:n_max)';
np = length(peatones);
ng = length(grupos);
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
% Velocidad a la cual camina cada peatón por el puente
v_vect = n_step*normrnd(mu_v,sigma_v,[np,1]);

%% Side
% Lado por el cual entran al puente el peatón
% 1: izquierdo; 2:derecho (un lado y el otro)
side = randi([1,2],[np,1]);

%% Tiempo para añadir
% Tiempo que se demora para añadir al peatón i
Taddvectprima = randi([Tadd_min,Tadd_max],[np-1,1]);
Tadd_vect = [0;Taddvectprima];

%% Mostrar tabla
tabla = table();
if n_step == 1
    tabla.Peaton = peatones;
else
    tabla.Grupo = num_grupo;
end
tabla.Tadd = Tadd_vect;
tabla.lado = side;
tabla.Velocidad = v_vect;
disp(tabla)
clear tabla

%% Calculo de posición de peatón en función del tiempo

% Tiempos
Tadd_cum = cumsum(Tadd_vect);                                               % Tiempo para añadir a persona i
t_simu_minima = Tadd_cum(end);                                              % Requiero que mi tiempo de simulación me permita añadir a todas las personas
dt = 1/10;                                                                  % Paso temporal para determinar las posiciones
t_vect = 0:dt:Tadd_cum(end);                                                % Vector con todos los tiempos hasta el fin de la simulación

% Cambiar vector si el lado del peatón es el 2
for i = 1:length(peatones)
    if side == 1
        x0 = 0;
    elseif side ==2
        x0 = L;                                                             % Lo veo desde el otro lado
        v_vect(i) = -v_vect(i);                                             % Me calcula la dirección desde el otro lado.
    end
end

% pton = 1;                                                                   % Partimos por el peatón 1
% % Necesito obtener la posición de cada peatón en cada tiempo, 
% for t = 1:length(t_vect)
%     if t >= Tadd_cum(pton+1)
%         pton = pton + 1;                                                    % Cambio a mi siguiente peatón
%     end
% end
