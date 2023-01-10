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

        function [Pchargers,delta] = update(obj, Ptrafo, Pchargers)
            % update: update the FCFS controller state.
            % Input:
            %   Ptrafo: current power of the transformer in W
            %   Pchargers: array of charging power for each charger
            %       connected to an EV. NOTE: This assumes that the array
            %       is sorted such that the most recently connected EV is
            %       the last element and the oldest EV is the first element.
            % Output:
            %   Pchargers: array of charging power for each charger
            %       connected to an EV.

            % Update step
			delta = Ptrafo - obj.Pmax;

            % Update charger power 
			% (ATM only possible to give chargers less power and not more)
			if delta > 0		% The trafo is going over limit, so we should charge less 
				for i = 1:numel(Pchargers)        
                	if Pchargers(i) >= obj.Pcharge_min + delta
                    	Pchargers(i) = Pchargers(i) - delta;
                    	delta = 0;
                    	break;
					else
						delta = delta - (Pchargers(i) - obj.Pcharge_min);	%code breaks when I swap this line with one below
                    	Pchargers(i) = obj.Pcharge_min;
                	end
				end
% Commented code is for when you want to be able to charge below Pcharge_min				
%				for i = 1:numel(Pchargers)	%lower to zero if lowering to minimum is not enough 
%                	if delta < 0
%						break
%					else
%						delta = delta - Pchargers(i);	%code breaks when I swap this line with one below
%                    	Pchargers(i) = 0;
%                	end
%				end
			elseif delta < 0	% The EVs can be charged with more power
				for i = numel(Pchargers):-1:1    % The EV that arrived first gets it P increased first       
                	if Pchargers(i) <=  delta + obj.Pcharge_max
                    	Pchargers(i) = Pchargers(i) - delta;
                    	delta = 0;
                    	break;
					else
						delta = delta + (obj.Pcharge_max - Pchargers(i));	%code breaks when I swap this line with one below
                    	Pchargers(i) = obj.Pcharge_max;
                	end
				end
            end
        end
    end
end