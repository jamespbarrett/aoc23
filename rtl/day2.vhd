library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity day2 is
    port(
        clock     : in  std_logic;
        reset     : in  std_logic;
        
        input : in std_logic_vector(7 downto 0);
        output : out std_logic_vector(7 downto 0)
    );
end entity day2;

architecture rtl of day2 is
    component chardet
        generic (
            CHAR: character
        );
        port(
            I : in std_logic_vector(7 downto 0);
            Q : out std_logic
        );
    end component;

    signal is_newline    : std_logic;
    signal is_colon      : std_logic;
    signal is_semicolon  : std_logic;
    signal is_comma      : std_logic;

    signal is_newline_z1   : std_logic;
    signal is_semicolon_z1 : std_logic;

    component digit is
        port(
            input : in std_logic_vector(7 downto 0);
            is_digit : out std_logic
        );
    end component;

    signal is_digit : std_logic;

    component BCDCounter is
        generic (
            DIGITS : integer;
            RSTVAL : std_logic_vector((4*DIGITS) - 1 downto 0) := (others => '0')
        );
        port(
            clock : in std_logic;
            reset : in std_logic;
    
            INC : in std_logic;
            Q : out std_logic_vector((4*DIGITS) - 1 downto 0)
        );
    end component;

    signal linenum : std_logic_vector(11 downto 0);

    signal curnum : std_logic_vector(7 downto 0);

    component strdet
        generic (
            STR: string
        );
        port(
            clock : std_logic;
            reset : std_logic;
    
            I : in std_logic_vector(7 downto 0);
            Q : out std_logic
        );
    end component;

    signal is_red   : std_logic;
    signal is_green : std_logic;
    signal is_blue  : std_logic;

    signal red   : std_logic_vector(curnum'range);
    signal green : std_logic_vector(curnum'range);
    signal blue  : std_logic_vector(curnum'range);

    component BCDGT is
        generic (
            CMPVAL : integer range 0 to 9
        );
        port(
            I : in std_logic_vector(3 downto 0);
            Q : out std_logic
        );
    end component;

    signal red_ok_units : std_logic;
    signal green_ok_units : std_logic;
    signal blue_ok_units : std_logic;

    signal red_ok : std_logic;
    signal green_ok : std_logic;
    signal blue_ok : std_logic;

    signal ok : std_logic;
    signal game_ok : std_logic;
    signal game_ok_z1 : std_logic;

    component BCDAccum is
        generic (
            DIGITS_IN : integer;
            DIGITS_EXTRA : integer
        );
        port(
            clock : in std_logic;
            reset : in std_logic;
    
            EN : in std_logic;
            I : in std_logic_vector((4*DIGITS_IN) - 1 downto 0);
            Q : out std_logic_vector((4*(DIGITS_IN + DIGITS_EXTRA)) - 1 downto 0)
        );
    end component;

    signal accum : std_logic_vector(19 downto 0);

    signal is_zero : std_logic;

    signal start_output : std_logic;

    signal outreg: std_logic_vector(accum'length - 1 downto 0);
    signal outactive : std_logic_vector(accum'length/4 - 1 downto 0);
begin

    NEWLINE: chardet
        generic map (
            CHAR => LF
        )
        port map (
            I => input,
            Q => is_newline
        );

    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '0' then
                is_newline_z1 <= '0';
            else
                is_newline_z1 <= is_newline;
            end if;
        end if;
    end process;

    COLON: chardet
        generic map (
            CHAR => ':'
        )
        port map (
            I => input,
            Q => is_colon
        );

    SEMICOLON: chardet
        generic map (
            CHAR => ';'
        )
        port map (
            I => input,
            Q => is_semicolon
        );

    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '0' then
                is_semicolon_z1 <= '0';
            else
                is_semicolon_z1 <= is_semicolon;
            end if;
        end if;
    end process;

    COMMA: chardet
        generic map (
            CHAR => ','
        )
        port map (
            I => input,
            Q => is_comma
        );

    DIGIT_I: digit
        port map (
            input => input,
            is_digit => is_digit
        );

    LINENUM_CTR: BCDCounter
        generic map (
            DIGITS => 3,
            RSTVAL => x"001"
        )
        port map (
            clock => clock,
            reset => reset,
            INC => is_newline_z1,
            Q => linenum
        );

    process(clock)
    begin
        if rising_edge(clock) then
            if (not reset or is_newline or is_colon or is_semicolon or is_comma) = '1' then
                curnum <= (others => '0');
            elsif is_digit = '1' then
                for i in curnum'length/4 -1 downto 1 loop
                    curnum(i*4 + 3 downto i*4) <= curnum(i*4 - 1 downto i*4 - 4);
                end loop;
                curnum(3 downto 0) <= input(3 downto 0);
            end if;
        end if;
    end process;

    REDDET: strdet
        generic map (
            STR => "red"
        )
        port map (
            clock => clock,
            reset => reset,
            I => input,
            Q => is_red
        );

    process(clock)
    begin
        if rising_edge(clock) then
            if (not reset or is_newline_z1 or is_semicolon_z1) then
                red <= (others => '0');
            elsif is_red = '1' then
                red <= curnum;
            end if;
        end if;
    end process;

    GREENDET: strdet
        generic map (
            STR => "green"
        )
        port map (
            clock => clock,
            reset => reset,
            I => input,
            Q => is_green
        );

    process(clock)
    begin
        if rising_edge(clock) then
            if (not reset or is_newline_z1 or is_semicolon_z1) then
                green <= (others => '0');
            elsif is_green = '1' then
                green <= curnum;
            end if;
        end if;
    end process;

    BLUEDET: strdet
        generic map (
            STR => "blue"
        )
        port map (
            clock => clock,
            reset => reset,
            I => input,
            Q => is_blue
        );

    process(clock)
    begin
        if rising_edge(clock) then
            if (not reset or is_newline_z1 or is_semicolon_z1) then
                blue <= (others => '0');
            elsif is_blue = '1' then
                blue <= curnum;
            end if;
        end if;
    end process;


    REDGT: BCDGT
        generic map (
            CMPVAL => 2
        )
        port map (
            I => red(3 downto 0),
            Q => red_ok_units
        );
    
    red_ok <= not red(7) and not red(6) and not red(5) and (not red(4) or not red_ok_units);

    GREENGT: BCDGT
        generic map (
            CMPVAL => 3
        )
        port map (
            I => green(3 downto 0),
            Q => green_ok_units
        );
    
    green_ok <= not green(7) and not green(6) and not green(5) and (not green(4) or not green_ok_units);

    BLUEGT: BCDGT
        generic map (
            CMPVAL => 4
        )
        port map (
            I => blue(3 downto 0),
            Q => blue_ok_units
        );
    
    blue_ok <= not blue(7) and not blue(6) and not blue(5) and (not blue(4) or not blue_ok_units);

    ok <= red_ok and green_ok and blue_ok;

    process(clock)
    begin
        if rising_edge(clock) then
            if (not reset or is_newline_z1) = '1' then
                game_ok <= '1';
            else
                game_ok <= game_ok and ok;
            end if;
        end if;
    end process;

    process(clock)
    begin
        if rising_edge(clock) then
            game_ok_z1 <= game_ok;
        end if;
    end process;

    ACCUM_I: BCDAccum
        generic map(
            DIGITS_IN => 3,
            DIGITS_EXTRA => accum'length/4 - 3
        )
        port map(
            clock => clock,
            reset => reset,
    
            EN => game_ok_z1 and is_newline_z1,
            I => linenum,
            Q => accum
        );

        is_zero <= not input(7) and not input(6) and not input(5) and not input(4) and not input(3) and not input(2) and not input(1) and not input(0);

        process(clock)
            variable is_zero_z1 : std_logic;
        begin
            if rising_edge(clock) then
                if reset = '0' then
                    is_zero_z1 := '0';
                    start_output <= '0';
                else
                    start_output <= is_zero and not is_zero_z1;
                    is_zero_z1 := is_zero;
                end if;
            end if;
        end process;
    
        process(clock)
        begin
            if rising_edge(clock) then
                if start_output = '1' then
                    outreg <= accum;
                    outactive <= (others => '1');
                else
                    for i in outreg'length/4 - 1 downto 1 loop
                        outreg((i + 1)*4 - 1 downto i*4) <= outreg(i* 4 - 1 downto (i-1)*4);
                    end loop;
                    outreg(3 downto 0) <= "0000";
    
                    outactive <= "0" & outactive(outactive'left downto 1);
                end if;
            end if;
        end process;
    
        output <= ("0011" & outreg(outreg'left downto outreg'left - 3)) when outactive(0) = '1' else "00000000";

end rtl;
