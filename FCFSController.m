classdef FCFSController < handle
    % FSFCController Implement a controller based on First-Come First-Served algorithm.
    properties
        Pmax        % Maximum power allowed, i.e. power limit, in W
        Prest       % Restoration power in W
        Pcharge_min % Minimum charging power in W
		Pcharge_max	% Maximum charging power in W
    end

    methods
        function obj = FCFSController(Pmax, Pcharge_min, Pcharge_max)
           % FCFSController: contruct FCFSController object
           obj.Pmax=Pmax;
           obj.Pcharge_min = Pcharge_min;
		   obj.Pcharge_max = Pcharge_max;
        end

        function [Pchargers,delta] = update(obj, Ptrafo, charger_readings)
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
			delta = Ptrafo - obj.Pmax;

            % Sort the chargers, most recently connected EV in first row
            % Note: NaN goes to the last entries, which is desired
            charger_readings = sortrows(charger_readings, "arrival_time", "descend");

            % Update charger power 
			% (ATM only possible to give chargers less power and not more)
			if delta > 0		% The trafo is going over limit, so we should charge less 
				for row = 1:size(charger_readings,2)           
                	if charger_readings.p(row) >= obj.Pcharge_min + delta
                    	charger_readings.p(row) = charger_readings.p(row) - delta;
                    	delta = 0;
                    	break;
					else
						delta = delta - (charger_readings.p(row) - obj.Pcharge_min);	%code breaks when I swap this line with one below
                    	charger_readings.p(row) = obj.Pcharge_min;
                	end
				end
				for row = 1:size(charger_readings,2)	%lower to zero if lowering to minimum is not enough 
                	if delta < 0
						break
					else
						delta = delta - charger_readings.p(row);	%code breaks when I swap this line with one below
                    	charger_readings.p(row) = 0;
                	end
				end
			elseif delta < 0	% The EVs can be charged with more power
				for row = size(charger_readings,2):-1:1    % The EV that arrived first gets it P increased first       
                	if charger_readings.p(row) <=  delta + obj.Pcharge_max
                    	charger_readings.p(row) = charger_readings.p(row) - delta;
                    	delta = 0;
                    	break;
					else
						delta = delta + (obj.Pcharge_max - charger_readings.p(row));	%code breaks when I swap this line with one below
                    	charger_readings.p(row) = obj.Pcharge_max;
                	end
				end
			end

            Pchargers = table;
            Pchargers.id = charger_readings.id;
            Pchargers.p = charger_readings.p;
        end
    end
end