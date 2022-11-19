%% Inicializar
clear variables
close all
clc


% Inputs
L = 100; % m                                                                % Altura del edificio
cant_modos = 5;                                                             % Cantidad de modos a considerar para el análisis

syms x
psi = sym(zeros(cant_modos,1));
for n = 1:cant_modos
    psi(n) = (x/L)^(n);
end
figure
fplot(psi)
xlim([0 L])