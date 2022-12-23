%% Pedestrian Position
% Alexis Contreras R.
% Pedestrian Bridge Capacity

% Calcular la posición de cada peatón en función del tiempo durante todo el
% tiempo de la simulación

%% Inicializar
clear variables
close all
clc

%% Inputs
t_init = 0;
t_step = 0.2;
t_final = 200;
t_vect = (t_init:t_step:t_final).';                                         % Vecor de todos los tiempos para la simulación
t_length = length(t_vect);

L = 144;    % m                                                             % Largo del puente
%% Importar Datos
% v = velocidad constante del peatón
% Side = Lado del puente del cual entra el peatón (1 o 2)
% Taddacum = Tiempo desde el cual entra el peatón al puente (Tadd acumulado)

fileName = 'rPedestrianProperties';                                         % Nombre del archivo con los variables 
pd = load(fileName);                                                        % pd: Pedestrian Data

% Formato (columnas): #Peaton | v | side | Tadd_acum 
v = pd.v(:,1);                                                              % velocidad del peatón
side = pd.Side(:,1);                                                        % Lado por el que entrea el peatón
tac = pd.Taddacum(:,1);                                                     % Tadd_cum (Acumulada) (Tiempo en el que entra el peatón)
pd_length = length(v);                                                      % Cantidad de peatones

%% Posición
% Procedimiento:    Primero obtengo la posición en función del tiempo como
% si el peatón siguiera caminando aunque llegue al final del puente, luego
% se va cambiando para que vaya oscilando sobre el puente.

% Algoritmo para determinar posición del peatón
% xo(i) = L(side(i)-1) = 0
% X_(tk,i) = xoi*delta1 + v(i)*delta2
% delta1 = 0 si tk < tac(i), 1 si tk >= tac(i)
% delta2 = 0 si tk < tac(i), (tk-tac(i)) si tk >= tac(i)
% n = floor(x_(tk,i)/L)
% x(tk,i) = xi(tk,i)-nL si n par, (n+1)L-x_(tk,i) si n impar

x = zeros(t_length,pd_length);
x_ = zeros(t_length,pd_length);

for i = 1:pd_length
    for tk = 1:t_length
        xoi = L*(side(i)-1);
        if t_vect(tk) < tac(i)
            delta1 = 0;
            delta2 = 0;
        elseif t_vect(tk) >= tac(i)
            delta1 = 1;
            delta2 = t_vect(tk) - tac(i);
        end
        x_(tk,i) = xoi*delta1 + v(i)*delta2;
        n = floor(x_(tk,i)/L);
        if rem(n,2) == 0
            x(tk,i) = x_(tk,i) - n*L;
        elseif rem(n,2) == 1
            x(tk,i) = (n+1)*L - x_(tk,i);
        end
    end
end


% %% Generar animación
% sequence = (1:1:pd_length).';
% for tk = 1:t_length
%     plot(x(tk,:),sequence,'o')
%     grid on
%     axis([0 L -1 pd_length+1])
%     pause(0.01)
%     legend(convertStringsToChars("T = " + string(t_vect(tk))));
%     exportgraphics(gca,"Ped_Posi_Animotion2.gif","Append",true)
% end