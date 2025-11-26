% Function to plot Input data.
clear functions


addpath(genpath('ProgramFiles'));
addpath(genpath('Problem_input_Data'));

problemToDraw = "IPE"; % "Hertz_Plasticity", "Hertz_Elasticity", "Lamalea", "IPE"

% Hertz version 1-12 (Based on force multiplier) 
% Lamalea version 1-16 sorted by lamelas and discretization as:
% nLamalea       = [2,2, 2, 2,  4, 4, 4, 4, 6, 6, 6, 6  8, 8, 8, 8]
% discretization = [5,10,20,30, 5,10,20,30, 5,10,20,30, 5,10,20,30, 
% IPE version only 1

version = 8;

PlotInputFn(problemToDraw,version)
