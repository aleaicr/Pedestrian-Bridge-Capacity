%% Simulacion MGDL
% Modelo del puente contínuo

%% Inicializar
clear variables
close all
clc

%% Random Properties Generation
% For each pedestrian we generate random: Tadd, Side, Mass, Speed,
% Frequency
load rnd_pedstrian_properties

%% Bridge Properties
% Import the MDOF properties for the bridge 
load bridge_properties

%%
