%% Random Pedestrian Position
% Alexis Contreras R.
% Pedestrian Bridge Capacity

%% Comentarios

%% Inicializar
clear variables
close all
clc

%% Peatones y grupos
n_min = 1;
n_max = 40;
n_step = 5;

peatones = (n_min:1:n_max)';
grupos = ((n_min-1)+n_step:n_step:n_max)';
np = length(peatones);
ng = length(grupos);
num_grupo = (1:1:ng)';

