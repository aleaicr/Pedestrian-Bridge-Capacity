%% Continuos Beam and Pedestrians Walking
% 

%% Inicilizar
clear variables
close all
clc

%%  Inputs
% Inputs puente
load('Bridge_Propierties.mat')

% Inputs peatones
load('Pedestrian_Properties.mat')

% Inputs simulaciones

t_step = 1/1000;
t_init = 0;
t_final = 500;

t_vect = (t_init:t_step:t_final).';



