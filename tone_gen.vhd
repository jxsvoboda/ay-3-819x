--
-- AY-819x Tone Generator
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

entity tone_gen is
    port (
	-- Clock signal
	clock : in std_logic;
	-- Reset signal
	reset : in std_logic;
	-- From Coarse/Fine Tune Registers
	tone_period : in tone_period_t;
	-- Counter value (for debugging)
	cnt : out tone_period_t;
	-- To mixer
	output : out std_logic
    );
end tone_gen;

architecture tone_gen_arch of tone_gen is
    -- Clock pre-division counter
    signal prediv_cnt : unsigned(3 downto 0);
    -- Tone counter
    signal tone_cnt : tone_period_t;
    -- Tone state
    signal tone_state : std_logic;
begin

    -- Pre-division counting
    process(clock, reset)
    begin
	if reset = '1' then
	    -- Reset
	    prediv_cnt <= (others => '1');
	    tone_cnt <= tone_period;
	    tone_state <= '0';
	elsif rising_edge(clock) then
	    if prediv_cnt > 0 then
		prediv_cnt <= prediv_cnt - 1;
	    else
		if tone_cnt > 0 then
		    tone_cnt <= tone_cnt - 1;
		else
		    tone_cnt <= tone_period;
		    tone_state <= not tone_state;
		end if;
	    end if;
	end if;
    end process;

    output <= tone_state;
    cnt <= tone_cnt;

end tone_gen_arch;
