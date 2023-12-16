library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity day1 is
    port(
        clock     : in  std_logic;
        reset     : in  std_logic;
        
        input : in std_logic_vector(7 downto 0);
        output : out std_logic_vector(7 downto 0)
    );
end entity day1;

architecture rtl of day1 is
    component digit
        port(
            input : in  std_logic_vector(7 downto 0);
            is_digit : out std_logic
        );
    end component;

    signal is_digit: std_logic;

    component newline
        port(
            input : in  std_logic_vector(7 downto 0);
            is_newline : out std_logic
        );
    end component;

    signal is_newline: std_logic;

    signal first_digit: std_logic_vector(3 downto 0);
    signal last_digit: std_logic_vector(3 downto 0);

    signal has_first: std_logic;

    component BCD_add
        port(
            A  : in  std_logic_vector(3 downto 0);
            B  : in  std_logic_vector(3 downto 0);
            CI : in  std_logic;
            O  : out std_logic_vector(3 downto 0);
            CO : out std_logic
        );
    end component;

    component LUT1
        generic (
            ILEN: integer := 1;
            DATA : std_logic_vector((2 ** ILEN) - 1 downto 0)
        );
        port(
            input : in  std_logic_vector(ILEN - 1 downto 0);
            output : out std_logic
        );
    end component;

    pure function BCDADD1BIT(
        N: integer
    ) return std_logic_vector is
        variable rval: std_logic_vector(31 downto 0) := (others => '0');
        variable tmp: std_logic_vector(3 downto 0);
    begin
        for i in 0 to 9 loop
            tmp := std_logic_vector(to_unsigned(i, 4));
            rval(i) := tmp(n);
            tmp := std_logic_vector(to_unsigned((i + 1) mod 10, 4)) when i + 1 < 10 else x"0";
            rval(16 + i) := tmp(n);
        end loop;
        return rval;
    end function;

    signal sum: std_logic_vector(19 downto 0);
    signal accum: std_logic_vector(sum'length - 1 downto 0);
    signal C: std_logic_vector(sum'length/4 - 1 downto 0);

    signal is_zero : std_logic;

    signal start_output : std_logic;

    signal outreg: std_logic_vector(sum'length - 1 downto 0);
    signal outactive : std_logic_vector(sum'length/4 - 1 downto 0);
begin

    ISDIGIT: digit 
    port map (
        input => input,
        is_digit => is_digit
    );

    ISNEWLINE: newline
    port map (
        input => input,
        is_newline => is_newline
    );

    process(clock)
    begin
        if rising_edge(clock) then
            if (not reset or is_newline) = '1' then
                first_digit <= (others => '0');
                has_first <= '0';
            elsif (is_digit and not has_first) = '1' then
                first_digit <= input(3 downto 0);
                has_first <= '1';
            end if;
        end if;
    end process;

    process(clock)
    begin
        if rising_edge(clock) then
            if (not reset or is_newline) = '1' then
                last_digit <= (others => '0');
            elsif is_digit = '1' then
                last_digit <= input(3 downto 0);
            end if;
        end if;
    end process;


    ADD0: BCD_add
        port map (
            A  => last_digit,
            B  => accum(3 downto 0),
            CI => '0',
            O  => sum(3 downto 0),
            CO => C(0)
        );
    ADD1: BCD_add
        port map (
            A  => first_digit,
            B  => accum(7 downto 4),
            CI => C(0),
            O  => sum(7 downto 4),
            CO => C(1)
        );
    
    ADDGEN: for i in 2 to (sum'length/4 - 1) generate
        LUTGEN: for j in 3 downto 0 generate
            LUT: LUT1
                generic map (
                    ILEN => 5,
                    DATA => BCDADD1BIT(j)
                )
                port map (
                    input => C(i-1) & accum((i + 1)*4 - 1 downto i*4),
                    output => sum(i*4 + j)
                );
            
            C(i) <= '1' when C(i-1) and accum(i*4 + 3) and not accum(i*4 + 2) and not accum(i*4 + 1) and accum(i*4 + 0) else '0';
        end generate;
    end generate;

    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '0' then
                accum <= (others => '0');
            elsif is_newline = '1' then
                accum <= sum;
            end if;
        end if;
    end process;

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
