-- This Package contains GLOBAL Configs
-- Author: Michal Kukowski
-- email: michalkukowski10@gmail.com
-- LICENCE: GPL3.0

package Configs is

    type Config is private;
    type Config_PTR is access Config;

    -- setters
    procedure SetMode(M :in Integer);
    procedure SetSPH(Sph :in Integer);
    procedure SetNTrains(NT :in Integer);
    procedure SetNTracks(NT :in Integer);
    procedure SetNSwiches(NS :in Integer);

    -- getters
    function GetMode return Integer;
    function GetSPH return Integer;
    function GetNTrains return Integer;
    function GetNTracks return Integer;
    function GetNSwitches return Integer;

    -- Load Configs from File
    procedure LoadConfigs;

    -- Print on stdout configs
    procedure ShowConfigs;

    SILENT: constant Integer    := 0;
    NOISY: constant Integer     := 1;

private
    type Config is record
        Mode        :Integer;
        S_per_h     :Integer;
        NumTrains   :Integer;
        NumTracks   :Integer;
        NumSwitches :Integer;
    end record;

    -- static variable
    Conf :Config_PTR := new Config;

end Configs;
