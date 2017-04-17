with Ada.Text_IO; use Ada.Text_IO;
with Track; use Track;
with Train; use Train;
with Switch; use Switch;
with Configs; use Configs;

package body Driver is

task body Driver_t is
    Train       :Train_PTR;
    TI          :Integer;
    ID          :Integer;
    Route       :ARoute_PTR;
    Track       :Track_PTR;
    Typee       :Integer;
    Time        :Float;
    VT          :Integer;
    VA          :Integer;
    VR          :Integer;
    S           :Integer;
    CurSwitchID :Integer;
    Switch      :Switch_PTR;
    Vers        :AVers_PTR;
    NewSwitchID :Integer;
    FirstTime   :Boolean;
begin
    accept Start(T :in Train_PTR) do
        Train := T;
        Train.GetRoute(Route);
        Train.GetMaxSpeed(VT);
        Train.GetID(ID);
    end Start;

    -- driving is your life :)
    while TRUE loop
        Train.GetStartPoint(CurSwitchID);

        -- we go to the sation
        Train.ChangePos(POS_STATION, Route(1));

        FirstTime := TRUE;
        -- for each track in your route
        for I in Route'range loop

            exit when Route(I) = 0;

            -- Get new Track object
            Tracks.GetByID(Route(I), Track);

            Track.GetID(TI);

            -- set track as busy
            Track.BUSY;


            Track.GetType(Typee);

            -- if is a station wait for people
            if Typee = STATION then
                Train.ChangePos(POS_STATION, Route(I));

                -- print info
                if GetMode = NOISY then
                    Put_Line("### [ " & Integer'Image(ID) & "  ]    " &  "GO TO STATION: " & Integer'Image(TI));
                end if;

                Track.GetHTime(Time) * Float(GetSPH);

            else -- it's normal track, so let's go

                Train.ChangePos(POS_TRACK, Route(I));

                -- print info
                if GetMode = NOISY then
                    Put_Line("### [ " & Integer'Image(ID) & "  ]    " &  "GO TO TRACK: " & Integer'Image(TI));
                end if;

                -- our speed is min speed of train speed and track speed
                Track.GetSpeed(VA);
                if VA < VT then
                    VR := VA;
                else
                    VR := VT;
                end if;

                Track.GetLen(S);

                -- T = S / V * second per real hour
                Time := Float(S) / Float(VR) * Float(GetSPH);
            end if;

            -- time for driving or waiting for people
            delay Duration(Time);

            -- Free Track
            Track.FREE;

            -- print info
            if GetMode = NOISY then
                if Typee = NORMAL then
                    Put_Line("@@@ [ " & Integer'Image(ID) & "  ]    " &  "LEAVING TRACK: " & Integer'Image(TI));
                else
                    Put_Line("@@@ [ " & Integer'Image(ID) & "  ]    " &  "LEAVING STATION: " & Integer'Image(TI));
                end if;
            end if;

            Track.GetVers(Vers);

            -- choose Switch (start or end )
            if FirstTime = FALSE then
                for J in Vers'range loop
                    if Vers(J) /= 0 then
                        NewSwitchID := Vers(J);
                    end if;
                    exit when NewSwitchID /= CurSwitchID;
                end loop;

                --change Switch
                CurSwitchID := NewSwitchID;
            end if;

            FirstTime := FALSE;

            exit when I = Route'Length or Route(I + 1) = 0;

            Switches.GetByID(CurSwitchID, Switch);

            -- enter switch
            Switch.BUSY;

            Train.ChangePos(POS_SWITCH, CurSwitchID);

            -- print info
            if GetMode = NOISY then
                Put_Line("### [ " & Integer'Image(ID) & "  ]    " &  "GO TO SWITCH: " & Integer'Image(CurSwitchID));
            end if;

            -- read time
            Switch.GetStayTime(Time);

            -- calc time to stay
            Time := Time * Float(GetSPH);

            -- wait
            delay Duration(Time);

            -- go out
            Switch.FREE;

            -- print info
            if GetMode = NOISY then
                Put_Line("@@@ [ " & Integer'Image(ID) & "  ]    " &  "LEAVING SWITCH: " & Integer'Image(CurSwitchID));
            end if;

        end loop;
    end loop;

end Driver_t;

end Driver;
