function [As,Bs,Cs,Ds] = SpaceState_bridge_alternative(n_modos,Me,Ke,Ce,Ge,alternative)
% Alexis Contreras R.
% Pedestrian Bridge Capacity

% Retorna el modelo del sistema dinámico en representación espacio estado

% La ecuación de respuesta retorna todos los estados (desplazamiento,
% velocidad y aceleración)

% Alternative: 'd''v','a','dv','da','va','dva', puedo obtener de la
% respuesta lo que yo quiera

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
As = [zeros(n_modos) eye(n_modos); -Me\Ke -Me\Ce];                          % Matriz de estados, nxn
Bs = [zeros(n_modos); Me\Ge];                                               % Matriz de influencia de excitacion pe1(t), nx1

% Ecuacion de Respuesta 
% y = Cs*x + Ds*p(t), donde y = [q1(t); q2(t)], solo desplazamientos
alternative = sort(alternative);
if isequal(alternative,'d')
    Cs = [eye(n_modos) zeros(n_modos)];                                         % Matriz de estados, 6x4
    Ds = zeros(n_modos);                                                        % Matriz de influencia de excitacion pe1(t), 6x1
elseif isequal(alternative,'v')
    Cs = [zeros(n_modos) eye(n_modos)];                                         % Matriz de estados, 6x4
    Ds = zeros(n_modos);
elseif isequal(alternative,'a')
    Cs = [-Me\Ke -Me\Ce];
    Ds = Me/Ge;
elseif isequal(alternative,'dv')
    Cs = [eye(n_modos) zeros(n_modos); zeros(n_modos) eye(n_modos)];
    Ds = [zeros(n_modos); zeros(n_modos)];
elseif isequal(alternative,'ad')
    Cs = [eye(n_modos) zeros(n_modos); -Me\Ke -Me\Ce];
    Ds = [zeros(n_modos); Me\Ge];
elseif isequal(alternative,'av')
    Cs = [zeros(n_modos) eye(n_modos); -Me\Ke -Me\Ce];
    Ds = [zeros(n_modos); Me\Ge];
elseif isequal(alternative,'adv')
    Cs = [eye(n_modos) zeros(n_modos); zeros(n_modos) eye(n_modos); -Me\Ke -Me\Ce];
    Ds = [zeros(n_modos); zeros(n_modos); Me\Ge];
end
end

