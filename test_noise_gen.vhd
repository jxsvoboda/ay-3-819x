--
-- AY-819x Noise Generator Test
--
-- Copyright 2018 Jiri Svoboda
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included
-- in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
-- OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.common.all;
use std.textio.all;

entity test_noise_gen is
end test_noise_gen;

architecture test_noise_gen_arch of test_noise_gen is
    component noise_gen is
	port (
	    -- Clock signal
	    clock : in std_logic;
	    -- Reset signal
	    reset : in std_logic;
	    -- From noise generator control register
	    noise_period : in noise_period_t;
	    cnt : out noise_period_t;
	    -- To mixer
	    output : out std_logic
	);
    end component;

    signal clock : std_logic;
    signal reset : std_logic;
    signal noise_period : noise_period_t;
    signal outp : std_logic;
    signal cnt : integer;
    signal ncnt : noise_period_t;

begin

    process
	variable l : line;

    begin
	reset <= '1';
	clock <= '0';
	noise_period <= "00001";

	wait for 100 ns;
	reset <= '0';

	cnt <= 0;
	loop
	    wait for 100 ns;
	    if cnt mod 16 = 0 then
		writeline (output, l);
	    end if;
	    if cnt mod 16 = 0 then
		write (l, cnt);
		write (l, String'(": ("));
		write (l, to_integer(ncnt));
		write (l, String'(") "));
	    end if;

	    write (l, String'(" "));
	    if outp = '1' then
		    write (l, 1);
	    else
		    write (l, 0);
	    end if;

	    if cnt < 2048 then
		cnt <= cnt + 1;
		clock <= not clock;
		wait for 100 ns;
		clock <= not clock;
	    else
		assert false
		    report "Simulation ended"
		    severity failure;
	    end if;
	end loop;
    end process;

    ng : noise_gen port map (
	clock => clock,
	reset => reset,
	noise_period => noise_period,
	cnt => ncnt,
	output => outp
    );


end test_noise_gen_arch;
