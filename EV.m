classdef EV < handle
    %EV Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        arrival_time
    end
    
%     properties(Access=private)
    properties
        pmax {mustBeNumeric}
        capacity {mustBeNumeric}
        sum_of_charge {mustBeNumeric}
        departure_time 
        desired_charge {mustBeNumeric}
        initial_charge {mustBeNumeric}
        time = 0
        soc_hist
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
            obj.time = obj.arrival_time;
            obj.soc_hist = [];
        end
       
%         function update(obj, power, time)
%             if ~obj.is_full && ~obj.leave(time)
%                 obj.charge(power, time)
%             end
%         end
       
        % sets new SoC based on time in s and delivered power
        function Pcharged = charge(obj, power)
            power = min([obj.pmax, power]);
            old_sum = obj.sum_of_charge;
            obj.sum_of_charge = min([(obj.sum_of_charge + power/3600) ...
                (obj.desired_charge + obj.initial_charge) ...
                obj.capacity]);
            
            obj.time = obj.time + seconds(1);
            Pcharged = (obj.sum_of_charge - old_sum) * 3600;
            obj.soc_hist = [obj.soc_hist obj.sum_of_charge];
            %obj.sum_of_charge = obj.sum_of_charge + power * time;
        end
        
        function full = is_full(obj)
            if obj.sum_of_charge == min([obj.capacity obj.initial_charge + obj.desired_charge])
                full = true;
            else
                full = false;
            end
        end
        
        function leave = leave(obj)
            if obj.departure_time <= obj.time
                leave = true;
            else
                leave = false;                
            end
        end
        
        function setTime(obj, time)
            obj.time = time;
        end
        
        function P = ENS(obj)
            % Return Energy Not Served in Wh
            P = min(obj.capacity - obj.sum_of_charge, ...
                obj.initial_charge + obj.desired_charge - obj.sum_of_charge);
        end
    end
end

