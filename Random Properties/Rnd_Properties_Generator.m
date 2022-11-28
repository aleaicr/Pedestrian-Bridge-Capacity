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
n_max = 200;
n_step = 1;                                                                 % Cuantos peatones van en "cada peatón"/grupo

mu_m = 71.91;  % kg                                                            % Media de la distribución de masa
sigma_m = 14.89; % kg                                                          % Desviación estándar de la distribución de masa
mu_v = 1.3; % m/s                                                            % Media
sigma_v = 0.13; % m/s                                                         % Desviación estándar
mu_freq = 1.8; % hz                                                         % Media                                                       
sigma_freq = 0.11;  % hz                                                     % Desviación estándar
Tadd_min = 0;
Tadd_max = 20;

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

%% Masa
m_vect = n_step*normrnd(mu_m,sigma_m,[np,1]);  

%% Velocidad
v_vect = normrnd(mu_v,sigma_v,[np,1]);

%% Frecuencia caminar
freq_vect = normrnd(mu_freq,sigma_freq,[np,1]); 

%% Tiempo para añadir
% Tiempo que se demora para añadir al peatón i
Taddvectprima = randi([Tadd_min,Tadd_max],[np-1,1]);
Tadd_vect = [0;Taddvectprima];

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
tabla.Tadd = Tadd_vect;
tabla.lado = side;
tabla.Masa = m_vect;
tabla.Velocidad = v_vect;
tabla.Frecuencia = freq_vect;
disp(tabla)                                                                 % Se muestra tabla
clear tabla

%% Histogramas
% Para verificar que siguen distribución normal
% figure
% hold on
% histogram(m_vect,'Normalization','pdf');
% histogram(v_vect,'Normalization','pdf');
% histogram(freq_vect,'Normalization','pdf');
% histogram(Tadd_vect,'Normalization','pdf');
% hold off
% grid on
% legend('Masa','Velocidad','Frecuencia','Tadd')

% Masa
figure
histogram(m_vect,[30;40;50;60;70;80;90;100;110;120],'Normalization','pdf')
grid on
legend('Masa')
title('Distribución de masa normalizada(pdf)', 'Johnson et al 2008')
xlabel('Masa [kg]')
ylabel('pdf')

% frecuencia
figure
histogram(freq_vect,'Normalization','pdf')
grid on
legend('Frecuencia')
title('Distribución de frecuencia normalizada(pdf)', 'Pachi et al 2005')
xlabel('Frecuencia [hz]')
ylabel('pdf')

% velocidad
figure
histogram(v_vect,'Normalization','pdf')
grid on
legend('Velocidad')
title('Distribución de velocidad normalizada(pdf)', 'Pachi et al 2005')
xlabel('Velocidad [m/s]')
ylabel('pdf')

% frecuencia vs velocidad
figure
plot(freq_vect,v_vect,'o')
grid on
title('Correlación frecuencia y velocidad')
xlabel('Frecuencia [hz]')
ylabel('Velocidad [m/s]')
xlim([0 2.7])
ylim([0 2.7])

figure
subplot(1,3,1)
histogram(m_vect,[30;40;50;60;70;80;90;100;110;120],'Normalization','probability')
xlabel('Masa [kg]')
title('Johnson et al 2008')
grid on

subplot(1,3,2)
histogram(v_vect,'Normalization','probability')
title('Pachi et al 2005')
xlabel('Velocidad [m/s]')
grid on

subplot(1,3,3)
histogram(freq_vect,'Normalization','probability')
title('Pachi et al 2005')
xlabel('Frecuencia [hz]')
sgtitle('Distribuciones normalizadas (pdf)')
grid on

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
% clear variables
% load('rnd_pedestrian_properties.mat')
