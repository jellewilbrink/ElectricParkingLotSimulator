function simulator(controller_type)
%     ParkingLot(trafo_pmax, csv_pv, num_chargers)
tic
%% set parameters
        Ptarget = 80000;
        Ptrafo = 100000;
        Prest = 1000;
        Pc_min = 7000;
        Pc_max = 22000;
        GS_step = 0.05;
        NumChargers = 10;
%% create controller
        if controller_type == "AbsControl"
            controller = AbsControl(Ptarget,Ptrafo,Prest, NumChargers);
%             Power = AbsControl(1000,900,100, 10);
        elseif controller_type == "GSController"
%             Pmax, Prest, step_size, N
            controller = GSController(Ptarget,Prest, GS_step, NumChargers);
        elseif controller_type == "FCFSController"
%             Pmax, Pcharge_min, Pcharge_max
            controller = FCFSController(Ptarget, Pc_min, Pc_max);
        elseif controller_type ~= "None"
            ME = MException('InputError:Controller', ...
            'An invalid controller called %s was given... Please input a valid controller.', controller_type);
            throw(ME)
        end
    
%% add DriveEV and ParkingLot instances
    dEV = DriveEV('data/BetterCars.csv');
    p = ParkingLot(Ptarget, 'data/solarPanelOutputDataSlimPark-1day.csv', 10);
    data = readtable('data/solarPanelOutputDataSlimPark-1day.csv');
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
    for i = 1:65375
%     for i = 1:numel(data(:,1))
        % get current time and power
        curr_time = data(i,1).Time;
        curr_power = data(i,2).devices_mean;
        
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
            [phi, Pchargers] = controller.update(Ptrafo, [p.chargers(:).pmax]);
            phi_history = [phi_history phi];
            p.updatePower(Pchargers);
        elseif controller_type == "FCFSController"
            [Pchargers,delta] = controller.update(Ptrafo, Pchargers);
            delta_history = [delta_history delta];
            p.updatePower(Pchargers);
        end
%         p.updatePower(Pchargers);
        
        
%% save data
        trafo_history = [trafo_history Ptrafo]; % Pchargers + PV
        time_history = [time_history curr_time]; % time
        pvdata = [pvdata p.pv.P];   % PV
        chargingdata = [chargingdata p.test]; % Pchargers
        
        
    end
    
toc
end