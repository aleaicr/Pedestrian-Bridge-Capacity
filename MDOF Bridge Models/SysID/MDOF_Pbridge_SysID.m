%% Modelo Puente Peatonal SysID
% Alexis Contreras R.
% Pedestrian Bridge-Capacity

%% Imput del Modelo
% E = 450*10^3*10^3; % 200GPa = E9 Pa(N/m2) = E6 kN/m2                        % Modulo de young del material del puente
% b = 5; % m                                                                % Ancho de losa de puente
% h = 2; % m                                                                  % Espesor de losa de puente
I = 1/12*h*b^3; % m4                                                        % Inercia de la sección del puente 
A = b*h; % m2                                                               % Area de la sección puente
% rho_vol = 20; % kg/m3                                                        % Densidad volumétrica del puente
rho_lin = rho_vol*A; % kg/m                                                 % Densidad lineal del puente


%% EDM Modos Asumidos
% Aplicar método de modos asumidos a las propiedades de la viga equivalente
% que genera la respuesta del puente en estudio
% Me*ddq(t) + Ce*dq(t) Ke*q(t) = Ge*Pe
[Me,Ke,Ce,Pe,Ge,wn] = assumedModes_beam(psi,E,I,rho_lin,A,L,zrmodal,P);

%% Espacio Estado - Puente 
% Modelo de viga equivalente queda representado en SpaceState
[modelo,As,Bs,Cs,Ds] = SpaceState_bridge(cant_modos,Me,Ke,Ce,Ge);

%% Simulación puente
% Simulación del puente para la carga equivalente peatonal sinusoidal Pe

% Ejecutar simulación
out = sim('Bridge_simu_SysID');                                                   % Ejecución de modelo simulink para puente

%% Desplazamientos
% Discretizando 
u_bridge = out.q.Data*psi.';
% [mdesp,ndesp] = size(u_bridge);                                           % mdesp = tiempos, ndesp = 1

% Desplazamiento máximo
max_desp = 0;
for j = 1:length(x_vals)                                                    % Utilizando las particiones de x, determinamos el desplazamiento máximo del puente SIN TMD
    desplpuente_en_x = max(double(subs(u_bridge,x,x_vals(j))));
    if abs(desplpuente_en_x) > max_desp
        max_desp = abs(desplpuente_en_x);                                   % Se guarda el desplazamiento 
    end
end