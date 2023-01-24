classdef DriveEV < handle
    % Class modelling the behavior of Photo Voltaic (PV) panels.
    % Load the generated power from a csv file containing time and power.
    properties(Access=private)
        ev_table % Table containing EV charging data
        t= timeofday(datetime("yesterday")) % Current simulation time. Initially 00:00:00
        P_min
        P_max
    end

    methods
        function obj = DriveEV(csv_in, P_min, P_max)
            % Create PV object
            % INPUT:
            %    csv_in: path to csv file containing at least "EV_id",
            %    "arrival", "departure" and "total_energy" columns

            % Read data from csv file
            obj.ev_table = readtable(csv_in);
            obj.ev_table.arrival = datetime(obj.ev_table.arrival, "Format","uuuu-MM-dd HH:mm:ss");
            obj.ev_table.departure = datetime(obj.ev_table.departure, "Format","uuuu-MM-dd HH:mm:ss");

            obj.ev_table.t_arrival = timeofday(datetime(obj.ev_table.arrival, "Format","uuuu-MM-dd HH:mm:ss"));
            obj.ev_table.t_departure = timeofday(datetime(obj.ev_table.departure, "Format","uuuu-MM-dd HH:mm:ss"));
            
            obj.P_min = P_min;
            obj.P_max = P_max;
        end

        function arrived_EVs = advance_time_to(obj, t)
            % Set time to the given time and set P to the corresponding
            % power from the table.
            
            % Search for any EVs arrived between the last time and updated
            % time
            if sum(t > obj.ev_table.t_arrival) > 0
                a = 0;
            end
            filt = obj.ev_table.t_arrival >obj.t & obj.ev_table.t_arrival <= t;
            arrived_EVs_table = obj.ev_table(filt,["t_arrival", "t_departure","total_energy"]);
            if sum(filt) > 0
                a = 0;
            end
            
            rows = height(arrived_EVs_table); 
            if rows <= 0
                arrived_EVs = [];
            end
            for row = 1:rows
                    arrived_EVs_table(row,"total_energy");
                arrived_EVs(row) = EV(obj.P_max,obj.P_max,obj.P_min,arrived_EVs_table{row,"t_arrival"},arrived_EVs_table{row,"t_departure"},arrived_EVs_table{row,"total_energy"}*1000);
            end

            % Update the time
            obj.t = t;            
        end

        function select_EVs(obj,ids)
            % Select the EVs to include in the simulation.
            % INPUT: 
            %   ids: column vector of the identifiers of the EVs to include

            if isnumeric(ids)
                % Add the "EV" prefix if integers are inserted
                ids = num2str(ids);
                ids = "EV"+strip(string(ids));
            end

            filt = ismember(obj.ev_table.EV_id, ids);
            obj.ev_table = obj.ev_table(filt,:);
        end
    end
end