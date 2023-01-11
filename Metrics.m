classdef metrics
	%METRICS Class to calculate and save metrics
	%   Detailed explanation goes here

	properties
		Pover_limit	% All instances that the trafo limit is exceeded
		Pover_limit_quadratic	% sum of the quadartic limit violation 
		E_from_grid	% single value of Energy from the grid during simulation
		E_to_grid	% single value of Energy to the grid during simulation
		%Input:
		Ptotal		% vector with Power at the trafo on each time interval
		Pmax_trafo	% the power limit of the trafo
		stepSize	% stepsize in seconds to convert to Energy
		time		% simulation time
		PVdata		% power of PV on each time interval
		Pchargers	% output power at each charger on each time interval
	end

	methods
		% constructor
		function obj = metrics(stepSize, Pmax_trafo)
			%METRICS Construct an instance of this class
			%   Detailed explanation goes here
			obj.stepSize = stepSize;
			obj.Pmax_trafo = Pmax_trafo;
			obj.Ptotal = [];
		end

		function obj = set.Ptotal(obj, Ptrafo)
			%values of a class can only be changed using set.prop method
			obj.Ptotal = [obj.Ptotal Ptrafo];
		end

		function obj = set.time(obj, curr_time)
			%values of a class can only be changed using set.prop method
			obj.time = [obj.time curr_time];
		end

		function obj = set.PVdata(obj, curr_PV)
			%values of a class can only be changed using set.prop method
			obj.PVdata = [obj.PVdata curr_PV];
		end

		function obj = set.Pchargers(obj, curr_Pcharger)
			%values of a class can only be changed using set.prop method
			obj.Pchargers = [obj.Pchargers curr_Pcharger];
		end

		function obj = compute(obj)
			%COMPUTE Compute all the metrics
			%   Compute the Metrics based on the info gathered by update
			%	(do after the loop)
			obj.Pover_limit = obj.Ptotal - obj.Pmax_trafo;
			obj.Pover_limit(obj.Pover_limit<0) = 0;	% Only show values that breach the limit and the rest as zero
			obj.Pover_limit_quadratic = sum(obj.Pover_limit.^2);
			obj.E_from_grid = sum(obj.Ptotal(obj.Ptotal>0))* obj.stepSize;		% Using the grid to charge EVs
			obj.E_to_grid = sum(obj.Ptotal(obj.Ptotal<0)) * obj.stepSize;		% Over production of PVs is send to grid

		end
	end
end