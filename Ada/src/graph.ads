-- This Package contains funtion to parse file to graph
-- Author: Michal Kukowski
-- email: michalkukowski10@gmail.com
-- LICENCE: GPL3.0

package Graph is

    type Node_t is private;
    type Node_PTR is access Node_t;

    type Path_t is array(Integer range <>) of Node_PTR;
    type Path_PTR is access Path_t;

    EDGE: constant Integer    := 0;
    VERTEX: constant Integer  := 1;

    function CreateNode(T : in Integer; ID : in Integer) return Node_PTR;
    function NodeGetType(N : in Node_PTR) return Integer;
    function NodeGetID(N : in Node_PTR) return Integer;
    procedure NodeDestroy(N : in out Node_PTR);

    -- Load graph from file
    procedure LoadGraph;

    -- Find path between two nodes
    function FindPath(N1 : in Node_PTR; N2 : in Node_PTR) return Path_PTR;
    procedure PathDestroy(P :in out Path_PTR);

private
    type Node_t is record
        Typee   :Integer;
        ID      :Integer;
    end record;

    -- private helper, find path between two verticles
    function FindPathVer(V1 : in Integer; V2 : in Integer) return Path_PTR;

end Graph;
