%% vdPWalker Model Testing

% Alexis Contreras R.
% Pedestrian Bridges Capacity
% https://github.com/aleaicr/Pedestrian-Bridge-Capacity

%% Inicializar
clear variables
close all
clc

%% Inputs
% Pedestrian
ai = 1;                                                                     %
fi = 1.7/2;                           % hz                                  % Frecuencia horizontal del caminar
wi = 2*pi*fi;                         % rad/sec                             % 
% wi = 1.2;    % autor
lambdai = 0.6;                                                              % 
mi = 70;                                                                    % kg

ai2 = 0.5;                                                                     %
fi2 = 1.8/2;                           % hz                                  % Frecuencia horizontal del caminar
wi2 = 2*pi*fi;                         % rad/sec                             % 
% wi = 1.2;    % autor
lambdai2 = 0.5;                                                              % 
mi2 = 75;                                                                    % kg

ai3 = 0.01;                                                                     %
fi3 = 1.6/2;                           % hz                                  % Frecuencia horizontal del caminar
wi3 = 2*pi*fi;                         % rad/sec                             % 
% wi = 1.2;    % autor
lambdai3 = 0.3;                                                              % 
mi3 = 89;                                                                    % kg

% Bridge (Marcheggiani & Lenci 2010) % Malos, no cumple ni con frecuencia
% ni amortiguamiento del puente de análisis.
% Mbridge = 113000;                   % kg
% Kbridge  = 4730;                    % kN/m                                  % 4730000 kg/s2 = 4730 kN/m
% Cbridge = 11;                       % kN/(m/s)                              % 11000 kg/s = 11 kN/(m/s)
% wbridge = sqrt(Kbridge/Mbridge);
% xi = Cbridge/(2*Mbridge*wbridge);

% Utilizando datos (Belykh etl al 2021)
Mspan = 130000;                                                           % kg
fspan = 0.49; %hz
w = 2*pi*fspan;                                                                   % rad/sec
Kspan = Mspan*w^2/1000;                                                     % kN/m
xi = 0.07/100;                                                              % Mejor ocupar desde fuente Dallard P. et al 2001
Cspan = xi*2*Mspan*w/1000;                                                  % kN/(m/s)

%% Space-State SDOF BRIDGE
% x = Ax+Bp , p = ypp 
% y = Cx+Dp , y = [u;up;upp]
A = [0 1; -w^2 -2*xi*w];
B = [0; 1/Mspan];

C = [1 0; 0 1; -w^2 -2*xi*w];                                  % y = [q;qp;qpp]
% Cdisp = [1 0];                                                              % y = [q]
% Cdisp_vel = [1 0; 0 1];                                                     % y = [q;qp]
% Cacc = [-Kbridge/Mbridge -Cbridge/Mbridge];                                 % y = [qpp]
% Cdisp_acc = [1 0; -Kbridge/Mbridge -Cbridge/Mbridge];                       % y = [q,qpp]

D = [0;0; 1/Mspan];                                                               % y = [q;qp;qpp]
% Ddisp = 0;                                                                  % y = [q]
% Ddisp_vel = [0; 0];                                                         % y = [q; qp]
% Dacc = -mi/Mbridge;                                                         % y = [qpp]
% Ddisp_acc = [0; -mi/Mbridge];                                               % y = [q; qpp]

% Modelo
modelo = ss(A,B,C,D);
modelo

% Simulación Impulso
t_inicial = 0;
t_step = 1/1000;
t_final = 500;
t_vect = (t_inicial:t_step:t_final)';