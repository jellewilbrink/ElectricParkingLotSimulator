function M=simulator(controller_type, sweep_var)
%     ParkingLot(trafo_pmax, csv_pv, num_chargers)
tic
%% set parameters
        % NOTE: next to the parameters below, there are also hardcoded
        % parameters in the DriveEV.m and ParkingLot.m files. For now it is
        % chosen to leave them there, because they can be configured once 
        % and changing them is less interesting for the purpose of
        % analyzing the controllers.
        Ptrafo_max = 100000; % Power limit of the trafo
        Prest =  80000;  % Restoration power for control
        Ptarget = Prest + (Ptrafo_max - Prest)/2; % Target power for Aim at the middle between Ptrafo and Prest
        GS_step = 0.01; % Stepsize to change phi in GridShield controller
        Pc_min = sweep_var; %7000; % Minimum charger power, If changed, also change in ParkingLot.m
        Pc_max = 22000;% Maximum charger power, If changed, also change in ParkingLot.m and in DriveEV.m
        NumChargers = 10; % Number of chargers.

        PV_file = 'data/solarPanelOutputDataSlimPark-1day.csv'; % Path to file containing PV data
        EV_file = 'data/BetterCars.csv'; % Path to file containing EV data
        end_time = duration("21:00:00");
%% create controller
        if controller_type == "AbsController"
            controller = AbsControl(Ptrafo_max,Ptarget,Prest, NumChargers);
%             Power = AbsControl(1000,900,100, 10);
        elseif controller_type == "GSController"
%             Pmax, Prest, step_size, N
            controller = GSController(Ptrafo_max,Prest, GS_step, NumChargers);
        elseif controller_type == "FCFSController"
%             Pmax, Pcharge_min, Pcharge_max
            controller = FCFSController(Ptrafo_max, Pc_min, Pc_max); % FIXME: Not sure about Ptarget here...
        elseif controller_type ~= "None"
            ME = MException('InputError:Controller', ...
            'An invalid controller called %s was given... Please input a valid controller.', controller_type);
            throw(ME)
        end
%%	Create metrics
	M = Metrics(1, Ptrafo_max);
%% add DriveEV and ParkingLot instances
   
    dEV = DriveEV(EV_file);
    p = ParkingLot(Ptarget, PV_file, 10);
    p.set_chargers(Pc_max,Pc_max,Pc_min,NumChargers);

    opts = detectImportOptions(PV_file);
    opts = setvaropts(opts,"Time",'InputFormat','MM/dd/uuuu HH:mm:ss');
    opts.VariableNamingRule = 'modify';
    data = readtable(PV_file, opts);

%     init_time = data(1,1).Time;
%     start_time = datetime(data(1,1).Time,"Format","uuuu/MM/dd hh:mm:ss")
%     end_time = datetime(data(numel(data(:,1)),1).Time,"Format","uuuu/MM/dd hh:mm:ss")
    % Go through all time steps
    trafo_history = [];
    pvdata = [];
    chargingdata = [];
    phi_history = [];
    delta_history = [];
    time_history = datetime('yesterday');
%% perform simulation
    for i = 1:numel(data(:,1))
        % get current time and power
        curr_time = data(i,1).Time;
        curr_power = data(i,2).devices_mean;

        if timeofday(curr_time) > end_time
            break
        end
        
%% update parkingLot and newEV
        p.advance_time_to(timeofday(curr_time));
        newEV = dEV.advance_time_to(timeofday(curr_time));
        if ~isempty(newEV)
            success = p.add_EV(newEV);
            if ~success
                rip = 1;
            else
                rip = 0;
            end
        end
%% get charger data
        Pchargers = [];
        for j = 1:NumChargers
%             if size(p.chargers(1,j).p) == 0
            if p.chargers(1,j).hasEV()
                Pchargers(j) = p.chargers(1,j).p;
            end
        end
        
%         Pprev = -1;
%% update controller
        Ptrafo = p.trafo.power;
        if controller_type == "AbsControl"
            Pchargers = controller.update(Ptrafo, Pchargers); % EV-PV, vector of chargers
        elseif controller_type == "GSController"
            p.updatePower(Pchargers);
            [phi, Pchargers] = controller.update(Ptrafo, Pc_max);	% [p.chargers(:).pmax] Was first instead of Pc_max
            phi_history = [phi_history phi];
            p.updatePower(Pchargers);
        elseif controller_type == "FCFSController"
            [Pchargers,delta] = controller.update(Ptrafo, Pchargers);
            delta_history = [delta_history delta];
            p.updatePower(Pchargers);
        end
%         p.updatePower(Pchargers);
        
        
%% save data
%         trafo_history = [trafo_history Ptrafo]; % Pchargers + PV
%         time_history = [time_history curr_time]; % time
        %pvdata = [pvdata p.pv.P];   % PV
        %chargingdata = [chargingdata p.test]; % Pchargers
        M.Ptotal = Ptrafo;
		M.time = curr_time;
		M.PVdata = p.pv.P;
		M.Pchargers = p.test;
        
    end
    M = M.compute;	% Compute all the metrics over the whole time frame

%     plot(time_history, trafo_history)
toc
end