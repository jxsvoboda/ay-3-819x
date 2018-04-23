--
-- AY-819x Envelope Generator
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

entity env_gen is
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
	-- To amplitude control
	output : out amp_lvl_t
    );
end env_gen;

architecture env_gen_arch of env_gen is
    component env_shape is
	port (
	    -- From Envelope Shapy/Cycle Control Register
	    shape : in env_shape_t;
	    -- Envelope phase
	    env_phase : in env_phase_t;
	    -- Amplitude
	    amp : out amp_lvl_t
	);
    end component;

    -- Clock pre-division counter
    signal prediv_cnt : unsigned(7 downto 0);
    -- Envelope counter
    signal env_cnt : env_period_t;
    -- Envelope phase
    signal env_phase : env_phase_t;
begin

    process(clock, reset)
	variable next_phase : env_phase_t;
        -- Next envelope period
	variable next_p : unsigned(1 downto 0);
    begin
	if reset = '1' then
	    prediv_cnt <= (others => '1');
	    env_cnt <= env_period;
	    env_phase <= (others => '0');
	elsif rising_edge(clock) then
	    if prediv_cnt > 0 then
		prediv_cnt <= prediv_cnt - 1;
	    else
		prediv_cnt <= (others => '1');
		if env_cnt > 0 then
		    env_cnt <= env_cnt - 1;
		else
		    env_cnt <= env_period;
		    case env_phase(5 downto 4) is
			when "00" =>
			    next_p := "01";
			when "01" =>
			    next_p := "10";
			when "10" =>
			    next_p := "01";
			when others =>
			    next_p := "XX";
		    end case;

		    next_phase := env_phase + 1;
		    env_phase <= next_p & next_phase(3 downto 0);
		end if;
	    end if;
	end if;
    end process;

    -- Generate envelope shape and send resulting amplitude to output
    eshape : env_shape port map (
	-- Take shape from our input ports
	shape => shape,
	-- Take env_phase from the phase counter
	env_phase => env_phase,
	-- Pass amplitude to output
	amp => output
    );

    cnt <= env_cnt;

end env_gen_arch;
