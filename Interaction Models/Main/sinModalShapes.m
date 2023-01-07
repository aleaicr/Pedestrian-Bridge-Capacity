function [psi] = sinModalShapes(n_modos,L)
% Alexis Contreras R.
% Pedestrian Bridge Capacity

% Genera forma modal de funciones seno para n_modos que cumplen con
% condiciones de ortogonalidad y condiciones de borde para una viga
% de dos apoyos simples en sus extremos.

%%
% Inputs
% n_modos           -> Cantidad de modos que se quieren considerar
% L                 -> Largo de la viga equivalente

% Outputs
% psi               -> Vector de sym con formas modales sinusoidales
%%
syms x
psi = sym(zeros(1,n_modos));
for n = 1:n_modos
    psi(n) = sin(n*pi*x/L);
end


end

