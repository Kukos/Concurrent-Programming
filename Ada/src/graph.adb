with Ada.Strings.Unbounded, Ada.Text_IO;
use Ada.Strings.Unbounded, Ada.Text_IO;
with Configs; use Configs;
with Switch; use Switch;
with Track; use Track;

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
    Open(File => File, Mode => In_File, Name => "configs/graph.txt");

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
end Graph;
