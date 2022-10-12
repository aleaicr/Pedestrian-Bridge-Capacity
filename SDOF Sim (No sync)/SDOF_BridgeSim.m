%% Simulación 1GDL, N Personas
% Se obtiene la respuest de 1 carro (1GDL) con N personas arriba
% que ejercen fuerzas horizontales al caminar, 

%% Inicialziar
clear variables
close all
clc

%% Comentarios
% Mejor ocupar/importar/correr el archivo Rnd_Properties_Generator para
% obtener las propiedades aleatorias incluyendo caantidad de peatones en
% grupos, (parejas,trios,grupos...)

%% Cantidad máxima de peatones
n_min = 1;
n_max = 500;
n_step = 1;
peatones = (n_min:n_step:n_max)';
peatones_length = length(peatones);

%% Propiedades Sistema 1GDL
% Ingreso propiedades de Marcheggiani & Lenci (2009) Figura 5, pág 7
m = 113000; %                                                               % Masa del carro
k = 4730000; %                                                              % Rigidez resorte
c = 11000; %                                                                % Amortiguamiento

% xi = 0.0075, Omega = sqrt(K/M) = 6.47 -> freq = 

%% Propiedades de peatones
% Fuerza del peatón i ->   F_i = G_i * sin(2*pi*freq_i*t+phi_i)

% Amplitud sinusoide (M&L 2009)
mu_G = 30; % N
sigma_G = 5; % N
G_vect = normrnd(mu_G,sigma_G,[n_max,1]);

% Frecuencias sinusoide
mu_freq = 1.03; % hz
sigma_freq = 0.2; % hz
freq_vect = normrnd(mu_freq,sigma_freq,[n_max,1]);

% Desfase sinusoide                                                         % Es uniforme, no tiene porqué haber una distribución normal
desfase_vect = 2*pi*rand(n_max,1);                                          % Quizás podría ser solamente entre 0 y pi/2

%% Tiempo para añadir
% Tiempo que se demora para añadir al peatón i
Tadd_min = 0;
Tadd_max = 5;
Taddvectprima = randi([Tadd_min,Tadd_max],[n_max-1,1]);
Tadd_vect = [0;Taddvectprima];

%% Mostrar en tabla 
tabla = table();
tabla.Peaton = peatones;
tabla.Tadd = Tadd_vect;
tabla.Amplitud = G_vect;
tabla.Frecuencia = freq_vect;
tabla.Desfase = desfase_vect;
disp(tabla)
clear tabla

%% Figura Fuerza en función del tiempo
% t_init = 0;
% t_final = 1800;
% t_step = 0.1;
% t_vect = (t_init:t_step:t_final)';
syms t;
F_vect = G_vect.*sin(2*pi*freq_vect*t+desfase_vect);
figure
fplot(F_vect)
xlabel('tiempo (t) [sec]')
ylabel('Fuerza (F) [N]')
title('Fuerza realizada por peatones')
grid on

%% Figura Peatones en puente vs tiempo
Tadd_cum = cumsum(Tadd_vect);
figure
stairs(Tadd_cum,peatones)
ylim([0,n_max])
grid on
xlabel('tiempo (t) [sec]')
ylabel('Cantidad de peatones en puente')
title('Cantidad de peatones simultáneamente en el puente')

%% Representación espacio estado
% de 1GDL -> carrito
% dx = Ax + Bp,  x = [u,du], p = sum(G_i sin(omega_i t + phi_i))
A = [0 1; -k/m -c/m];                                                       % x = dx,x
B = [0; 1];                                                                 % u -> solo a aceleración
C = [1 0; 0 1; -k/m -c/m];                                                  % y = x,dx,ddx
D = [0; 0; 0];

%% Simulación
t_start = 0;                                                                % Tiempo inicial de la simulación
t_step = 1/400;                                                             % Paso temporal
t_LastPed = 10;                                                             % Tiempo que el último peatón 
t_stop = sum(Tadd_vect) + t_LastPed;                                        % Tiempo de parada de la simulación

t_vect = (t_start:t_step:t_stop)';                                          % Vector de tiempo
t_length = length(t_vect);


% Tiempo al que se añade cada peatón
tAdd_vect = zeros(peatones_length,1);
for i = 1:peatones_length
    tAdd_vect(i) = Tadd_vect(i)*t_step^-1 + 1;
end

senos_peatones = G_vect'.*sin((2*pi*freq_vect)'.*t_vect+desfase_vect');     % Matriz (horizontal peatones, vertical tiempo), sumo horizontalmente
% 2*pi*freq_i = omega_i = frecuencia circular
% Considerar que para tiempos menores a Tadd del peatón, este no hace
% fuerza en puente

for i = 2:peatones_length
    tau_Tadd = t_step^-1*(sum(Tadd_vect(1:i))); 
    senos_peatones(:,i) = senos_peatones(:,i).*[zeros(tau_Tadd,1); ones(t_length - tau_Tadd,1)];
end

F_vect = sum(senos_peatones,2);                                             % Suma horizontal para obtener las fuerzas                                         

figure
yyaxis right
plot(t_vect,F_vect)
xlabel('Tiempo (t) [sec]')
ylabel('Suma de Fuerzas [F]')
hold on
yyaxis left
stairs(Tadd_cum,peatones)
hold off
xlabel('Tiempo (t) [sec]')
ylabel('Cantidad de Peatones sobre el puente')
legend('Patrón de ingreso de peatones','Fuerzas Peatones sobre Puente')
grid on

tF_vect = [t_vect F_vect];                                                  % Fuerza asociada a tiempo para ingresar a simulink

out = sim('simSDOF.slx');

x = out.simout.Data(:,1);
dx = out.simout.Data(:,2);
ddx = out.simout.Data(:,3);

figure
plot(out.tout,abs(x))
xlabel('Tiempo (t) [sec]')
ylabel('Desplazamiento (x) [unidad]')
grid on

%%% COMENTARIOS PARA 02-OCT-2022
% En vez de generar los parámetros acá, tener un archivo que genere las
% propiedades aleatoriamente e importar los datos (con correr el archivo,
% ya genera propiedades

%%% Generar varios para que se vea bonito (generar figura también y poner
%%% en ppt)

% t_prolongacion = 10;
% 
% prol = 0;
% t_stop = Tadd_vect(2) - t_step;
% t_next = Tadd_vect(2);
% x = [];
% tstartn = Tadd_vect(1);
% tstartnm1 = Tadd_vect(2);
% for n = 1:n_max
%     % Parámetros simulación
%     Tadd = Tadd_vect(1:n);                                                  % Vector de tiempos para la simulación 'n'
%     G = G_vect(1:n);                                                        % Vector de amplitudes (de sinusoide) para la simulación 'n'
%     freq = freq_vect(1:n);                                                  % Vector de frecuencias (de sinusoide) para la simulación 'n'
%     desfase = desfase_vect(1:n);
%     
%     %%%% CON INTERP1() genero fuerzas, y solo ingreso vector de fuerzas con
%     %%%% tiempo en simulink (y) y tamos
%     
%     time_vect = t_start:t_step:(t_next-t_step);                             % Vector de tiempos de la simulación 'n' (n peatones)
%     for j = 1:n
%         % generar vector de fuerzas sumando todas las componentes
%         
%     end
%     
% 
%     % Simular
%     out = sim('simSDOF.slx');                                               % Simulación
%     
%     % Extraer información (simulation output)
%     x_new = out.simout.Data;                                                    % Desplazamiento de sist.1GDL
%     dx_new = out.simout.Data;                                                   % Velocidad de sist.1GDL
%     ddx_new = out.simout.Data;                                                  % Aceleración de sist.1GDL
%     
%     x(t_start:t_stop) = [x; x_new];                                                         %%%%%% Va a reescribir hartas veces en memoria
%     dx(tstartn:(tstartnm1-1)) = [dx; dx_new];
%     ddx(tstartn:(tstartnm1-1)) = [ddx; ddx_new];
% 
%     % Recalcular tiempo de simulacion siguiente
%     t_start = t_start + Tadd_vect(n);                                       %
%     t_stop = t_stop + Tadd_vect(n+1) - t_step + prol;                        % Sumar todos los tiempos, hasta que entre el siguiente peatón ¿? -> no necesariamente  t_f
%     
%     % Condiciones iniciales de iteración siguiente
%     x0 = [x_new(end); dx_new(end)];                                         % Condiciones iniciales serán las últimas de
%     
%     % Dejar vibrando el sistema después de que se añade el último peatón
%     if n == n_max
%         prol = prolongacion;
%     end
%     % Para evitar hacer el if en cada iteración, se puede iterar hasta
%     % n_max-1 y la última se realiza fuera del ciclo for, pero el código
%     % quedaría feo
% end