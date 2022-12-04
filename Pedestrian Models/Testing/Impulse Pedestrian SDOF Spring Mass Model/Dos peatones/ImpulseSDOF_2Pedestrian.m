%% vdPWalker Model Testing

% Alexis Contreras R.
% Pedestrian Bridges Capacity
% https://github.com/aleaicr/Pedestrian-Bridge-Capacity

%% Inicializar
clear variables
close all
clc

%% Inputs
% Pedestrian 1
ai = 1;                                                                     %
fi = 1.8/2;                           % hz                                  % Frecuencia horizontal del caminar
wi = 2*pi*fi;                         % rad/sec                             % 
% wi = 1.2;    % autor
lambdai = 0.5;                                                              % 
mi = 70;                                                                    % kg

% Pedestrian 2
ai2 = 0.7;                                                                     %
fi2 = 1.5/2;                           % hz                                  % Frecuencia horizontal del caminar
wi2 = 2*pi*fi;                         % rad/sec                             % 
% wi = 1.2;    % autor
lambdai2 = 0.3;                                                              % 
mi2 = 90;                                                                    % kg

% Bridge (Marcheggiani & Lenci 2010) % Malos, no cumple ni con frecuencia
% ni amortiguamiento del puente de análisis.
% Mbridge = 113000;                   % kg
% Kbridge  = 4730;                    % kN/m                                  % 4730000 kg/s2 = 4730 kN/m
% Cbridge = 11;                       % kN/(m/s)                              % 11000 kg/s = 11 kN/(m/s)
% wbridge = sqrt(Kbridge/Mbridge);
% xi = Cbridge/(2*Mbridge*wbridge);

% Utilizando datos (Belykh etl al 2021)
Mspan = 130000;                                                             % kg
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
t_step = 1/100;
% t_final = 500;
% t_vect = (t_inicial:t_step:t_final)';


%% Cambiando la masa del peatón
% Figura solo posición chart
x0_chart = 0;
x0_1 = 0.2;
x0_2 = 0.1;
t_final = 400;

figure
x0_ped = 0.1;
out = sim('ImpulseSDOF_2Pedestrian_sim');
plot(out.tout,out.simout.Data(:,1))
hold on
plot(out.tout,out.simout.Data(:,2))
hold off
%     plot(out.tout,out.simout.Data(:,1),'color',convertStringsToChars(colors_ped(i)))
xlabel('Tiempo [sec]')
ylabel('Desplazamiento peatón[m]')
grid on
legend('x0_1 = 0.08','x0_2 = 0.1')
title('Simulación 2 peatones sobre carro')

figure
plot(out.tout,out.simout.Data(:,3))
xlabel('Tiempo [sec]')
ylabel('Desplazamiento peatón[m]')
grid on
legend('x0_1 = 0.08','x0_2 = 0.1')
title('Simulación 2 peatones sobre carro')



% figure
% x0_ped = 0.1;
% out = sim('ImpulseSDOF_2Pedestrian_sim');
% plot(out.tout,envelope(out.simout.Data(:,1),500,'peak'))
% data_peaton_1 = out.simout.Data(:,1);
% hold on
% plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% hold off
% %     plot(out.tout,out.simout.Data(:,1),'color',convertStringsToChars(colors_ped(i)))
% xlabel('Tiempo [sec]')
% ylabel('Desplazamiento peatón[m]')
% grid on
% legend('x0_1 = 0.08','x0_2 = 0.1')
% title('Simulación 2 peatones sobre carro')
% 
% figure
% plot(out.tout,envelope(out.simout.Data(:,3),500,'peak'))
% xlabel('Tiempo [sec]')
% ylabel('Desplazamiento peatón[m]')
% grid on
% legend('x0_1 = 0.08','x0_2 = 0.1')
% title('Simulación 2 peatones sobre carro')

