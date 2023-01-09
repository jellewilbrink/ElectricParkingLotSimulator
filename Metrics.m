classdef metrics
	%METRICS Class to calculate and save metrics
	%   Detailed explanation goes here

	properties
		Pover_limit
		E_from_grid	% single value of Energy from the grid during simulation
		E_to_grid	% single value of Energy to the grid during simulation
		%Input:
		Ptotal		% vector with Power at the trafo on each time interval
		Pmax_trafo	% the power limit of the trafo
		stepSize	% Stepsize in seconds to convert to Energy
	end

	methods
		% constructor
		function obj = metrics(stepSize)
			%METRICS Construct an instance of this class
			%   Detailed explanation goes here
			obj.stepSize = stepSize;
		end

		function update(obj,Ptrafo)
			%UPDATE Save data during simulation
			%   Add current value of Ptrafo to list of all trafo values
			%   (do every loop cycle)
			obj.Ptotal(end + 1) = Ptrafo;
		end

		function outputArg = compute(obj,inputArg)
			%COMPUTE Compute all the metrics
			%   Compute the Metrics based on the info gathered by update
			%	(do after the loop)
			obj.Pover_limit = obj.Ptotal - obj.Pmax_trafo;
			obj.Pover_limit(obj.Pover_limit(A>0)) = 0;	% Only show values that breach the limit and the rest as zero
			obj.E_from_grid = sum(obj.Ptotal(A>0))* obj.stepSize;		% Using the grid to charge EVs
			obj.E_to_grid = sum(obj.Ptotal(A<0)) * obj.stepSize;		% Over production of PVs is send to grid

		end
	end
end