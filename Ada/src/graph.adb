with Ada.Strings.Unbounded, Ada.Text_IO;
use Ada.Strings.Unbounded, Ada.Text_IO;
with Configs; use Configs;
with Switch; use Switch;
with Track; use Track;
with Fifo;
with Ada.Unchecked_Deallocation;

package body Graph is

procedure LoadGraph is
    File    :File_Type;
    Line    :Unbounded_String;
    T   :Track_PTR;
    S   :Switch_PTR;
    ID  :Integer;
    C   :Integer;
    OC  :Integer;
begin
    Open(File => File, Mode => In_File, Name => "../configs/graph.txt");

    -- SKIP ALL COMMENTS
    loop exit when End_Of_File(File);
        Line := To_Unbounded_String(Get_Line(File));
        exit when Element(Line, 1) /= '#';
    end loop;

    -- for each track DO
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
        C := C + 2;
        OC := C;

        Tracks.GetByID(I, T);

        -- Parse Graph
        loop exit when Element(Line, C - 1) = ']';

            -- Get single Switch
            while Element(Line, C) /= ';' and Element(Line, C) /= ']' loop
                C := C + 1;
            end loop;

            -- Add Track to Route
            T.AddVer(Integer'Value(Slice(Line, OC, C - 1)));
            C := C + 1;
            OC := C;
        end loop;

        Line := To_Unbounded_String(Get_Line(File));
    end loop;

    -- for each Switch DO
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
        C := C + 2;
        OC := C;

        Switches.GetByID(I, S);

        -- Parse Graph
        loop exit when Element(Line, C - 1) = ']';

            -- Get single Switch
            while Element(Line, C) /= ';' and Element(Line, C) /= ']' loop
                C := C + 1;
            end loop;

            -- Add Track to Route
            S.AddEdge(Integer'Value(Slice(Line, OC, C - 1)));
            C := C + 1;
            OC := C;
        end loop;

        exit when End_Of_File(File);
        Line := To_Unbounded_String(Get_Line(File));
    end loop;

end LoadGraph;

function CreateNode(T : in Integer; ID : in Integer) return Node_PTR is
N :Node_PTR;
begin
    N := new Node_t;
    N.Typee := T;
    N.ID := ID;

    return N;
end CreateNode;

function NodeGetType(N : in Node_PTR) return Integer is
begin
    return N.Typee;
end NodeGetType;

function NodeGetID(N : in Node_PTR) return Integer is
begin
    return N.ID;
end NodeGetID;

procedure NodeDestroy(N : in out Node_PTR) is
procedure Free is new Ada.Unchecked_Deallocation(Node_t, Node_PTR);
begin
    Free(N);
end NodeDestroy;

procedure PathDestroy(P :in out Path_PTR) is
procedure Free is new Ada.Unchecked_Deallocation(Path_t, Path_PTR);
begin
    for I in P'range loop
        NodeDestroy(P(I));
    end loop;

    Free(P);
end PathDestroy;

function FindPath(N1 :Node_PTR; N2 :Node_PTR) return Path_PTR is
P1 :Path_PTR;
P2 :Path_PTR;
P3 :Path_PTR;
P4 :Path_PTR;
T1 :Track_PTR;
T2 :Track_PTR;
Vers1 :AVers_PTR;
Vers2 :AVers_PTR;
RP :Path_PTR;
begin
    if NodeGetType(N1) = VERTEX AND NodeGetType(N2) = VERTEX then
        RP := FindPathVer(NodeGetID(N1), NodeGetID(N2));

        -- delete 1st VERTEX
        NodeDestroy(RP(1));
        RP(1) := CreateNode(VERTEX, 0);

        -- we have to add FAKE Node
        RP(RP'Length) := CreateNode(VERTEX, 0);
    elsif NodeGetType(N1) = VERTEX AND NodeGetType(N2) = EDGE then
        Tracks.GetByID(NodeGetID(N2), T1);
        T1.GetVers(Vers1);
        P1 := FindPathVer(NodeGetID(N1), Vers1(1));

        if Vers1(2) /= 0 then
            P2 := FindPathVer(NodeGetID(N1), Vers1(2));

            if P1'Length <= P2'Length then
                RP := P1;
                PathDestroy(P2);
                RP(RP'Length) := CreateNode(VERTEX, Vers1(1));
            else
                RP := P2;
                PathDestroy(P1);
                RP(RP'Length) := CreateNode(VERTEX, Vers1(2));
            end if;
        else
            RP := P1;
        end if;

        -- delete 1st VERTEX
        NodeDestroy(RP(1));
        RP(1) := CreateNode(VERTEX, 0);

    elsif NodeGetType(N1) = EDGE AND NodeGetType(N2) = VERTEX then
        Tracks.GetByID(NodeGetID(N1), T1);
        T1.GetVers(Vers1);
        P1 := FindPathVer(Vers1(1), NodeGetID(N2));

        if Vers1(2) /= 0 then
            P2 := FindPathVer(Vers1(2), NodeGetID(N2));

            if P1'Length <= P2'Length then
                RP := P1;
                PathDestroy(P2);
            else
                RP := P2;
                PathDestroy(P1);
            end if;
        else
            RP := P1;
        end if;

        -- we have to add FAKE Node
        RP(RP'Length) := CreateNode(VERTEX, 0);

    else
        Tracks.GetByID(NodeGetID(N1), T1);
        T1.GetVers(Vers1);

        Tracks.GetByID(NodeGetID(N2), T2);
        T2.GetVers(Vers2);

        if Vers1(2) /= 0 AND Vers2(2) /= 0 then
            P1 := FindPathVer(Vers1(1), Vers2(1));
            P2 := FindPathVer(Vers1(1), Vers2(2));
            P3 := FindPathVer(Vers1(2), Vers2(1));
            P4 := FindPathVer(Vers1(2), Vers2(2));
            -- Find Minimum
            if P1'Length <= P2'Length then
                RP := P1;
                PathDestroy(P2);
                RP(RP'Length) := CreateNode(VERTEX, Vers2(1));
            else
                RP := P2;
                PathDestroy(P1);
                RP(RP'Length) := CreateNode(VERTEX, Vers2(2));
            end if;

            if RP'Length > P3'Length then
                PathDestroy(RP);
                RP := P3;
                RP(RP'Length) := CreateNode(VERTEX, Vers2(1));
            end if;

            if RP'Length > P4'Length then
                PathDestroy(RP);
                RP := P4;
                RP(RP'Length) := CreateNode(VERTEX, Vers2(2));
            end if;
        elsif Vers1(2) /= 0 then
            P1 := FindPathVer(Vers1(1), Vers2(1));
            P2 := FindPathVer(Vers1(2), Vers2(1));

            -- Find Minimum
            if P1'Length <= P2'Length then
                RP := P1;
                PathDestroy(P2);
                RP(RP'Length) := CreateNode(VERTEX, Vers2(1));
            else
                RP := P2;
                PathDestroy(P1);
                RP(RP'Length) := CreateNode(VERTEX, Vers2(1));
            end if;
        elsif Vers2(2) /= 0 then
            P1 := FindPathVer(Vers1(1), Vers2(1));
            P2 := FindPathVer(Vers1(1), Vers2(2));

            -- Find Minimum
            if P1'Length <= P2'Length then
                RP := P1;
                PathDestroy(P2);
                RP(RP'Length) := CreateNode(VERTEX, Vers2(1));
            else
                RP := P2;
                PathDestroy(P1);
                RP(RP'Length) := CreateNode(VERTEX, Vers2(2));
            end if;
        else
            RP :=  FindPathVer(Vers1(1), Vers2(1));
            RP(RP'Length) := CreateNode(VERTEX, Vers2(1));
        end if;
    end if;

    return RP;
end FindPath;

-- Simple BFS Algorithm PATH include edges and verticles
function FindPathVer(V1 :Integer; V2: Integer) return Path_PTR is
Path :Path_PTR;
Ver : Integer;
S :Switch_PTR;
E :AEdges_PTR;
I :Integer;
T :Track_PTR;
V :AVers_PTR;
C :Integer;
ID :Integer;

-- Need array of Bool, to setting visited flag
type VisitedArray is array(Integer range <>) of Boolean;
type VisitedArray_PTR is access VisitedArray;
procedure FreeV is new Ada.Unchecked_Deallocation(VisitedArray, VisitedArray_PTR);
Visited :VisitedArray_PTR;

-- Need array of Edges, to save temporary path
type TPathArray is array(Integer range <>) of Track_PTR;
type TPathArray_PTR is access TPathArray;
procedure FreeTP is new Ada.Unchecked_Deallocation(TPathArray, TPathArray_PTR);
TPath :TPathArray_PTR;

package Node_Fifo is new Fifo(Node_PTR);
N :Node_PTR;
QP :Node_Fifo.Fifo_PTR;

-- need Fifo with Verticles
package INT_Fifo is new Fifo(Integer);
use INT_Fifo;
Q : Fifo_PTR;


begin

    if V1 = V2 then
        Path := new Path_t(1 .. 1);
        return Path;
    end if;

    Visited := new VisitedArray(1 .. GetNSwitches);
    for J in Visited'range loop
        Visited(J) := FALSE;
    end loop;

    TPath := new TPathArray(1 .. GetNSwitches);

    -- Create Empty Fifo
    Q := CreateFifo;

    -- Visit Start point
    Visited(V1) := TRUE;
    Enqueue(Q, V1);

    while not Is_Empty(Q) loop
        -- get first vertex from queue
        Dequeue(Q, Ver);

        -- we reach end point
        if Ver = V2 then

            -- get real path from TPathArray
            QP := Node_Fifo.CreateFifo;
            C := 0;

            TPath(Ver).GetVers(V);
            while V(1) /= V1 AND V(2) /= V1 loop
                TPath(Ver).GetID(ID);
                N := CreateNode(EDGE, ID);
                Node_Fifo.Enqueue(QP, N);
                C := C + 1;

                if V(1) /= Ver then
                    N := CreateNode(VERTEX, V(1));
                    Node_Fifo.Enqueue(QP, N);
                    C := C + 1;
                    Ver := V(1);
                else
                    N := CreateNode(VERTEX, V(2));
                    Node_Fifo.Enqueue(QP, N);
                    C := C + 1;
                    Ver := V(2);
                end if;

                TPath(Ver).GetVers(V);
            end loop;

            -- insert last
            TPath(Ver).GetID(ID);
            N := CreateNode(EDGE, ID);
            Node_Fifo.Enqueue(QP, N);
            C := C + 1;

            if V(1) /= Ver then
                N := CreateNode(VERTEX, V(1));
                Node_Fifo.Enqueue(QP, N);
                C := C + 1;
                Ver := V(1);
            else
                N := CreateNode(VERTEX, V(2));
                Node_Fifo.Enqueue(QP, N);
                C := C + 1;
                Ver := V(2);
            end if;


            -- create PATH with reverse order
            Path := new Path_t(1 .. (C + 1));
            while not Node_Fifo.Is_Empty(QP) loop
                Node_Fifo.Dequeue(QP, N);
                Path(C) := N;
                C := C - 1;
            end loop;

            DestroyFifo(Q);
            Node_Fifo.DestroyFifo(QP);
            FreeV(Visited);
            FreeTP(TPath);

            return Path;

        end if;

        -- Get Switches
        Switches.GetByID(Ver, S);
        S.GetEdges(E);

        -- for each adjacent edge
        I := 1;
        while E(I) /= 0 loop
            Tracks.GetByID(E(I), T);
            T.GetVers(V);
            if V(1) /= Ver then
                if (V1) /= 0 then
                    if V(1) /= 0 AND Visited(V(1)) = FALSE then

                        -- Visit new Ver
                        Enqueue(Q, V(1));
                        Visited(V(1)) := TRUE;

                        -- save edge
                        TPath(V(1)) := T;
                    end if;
                end if;
            else
                if V(2) /= 0 then
                    if Visited(V(2)) = FALSE then

                        -- Visit new Ver
                        Enqueue(Q, V(2));
                        Visited(V(2)) := TRUE;

                        -- save edge
                        TPath(V(2)) := T;
                    end if;
                end if;
            end if;

            I := I + 1;
        end loop;
    end loop;

    DestroyFifo(Q);
    FreeV(Visited);
    FreeTP(TPath);

    return null;
end FindPathVer;

end Graph;
