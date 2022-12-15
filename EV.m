classdef EV < handle
    %EV Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pmax {mustBeNumeric}
        capacity {mustBeNumeric}
        sum_of_charge {mustBeNumeric}
        arrival_time {mustBeNumeric}
        departure_time {mustBeNumeric}
        desired_charge {mustBeNumeric}
        initial_charge {mustBeNumeric}
    end
    
    methods
        function obj = EV(pmax,capacity, sum_of_charge, arrival_time, departure_time, desired_charge)
            %EV Construct an instance of this class
            %   Detailed explanation goes here
            obj.pmax = pmax;
            obj.capacity = capacity;
            obj.sum_of_charge = sum_of_charge;
            obj.arrival_time = arrival_time;
            obj.departure_time = departure_time;
            obj.desired_charge = desired_charge;
            obj.initial_charge = sum_of_charge;
        end
       
%         function update(obj, power, time)
%             if ~obj.is_full && ~obj.leave(time)
%                 obj.charge(power, time)
%             end
%         end
       
        % sets new SoC based on time in s and delivered power
        function obj = charge(obj, power, time)
            obj.sum_of_charge = min([(obj.sum_of_charge + power * time) obj.desired_charge + obj.initial_charge obj.capacity]);
            %obj.sum_of_charge = obj.sum_of_charge + power * time;
        end
        
        function full = is_full(obj)
            if obj.sum_of_charge == min([obj.capacity obj.initial_charge + obj.desired_charge])
                full = true;
            else
                full = false;
            end
        end
        
        function leave = leave(obj, time)
            if obj.departure_time <= time
                leave = true;
            else
                leave = false;                
            end
        end
    end
end

