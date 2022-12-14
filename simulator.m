pv = PV("data/solarPanelOutputDataSlimPark.csv");
t= timeofday(datetime("today"))+ seconds(3600*7)
pv.advance_time_to(t);
P = pv.P

driveev = DriveEV("data/20221206GS_DEMSdata_spikyPV.xlsx");
evs = [0;1;54]
driveev.select_EVs(evs);
arrived_evs = driveev.advance_time_to(t)