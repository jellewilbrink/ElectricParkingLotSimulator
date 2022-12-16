classdef charger < handle
    %CHARGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        pmin {mustBeNumeric}
        pcontrolled_history {mustBeNumeric} = []
        pmax {mustBeNumeric}
        pcontrolled {mustBeNumeric}
        time = 0
    end
    
    properties
        ev;        
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
        
        function update(obj, pcontrolled)
            obj.pcontrolled = pcontrolled;
            obj.time = obj.time + 1;
            obj.pcontrolled_history = [obj.pcontrolled_history obj.pcontrolled];
            if obj.hasEV()
                obj.charge();
            end
        end
        
        
        function obj = charge(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
%             if time > obj.old_time
            if obj.hasEV() && numel(obj.pcontrolled_history) >= 3
%                 obj.ev.charge(max([obj.pmin, obj.pcontrolled_history(time - 2)]), time - obj.old_time);
                obj.ev.charge(max([obj.pmin, obj.pcontrolled_history(obj.time - 2)]));
%                     obj.ev.charge(max([obj.pcontrolled obj.pmin]), time - obj.old_time);
            elseif obj.hasEV()
                obj.ev.charge(obj.pmax);
            end
%             end
        end
        
        function obj = addEV(obj, e) % adds EV e to charger
            obj.ev = e;
            obj.time = obj.ev.arrival_time;
        end
        
        function result = hasEV(obj)
            if ~isempty(obj.ev) 
                if ~obj.ev.leave()
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

