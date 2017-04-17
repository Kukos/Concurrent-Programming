with Ada.Strings.Unbounded, Ada.Text_IO;
use Ada.Strings.Unbounded, Ada.Text_IO;
package body Configs is

procedure SetMode(M: in Integer) is
begin
    Conf.Mode := M;
end SetMode;

procedure SetSPH(Sph: in Integer) is
begin
    Conf.S_per_h := Sph;
end SetSPH;

procedure SetNTrains(NT: in Integer) is
begin
    Conf.NumTrains := NT;
end SetNTrains;

procedure SetNTracks(NT: in Integer) is
begin
    Conf.NumTracks := NT;
end SetNTracks;

procedure SetNSwiches(NS :in Integer) is
begin
    Conf.NumSwitches := NS;
end SetNSwiches;

function GetMode return Integer is
begin
    return Conf.Mode;
end GetMode;

function GetSPH return Integer is
begin
    return Conf.S_per_h;
end GetSPH;

function GetNTrains return Integer is
begin
    return Conf.NumTrains;
end GetNTrains;

function GetNTracks return Integer is
begin
    return Conf.NumTracks;
end GetNTracks;

function GetNSwitches return Integer is
begin
    return Conf.NumSwitches;
end GetNSwitches;

-- A little magic here
procedure LoadConfigs is
    File :File_Type;
    Line :Unbounded_String;
begin
    Open(File => File, Mode => In_File, Name => "../configs/conf.txt");

    -- SKIP ALL COMMENTS
    loop exit when End_Of_File(File);
        Line := To_Unbounded_String(Get_Line(File));
        exit when Element(Line, 1) /= '#';
    end loop;

    -- Set MODE
    if Line = "SILENT" then
        SetMode(SILENT);
    else
        SetMode(NOISY);
    end if;

    Line := To_Unbounded_String(Get_Line(File));

    -- SET Second per hour
    SetSPH(Integer'Value(To_String(Line)));
    Line := To_Unbounded_String(Get_Line(File));

    -- SET Num of Trains
    SetNTrains(Integer'Value(To_String(Line)));
    Line := To_Unbounded_String(Get_Line(File));

    -- SET Num of Swicthes
    SetNSwiches(Integer'Value(To_String(Line)));
    Line := To_Unbounded_String(Get_Line(File));

    -- SET Num of Tracks
    SetNTracks(Integer'Value(To_String(Line)));

    Close(File);

end LoadConfigs;

procedure ShowConfigs is
begin

    Put_Line("Configs:");

    if Conf.Mode = SILENT then
        Put_Line("MODE: SILENT");
    else
        Put_Line("MODE: NOISY");
    end if;

    Put_Line("Seconds per hour: " & Integer'Image(Conf.S_per_h));
    Put_Line("Num Trains: " & Integer'Image(Conf.NumTrains));
    Put_Line("Num Switches: " & Integer'Image(Conf.NumSwitches));
    Put_Line("Num Tracks: " & Integer'Image(Conf.NumTracks));
    New_Line;
    New_Line;

end ShowConfigs;

end Configs;
