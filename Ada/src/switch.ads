-- This Package contain functions of our Switch
-- Author: Michal Kukowski
-- email: michalkukowski10@gmail.com
-- LICENCE: GPL3.0

package Switch is

    type AEdges is array(Integer range <>) of Integer;

    protected type Switch_t is
        entry IsFree(B :out Boolean);
        entry GetID(I :out Integer);
        entry GetStayTime(ST: out Float);
        entry AddEdge(I :in Integer);
        entry Show;
        entry SetID(I :in Integer);
        entry SetStayTime(ST :in Float);
        entry CreateAEdges(N :in Integer);
        entry BUSY;
        entry FREE;

    private
        ID          :Integer;
        StayTime    :Float;
        Freee       :Boolean := TRUE;
        Edges       :access AEdges;
        CurEdge     :Integer;
    end Switch_t;

    type Switch_PTR is access Switch_t;

    -- private array of switches
    type ASwitches is array(Integer range <>) of Switch_PTR;
    type ASwitches_PTR is access ASwitches;

    protected type Switches_P is
        entry Create(N :in Integer);
        entry Insert(S :in Switch_PTR);
        entry Get(A :out ASwitches_PTR);
        entry GetByID(I :in Integer; S :out Switch_PTR);
        entry Show;
    private
        Switches    :ASwitches_PTR;
        CurSwitch   :Integer;
        Init        :Boolean := False;
    end Switches_P;

    -- Create Switch with parameters
    -- @IN I - ID
    -- @IN ST - StayTime
    function CreateSwitch(I :in Integer; ST :in Float) return Switch_PTR;

    -- Load Switches from file
    procedure LoadSwitches;

    Switches :Switches_P;

end Switch;
