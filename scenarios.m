% Clean up workspace
% clear variables
% close all

% disable annoying warning
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')

sweep = [0.05];
for j = 1:numel(sweep)
    sweep_var = sweep(j);
    fprintf("Sweep cycle %d of %d. Sweep_var = %f \n", j, numel(sweep), sweep_var)

    % simulate controller of each type
    fprintf("Starting Abscontroller... ")
    abs(j) = simulator("AbsController", sweep_var);
    
    fprintf("Starting GSController... ")
    gs(j) = simulator("GSController", sweep_var);
    
    fprintf("Starting FCFSController... ")
    fcfs(j) = simulator("FCFSController", sweep_var);
    
    fprintf("Starting without controller...")
    noCont(j) = simulator("None", sweep_var);
end

fprintf("Finished simulations...\n")


%% Choose stepsize value by sweeping


%% Plot results

for i = 1
    figure; hold on;
    plot(abs(i).time,abs(i).Pover_limit/1000);
    plot(fcfs(i).time,fcfs(i).Pover_limit/1000);
    plot(gs(i).time,gs(i).Pover_limit/1000);
end
