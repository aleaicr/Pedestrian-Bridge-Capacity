%% Properties of the bridge
% Genera un archivo cargable (load) de propiedades del puente


%% Inicializar
clear variables
close all
clc

%% Define Properties

E = 1;                                                                      % E(x)
I = 1;                                                                      % I(x)
A = 1;                                                                      % A(x)
rho = 1;                                                                    % rho(x)
xi = 0.01;                                                                  % xi(x)

matObj = matfile('bridge_properties.mat');
matObj.E = E;
matObj.I = I;
matObj.A = A;
matObj.rho = rho;
matObj.xi = xi;