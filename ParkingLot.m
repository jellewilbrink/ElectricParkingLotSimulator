classdef ParkingLot < handle
    % Class modelling the parking lot.
    properties
        trafo
        chargers
        pv
    end

    properties(Access=private)
        t= seconds(0) % Current simulation time. Initially 00:00:00
    end

    methods
        function obj = ParkingLot(trafo_pmax, csv_pv, num_chargers)
            obj.trafo = Transformer(trafo_pmax);
            obj.pv = PV(csv_pv);
            obj.chargers= [charger(22000,22000,7000,[]) charger(22000,22000,7000,[])];
            
            for i = 1:num_chargers
                obj.chargers(i) = charger(22000,22000,7000,[]);
            end
        end

        function advance_time_to(obj, t)
            % Update time to t. TODO
        end

        function found_space = add_EV(obj,ev)
            % Connect the ev to the first available charger.
            % Returns false if no space is available for the EV, else true.

            for i = 1:numel(obj.chargers)
                if ~obj.chargers(i).hasEV(obj.t)
                    obj.chargers(i).addEV(ev);

                    found_space = true;
                    return
                end
            end

            found_space = false;
        end
         
    end
end    