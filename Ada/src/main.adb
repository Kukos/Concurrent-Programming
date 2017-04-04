with Ada.Text_IO; use Ada.Text_IO;
with Configs; use Configs;
with Train; use Train;
with Switch; use Switch;
with Track; use Track;
with Client; use Client;
with Graph; use Graph;
with Driver; use Driver;

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

    -- start task to talk with user iff mode = silent
    if GetMode = SILENT then
        Talk.Start;
    end if;

    -- Start Drivers
    Drivers := new ADrivers(1 .. GetNTrains);
    for I in Drivers'range loop
        Trains.GetByID(I, T);
        Drivers(I) := new Driver_t;
        Drivers(I).Start(T);
    end loop;

end main;
