with Ada.Text_IO; use Ada.Text_IO;
with  Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Configs; use Configs;
with Train; use Train;
with Switch; use Switch;
with Track; use Track;
with GNAT.OS_Lib; use GNAT.OS_Lib;

package body Client is

task body Talk is
CMD   :Integer;
begin
    accept Start;

    while TRUE loop
        Put_Line("Enter Command: ");
        Put_Line("[1]    Print Configs");
        Put_Line("[2]    Print Trains");
        Put_Line("[3]    Print Tracks");
        Put_Line("[4]    Print Switches");
        Put_Line("[5]    Print Trains Posision");
        Put_Line("[6]    Exit");

        Get(CMD);

        -- Clear screen
        Put(ASCII.ESC & "[2J");

        case CMD is
            when 1 => ShowConfigs;
            when 2 => Trains.Show;
            when 3 => Tracks.Show;
            when 4 => Switches.Show;
            when 5 => Trains.ShowPos;
            when 6 => OS_Exit(0);
            when others => null;
        end case;

    end loop;
end Talk;

end Client;
