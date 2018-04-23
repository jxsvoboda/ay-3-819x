--
-- AY-819x Tone Generator Test
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

entity test_env_gen is
end test_env_gen;

architecture test_env_gen_arch of test_env_gen is
    component env_gen is
	port (
	    -- Clock signal
	    clock : in std_logic;
	    -- Reset signal
	    reset : in std_logic;
	    -- From Envelope Coarse/Fine Tune Registers
	    env_period : in env_period_t;
	    -- From Envelope Shapy/Cycle Control Register
	    shape : in env_shape_t;
	    -- Counter value (for debugging)
	    cnt : out env_period_t;
	    -- To mixer
	    output : out amp_lvl_t
	);
    end component;

    signal clock : std_logic;
    signal reset : std_logic;
    signal env_period : env_period_t;
    signal outp : amp_lvl_t;
    signal cnt : integer;
    signal ecnt : env_period_t;
    signal shape : env_shape_t;

begin

    process
	variable l : line;

    begin
	reset <= '1';
	clock <= '0';
	env_period <= "0000000000000001";

	wait for 100 ns;
	reset <= '0';
	cnt <= 0;

        wait for 100 ns;

	loop
	    if cnt mod 256 = 0 then
		writeline (output, l);
		write (l, cnt);
		write (l, String'(": ("));
		write (l, to_integer(ecnt));
		write (l, String'(") "));

		write (l, String'(" "));
		write (l, to_integer(outp));
	    end if;

	    if cnt < 65536 then
		cnt <= cnt + 1;
		clock <= not clock;
		wait for 100 ns;
		clock <= not clock;
		wait for 100 ns;
	    else
		assert false
		    report "Simulation ended"
		    severity failure;
	    end if;
	end loop;
    end process;

    eg : env_gen port map (
	clock => clock,
	reset => reset,
	env_period => env_period,
	shape => shape,
	cnt => ecnt,
	output => outp
    );


end test_env_gen_arch;
