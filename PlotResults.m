% Function to plot Output data.

addpath(genpath('ProgramFiles'));
addpath(genpath('Problem_Input_Data'));
addpath(genpath("Problem_Output_Data"))

problemToDraw = "Hertz_Plastic"; % "Hertz_Plastic", "Hertz_Elastic", "Lamalea_1" "Lamalea_2" .... "Lamalea_16" 
problemVersion = 1; % 1-13 Hertz, 1-16 Lamalea

PlotOutputFn(problemToDraw,problemVersion,"sigmaX",1)