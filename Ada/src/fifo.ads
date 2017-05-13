-- This Package contains generic FIFO queue
-- Author: Michal Kukowski
-- email: michalkukowski10@gmail.com
-- LICENCE: GPL3.0

generic
    type Element_t is private;
package Fifo is

    type Fifo_t is private;
    type Fifo_PTR is access Fifo_t;

    function CreateFifo return Fifo_PTR;
    procedure DestroyFifo(Q : in out Fifo_PTR);
    procedure Enqueue(Q : in out Fifo_PTR; Item : in Element_t);
    procedure Dequeue(Q : in out Fifo_PTR; Item :out Element_t);
    procedure GetHead(Q  : in Fifo_PTR; Item :out Element_t);
    function Is_Empty(Q : Fifo_PTR) return Boolean;

private
    type QNode;
    type QNode_PTR is access QNode;

    type Fifo_t is record
        Head : QNode_PTR;
        Tail : QNode_PTR;
    end record;

    type QNode is record
        Value : Element_t;
        Next  : QNode_PTR;
    end record;

end Fifo;
