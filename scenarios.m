% Clean up workspace
clear variables
close all

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
    
    plot(noCont(i).time,get(noCont(i),param)/1000);
    plot(gs(i).time,get(gs(i),param)/1000,"Color","#EDB120");
    plot(abs(i).time, get(abs(i),param)/1000, "Color",	"#D95319");
    plot(fcfs(i).time,get(fcfs(i),param)/1000);

    yline(100,'-',{"Transformer", "Limit"});

    title("P_{trafo}");
    legend("No controller", "GridShield", "Absolute", "FCFS");
    ylabel("Power (kW)");
    xlabel("Time");
    ylim([-25 inf])
    xlim([datetime(2021,6,1,6,0,0) datetime(2021,6,1,18,0,0)])
end
% Save in good resolution
pause(0.1)
exportgraphics(gcf,"./output/Ptrafo.pdf","Resolution",300); 
close(gcf);

%% Make metrics table
params = ["Pover_limit_quadratic", "Tover_limit"];
t=zeros(0,4);
i=1;
for j = 1:length(params)
    [get(abs(i),params(j)), get(fcfs(i),params(j)), get(gs(i),params(j))]
end
[max(get(noCont(i),"ENS")),max(get(abs(i),"ENS")), max(get(fcfs(i),"ENS")), max(get(gs(i),"ENS"))]
[mean(get(noCont(i),"ENS")),mean(get(abs(i),"ENS")), mean(get(fcfs(i),"ENS")), mean(get(gs(i),"ENS"))]
[std(get(noCont(i),"ENS")),std(get(abs(i),"ENS")), std(get(fcfs(i),"ENS")), std(get(gs(i),"ENS"))]


