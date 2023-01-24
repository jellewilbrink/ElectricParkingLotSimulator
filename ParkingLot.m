classdef ParkingLot < handle
    % Class modelling the parking lot.
    properties
        trafo
        chargers
        pv
        test
        P_min
        P_max
    end

    properties(Access=private)
        t= seconds(0) % Current simulation time. Initially 00:00:00
    end

    methods
        function obj = ParkingLot(trafo_pmax, csv_pv, num_chargers, P_min, P_max)
            obj.trafo = Transformer(trafo_pmax, 0);
            obj.pv = PV(csv_pv);         
            obj.P_min = P_min;
            obj.P_max = P_max;
            % Initialize chargers with default values
            obj.set_chargers(P_max,P_max,P_min,num_chargers)
        end

        function advance_time_to(obj, t)
            % Update time to t.
            obj.pv.advance_time_to(t);

            total_charging=0;
            for i = 1:numel(obj.chargers)
                obj.chargers(i).update(t, obj.chargers(i).pcontrolled);
                total_charging = total_charging + obj.chargers(i).p; 
            end
            
            
            obj.trafo.power = obj.pv.P + total_charging;
            obj.test = total_charging;
            obj.t = t;
        end

        function set_chargers(obj, pmax, pcontrolled, pmin, num_chargers)
            % Initialize num_chargers chargers all with the same parameters

            % Create 'empty'charger array
            obj.chargers= [charger(obj.P_max,obj.P_max,obj.P_min,[]) charger(obj.P_max,obj.P_max,obj.P_min,[])];

            % Fill with values and increase array length if needed
            for i = 1:num_chargers
                obj.chargers(i) = charger(pmax,pcontrolled,pmin,[]);
            end
        end

        function found_space = add_EV(obj,ev)
            % Connect the ev to the first available charger.
            % Returns false if no space is available for the EV, else true.

            for i = 1:numel(obj.chargers)
                if ~obj.chargers(i).hasEV()
                    obj.chargers(i).addEV(ev);

                    found_space = true;
                    return
                end
            end

            found_space = false;
        end
        
        function updatePower(obj, chargingPower)
           for i = 1:width(chargingPower)
               obj.chargers(i).pcontrolled = chargingPower(i);
           end
        end
         
    end
end    