--
-- AY-819x Envelope Shape Test
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

entity test_env_shape is
end test_env_shape;

architecture test_env_shape_arch of test_env_shape is
    component env_shape is
	port (
	    -- From Envelope Shapy/Cycle Control Register
	    continue : in std_logic;
	    -- From Envelope Shapy/Cycle Control Register
	    attack : in std_logic;
	    -- From Envelope Shapy/Cycle Control Register
	    alternate : in std_logic;
	    -- From Envelope Shapy/Cycle Control Register
	    hold : in std_logic;
	    -- Envelope phase
	    env_phase : in env_phase_t;
	    -- Amplitude
	    amp : out amp_lvl_t
	);
    end component;

    signal env_phase : env_phase_t;
    signal out00xx : amp_lvl_t;
    signal out01xx : amp_lvl_t;
    signal out1000 : amp_lvl_t;
    signal out1001 : amp_lvl_t;
    signal out1010 : amp_lvl_t;
    signal out1011 : amp_lvl_t;
    signal out1100 : amp_lvl_t;
    signal out1101 : amp_lvl_t;
    signal out1110 : amp_lvl_t;
    signal out1111 : amp_lvl_t;
begin

    process
	variable l : line;

        procedure write_snn(n : in unsigned) is
        begin
    	    write (l, String'(" "));
	    if to_integer(n) < 10 then
		write (l, String'(" "));
	    end if;
	    write (l, to_integer(n));
        end write_snn;
    begin
	env_phase <= (others => '0');
	loop
	    wait for 100 ns;
	    write_snn(env_phase);
	    write (l, String'(":"));
	    write_snn(out00xx);
	    write_snn(out01xx);
	    write_snn(out1000);
	    write_snn(out1001);
	    write_snn(out1010);
	    write_snn(out1011);
	    write_snn(out1100);
	    write_snn(out1101);
	    write_snn(out1110);
	    write_snn(out1111);
	    writeline (output, l);

	    if env_phase /= "100000" then
		env_phase <= env_phase + 1;
	    else
		env_phase <= "010000";
		assert false
		    report "Simulation ended"
		    severity failure;
	    end if;
	end loop;
    end process;

    e00xx : env_shape port map (
	continue => '0',
	attack => '0',
	alternate => 'X',
	hold => 'X',
	env_phase => env_phase,
	amp => out00xx
    );

    e01xx : env_shape port map (
	continue => '0',
	attack => '1',
	alternate => 'X',
	hold => 'X',
	env_phase => env_phase,
	amp => out01xx
    );

    e1000 : env_shape port map (
	continue => '1',
	attack => '0',
	alternate => '0',
	hold => '0',
	env_phase => env_phase,
	amp => out1000
    );

    e1001 : env_shape port map (
	continue => '1',
	attack => '0',
	alternate => '0',
	hold => '1',
	env_phase => env_phase,
	amp => out1001
    );

    e1010 : env_shape port map (
	continue => '1',
	attack => '0',
	alternate => '1',
	hold => '0',
	env_phase => env_phase,
	amp => out1010
    );

    e1011 : env_shape port map (
	continue => '1',
	attack => '0',
	alternate => '1',
	hold => '1',
	env_phase => env_phase,
	amp => out1011
    );

    e1100 : env_shape port map (
	continue => '1',
	attack => '1',
	alternate => '0',
	hold => '0',
	env_phase => env_phase,
	amp => out1100
    );

    e1101 : env_shape port map (
	continue => '1',
	attack => '1',
	alternate => '0',
	hold => '1',
	env_phase => env_phase,
	amp => out1101
    );

    e1110 : env_shape port map (
	continue => '1',
	attack => '1',
	alternate => '1',
	hold => '0',
	env_phase => env_phase,
	amp => out1110
    );

    e1111 : env_shape port map (
	continue => '1',
	attack => '1',
	alternate => '1',
	hold => '1',
	env_phase => env_phase,
	amp => out1111
    );

end test_env_shape_arch;
