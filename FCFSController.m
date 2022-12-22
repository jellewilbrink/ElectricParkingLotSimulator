classdef FCFSController < handle
    % FSFCController Implement a controller based on First-Come First-Served algorithm.
    properties
        Pmax        % Maximum power allowed, i.e. power limit, in W
        Prest       % Restoration power in W
        Pcharge_min % Minimum charging power in W
    end

    methods
        function obj = FCFSController(Pmax, Pcharge_min)
           % FCFSController: contruct FCFSController object
           obj.Pmax=Pmax;
           obj.Pcharge_min = Pcharge_min;          
        end

        function Pchargers = update(obj, Ptrafo, charger_readings)
            % update: update the FCFS controller state.
            % Input:
            %   Ptrafo: current power of the transformer in W
            %   charger_readings: table with the following columns:
            %       id: identifier of the charger
            %       arrival_time: arrival time of the EV, nan if not
            %       applicable
            %       p: current charging power in W
            % Output:
            %   Pchargers: table with columns: 
            %       id: identifier of the charger
            %       p: updated of the power for each charger, based on
            %       the control algorithm

            % Update step
            delta = 0;
            if Ptrafo > obj.Pmax
                delta = Ptrafo - obj.Pmax;
            end

            % Sort the chargers, most recently connected EV in first row
            % Note: NaN goes to the last entries, which is desired
            charger_readings = sortrows(charger_readings, "arrival_time", "descend");

            % Update charger power
            for row = 1:size(charger_readings,1)           
                if charger_readings.p >= obj.Pcharge_min + delta
                    charger_readings.p = charger_readings.p - delta;
                    delta = 0;
                    break;
                else
                     charger_readings.p = charger_readings.p - (delta - obj.Pcharge_min);
                     delta = delta - obj.Pcharge_min;
                end
            end

            if delta > 0
                throw(MException("Controller Error","The FCFS controller cannot reduce the power to within the trafo limit..."));
            end

            Pchargers = table;
            Pchargers.id = charger_readings.id;
            Pchargers.p = charger_readings.p;
        end
    end
end