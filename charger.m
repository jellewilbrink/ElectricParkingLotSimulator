classdef charger < handle
    %CHARGER Summary of this class goes here
    %   Detailed explanation goes here
    properties
        ev;
        pmax {mustBeNumeric}
        pcontrolled {mustBeNumeric}
        pmin {mustBeNumeric}
        pcontrolled_history {mustBeNumeric} = []
        
        old_time {mustBeNumeric}
    end
    
    methods
        % constructor
        function obj = charger(pmax, pcontrolled, pmin, pcontrolled_history)
            %CHARGER Construct an instance of this class
            %   Detailed explanation goes here
            obj.pmax = pmax;
            obj.pcontrolled = pcontrolled;
            obj.pmin = pmin;
            obj.pcontrolled_history = pcontrolled_history;
        end
        
        function update(obj, time, pcontrolled)
            obj.pcontrolled = pcontrolled;
            obj.pcontrolled_history = [obj.pcontrolled_history obj.pcontrolled];
            if obj.hasEV(time)
                obj.charge(time);
            end
        end
        
        
        function obj = charge(obj, time)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if time > obj.old_time
                if obj.hasEV(time)
                    obj.ev.charge(max([obj.pcontrolled obj.pmin]), time - obj.old_time);
                    obj.old_time = time;
                end
            end
        end
        
        function obj = addEV(obj, e) % adds EV e to charger
            obj.ev = e;
            obj.old_time = obj.ev.arrival_time;
        end
        
        function result = hasEV(obj, time)
            if ~isempty(obj.ev) 
                if ~obj.ev.leave(time)
                    result = 1; 
                else
                    obj.ev = [];
                    result = 0;
                end
            else
                result = 0;
            end
        end
        
        function set_Pcontrolled(obj, newP)
            obj.pcontrolled = newP;
        end
    end
end

