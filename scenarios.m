% Clean up workspace
% clear variables
% close all

% disable annoying warning
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')

% simulate controller of each type
fprintf("Starting Abscontroller... ")
abs = simulator("AbsController");

fprintf("Starting GSController... ")
gs = simulator("GSController");

fprintf("Starting FCFSController... ")
fcfs = simulator("FCFSController");

fprintf("Finished simulations...\n")