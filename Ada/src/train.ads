-- This Package contains functions of our Train
-- Author: Michal Kukowski
-- email: michalkukowski10@gmail.com
-- LICENCE: GPL3.0

package Train is

    -- New Types, Array Route and Train
    type ARoute is array(Integer range <>) of Integer;
    type ARoute_PTR is access ARoute;

    POS_NONE    :constant Integer    := 0;
    POS_STATION :constant Integer    := 1;
    POS_TRACK   :constant Integer    := 2;
    POS_SWITCH  :constant Integer    := 3;

    protected type Train_t is
        entry GetID(I :out Integer);
        entry GetMaxSpeed(MS :out Integer);
        entry GetCapacity(C :out Integer);
        entry GetRoute(R :out ARoute_PTR);
        entry GetStartPoint(SP :out Integer);
        entry SetID(I :in Integer);
        entry SetMaxSpeed(MS :in Integer);
        entry SetCapacity(C :in Integer);
        entry SetStartPoint(SP: in Integer);
        entry CreateRoute(N :in Integer);
        entry AddRoute(R :in Integer);
        entry ChangePos(PT :in Integer; I :in Integer);
        entry Show;
        entry ShowPos;
    private
        ID          :Integer;
        MaxSpeed    :Integer;
        Capacity    :Integer;
        StartPoint  :Integer;
        PosType     :Integer;
        PosID       :Integer;
        Route       :ARoute_PTR;
        CurRoute    :Integer;
    end Train_t;

    type Train_PTR is access Train_t;

    -- Private array of trains
    type ATrains is array(Integer range <>) of Train_PTR;
    type ATrains_PTR is access ATrains;

    protected type Trains_P is
        entry Create(N :in Integer);
        entry Insert(T :in Train_PTR);
        entry Get(A :out ATrains_PTR);
        entry GetByID(I :in Integer; T: out Train_PTR);
        entry Show;
        entry ShowPos;
    private
        Trains       :ATrains_PTR;
        Init         :Boolean := False;
    end Trains_P;

    -- Create Train with Parameters
    -- @IN I - ID
    -- @IN MS - MaxSpeed
    -- @IN C - Capacity
    --@IN SP - Start Point
    -- @IN N - size of Route
    function CreateTrain(I :in Integer; MS :in Integer; C :in Integer; SP :in Integer; N :in Integer) return Train_PTR;

    -- Load trains info from file
    procedure LoadTrains;

    -- static protected
    Trains :Trains_P;

end Train;
