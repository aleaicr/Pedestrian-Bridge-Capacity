%% Pedestrian Bridge Properties
% Alexis Contreras R - 2022
% Pedestrian bridge properties data file generator

%% Inicializar
clear varibales
close all
clc

%% Inputs
EI  = 1;        % kN*m2                                                     % Rigidez equivalente
L = 1;          % m                                                         % Largo del puente
rho_lin = 1;    % kg/m                                                      % Densidad lineal equivalente
n_modos = 3;                                                                % Cantidad de modos
xi = 0.7/100;                                                               % Razón de amortiguamiento (será igual para todos los modos), source: Dallard P. et al 2001
zrmodal = xi*ones(n_modos,1);                                               % Vector de razones de amortiguamiento para cada modo

%% Funciones de formas modales
syms x
psi = sinModalShapes(n_modos,L);                                            % Vector de funciones de formas modales

%% Modos Asumidos
[Me,Ke,Ce,Ge] = assumedModes_beam(psi,EI,rho_lin,L,zrmodal);                % Matrices equivalentes de modos asumidos (EDM es 

%% Espacio-Estaado
[modelo,As,Bs,Cs,Ds] = SpaceState_bridge(n_modos,Me,Ke,Ce,Ge);              % Matrices de la dinámica del sistema en representación espacio estado

%% Save Data
matObj = matfile('Bridge_Properties.mat');
matObj.Properties.Writable = true;
matObj.EI = EI;
matObj.L = L;
matObj.rho = rho_lin;
matObj.phi = phi;                                                           % dudo que funcionen con simbólicas
matObj.Me = Me;
matObj.Ke = Ke;
matObj.Ce = Ce;
matObj.Ge = Ge;
matObj.modelo = modelo;
matObj.As = As;
matObj.Bs = Bs;
matObj.Cs = Cs;
matObj.Ds = Ds;
clear matObj

%% Comentario consola
fprintf('Se ha generado el archivo Bridge_Properties.mat\n\n')