classdef Transformer < handle
    %UNTITLED Summary of this class goes here
    %   This class represents the transformer with all of its variables 
    %   and functions 
    
    properties
        pmax {mustBeNumeric}
        power {mustBeNumeric}
    end
    
    methods
        function obj = Transformer(pmax)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.pmax = pmax;
            obj.power = 0;
        end
    end
end

