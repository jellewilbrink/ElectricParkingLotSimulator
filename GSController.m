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
        end

        function [phi, Pchargers] = update(obj, Ptrafo, Pmax_chargers)
            % update: update the GridShield controller state.
            % Input:
            %   Ptrafo: current power of the transformer in W
            %   Pmax_chargers: 1D vector with maximum power (i.e. limit) for each vector
            % Output:
            %   Pchargers: array of the maximum allowed power for each
            %   charger, based on the control algorithm

            % update phi and keep it between 0 and 1
            if Ptrafo > obj.Pmax &&obj.phi > 0
                obj.phi = obj.phi - obj.step_size;
            elseif Ptrafo < obj.Prest && obj.phi < 1
                obj.phi = obj.phi + obj.step_size;
            end
            
            phi = obj.phi;

            Pchargers = obj.phi .* Pmax_chargers;
        end
    end
end