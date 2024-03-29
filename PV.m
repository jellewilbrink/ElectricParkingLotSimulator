classdef PV < handle
    % Class modelling the behavior of Photo Voltaic (PV) panels.
    % Load the generated power from a csv file containing time and power.
    properties
        P = 0 % Power currently generated by the PV panels. (negative is generation)
    end

    properties(Access=private)
        Pt % Table containing generated power for each timestep
        t= timeofday(datetime("yesterday")) % Current simulation time.
    end

    methods
        function obj = PV(csv_in)
            % Create PV object
            % INPUT:
            %    csv_in: path to csv file containing "Time" and
            %    "devices.mean" columns

            % Read data from csv file
            opts = detectImportOptions(csv_in);
            opts.VariableNamingRule = 'modify';
            opts = setvaropts(opts,"Time",'InputFormat','MM/dd/uuuu HH:mm:ss');


            obj.Pt = readtable(csv_in, opts);
            obj.Pt = renamevars(obj.Pt,["Time","devices_mean"],["dt","P"]);
            obj.Pt.t = timeofday(obj.Pt.dt);
            obj.Pt.d = obj.Pt.dt;
            obj.Pt.d.Format = 'yyyy-MM-dd';
            
            % Remove rows with missing data, like NaNs
            obj.Pt = rmmissing(obj.Pt);
        end

        function advance_time_to(obj, t)
            % Set time to the given time and set P to the corresponding
            % power from the table.

            obj.t = t;
            
            filt = obj.Pt.t <= obj.t;
            [~,filt_t] = max(obj.Pt.t(filt));
            obj.P = obj.Pt.P(filt_t);
        end        

    end

end