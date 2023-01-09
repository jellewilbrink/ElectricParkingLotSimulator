classdef charger < handle
    %CHARGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        pmin {mustBeNumeric}
        pcontrolled_history {mustBeNumeric} = []
        pmax {mustBeNumeric}
        time = 0
    end
    
    properties
        ev;        
        pcontrolled {mustBeNumeric}
        p {mustBeNumeric}
    end
    
    methods
        function obj = charger(pmax, pcontrolled, pmin, pcontrolled_history)
            %CHARGER Construct an instance of this class
            %   Detailed explanation goes here
            obj.pmax = pmax;
            obj.pcontrolled = pcontrolled;
            obj.pmin = pmin;
            obj.pcontrolled_history = pcontrolled_history;
        end
        
        function update(obj, time, pcontrolled)
            %update update all the parameters of the charger (pcontrolled, time and history)
            %Input:
            %	pcontrolled - controlled power from parkingLot
            %Output:
            %	-
            obj.pcontrolled = pcontrolled;
%             obj.time = obj.time + 1;
            obj.time = time;
            obj.pcontrolled_history = [obj.pcontrolled_history obj.pcontrolled];
            if obj.hasEV()
                obj.ev.setTime(time);
                obj.charge();
            else
                obj.p = 0;
            end
        end
        
        
        function obj = charge(obj)
            %charge charge the ev object connected to charger
            %Input:
            %	-
            %Output:
            %	-
            if obj.hasEV() && numel(obj.pcontrolled_history) >= 3
                obj.p = obj.ev.charge(max([obj.pmin, ...
                    obj.pcontrolled_history(width(obj.pcontrolled_history) - 2)]));
            elseif obj.hasEV()
                obj.ev.charge(obj.pmax);
            end
        end
        
        function obj = addEV(obj, e) % adds EV e to charger
            obj.ev = e;
            obj.time = obj.ev.arrival_time;
        end
        
        function result = hasEV(obj)
            if ~isempty(obj.ev) && isvalid(obj.ev)
                if ~obj.ev.leave()
                    result = 1; 
                else
                    delete(obj.ev);
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

