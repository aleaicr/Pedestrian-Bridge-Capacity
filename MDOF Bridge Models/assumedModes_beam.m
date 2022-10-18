function [Me,Ke,Ce,Pe,Ge,wn] = assumedModes_beam(psi,E,I,rho,A,L,zrmodal,P)
% Alexis Contreras R.
% Pedestrian Bridge Capacity

% Genera matrices de masa, rigidez y amortiguamiento utilizando el método
% de MODOS ASUMIDOS de una viga.

%%
% Inputs
% psi           -> (sym) Vector de funciones con las formas modales
% E             -> Modulo de elasticidad de la viga equivalente
% I             -> Inercia en dirección de análisis de la viga equivalente
% rho           -> Densidad lineal de la viga equivalente
% A             -> Area de sección de la viga equivalente
% L             -> Largo de la viga
% zrmodal       -> Amortiguamiento de cada modo
% P             -> Función de carga (integrable)

% Outputs
% Me            -> Matriz equivalente
% Ke            -> Rigidez equivalente
% Ce            -> Amortiguaiento equivalente (proporcional)
% Pe            -> Carga equivalente
% Ge            -> Participación equivalente (en verdad queda como una
% identidad siempre) (no es la participación modal, aun no la saco)

%%
Me = double(int(rho*A*(psi).'*psi,x,0,L));
Ke = double(int(E*I*(ddpsi).'*ddpsi,x,0,L));
Pe = int(P*psi.',x,0,L);  
Ge = eye(cant_modos,cant_modos); 

% Amortiguamiento modal proporcional
[~, lambda] = eig(Ke,Me);                                                   % Problema de valores y vectores propios
wn = sqrt(diag(lambda));  
Phi = eye(cant_modos);
Ce = (Me*Phi)*diag(2*zrmodal.*wn./Me).*(Me*Phi).';    % Esto es C

end

