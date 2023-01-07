%% New Pedestrian Properties Generator
% This script generates a file named "Pedestrian_Properties.mat" with all
% data, Inputs can be set in another script and just "run
% NewPedestrianPropertiesGenerator.m" to load data in another file

%% Inicializar
clear variables
close all
clc

%% Inputs
% Dejar INPUTS en el script ContinuosBeamAndPedestrian

% Cantidad de peatones
n_min = 1;                                                                  % Primer peatones es 1, si quiero ir de 100 a 200, parto del 101, no del 100
n_max = 20;                                                                 % Cantidad máxima de peatones
n_step = 1;                                                                 % Cuantos peatones van en "cada peatón"/grupo (fijar como 1, no se puede juntar con lel modelo de Belykh et al 2017

% Propiedades puentes (para calcular tiempo de incorporación)
L = 144; % m                                                                % Longitud del puente

% Distribución normal Masa (Johnson et al 2008)
mu_m = 71.81;  % kg                                                         % Media de la distribución de masa
sigma_m = 14.89; % kg                                                       % Desviación estándar de la distribución de masa

% Distribución normal Velocidad (Pachi & Ji, 2005)
mu_v = 1.3; % m/s                                                           % Media
sigma_v = 0.13; % m/                                                        % Desviación estándar

% Distribución normal Frecuencia (Pachi & Ji 2005)
mu_freq = 1.8; % hz                                                         % Media                                                       
sigma_freq = 0.11;  % hz                                                    % Desviación estándar

% Distribución normal Propiedades de Modelo de Belykh et al 2017
% ai
mu_ai = 1;
sigma_si = 0.1;
% lambda_i
mu_lambdai = 1;
sigma_lambdai = 0.1;

% Tiempo de incorporación
Tadd_min = 0; % sec                                                         % Tiempo de añadir mínimo
Tadd_max = 5; % sec                                                         % Tiempo de añadir máximo (que espera el peatón i para incorporarse)

% Tiempo de simulación
t_inicial = 0;                                                              % Tiempo inicial de simulación
t_step = 1/1000;                                                            % Paso temporal de simulación
t_final = 100;                                                              % Tiempo final de simulación, Debería ser el último Tadd_cum + tiempo extra de simulaci´no
t_vect = (t_inicial:t_step:t_final).';                                      % Vector de tiempos
t_length = length(t_vect);                                                  % Cantidad de passo temporales en simulación (puntos)

%% Generación de data
% m_i: masa del peatón i
% v_i: velocidad longitudinal del caminar del peatón i
% w_i: frecuencia angular del caminar del peatón i
% side_i: lado por el cual entra el peatón i
% Tadd_i: tiempo que el peatón i espera para ser incoporado al puente respecto al peatón i-1
% Tadd_cum_i: tiempo en el cual el peatón es incorporado al puente

% Peatones y grupos
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

% Masa
m_vect = normrnd(mu_m,sigma_m,[np,1]);                                      % Distribución normal

% Velocidad
v_vect = normrnd(mu_v,sigma_v,[np,1]);                                      % Distribución normal

% Frecuencia
freq_vect = normrnd(mu_freq,sigma_freq,[np,1]); % hz                              % Distribución normal
w_vect = 2*pi*freq_vect; % rad/sec                                          % Distribución normal

% Propiedades Modelo de Belykh et al 2017

% Tiempo de incorporación
Taddvectprima = randi([Tadd_min,Tadd_max],[np-1,1]);                        % Distribución uniforme
Tadd_vect = [0;Taddvectprima];                                              % El primer peatón, ingresa instantáneamente cuando empieza la simulación                                         
% Acumulado (stairs)
Tadd_cum = cumsum(Tadd_vect);

% Lado
side_vect = randi([1,2],[np,1]);                                            % Dicotómico

%% Mostrar tabla
tabla = table();
if n_step == 1
    tabla.Peaton = peatones;
else
    tabla.Grupo = num_grupo;
end
tabla.Masa_kg = m_vect;
tabla.Velocidad_m_s = v_vect;
tabla.Frecuencia_hz = w_vect;
tabla.Lado = side_vect;
tabla.Taddcum_s = Tadd_cum;
disp(tabla)                                                                 % Se muestra tabla
clear tabla

%% Posición de peatón
% Calcular en cada tiempo (del vector t_vect) la posición de cada peatón
% Renombramiento de variables (script estaba listo de antes)
v = v_vect;                                                                 % Velocidad del peatón
side = side_vect;                                                           % Lado por el que entrea el peatón
tac = Tadd_cum(:,1);                                                        % Tadd_cum (Acumulada) (Tiempo en el que entra el peatón)
pd_length = length(v);                                                      % Cantidad de peatones

% Algoritmo para determinar posición del peatón
% xo(i) = L(side(i)-1) = 0
% X_(tk,i) = xoi*delta1 + v(i)*delta2
% delta1 = 0 si tk < tac(i), 1 si tk >= tac(i)
% delta2 = 0 si tk < tac(i), (tk-tac(i)) si tk >= tac(i)
% n = floor(x_(tk,i)/L)
% x(tk,i) = xi(tk,i)-nL si n par, (n+1)L-x_(tk,i) si n impar

% Aplicación del algoritmo
x = zeros(t_length,pd_length);
x_ = zeros(t_length,pd_length);

for i = 1:pd_length
    for tk = 1:t_length
        xoi = L*(side(i)-1);
        if t_vect(tk) < tac(i)
            delta1 = 0;
            delta2 = 0;
        elseif t_vect(tk) >= tac(i)
            delta1 = 1;
            delta2 = t_vect(tk) - tac(i);
        end
        x_(tk,i) = xoi*delta1 + v(i)*delta2;
        n = floor(x_(tk,i)/L);
        if rem(n,2) == 0
            x(tk,i) = x_(tk,i) - n*L;
        elseif rem(n,2) == 1
            x(tk,i) = (n+1)*L - x_(tk,i);
        end
    end
end


%% Generar archivo cargable "load()"

matObj = matfile('Pedestrian_Properties.mat');
matObj.Properties.Writable = true;
matObj.m = m_vect;                                                          % Vector, Masa de peatones
matObj.v = v_vect;                                                          % Vector, Velocidad de caminar de peatones
matObj.freq = freq_vect;                                                    % Vector, Frecuencia de caminar de peatones
matObj.w = w_vect;                                                          % Vector, Frecuencia angular de peatones
matObj.Side = side;                                                         % Vector, Lado incorporación al puente de peatones
matObj.Taddacum = Tadd_cum;                                                 % Vector, Tiempo de incorporación peatón
matObj.x = x;                                                               % Matriz, Posición peatón en todo tiempo t
clear matObj

