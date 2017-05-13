-- This Package contains functions of ReapitTeam
-- Author: Michal Kukowski
-- email: michalkukowski10@gmail.com
-- LICENCE: GPL3.0

with Graph; use Graph;
with Train; use Train;

package RepairTeam is

protected type Using_t is
    entry UseItem(N :in Node_PTR);

    private
    isFree :Boolean := TRUE;

end Using_t;

Using_PTR :Using_t;
RepairNodeStation : Node_PTR;
RepairTrain :Train_PTR;

task Reserve is
    entry Start (P :in Path_PTR);
end Reserve;

task Repair is
    entry Start(P : in Path_PTR; N :in Node_PTR);
    entry Ready;
end Repair;

private
    BrokenItems :Integer := 0;

end RepairTeam;
