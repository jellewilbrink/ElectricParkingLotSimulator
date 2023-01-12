% Clean up workspace
% clear variables
% close all

% disable annoying warning
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')

sweep = [0.01:0.03:0.1];
for j = 1:numel(sweep)
    sweep_var = sweep(j);
    fprintf("Sweep cycle %d of %d. Sweep_var = %f", j, numel(sweep), sweep_var)

    % simulate controller of each type
    fprintf("Starting Abscontroller... ")
    abs(j) = simulator("AbsController", sweep_var);
    
    fprintf("Starting GSController... ")
    gs(j) = simulator("GSController", sweep_var);
    
    fprintf("Starting FCFSController... ")
    fcfs(j) = simulator("FCFSController", sweep_var);
end

fprintf("Finished simulations...\n")
