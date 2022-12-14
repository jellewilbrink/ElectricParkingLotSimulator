classdef DriveEV < handle
    % Class modelling the behavior of Photo Voltaic (PV) panels.
    % Load the generated power from a csv file containing time and power.
    properties
    end

    properties(Access=private)
        ev_table % Table containing EV charging data
        t= timeofday(datetime("yesterday")) % Current simulation time. Initially 00:00:00
    end

    methods
        function obj = DriveEV(csv_in)
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
        end

        function arrived_EVs = advance_time_to(obj, t)
            % Set time to the given time and set P to the corresponding
            % power from the table.
            
            % Search for any EVs arrived between the last time and updated
            % time
            filt = obj.ev_table.t_arrival >obj.t & obj.ev_table.t_arrival <= t;
            arrived_EVs = obj.ev_table(filt,["t_arrival", "t_departure","total_energy"]);


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