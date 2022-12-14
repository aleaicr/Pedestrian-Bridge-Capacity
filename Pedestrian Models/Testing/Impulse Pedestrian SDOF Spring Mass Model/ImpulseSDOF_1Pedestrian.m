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
fi = 1.8/2;                           % hz                                  % Frecuencia horizontal del caminar
wi = 2*pi*fi;                         % rad/sec                             % 
% wi = 1.2;    % autor
lambdai = 0.1;                                                              % 
mi = 210*70;                                                                    % kg

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
w = 2*pi*fspan;                                                             % rad/sec
Kspan = Mspan*w^2/1000;                                                     % kN/m
xi = 0.07/100;                                                              % Mejor ocupar desde fuente Dallard P. et al 2001
Cspan = xi*2*Mspan*w/1000;                                                  % kN/(m/s)

%% Space-State SDOF CHART
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
disp(modelo)

% Simulación Impulso
t_inicial = 0;
t_step = 1/90;
t_final = 1000;
t_vect = (t_inicial:t_step:t_final)';



%% Trabajo de datos

% actualmente, se tiene que la condic
x0_ped_vals = [0.02; 0.01; 0.05; 0.1; 0.06; 0.09; 0.15; 0.2; 0.21; 0.03; 0.08];
x0_chart = [0;0];
despl_obj = 0.03;
cant_veces_excede = 0;

for i = 1:length(x0_ped_vals)
    fprintf('simulación %.0f\n', i)
    x0_ped = x0_ped_vals(i,1);
    out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
    despl_max = max(out.simout.Data(:,1));
    if despl_max > despl_obj
        cant_veces_excede = cant_veces_excede + 1;
    end
end
fprintf('Cant_veces_exede_total = %.0f\n',cant_veces_excede)

fraccion = cant_veces_excede/length(x0_ped_vals);

fprintf('fraccion = %.2f\n',fraccion)



% %% Testing and plot
% % Muchas figuras
% 
% % Probemos qué pasa si 1 peatón con distintas condiciones iniciales
% cond_init_ped = [0.01; 0.05; 0.1; 0.13];
% % cond_init_ped = [0.01; 0.05; 0.1; 0.15; 0.2; 0.3];
% x0_chart = [0;0];
% colors_chart = ["#00290b";"#000dd6";"#008023";"#00ad2f";"#00de3c"];
% colors_ped = ["#000440";"#000887";"#000dd6";"#0069d1";"#02b2ed"];

% %% Condición carro 
% x0_ped = 0;
% x0_chart = [0.05; 0];
% mi = 0;
% t_final = 1000;
% figure
% out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
% plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% hold on
% mi = 70;
% out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
% plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% mi = 20*70;
% out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
% plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% mi = 100*70;
% out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
% plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% mi = 200*70;
% out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
% plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% mi = 500*70;
% out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
% plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% 
% hold off
% xlabel('Tiempo [sec]')
% ylabel('Desplazamiento puente [m]')
% legend('sin peatón','1 peatón','20 peatones','100 peatones','200 peatones','500 peatones')
% grid on
% %% 500 Peatones --> algo curioso
% 
% figure
% mi = 500*70;
% t_final = 10000;
% out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
% plot(out.tout,out.simout.Data(:,2))
% xlabel('Tiempo [sec]')
% ylabel('Desplazamiento puente [m]')
% legend('500 peatones')
% grid on
% 
% 
% %% Variando condición inicial carro
% x0_ped = 0;
% figure
% mi = 70;
% x0_chart = [0.05; 0];
% t_final = 600;
% out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
% plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% data_ped_1 = out.simout.Data(:,1);
% hold on
% x0_chart = [0.07; 0];
% out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
% plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% data_ped_2 = out.simout.Data(:,1);
% 
% x0_chart = [0.1; 0];
% out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
% plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% data_ped_3 = out.simout.Data(:,1);
% 
% x0_chart = [0.15; 0];
% out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
% plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% data_ped_4 = out.simout.Data(:,1);
% hold off
% xlabel('Tiempo [sec]')
% ylabel('Desplazamiento puente [m]')
% legend('x0 = 0.05','x0 = 0.07', 'x0 = 0.1', 'x0 = 0.15')
% title('Respuesta carro + 1 peatón','Variando condición inicial carro')
% 
% 
% figure
% plot(out.tout, envelope(data_ped_1,50,'peak'))
% hold on
% plot(out.tout, envelope(data_ped_2,50,'peak'))
% plot(out.tout, envelope(data_ped_3,50,'peak'))
% plot(out.tout, envelope(data_ped_4,50,'peak'))
% hold off
% xlabel('Tiempo [sec]')
% ylabel('Desplazamiento peatón [m]')
% legend('x0 = 0.05','x0 = 0.07', 'x0 = 0.1', 'x0 = 0.15')
% title('Respuesta carro + 1 peatón','Variando condición inicial carro')
% grid on
% 
% %% Variando condición inicial carro
% x0_ped = 0;
% figure
% mi = 500*70;
% x0_chart = [0.05; 0];
% t_final = 600;
% out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
% plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% data_ped_1 = out.simout.Data(:,1);
% hold on
% x0_chart = [0.07; 0];
% out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
% plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% data_ped_2 = out.simout.Data(:,1);
% 
% x0_chart = [0.1; 0];
% out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
% plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% data_ped_3 = out.simout.Data(:,1);
% 
% x0_chart = [0.15; 0];
% out = sim('ImpulseSDOF_1Pedestrian_sim.slx');
% plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% data_ped_4 = out.simout.Data(:,1);
% hold off
% xlabel('Tiempo [sec]')
% ylabel('Desplazamiento puente [m]')
% legend('x0 = 0.05','x0 = 0.07', 'x0 = 0.1', 'x0 = 0.15')
% title('Respuesta carro + 1 peatón','Variando condición inicial carro')
% 
% 
% figure
% plot(out.tout, envelope(data_ped_1,50,'peak'))
% hold on
% plot(out.tout, envelope(data_ped_2,50,'peak'))
% plot(out.tout, envelope(data_ped_3,50,'peak'))
% plot(out.tout, envelope(data_ped_4,50,'peak'))
% hold off
% xlabel('Tiempo [sec]')
% ylabel('Desplazamiento peatón [m]')
% legend('x0 = 0.05','x0 = 0.07', 'x0 = 0.1', 'x0 = 0.15')
% title('Respuesta carro + 1 peatón','Variando condición inicial carro')
% grid on
% 
% %% Variando condición inicial peatón
% % % Figura solo posición chart
% % figure
% % x0_ped = cond_init_ped(1,1);
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% % data_peaton_1 = out.simout.Data(:,1);
% % hold on
% % x0_ped = cond_init_ped(2,1);
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% % data_peaton_2 = out.simout.Data(:,1);
% % x0_ped = cond_init_ped(3,1);
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% % data_peaton_3 = out.simout.Data(:,1);
% % x0_ped = cond_init_ped(4,1);
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% % data_peaton_4 = out.simout.Data(:,1);
% % hold off
% % %     plot(out.tout,out.simout.Data(:,1),'color',convertStringsToChars(colors_ped(i)))
% % xlabel('Tiempo [sec]')
% % ylabel('Desplazamiento puente [m]')
% % grid on
% % legend('x0 = 0.01','x0 = 0.05', 'x0 = 0.10', 'x0 = 0.13')
% % title('Simulación 1 peatón sobre carro','Variación de cond. inicial posición peatón (x)')
% 
% % figure
% % hold on
% % x0_ped = cond_init_ped(1,1);
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,out.simout.Data(:,2),'color',convertStringsToChars(colors_chart(3,1)),'LineWidth',1.5)
% % %     plot(out.tout,out.simout.Data(:,1),'color',convertStringsToChars(colors_ped(i)))
% % x0_ped = cond_init_ped(2,1);
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,out.simout.Data(:,2),'color',convertStringsToChars(colors_chart(2,1)),'LineWidth',1.5)
% % hold off
% % xlabel('Tiempo [sec]')
% % ylabel('Desplazamiento puente [m]')
% % grid on
% % legend('x0 = 0.01', 'x0 = 0.15')
% % title('Simulación 1 peatón sobre carro','Variación de cond. inicial posición peatón (x)')
% 
% 
% % % Figura solo posición peatón
% % figure
% % % x0_ped = cond_init_ped(1,1);
% % % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % % plot(out.tout,out.simout.Data(:,1),'color',convertStringsToChars(colors_ped(4,1)),'LineWidth',1.5)
% % plot(out.tout,envelope(data_peaton_1,10,'peak'))
% % hold on
% % plot(out.tout,envelope(data_peaton_2,10,'peak'))
% % plot(out.tout,envelope(data_peaton_3,10,'peak'))
% % plot(out.tout,envelope(data_peaton_4,10,'peak'))
% % hold off
% % %     plot(out.tout,out.simout.Data(:,1),'color',convertStringsToChars(colors_ped(i)))
% % xlabel('Tiempo [sec]')
% % ylabel('Desplazamiento peatón [m]')
% % grid on
% % legend('x0 = 0.01','x0 = 0.05', 'x0 = 0.10', 'x0 = 0.13')
% % title('Simulación 1 peatón sobre carro','Variación de cond. inicial posición peatón (x)')
% 
% % % Figura solo posición peatón
% % figure
% % hold on
% % x0_ped = cond_init_ped(1,1);
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,out.simout.Data(:,1),'color',convertStringsToChars(colors_chart(3,1)),'LineWidth',1.5)
% % %     plot(out.tout,out.simout.Data(:,1),'color',convertStringsToChars(colors_ped(i)))
% % x0_ped = cond_init_ped(2,1);
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,out.simout.Data(:,1),'color',convertStringsToChars(colors_chart(2,1)),'LineWidth',1.5)
% % hold off
% % xlabel('Tiempo [sec]')
% % ylabel('Desplazamiento peatón [m]')
% % grid on
% % legend('x0 = 0.01', 'x0 = 0.15')
% % title('Simulación 1 peatón sobre carro','Variación de cond. inicial posición peatón (x)')
% 
% %% Cambiando parámetros a, lambda, w
% % % Figura solo posición chart
% % figure
% % x0_ped = 0.1;
% % lambdai = 0.7;
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% % data_peaton_1 = out.simout.Data(:,1);
% % hold on
% % lambdai = 0.8;
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% % data_peaton_2 = out.simout.Data(:,1);
% % lambdai = 1;
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% % data_peaton_3 = out.simout.Data(:,1);
% % lambdai = 1.1;
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% % data_peaton_4 = out.simout.Data(:,1);
% % hold off
% % %     plot(out.tout,out.simout.Data(:,1),'color',convertStringsToChars(colors_ped(i)))
% % xlabel('Tiempo [sec]')
% % ylabel('Desplazamiento puente [m]')
% % grid on
% % legend('lambda = 0.1','lambda = 0.5', 'lambda = 1', 'lambda = 1.1')
% % title('Simulación 1 peatón sobre carro','Cond.Inicial (x0 = 0.1)')
% 
% 
% % % Figura solo posición peatón
% % figure
% % % x0_ped = cond_init_ped(1,1);
% % % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % % plot(out.tout,out.simout.Data(:,1),'color',convertStringsToChars(colors_ped(4,1)),'LineWidth',1.5)
% % plot(out.tout,envelope(data_peaton_1,10,'peak'))
% % hold on
% % plot(out.tout,envelope(data_peaton_2,10,'peak'))
% % plot(out.tout,envelope(data_peaton_3,10,'peak'))
% % plot(out.tout,envelope(data_peaton_4,10,'peak'))
% % hold off
% % %     plot(out.tout,out.simout.Data(:,1),'color',convertStringsToChars(colors_ped(i)))
% % xlabel('Tiempo [sec]')
% % ylabel('Desplazamiento peatón [m]')
% % grid on
% % legend('lambda = 0.1','lambda = 0.5', 'lambda = 1', 'lambda = 1.1')
% % title('Simulación 1 peatón sobre carro','Cond.Inicial (x0 = 0.1)')
% 
% %% Cambiando la masa del peatón
% 
% % % Figura solo posición chart
% % figure
% % x0_ped = 0.1;
% % mi = 70;
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% % data_peaton_1 = out.simout.Data(:,1);
% % hold on
% % mi = 10*70;
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% % data_peaton_2 = out.simout.Data(:,1);
% % mi = 70*70;
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% % data_peaton_3 = out.simout.Data(:,1);
% % mi = 120*70;
% % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % plot(out.tout,envelope(out.simout.Data(:,2),500,'peak'))
% % data_peaton_4 = out.simout.Data(:,1);
% % hold off
% % %     plot(out.tout,out.simout.Data(:,1),'color',convertStringsToChars(colors_ped(i)))
% % xlabel('Tiempo [sec]')
% % ylabel('Desplazamiento puente [m]')
% % grid on
% % legend('m = 1*70[kg]','m = 10*70[kg]', 'm = 70*70[kg]', 'm = 120*70[kg]')
% % title('Simulación 1 peatón sobre carro','Cond.Inicial (x0 = 0.1)')
% % 
% % 
% % % Figura solo posición peatón
% % figure
% % % x0_ped = cond_init_ped(1,1);
% % % out = sim('ImpulseSDOF_1Pedestrian_sim');
% % % plot(out.tout,out.simout.Data(:,1),'color',convertStringsToChars(colors_ped(4,1)),'LineWidth',1.5)
% % plot(out.tout,envelope(data_peaton_1,10,'peak'))
% % hold on
% % plot(out.tout,envelope(data_peaton_2,10,'peak'))
% % plot(out.tout,envelope(data_peaton_3,10,'peak'))
% % plot(out.tout,envelope(data_peaton_4,10,'peak'))
% % hold off
% % %     plot(out.tout,out.simout.Data(:,1),'color',convertStringsToChars(colors_ped(i)))
% % xlabel('Tiempo [sec]')
% % ylabel('Desplazamiento peatón [m]')
% % grid on
% % legend('m = 1*70[kg]','m = 10*70[kg]', 'm = 70*70[kg]', 'm = 120*70[kg]')
% % title('Simulación 1 peatón sobre carro','Cond.Inicial (x0 = 0.1)')
% 


