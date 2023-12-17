library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity strdet is
    generic (
        STR: string
    );
    port(
        clock : std_logic;
        reset : std_logic;

        I : in std_logic_vector(7 downto 0);
        Q : out std_logic
    );
end entity strdet;

architecture rtl of strdet is
    signal DET : std_logic_vector(STR'length downto 0);
    signal EN  : std_logic_vector(STR'length downto 1);
    signal QQ : std_logic_vector(STR'length downto 1);

    component chardet
        generic (
            CHAR: character
        );
        port(
            I : in std_logic_vector(7 downto 0);
            Q : out std_logic
        );
    end component;
begin

    GEN: for n in STR'length downto 1 generate
        CHARDET_I: chardet
            generic map (
                CHAR => STR(n)
            )
            port map (
                I => I,
                Q => QQ(n)
            );
        
        EN(n) <= reset and QQ(n) and DET(n-1);

        process(clock)
        begin
            if rising_edge(clock) then
                if EN(n) then
                    DET(n) <= '1';
                else
                    DET(n) <= '0';
                end if;
            end if;
        end process;
    end generate;

    DET(0) <= '1';

    Q <= DET(STR'length);

end rtl;
