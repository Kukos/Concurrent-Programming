-- This Package contains funtion to random numbers
-- Author: Michal Kukowski
-- email: michalkukowski10@gmail.com
-- LICENCE: GPL3.0

package RandGen is
    -- Return Random [N; M]
    function GenRand (N: in Positive; M :in Positive) return Positive;
end RandGen;
