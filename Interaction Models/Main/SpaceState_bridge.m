function [modelo,As,Bs,Cs,Ds] = SpaceState_bridge(n_modos,Me,Ke,Ce,Ge)
% Alexis Contreras R.
% Pedestrian Bridge Capacity

% Retorna el modelo del sistema dinámico en representación espacio estado

% La ecuación de respuesta retorna todos los estados (desplazamiento,
% velocidad y aceleración)

%%
% Inputs
% n_modos           -> Cantidad de modos que se consideran
% Me                -> Matriz de masa (asociada a los modos)
% Ke                -> Matriz de rigidez
% Ce                -> Matriz de amortiguamiento
% Ge                -> Matriz (o vector) de participación de cada carga

% Outputs
% modelo            -> Representación espacio estado del sistema dinámico
% As                -> Matriz A de State-Space
% Bs                -> Matriz B de State-Space
% Cs                -> Matriz C de State-Space
% Ds                -> Matriz D de State-Space

% Ecuacion de Estado 
% dx(t) = As*x(t) + Bs*u(t), donde x(t) = [q1(t); q2(t); dq1(t); dq2(t)] y u(t) = Pe(t) 
As = [zeros(n_modos) eye(n_modos); -Me\Ke -Me\Ce];                          % Matriz de estados, 4x4
Bs = [zeros(n_modos); Me\Ge];                                               % Matriz de influencia de excitacion pe1(t), 4x1

% Ecuacion de Respuesta 
% y = Cs*x + Ds*p(t), donde y = [q1(t); q2(t); dq1(t); dq2(t);  ddq1(t); ddq2(t)]
Cs = [eye(n_modos) zeros(n_modos) ; zeros(n_modos) eye(n_modos); -Me\Ke -Me\Ce]; % Matriz de estados, 6x4
Ds = [zeros(n_modos) ; zeros(n_modos); Me\Ge];                              % Matriz de influencia de excitacion pe1(t), 6x1

% Representación
modelo = ss(As,Bs,Cs,Ds);
end

