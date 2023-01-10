function simulator(controller_type)
%     ParkingLot(trafo_pmax, csv_pv, num_chargers)
%% set parameters
        Ptarget = 80000;
        Ptrafo = 100000;
        Prest = 1000;
        NumChargers = 10;
%% create controller
        if controller_type == "AbsControl"
            controller = AbsControl(Ptarget,Ptrafo,Prest, NumChargers);
%             Power = AbsControl(1000,900,100, 10);
        elseif controller_type == "GSController"
%             Pmax, Prest, step_size, N
            controller = GSController(Ptarget,Prest, 0.1, NumChargers);
        elseif controller_type == "FCFSController"
%             Pmax, Pcharge_min, Pcharge_max
            controller = FCFSController(Ptarget, 7000, 22000);
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
    for i = 1:numel(data(:,1))
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
        Pchargers = zeros(1,NumChargers);
        for j = 1:NumChargers
            if size(p.chargers(1,j).p) == 0
                p.chargers(1,j).p = 0;
            end
            Pchargers(j) = p.chargers(1,j).p;
        end
        
%         Pprev = -1;
%% update controller
        Ptrafo = p.trafo.power;
        if controller_type == "AbsControl"
            Pchargers = controller.update(Ptrafo, Pchargers); % EV-PV, vector of chargers
        elseif controller_type == "GSController"
            [phi, Pchargers] = controller.update(Ptrafo, [p.chargers(:).pmax]);
            phi_history = [phi_history phi];
        elseif controller_type == "FCFSController"
            [Pchargers,delta] = controller.update(Ptrafo, Pchargers);
            delta_history = [delta_history delta];
        end
        p.updatePower(Pchargers);
        
        
%% save data
        trafo_history = [trafo_history Ptrafo];
        time_history = [time_history curr_time];
        pvdata = [pvdata p.pv.P];
        chargingdata = [chargingdata p.test];
        
        
    end
    

end