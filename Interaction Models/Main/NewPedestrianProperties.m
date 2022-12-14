function [m_vect,v_vect,freq_vect,w_vect,ai_vect,lambdai_vect,side_vect,Tadd_cum,pos,psi_posi] = NewPedestrianProperties(n_min,n_max,n_step,L,mu_m,sigma_m,mu_v,sigma_v,mu_freq,sigma_freq,mu_ai,sigma_ai,mu_lambdai,sigma_lambdai,Tadd_min,Tadd_max,t_step,t_extra,n_modos)
% Pedestrian Bridge Performance
% Alexis Contreras R.

% Generador de propiedades aleatorias de peatones.

% Estas propiedades son seleccionadas de forma aleatoria según la
% distribución que tenga la propiedad

% INPUTS
% n_min:        Primer peatón es 1, si quiero ir de 100 a 200 peato del101, no del 100
% n_max:        Cantidad máxima de peatones
% n_step:       Cantidad de peatones por grupo (si se desean agrupar)
% L:            Largo del puente (viga equivalente)
% mu_m:         [kg] Median de la distribución normal de la masa de cada peatón
% sigma_m:      [kg] Desviación estándar de la distribución normal de la masa de cada peatón
% mu_v:         [m/s] Media de la destribución normal de la velocidad longitudinal del caminar de cada peatón
% sigma_v:      [m/s] Desviación estándar de la distribución normal de la velocidad longitudinal del caminar de cada peatón
% mu_freq:      [rad/s] Media de la distribución normal de la frecuencia media delcaminar de cada peatón
% sigma_freq:   [rad/s] Desviación estándar de la distribución normal de la frecuencia media delcaminar de cada peatón
% mu_ai:        [-] Media de la distribución normal del parámetro de Belykh et al 2017 (ai)
% sigma_ai:     [-] Ddesviación estándar de la distribución normal del parámetro de Belykh et al 2017 (ai)
% mu_lambdai:   [-] Media de la distribución normal del parámetro de Belykh et al 2017 (lambdai)
% sigma_lambdai:[-]Desviación estándar de la distribución normal del parámetro de Belykh et al 2017 (lambdai)
% Tadd_min:     [s] Tiempo mínimo de incorporación consecutiva entre dos poeatones
% Tadd_max:     [s] Tiempo máximo de incorporación consecutiva entre dos peatones
% t_step:       [s] Paso temporal para la simulación (1/1000 funciona bien para runge-kutta ode4)
% t_extra:      [s] Tiempo extra después de agregar el último peatón
% n_modos:      Cantidad de modos a considerar para obtener la respuesta de la viga equivalente

% OUTPUTS
% m_vect:       Vector con la masa de cada peatón
% v_vect


% Comentarios
% * Las distribuciones utilizadas son las siguientes
% Masa -  Distribución normal
% Velocidad - Distribución normal
% Frecuencia - Distribución normal
% Parámetros de modelo de Belykh 2017 - ai, lambdai -  Distribución normal
% Tiempo de incorporación - Distribución uniforme
% Lado - aleatorio entre 1 y 2 (lado 1 y lado 2) - Dicotómica
% * Actualmente, el agrupar, solo funciona agrupando todos los peatones en
% grupos de n_step, no que solo algunos se agrupen.

%% Generación de data (selección aleatoria dentro de distribución)
% Peatones y grupos
peatones = (n_min:1:n_max).';                                               % Peatón n_min
grupos = ((n_min-1)+n_step:n_step:n_max).';                                 
np = length(peatones);
ng = length(grupos);                                                        % Cantidad de grupos o peatones

% Vamos a ver grupos o peatones?
if n_step ~= 1
    np = ng;
end

% Masa
m_vect = normrnd(mu_m,sigma_m,[np,1]);                                      % Distribución normal

% Velocidad
v_vect = normrnd(mu_v,sigma_v,[np,1]);                                      % Distribución normal

% Frecuencia
freq_vect = normrnd(mu_freq,sigma_freq,[np,1]); % hz                        % Distribución normal
w_vect = 2*pi*freq_vect; % rad/sec                                          % Distribución normal

% Propiedades Modelo de Belykh et al 2017
% ai
ai_vect = normrnd(mu_ai,sigma_ai,[np,1]);
%lambdai
lambdai_vect = normrnd(mu_lambdai,sigma_lambdai,[np,1]);

% Tiempo de incorporación
Taddvectprima = randi([Tadd_min,Tadd_max],[np-1,1]);                        % Distribución uniforme
Tadd_vect = [0;Taddvectprima];                                              % El primer peatón, ingresa instantáneamente cuando empieza la simulación                                         

% Acumulado (stairs)
Tadd_cum = cumsum(Tadd_vect);

% Lado
side_vect = randi([1,2],[np,1]);                                            % Dicotómico

%% Posición de peatón
% Calcular en cada tiempo (del vector t_vect) la posición de cada peatón
% Renombramiento de variables (script estaba listo de antes)
pd_length = length(v_vect);                                                 % Cantidad de peatones
t_vect = (0:t_step:(Tadd_cum(end)+t_extra)).';                              % Vector de tiempos
t_length = length(t_vect);                                                  % Cantidad de tiempos

% Algoritmo para determinar posición del peatón (x = pos)
% xo(i) = L(side(i)-1) = 0
% X_(tk,i) = xoi*delta1 + v(i)*delta2
% delta1 = 0 si tk < tac(i), 1 si tk >= tac(i)
% delta2 = 0 si tk < tac(i), (tk-tac(i)) si tk >= tac(i)
% n = floor(x_(tk,i)/L)
% x(tk,i) = xi(tk,i)-nL si n par, (n+1)L-x_(tk,i) si n impar

% Aplicación del algoritmo
pos = zeros(t_length,pd_length);
x_ = zeros(t_length,pd_length);

for i = 1:pd_length                                                         % Recorremos para cada peatón
    for tk = 1:t_length                                                     % Para cad atiempo
        xoi = L*(side_vect(i)-1);
        if t_vect(tk) < Tadd_cum(i)                                         % * Si aun no entra
            delta1 = 0;
            delta2 = 0;
        elseif t_vect(tk) >= Tadd_cum(i)                                    % ** si entra
            delta1 = 1;
            delta2 = t_vect(tk) - Tadd_cum(i);
        end
        x_(tk,i) = xoi*delta1 + v_vect(i)*delta2;                           % * entonces se queda en 0; ** entonces se mueve
        n = floor(x_(tk,i)/L);
        if rem(n,2) == 0                                                    % si sale de la viga, entonces rebota
            pos(tk,i) = x_(tk,i) - n*L;
        elseif rem(n,2) == 1
            pos(tk,i) = (n+1)*L - x_(tk,i);
        end                                                                 % y se mantiene en un ciclo
    end
end

%% Obtener psi_n(x_i)
% Obtenemos el vector con las funciones simbólicas psi
% tenemos pos = [pos1(t) pos2(t) pos3(t) ... posp(t)]
% donde posi(t) = vector[posi(t1); posi(t2); ... ; posi(tf)]

psi_posi = zeros(t_length,n_modos,pd_length);
for i = 1:pd_length
    psi_posi(:,:,i) = sinModalShapes_psiposit(n_modos,L,pos(:,i));
end

end