function [response] = genToPhys(psi_xvals, q, x_vals)

% Generar matriz con todos los vectores de la respuesta en todo el
% tiempo para cada posición x_vals de la viga equivalente, es decir:

% y_bridge = [ y(x1) y(x2) y(x3) ... y(xi)] (matriz = vector fila de vectores columna
% donde: y(x1) = [y(x1(t1)); y(x1(t2)); ... y(x1(tf))] (vector)
% notar que y, puede ser yp o ypp si quiero velocidad o aceleración

% INPUTS
% psi_xvals:    Matriz con todos los valores de psi evaluados en todos los xvals para todos los modos (n_moods x length(x_vals))
% q:            Matriz con la respuesta de desplazamiento/velocidad/aceleracion en coordenadas generalizadas para todos los modos (t_length x n_modos)
% x_vals:       Vector con las posiciones de todos los puntos que se quiere obtener la respuesta en coordenadas físicas

% OUTPUT
% response: respuesta en coordenadas físicas

% COMENTARIOS
% Notar que q, puede ser qp o qpp si se quiere velocidad o aceleración
% respectivamente, ya que esta función compone desde coordenadas a otras.

%%
t_length = length(q(:,1));
x_length = length(x_vals);

response_aux = zeros(t_length,n_modos);
response = zeros(t_length,x_length);

for i = 1:x_length
    for t = 1:t_length
        for n = 1:n_modos
            response_aux(t,n) = psi_xvals(n,i)*q(t,n);
        end
        response(t,i) = sum(response_aux(t,:));                             % para cada tiempo response = suma_modos (psi_n(xval)*q_n(t))
    end
end
end

