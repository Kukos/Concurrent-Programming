with Ada.Numerics.discrete_Random;
package body RandGen is

subtype RandRange is Positive;
package RandInt is new Ada.Numerics.Discrete_Random(RandRange);

Generator : RandInt.Generator;

function GenRand (N: in Positive; M :in Positive) return Positive is
begin
    return (RandInt.Random(Generator) mod (M - N + 1)) + N;
end GenRand;

begin
   RandInt.Reset(Generator);
end RandGen;
