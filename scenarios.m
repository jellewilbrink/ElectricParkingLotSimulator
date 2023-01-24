% Clean up workspace
% clear variables
% close all

% disable annoying warning
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')

sweep = [50000];
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
param = "Ptotal";


for i = 1
    figure; hold on;
    
    plot(abs(i).time, get(abs(i),param)/1000);
    plot(fcfs(i).time,get(fcfs(i),param)/1000);
    plot(gs(i).time,get(gs(i),param)/1000);
    plot(noCont(i).time,get(noCont(i),param)/1000);

    yline(100,'-',{"Transformer", "Limit"});

    title("P_{trafo}");
    legend("Absolute", "FCFS", "GridShield");
    ylabel("Power (kW)");
    xlabel("Time");
    ylim([-25 inf])
    xlim([datetime(2021,6,1,6,0,0) datetime(2021,6,1,18,0,0)])
end
% % Save in good resolution
% pause(0.1)
% exportgraphics(gcf,"./output/Ptrafo.pdf","Resolution",300); 
% close(gcf);