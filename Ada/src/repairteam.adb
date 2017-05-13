with Ada.Text_IO; use Ada.Text_IO;
with Switch; use Switch;
with Track; use Track;
with RandGen; use RandGen;
with Configs; use Configs;
with Graph; use Graph;

package body RepairTeam is

protected body Using_t is

entry UseItem(N :in Node_PTR) when isFree = TRUE is
    S : Switch_PTR;
    T : Track_PTR;
    NP :Node_PTR;
    P :Path_PTR;
begin
    isFree := FALSE;
    NP := N;

    if BrokenItems = 0 AND GenRand(1, 100) <= GetProbability then
        if NodeGetType(N) = VERTEX then
            Switches.GetByID(NodeGetID(N), S);
            S.Breaking;
        else
            Tracks.GetByID(NodeGetID(N), T);
            T.Breaking;
        end if;
        BrokenItems := 1;

        P := FindPath(RepairNodeStation, N);
        Repair.Start(P, N);
    end if;

    isFree := TRUE;
end UseItem;

end Using_t;

task body Repair is
S       :Switch_PTR;
T       :Track_PTR;
Path    :Path_PTR;
Node    :Node_PTR;
ID      :Integer;
Time    :Float;
Typee   :Integer;
VT      :Integer;
VA      :Integer;
VR      :Integer;
Len     :Integer;
begin
    loop
        select
            accept Start(P :in Path_PTR; N : in Node_PTR) do
                Path := P;
                Node := N;
                RepairTrain.GetID(ID);
            end Start;
        end select;

        Reserve.Start(Path);

        -- wait for ready
        select
            accept Ready;
        end select;

        if GetMode = NOISY then
            Put_Line("/\/\/\ REPAIR TEAM ARE GOING TO BROKEN NODE /\/\/\");
        end if;

        -- OK Path is locked for RTeam, so GO
        for I in Path'range loop
            if NodeGetID(Path(I)) /= 0 then
                if NodeGetType(Path(I)) = EDGE then
                    Tracks.GetByID(NodeGetID(Path(I)), T);

                    -- enter track
                    T.GetType(Typee);

                    -- if is a station just go
                    if Typee = STATION then
                        RepairTrain.ChangePos(POS_STATION, NodeGetID(Path(I)));

                        -- print info
                        if GetMode = NOISY then
                            Put_Line("### [ " & Integer'Image(ID) & "  ]    " &  "GO TO STATION: " & Integer'Image(NodeGetID(Path(I))));
                        end if;
                    else -- it's normal track, so let's go

                        RepairTrain.ChangePos(POS_TRACK, NodeGetID(Path(I)));

                        -- print info
                        if GetMode = NOISY then
                            Put_Line("### [ " & Integer'Image(ID) & "  ]    " &  "GO TO TRACK: " & Integer'Image(NodeGetID(Path(I))));
                        end if;

                        -- our speed is min speed of train speed and track speed
                        T.GetSpeed(VA);
                        RepairTrain.GetMaxSpeed(VT);
                        if VA < VT then
                            VR := VA;
                        else
                            VR := VT;
                        end if;

                        T.GetLen(Len);

                        -- T = Len / V * second per real hour
                        Time := Float(Len) / Float(VR) * Float(GetSPH);
                    end if;

                    -- time for driving or waiting for people
                    delay Duration(Time);

                    T.FREE;

                    -- print info
                    if GetMode = NOISY then
                        if Typee = NORMAL then
                            Put_Line("@@@ [ " & Integer'Image(ID) & "  ]    " &  "LEAVING TRACK: " & Integer'Image(NodeGetID(Path(I))));
                        else
                            Put_Line("@@@ [ " & Integer'Image(ID) & "  ]    " &  "LEAVING STATION: " & Integer'Image(NodeGetID(Path(I))));
                        end if;
                    end if;
                else
                    Switches.GetByID(NodeGetID(Path(I)), S);

                    -- enter switch
                    RepairTrain.ChangePos(POS_SWITCH, NodeGetID(Path(I)));

                    -- print info
                    if GetMode = NOISY then
                        Put_Line("### [ " & Integer'Image(ID) & "  ]    " &  "GO TO SWITCH: " & Integer'Image(NodeGetID(Path(I))));
                    end if;

                    -- read time
                    S.GetStayTime(Time);

                    -- calc time to stay
                    Time := Time * Float(GetSPH);

                    -- wait
                    delay Duration(Time);
                    -- go out
                    S.FREE;

                    -- print info
                    if GetMode = NOISY then
                        Put_Line("@@@ [ " & Integer'Image(ID) & "  ]    " &  "LEAVING SWITCH: " & Integer'Image(NodeGetID(Path(I))));
                    end if;
                end if;
            end if;
        end loop;

        -- Fix Node
        if NodeGetType(Node) = VERTEX then
            Switches.GetByID(NodeGetID(Node), S);
            S.Fix;
        else
            Tracks.GetByID(NodeGetID(Node), T);
            T.Fix;
        end if;

        if GetMode = NOISY then
            Put_Line("/\/\/\ REPAIR TEAM ARE COMING BACK TO STATION /\/\/\");
        end if;

        -- Come Back
        for I in reverse Path'range loop
            if NodeGetID(Path(I)) /= 0 then
                if NodeGetType(Path(I)) = EDGE then
                    Tracks.GetByID(NodeGetID(Path(I)), T);

                    -- enter track
                    T.BUSY;

                    T.GetType(Typee);

                    -- if is a station just go
                    if Typee = STATION then
                        RepairTrain.ChangePos(POS_STATION, NodeGetID(Path(I)));

                        -- print info
                        if GetMode = NOISY then
                            Put_Line("### [ " & Integer'Image(ID) & "  ]    " &  "GO TO STATION: " & Integer'Image(NodeGetID(Path(I))));
                        end if;
                    else -- it's normal track, so let's go

                        RepairTrain.ChangePos(POS_TRACK, NodeGetID(Path(I)));

                        -- print info
                        if GetMode = NOISY then
                            Put_Line("### [ " & Integer'Image(ID) & "  ]    " &  "GO TO TRACK: " & Integer'Image(NodeGetID(Path(I))));
                        end if;

                        -- our speed is min speed of train speed and track speed
                        T.GetSpeed(VA);
                        RepairTrain.GetMaxSpeed(VT);
                        if VA < VT then
                            VR := VA;
                        else
                            VR := VT;
                        end if;

                        T.GetLen(Len);

                        -- T = Len / V * second per real hour
                        Time := Float(Len) / Float(VR) * Float(GetSPH);
                    end if;

                    -- time for driving or waiting for people
                    delay Duration(Time);

                    T.FREE;

                    -- print info
                    if GetMode = NOISY then
                        if Typee = NORMAL then
                            Put_Line("@@@ [ " & Integer'Image(ID) & "  ]    " &  "LEAVING TRACK: " & Integer'Image(NodeGetID(Path(I))));
                        else
                            Put_Line("@@@ [ " & Integer'Image(ID) & "  ]    " &  "LEAVING STATION: " & Integer'Image(NodeGetID(Path(I))));
                        end if;
                    end if;
                else
                    Switches.GetByID(NodeGetID(Path(I)), S);

                    -- enter switch
                    S.BUSY;

                    RepairTrain.ChangePos(POS_SWITCH, NodeGetID(Path(I)));

                    -- print info
                    if GetMode = NOISY then
                        Put_Line("### [ " & Integer'Image(ID) & "  ]    " &  "GO TO SWITCH: " & Integer'Image(NodeGetID(Path(I))));
                    end if;

                    -- read time
                    S.GetStayTime(Time);

                    -- calc time to stay
                    Time := Time * Float(GetSPH);

                    -- wait
                    delay Duration(Time);

                    -- go out
                    S.FREE;

                    -- print info
                    if GetMode = NOISY then
                        Put_Line("@@@ [ " & Integer'Image(ID) & "  ]    " &  "LEAVING SWITCH: " & Integer'Image(NodeGetID(Path(I))));
                    end if;
                end if;
            end if;
        end loop;

        if GetMode = NOISY then
            Put_Line("/\/\/\ REPAIR TEAM ARE IN HOME /\/\/\");
        end if;

        BrokenItems := 0;
        RepairTrain.ChangePos(POS_STATION, NodeGetID(RepairNodeStation));
        PathDestroy(Path);
        NodeDestroy(Node);
    end loop;
end Repair;

task body Reserve is
    Path    :Path_PTR;
    S       :Switch_PTR;
    T       :Track_PTR;
begin
    loop
        select
            accept Start(P :in Path_PTR) do
                Path := P;
            end Start;
        end select;

        -- lock path
        for I in Path'range loop
            if NodeGetID(Path(I)) /= 0 then
                if NodeGetType(Path(I)) = EDGE then
                    Tracks.GetByID(NodeGetID(Path(I)), T);
                    T.Reserve;
                    if GetMode = NOISY then
                        Put_Line("<><><> TRACK " & Integer'Image(NodeGetID(Path(I))) & " IS LOCKED <><><>");
                    end if;
                else
                    Switches.GetByID(NodeGetID(Path(I)), S);
                    S.Reserve;
                    if GetMode = NOISY then
                        Put_Line("<><><> SWITCH " & Integer'Image(NodeGetID(Path(I))) & " IS LOCKED <><><>");
                    end if;
                end if;
            end if;
        end loop;

        Repair.Ready;

    end loop;
end Reserve;

end RepairTeam;
