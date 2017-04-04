-- This Package contain functions of our Track
-- Author: Michal Kukowski
-- email: michalkukowski10@gmail.com
-- LICENCE: GPL3.0

package Track is

    type AVers is array(Integer range <>) of Integer;
    type AVers_PTR is access AVers;

    STATION: constant Integer    := 0;
    NORMAL: constant Integer     := 1;

    protected type Track_t is
        entry GetID(I :out Integer);
        entry GetType(T :out Integer);
        entry GetHTime(HT :out Float);
        entry GetLen(L :out Integer);
        entry GetSpeed(S :out Integer);
        entry IsFree(B :out Boolean);
        entry SetID(I :in Integer);
        entry SetType(T :in Integer);
        entry SetHTime(HT :in Float);
        entry SetLen(L :in Integer);
        entry SetSpeed(S :in Integer);
        entry BUSY;
        entry FREE;
        entry Show;
        entry AddVer(V :in Integer);
        entry CreateVer(N :in Integer);
        entry GetVers(V :out AVers_PTR);
    private
        -- common
        ID          :Integer;
        Freee       :Boolean := TRUE;
        Typee       :Integer;
        Vers        :AVers_PTR;
        CurVer      :Integer;

        -- STATION
        HTime        :Float;

        --NORMAL
        Len         :Integer;
        Speed       :Integer;
    end Track_t;

    type Track_PTR is access Track_t;

    -- private array of tracks
    type ATracks is array(Integer range <>) of Track_PTR;
    type ATracks_PTR is access ATracks;

    protected type Tracks_P is
        entry Create(N :in Integer);
        entry Insert(T :in Track_PTR);
        entry Get(A :out ATracks_PTR);
        entry GetByID(I :in Integer; T: out Track_PTR);
        entry Show;
    private
        Tracks      :ATracks_PTR;
        CurTrack    :Integer;
        Init        :Boolean := False;
    end Tracks_P;


    -- Create Station with parameters
    -- @IN I - ID
    -- @IN HT - Halt Time
    function CreateStationTrack(I :in Integer; HT :in Float) return Track_PTR;

    -- Create Normal Track with parameters
    -- @IN I - ID
    -- @IN L - Length
    -- @IN S - Speed
    function CreateNormalTrack(I :in Integer; L :in Integer; S :in Integer) return Track_PTR;

    -- Load Tracks from file
    procedure LoadTracks;

    Tracks :Tracks_P;

end Track;
