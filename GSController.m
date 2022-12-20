classdef GSController < handle
    % GSController Implement a controller based on GridShield.
    properties
        step_size   % Stepsize to change phi with. between 0 and 1
        Pmax        % Maximum power gridshield will allow, i.e. power limit, in W
        Prest       % Restoration power in W
        N           % Number of chargers
    end

    properties(Access=private)
        phi = 1             % Power factor for gridshield
        Pchargers_prev = [] % Last known power state for each charger
    end

    methods
        function obj = GSController(Pmax, Prest, step_size, N)
           % GSController: contruct GSController object
           
           obj.step_size = step_size;
           obj.Pmax=Pmax;
           obj.Prest=Prest;
           obj.N=N;
           % initialize charger array
           obj.Pcharger_prev = zeros([1 N]);           
        end

        function phi = update(obj, Ptrafo)
            % update: update the GridShield controller state.
            % Input:
            %   Ptrafo: current power of the transformer in W
            % Output:
            %   Pchargers: array of the maximum allowed power for each
            %   charger, based on the control algorithm

            % update phi
            if Ptrafo > obj.Pmax
                obj.phi = obj.phi - obj.step_size;
            elseif Ptrafo < obj.Prest
                obj.phi = obj.phi - obj.step_size;
            end
            
            phi = obj.phi;            
        end
    end
end