function [psi_xvals] = sinModalShapes_xvals(n_modos,L,x_vals)

% Crea la matriz psi_xvals que contiene los valores de las formas modales
% evaluadas en las posiciones 0 < x_vals < L de la siguiente forma:

% psi_xvals = [ psi1_xvals  psi2_xvals  psi3_xvals ... psin_xvals] (matrix)

psi_xvals = zeros(length(x_vals),n_modos);
for n = 1:n_modos
    psi_xvals(:,n) = sin(2*pi*n/L*x_vals);
end

end