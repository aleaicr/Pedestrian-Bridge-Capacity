%% Functions testing

%% Inicializar
clear variables
close all
clc


%% Testing sinModalShapes_xvals

n_modos = 3;                                                                % Cantidad de modos
L = 100;                                                                    % Largo de la viga equivalente
x_parts = 10;                                                               % Cantidad de particiones        
x_vals = (L/x_parts:L/x_parts:L-L/x_parts).';                               % Vector con todos los puntos para evaluar el desplazamiento en el puente

% Probemos si me genera la matriz esperada
psi_xvals = sinModalShapes_xvals(n_modos,L,x_vals);
fprintf(['La función sinModalShapes_xvals retorna la siguiente matris psi_xvals \n' ...
    'Parámetros: n_modos = %.0f ; L = %.0f ; x_parts = %.0f \n \n'],n_modos,L,x_parts)
disp('psi_xvals = ')
disp(psi_xvals)
disp('Filas -> para cada punto')
disp('Columnas -> para cada modo')
disp('valores -> psi(xpos)')

fprintf('Notar que la cantidad de filas es x_parts - 1 -> no se evaluarán extremos \n \n')
