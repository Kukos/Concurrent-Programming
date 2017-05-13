-- MAIN
-- Author: Michal Kukowski
-- email: michalkukowski10@gmail.com
-- LICENCE: GPL3.0

with Ada.Text_IO; use Ada.Text_IO;
with Configs; use Configs;
with Train; use Train;
with Switch; use Switch;
with Track; use Track;
with Client; use Client;
with Graph; use Graph;
with Driver; use Driver;
with RepairTeam; use RepairTeam;

procedure main is
    Drivers :access ADrivers;
    T       :Train_PTR;
begin
    -- Load configs from file
    LoadConfigs;

    -- Create Arrays
    Trains.Create(GetNTrains);
    Switches.Create(GetNSwitches);
    Tracks.Create(GetNTracks);

    -- Load ALL
    LoadTrains;
    LoadSwitches;
    LoadTracks;
    LoadGraph;

    RepairNodeStation := CreateNode(EDGE, GetNTracks);
    Trains.GetByID(GetNTrains, RepairTrain);
    RepairTrain.ChangePos(POS_STATION, NodeGetID(RepairNodeStation));

    -- start task to talk with user iff mode = silent
    if GetMode = SILENT then
        Talk.Start;
    end if;

    -- Start Drivers
    Drivers := new ADrivers(1 .. (GetNTrains - 1));
    for I in Drivers'range loop
        Trains.GetByID(I, T);
        Drivers(I) := new Driver_t;
        Drivers(I).Start(T);
    end loop;

end main;
