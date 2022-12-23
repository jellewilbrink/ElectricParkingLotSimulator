classdef metrics
	%METRICS Summary of this class goes here
	%   Detailed explanation goes here

	properties
		Pover_limit
		%Input:
		Ptotal		% vector with Power at the trafo on each time interval
		Pmax_trafo	% the power limit of the trafo
	end

	methods
		% constructor
		function obj = metrics(inputArg1,inputArg2)
			%UNTITLED Construct an instance of this class
			%   Detailed explanation goes here
			obj.Property1 = inputArg1 + inputArg2;
		end

		function update(obj,Ptrafo)
			%UPDATE Save data during simulation
			%   Add current value of Ptrafo to list of all trafo values
			obj.Ptotal(end + 1) = Ptrafo;
		end

		function outputArg = compute(obj,inputArg)
			%COMPUTE Compute all the metrics
			%   Detailed explanation goes here
			obj.Pover_limit = obj.Ptotal - obj.Pmax_trafo;
			obj.Pover_limit(obj.Pover_limit(A>0)) = 0; % Only show values that breach the limit
			sum(obj.Pover_limit);
		end
	end
end