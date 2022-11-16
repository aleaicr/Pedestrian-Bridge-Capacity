function [Me,Ke,Ce,Ge,wn] = assumedModes_beam_V2(psi,E,I,rho,A,L,zrmodal)
% Alexis Contreras R.
% Pedestrian Bridge Capacity

% Genera matrices de masa, rigidez y amortiguamiento utilizando el método
% de MODOS ASUMIDOS de una viga.

%%
% Inputs
% psi           -> (sym) Vector de funciones con las formas modales
% E             -> (Escalar)Modulo de elasticidad de la viga equivalente
% I             -> (Escalar) Inercia en dirección de análisis de la viga equivalente
% rho           -> (Escalar) Densidad lineal de la viga equivalente
% A             -> (Escalar) Area de sección de la viga equivalente
% L             -> (Escalar) Largo de la viga
% zrmodal       -> (Vector) Amortiguamiento de cada modo
% P             -> Función de carga (integrable)

% Outputs
% Me            -> (Matriz) de masa equivalente
% Ke            -> (Matriz) de Rigidez equivalente
% Ce            -> (Matriz) de dAmortiguaiento equivalente (proporcional)
% Ge            -> (Matriz) de Participación equivalente (en verdad queda como una identidad siempre) 
%%
syms x
ddpsi = diff(psi,x,x);
cant_modos = length(psi);

% Matriz de masa equivalente
Me = double(int(rho*A*(psi).'*psi,x,0,L));

% Matriz de Rigidez equivalente
Ke = double(int(E*I*(ddpsi).'*ddpsi,x,0,L));


% Participación modal ??? % No me acuerdo el nombre exacto
Ge = eye(cant_modos,cant_modos); 

% Amortiguamiento modal proporcional
[~, lambda] = eig(Ke,Me);                                                   % Problema de valores y vectores propios
wn = sqrt(diag(lambda));  
Phi = eye(cant_modos);
Ce = (Me*Phi)*diag(2*zrmodal.*wn./Me).*(Me*Phi).';                          % Matriz de amortiguamiento
end

