with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;
with Configs; use Configs;

package body Track is

protected body Track_t is

entry IsFree(B :out Boolean) when Freee = TRUE is
begin
    B := Freee;
end IsFree;

entry GetID(I :out Integer) when TRUE is
begin
    I := ID;
end GetID;

entry GetHTime(HT :out Float) when TRUE is
begin
    HT := HTime;
end GetHTime;

entry GetLen(L :out Integer) when TRUE is
begin
    L := Len;
end GetLen;

entry GetSpeed(S :out Integer) when TRUE is
begin
    S := Speed;
end GetSpeed;

entry GetType(T :out Integer) when TRUE is
begin
    T := Typee;
end GetType;

entry SetID(I :in Integer) when TRUE is
begin
    ID := I;
end SetID;

entry SetType(T :in Integer) when TRUE is
begin
    Typee := T;
end SetType;

entry SetHTime(HT :in Float) when TRUE is
begin
    HTime := HT;
end SetHTime;

entry SetLen(L :in Integer) when TRUE is
begin
    Len := L;
end SetLen;

entry SetSpeed(S :in Integer) when TRUE is
begin
    Speed := S;
end SetSpeed;

entry Breaking when isBroken = FALSE is
begin
    if GetMode = NOISY then
        Put_Line("!!!!! TRACK  " & Integer'Image(ID) & "  IS BROKEN !!!!!");
    end if;
    isBroken := TRUE;
end Breaking;

entry Fix when isBroken = TRUE is
begin
    if GetMode = NOISY then
        Put_Line("----- TRACK  " & Integer'Image(ID) & "  IS FIXED -----");
    end if;
    isBroken := FALSE;
end Fix;

entry BUSY when Freee = TRUE and not isBroken is
begin
    Freee := FALSE;
end BUSY;

entry FREE when Freee = FALSE is
begin
    Freee := TRUE;
end FREE;

entry Reserve when Freee = TRUE is
begin
    Freee := FALSE;
end Reserve;

entry Show when TRUE is
begin
    if Typee = NORMAL then
        Put_Line("Normal Track:");
    else
        Put_Line("Station:");
    end if;

    Put_Line("ID: " & Integer'Image(ID));

    if isBroken = TRUE then
        Put_Line("BROKEN!");
    end if;

    if Freee = TRUE then
        Put_Line("State: FREE");
    else
        Put_Line("State: BUSY");
    end if;

    if Typee = NORMAL then
        Put_Line("Length: " & Integer'Image(Len));
        Put_Line("Available Speed: " & Integer'Image(Speed));
    else
        Put_Line("Halt Time: " & Float'Image(HTime));
    end if;

    Put("Vertices: [");
    for I in Vers'range loop
        if Vers(I) /= 0 then
            Put(Integer'Image(Vers(I)) & " ");
        end if;
    end loop;

    Put_Line("]");
    New_Line;
    New_Line;
end Show;

entry AddVer(V :in Integer) when TRUE is
begin
    if CurVer <= Vers'Length then
        Vers(CurVer) := V;
        CurVer := CurVer + 1;
    end if;

end AddVer;

entry CreateVer(N :in Integer) when TRUE is
begin
    Vers := new AVers (1 .. N);

    for I in Vers'range loop
        Vers(I) := 0;
    end loop;

    CurVer := 1;
end CreateVer;

entry GetVers(V :out AVers_PTR) when TRUE is
begin
    V := Vers;
end GetVers;

end Track_t;

protected body Tracks_P is
    entry Create(N :in Integer) when not Init is
    begin
        Tracks := new ATracks(1 .. N);
        Init := TRUE;
    end Create;

    entry Insert(T :in Track_PTR) when Init is
    I :Integer;
    begin
        T.GetID(I);
        if I >= 1 AND I <= Tracks'Length then
            Tracks(I) := T;
        end if;
    end Insert;

    entry Get(A :out ATracks_PTR) when Init is
    begin
        A := Tracks;
    end Get;

    entry GetByID(I :in Integer; T: out Track_PTR) when Init is
    begin
        T := Tracks(I);
    end GetByID;

    entry Show when Init is
    begin
        Put_Line("ALL TRACKS");
        New_Line;

        for I in Tracks'range loop
            Tracks(I).Show;
        end loop;

        New_Line;
    end Show;
end Tracks_P;


function CreateStationTrack(I :in Integer; HT :in Float) return Track_PTR is
T :Track_PTR;
begin
    T := new Track_t;
    T.SetID(I);
    T.SetType(STATION);
    T.SetLen(0);
    T.SetSpeed(0);
    T.SetHTime(HT);
    T.CreateVer(2);
    return T;
end CreateStationTrack;

function CreateNormalTrack(I :in Integer; L :in Integer; S :in Integer) return Track_PTR is
T :Track_PTR;
begin
    T := new Track_t;
    T.SetID(I);
    T.SetType(NORMAL);
    T.SetLen(L);
    T.SetSpeed(S);
    T.SetHTime(0.0);
    T.CreateVer(2);
    return T;
end CreateNormalTrack;

procedure LoadTracks is
    File    :File_Type;
    Line    :Unbounded_String;
    T       :Track_PTR;
    ID      :Integer;
    Typee   :Integer;
    Time    :Float;
    Len     :Integer;
    Speed   :Integer;
    C       :Integer;
    OC      :Integer;
begin
    Open(File => File, Mode => In_File, Name => "../configs/tracks.txt");

    -- SKIP ALL COMMENTS
    loop exit when End_Of_File(File);
        Line := To_Unbounded_String(Get_Line(File));
        exit when Element(Line, 1) /= '#';
    end loop;

    -- for each line ( track ) DO
    for I in Integer range 1 .. GetNTracks loop

        -- start from begining
        OC := 1;
        C := 1;

        -- Find ID value
        while Element(Line, C) /= ';' loop
            C := C + 1;
        end loop;

        -- Get ID value
        ID := Integer'Value(Slice(Line, OC, C - 1));
        C := C + 1;
        OC := C;

        -- Find TYPE
        while Element(Line, C) /= ';' loop
            C := C + 1;
        end loop;

        if Slice(Line, OC, C - 1) = "NORMAL" then
            Typee := NORMAL;
        else
            Typee := STATION;
        end if;

        C := C + 1;
        OC := C;

        -- Load Normal
        if Typee = NORMAL then
            -- Find Len
            while Element(Line, C) /= ';' loop
                C := C + 1;
            end loop;

            -- Get Len value
            Len := Integer'Value(Slice(Line, OC, C - 1));
            C := C + 1;
            OC := C;

            -- Get Speed value
            Speed := Integer'Value(Slice(Line, OC, Length(Line)));

            -- Add new Track
            T := CreateNormalTrack(ID, Len, Speed);
            Tracks.Insert(T);
        else
            -- Get Time value
            Time := Float'Value(Slice(Line, OC, Length(Line)));
            T := CreateStationTrack(ID, Time);
            Tracks.Insert(T);
        end if;

        exit when End_Of_File(File);
        Line := To_Unbounded_String(Get_Line(File));

    end loop;

end LoadTracks;

end Track;
