with Ada.Unchecked_Deallocation;

package body Fifo is

function CreateFifo return Fifo_PTR is
Q :Fifo_PTR;
begin
    Q := new Fifo_t;
    Q.Head := null;
    Q.Tail := null;

    return Q;
end CreateFifo;

procedure DestroyFifo(Q : in out Fifo_PTR) is
procedure Free is new Ada.Unchecked_Deallocation(Fifo_t, Fifo_PTR);
begin
    Free(Q);
end DestroyFifo;

procedure Enqueue(Q : in out Fifo_PTR; Item : in Element_t) is
Temp : QNode_PTR;
begin
    Temp := new QNode;
    Temp.Value := Item;
    Temp.Next := null;

    if Is_Empty(Q) then
        Q.Tail := Temp;
        Q.Head := Temp;
        Q.Head.Next := Q.Tail;
    else
        Q.Tail.Next := Temp;
        Q.Tail := Q.Tail.Next;
    end if;
end Enqueue;

procedure Dequeue(Q : in out Fifo_PTR; Item :out Element_t) is
procedure Free is new Ada.Unchecked_Deallocation(QNode, QNode_PTR);
Temp : QNode_PTR;
begin
    Temp := Q.Head;

    if Is_Empty(Q) then
        return;
    end if;

    Item := Q.Head.Value;
    Q.Head := Q.Head.Next;

    if Q.Head = null then
        Q.Tail := null;
    end if;

     Free(Temp);
end Dequeue;

procedure GetHead(Q  : in Fifo_PTR; Item :out Element_t) is
begin
    Item := Q.Head.Value;
end GetHead;

function Is_Empty(Q : Fifo_PTR) return Boolean is
begin
    return Q.Head = null;
end Is_Empty;

end Fifo;
