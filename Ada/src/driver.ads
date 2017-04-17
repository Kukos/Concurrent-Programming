-- This Package contains functions of Train Driver ( Single task )
-- Author: Michal Kukowski
-- email: michalkukowski10@gmail.com
-- LICENCE: GPL3.0

with Train; use Train;

package Driver is

task type Driver_t is
    entry Start(T : in Train_PTR);
end Driver_t;

type Driver_PTR is access Driver_t;

type ADrivers is array(Integer range <>) of Driver_PTR;

end Driver;
