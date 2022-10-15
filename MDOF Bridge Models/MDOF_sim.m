%% Simulacion MGDL
% Modelo del puente contínuo

%% Inicializar
clear variables
close all
clc

%% Random Properties Generation
% For each pedestrian we generate random properties
load ..\RandomProperties\rnd_pedstrian_properties

%% Bridge Properties
% Import the MDOF properties for the bridge 
load ..\BridgeProperties\MDOF_bridge_properties

%%
