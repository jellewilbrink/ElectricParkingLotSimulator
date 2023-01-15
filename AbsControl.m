classdef AbsControl < handle
% AbsControl Controlling the chargers in absolute steps

    properties
        Pmax    %	Pmax	= power limit of the trafo
        Ptarget %	Ptarget	= the wanted value for Ptrafo
        Prest   %   Prest   = restoration power
        N       %	N		= the number of chargers
    end

    properties(Access=private)
        Pprev   %	Pprev	= previous value of Pcharger
    end

    methods
        function obj = AbsControl(Pmax, Ptarget, Prest, N)
            obj.Pmax = Pmax;
            obj.Ptarget = Ptarget;
            obj.Prest = Prest;
            obj.N = N;
        end

        function Pchargers = update(obj, Ptrafo, Pchargers)
            % Input:
            %   Ptrafo	= the power at the trafo (power consumed by EV - power produced by PV)
            %   Pchargers = Vector with the power draw of each charger. 
            % Output:
            %	Pchargers = The power for each charger. This is an N-length vector, because
            %	in FCFS chargers will get different power.
    
            if (Ptrafo >= obj.Pmax) || (Ptrafo < obj.Prest)
	            % If all chargers will use Pev than the Ptarget will be reached 
	            Pchargers = Pchargers + (obj.Ptarget - Ptrafo)/obj.N;		
            end
        end
    end

end



