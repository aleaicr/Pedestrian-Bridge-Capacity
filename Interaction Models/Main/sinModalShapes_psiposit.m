function [psi_pos] = sinModalShapes_psiposit(n_modos,L,posi)

% Crea la matriz psi_xvals que contiene los valores de las formas modales
% evaluadas en las posiciones 0 < x_vals < L de la siguiente forma:
% psi_xvals = [ psi1_xvals  psi2_xvals  psi3_xvals ... psin_xvals] (matrix)

% INPUTS
% n_modos:      Cantidad de modos para el análisis
% L:            Largo de la viga equivalente (metros)
% posi:         Vector columna de la posición del peatón a lo largo de la viga para  el peatón "i" donde cada fila es para cada tiempo tj hasta el tiempo tf


% OUTPUTS
% psi_pos:   Matriz con las funciones de forma modal evaluadas en la posición para cada tiempo para cada modo, 3 Dimensiones --> tiempo, #modo, #peatón
%%

psi_pos = zeros(length(posi),n_modos);                                      % length(posi) = t_length -> Cantidades de tiempos
for n = 1:n_modos
    psi_pos(:,n) = sin(pi*n/L*posi);
end

end