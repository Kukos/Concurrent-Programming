with Ada.Strings.Unbounded, Ada.Text_IO, Configs;
use Ada.Strings.Unbounded, Ada.Text_IO, Configs;

package body Train is

protected body Train_t is

    entry GetID(I :out Integer) when TRUE is
    begin
        I := ID;
    end GetID;

    entry GetMaxSpeed(MS :out Integer) when TRUE is
    begin
        MS := MaxSpeed;
    end GetMaxSpeed;

    entry GetCapacity(C :out Integer) when TRUE is
    begin
        C := Capacity;
    end GetCapacity;

    entry GetRoute(R :out ARoute_PTR) when TRUE is
    begin
        R := Route;
    end GetRoute;

    entry GetStartPoint(SP :out Integer) when TRUE is
    begin
        SP := StartPoint;
    end GetStartPoint;

    entry SetID(I :in Integer) when TRUE is
    begin
        ID := I;
    end SetID;

    entry SetMaxSpeed(MS :in Integer) when TRUE is
    begin
        MaxSpeed := MS;
    end SetMaxSpeed;

    entry SetCapacity(C :in Integer) when TRUE is
    begin
        Capacity := C;
    end SetCapacity;

    entry SetStartPoint(SP :in Integer) when TRUE is
    begin
        StartPoint := SP;
    end SetStartPoint;

    entry CreateRoute(N :in Integer) when TRUE is
    begin
        Route := new ARoute(1 .. N);

        for I in Route'range loop
            Route(I) := 0;
        end loop;

        CurRoute := 1;
    end CreateRoute;

    entry AddRoute(R :in Integer) when TRUE is
    begin
        if CurRoute <= Route'Length then
            Route(CurRoute) := R;
            CurRoute := CurRoute + 1;
        end if;
    end AddRoute;

    entry ChangePos(PT :in Integer; I :in Integer) when TRUE is
    begin
        PosType := PT;
        PosID := I;
    end ChangePos;

    entry ShowPos when TRUE is
    begin
        Put_Line("Train:");
        Put_Line("ID: " & Integer'Image(ID));
        case PosType is
            when POS_STATION => Put_Line("Current Pos: Station " & Integer'Image(PosID));
            when POS_TRACK =>  Put_Line("Current Pos: Track " & Integer'Image(PosID));
            when POS_SWITCH =>  Put_Line("Current Pos: Switch " & Integer'Image(PosID));
            when others => Put_Line("Not use");
        end case;

        New_Line;
        New_Line;
    end ShowPos;

    entry Show when TRUE is
    begin
        Put_Line("Train:");
        Put_Line("ID: " & Integer'Image(ID));
        Put_Line("MaxSpeed: " & Integer'Image(MaxSpeed));
        Put_Line("Capacity: " & Integer'Image(Capacity));
        Put_Line("StartPoint: " & Integer'Image(StartPoint));
        Put("Route: [");
        for I in Route'range loop
            if Route(I) /= 0 then
                Put(Integer'Image(Route(I)) & " ");
            end if;
        end loop;

        Put_Line("]");

        case PosType is
            when POS_STATION => Put_Line("Current Pos: Station " & Integer'Image(PosID));
            when POS_TRACK =>  Put_Line("Current Pos: Track " & Integer'Image(PosID));
            when POS_SWITCH =>  Put_Line("Current Pos: Switch " & Integer'Image(PosID));
            when others => Put_Line("Not use");
        end case;

        New_Line;
        New_Line;
    end Show;

end Train_t;


protected body Trains_P is
    entry Create(N :in Integer) when not Init is
    begin
        Trains := new ATrains(1 .. N);
        CurTrain := 1;
        Init := TRUE;
    end Create;

    entry Insert(T :in Train_PTR) when Init is
    begin
        if CurTrain <= Trains'Length then
            Trains(CurTrain) := T;
            CurTrain := CurTrain + 1;
        end if;
    end Insert;

    entry Get(A :out ATrains_PTR) when Init is
    begin
        A := Trains;
    end Get;

    entry GetByID(I :in Integer; T: out Train_PTR) when Init is
    begin
        T := Trains(I);
    end GetByID;

    entry Show when Init is
    begin
        Put_Line("ALL TRAINS");
        New_Line;

        for I in Trains'range loop
            Trains(I).Show;
        end loop;

        New_Line;

    end Show;

    entry ShowPos when Init is
    begin
        Put_Line("ALL TRAINS");
        New_Line;

        for I in Trains'range loop
            Trains(I).ShowPos;
        end loop;

        New_Line;

    end ShowPos;

end Trains_P;

function CreateTrain(I :in Integer; MS :in Integer; C :in Integer; SP: in Integer; N :in Integer) return Train_PTR is
T :Train_PTR;
begin

    T := new Train_t;

    T.SetID(I);
    T.SetMaxSpeed(MS);
    T.SetCapacity(C);
    T.SetStartPoint(SP);
    T.CreateRoute(N);
    t.ChangePos(POS_NONE, 0);

    return T;

end CreateTrain;

-- A little magic here
procedure LoadTrains is
    File    :File_Type;
    Line    :Unbounded_String;
    OC      :Integer;
    C       :Integer;
    SP      :Integer;
    T_PTR   :Train_PTR;
    ID      :Integer;
    MS      :Integer;
    CAP     :Integer;
begin
    Open(File => File, Mode => In_File, Name => "configs/trains.txt");

    -- SKIP ALL COMMENTS
    loop exit when End_Of_File(File);
        Line := To_Unbounded_String(Get_Line(File));
        exit when Element(Line, 1) /= '#';
    end loop;

    -- for each line ( train ) DO
    for I in Integer range 1 .. GetNTrains loop

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

        -- Find MaxSpeed value
        while Element(Line, C) /= ';' loop
            C := C + 1;
        end loop;

        -- Get MaxSpeed value
        MS := Integer'Value(Slice(Line, OC, C - 1));
        C := C + 1;
        OC := C;

        -- Find Capacity value
        while Element(Line, C) /= ';' loop
            C := C + 1;
        end loop;

        -- Get Capacity value
        CAP := Integer'Value(Slice(Line, OC, C - 1));
        C := C + 1;
        OC := C;

        -- Find Start Point value
        while Element(Line, C) /= ';' loop
            C := C + 1;
        end loop;

        -- Get Start Point value
        SP := Integer'Value(Slice(Line, OC, C - 1));
        C := C + 2;
        OC := C;

        -- Create Train and add to Global Array
        T_PTR := CreateTrain(ID, MS, CAP, SP, GetNTracks);
        Trains.Insert(T_PTR);

        -- Parse Route
        loop exit when Element(Line, C - 1) = ']';
            -- Get single Track
            while Element(Line, C) /= ';' and Element(Line, C) /= ']' loop
                C := C + 1;
            end loop;

            -- Add Track to Route
            T_PTR.AddRoute(Integer'Value(Slice(Line, OC, C - 1)));
            C := C + 1;
            OC := C;
        end loop;

        exit when End_Of_File(File);
        Line := To_Unbounded_String(Get_Line(File));
    end loop;

end LoadTrains;

end Train;
