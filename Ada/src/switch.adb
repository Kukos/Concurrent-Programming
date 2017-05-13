with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;
with Configs; use Configs;

package body Switch is

protected body Switch_t is

entry IsFree(B :out Boolean) when Freee = TRUE is
begin
    B := Freee;
end IsFree;

entry GetID(I :out Integer) when TRUE is
begin
    I := ID;
end GetID;

entry GetStayTime(ST: out Float) when TRUE is
begin
    ST := StayTime;
end GetStayTime;

entry AddEdge(I :in Integer) when TRUE is
begin
    if CurEdge <= Edges'Length then
        Edges(CurEdge) := I;
        CurEdge := CurEdge + 1;
    end if;
end AddEdge;

entry GetEdges(E :out AEdges_PTR) when TRUE is
begin
    E := Edges;
end GetEdges;

entry Show when TRUE is
begin
    Put_Line("Switch:");
    Put_Line("ID: " & Integer'Image(ID));
    Put_Line("StayTime: " & Float'Image(StayTime));

    if isBroken = TRUE then
        Put_Line("BROKEN!");
    end if;

    if Freee = TRUE then
        Put_Line("State: FREE");
    else
        Put_Line("State: BUSY");
    end if;

    Put("Edges: [");
    for I in Edges'range loop
        if Edges(I) /= 0 then
            Put(Integer'Image(Edges(I)) & " ");
        end if;
    end loop;

    Put_Line("]");
    New_Line;
    New_Line;

end Show;

entry SetID(I :in Integer) when TRUE is
begin
    ID := I;
end SetID;

entry SetStayTime(ST :in Float) when TRUE is
begin
    StayTime := ST;
end SetStayTime;

entry Breaking when IsBroken = FALSE is
begin
    if GetMode = NOISY then
        Put_Line("!!!!! SWITCH  " & Integer'Image(ID) & "  IS BROKEN !!!!!");
    end if;
    isBroken := TRUE;
end Breaking;

entry Fix when isBroken = TRUE is
begin
    if GetMode = NOISY then
        Put_Line("----- SWITCH  " & Integer'Image(ID) & "  IS FIXED -----");
    end if;
        isBroken := FALSE;
end Fix;

entry BUSY when Freee = TRUE AND not isBroken is
begin
    Freee := FALSE;
end BUSY;

entry Reserve when Freee = TRUE is
begin
    Freee := FALSE;
end Reserve;

entry FREE when Freee = FALSE is
begin
    Freee := TRUE;
end FREE;

entry CreateAEdges(N :in Integer) when TRUE is
begin
    Edges := new AEdges(1 .. N);
    CurEdge := 1;
    for I in Edges'range loop
        Edges(I) := 0;
    end loop;
end CreateAEdges;

end Switch_t;

protected body Switches_P is
    entry Create(N :in Integer) when not Init is
    begin
        Switches := new ASwitches(1 .. N);
        Init := TRUE;
    end Create;

    entry Insert(S :in Switch_PTR) when Init is
    I :Integer;
    begin
        S.GetID(I);
        if I >= 1 AND I <= Switches'Length then
            Switches(I) := S;
        end if;
    end Insert;

    entry Get(A :out ASwitches_PTR) when Init is
    begin
        A := Switches;
    end Get;

    entry GetByID(I :in Integer; S: out Switch_PTR) when Init is
    begin
        S := Switches(I);
    end GetByID;


    entry Show when Init is
    begin
        Put_Line("ALL SWITCHES");
        New_Line;

        for I in Switches'range loop
            Switches(I).Show;
        end loop;

        New_Line;
    end Show;

end Switches_P;

function CreateSwitch(I :in Integer; ST :in Float) return Switch_PTR is
S :Switch_PTR;
begin
    S := new Switch_t;
    S.SetID(I);
    S.SetStayTime(ST);
    S.CreateAEdges(GetNTracks);
    return S;
end CreateSwitch;

procedure LoadSwitches is
    File    :File_Type;
    Line    :Unbounded_String;
    S       :Switch_PTR;
    ID      :Integer;
    ST      :Float;
    C       :Integer;
begin
    Open(File => File, Mode => In_File, Name => "../configs/switches.txt");

    -- SKIP ALL COMMENTS
    loop exit when End_Of_File(File);
        Line := To_Unbounded_String(Get_Line(File));
        exit when Element(Line, 1) /= '#';
    end loop;

    -- for each line ( switch ) DO
    for I in Integer range 1 .. GetNSwitches loop

        -- start from begining
        C := 1;

        -- Find ID value
        while Element(Line, C) /= ';' loop
            C := C + 1;
        end loop;

        -- Get ID value
        ID := Integer'Value(Slice(Line, 1, C - 1));
        C := C + 1;

        ST := Float'Value(Slice(Line, C, Length(Line)));

        S := CreateSwitch(ID, ST);
        Switches.Insert(S);

        exit when End_Of_File(File);
        Line := To_Unbounded_String(Get_Line(File));
    end loop;

end LoadSwitches;

end Switch;
