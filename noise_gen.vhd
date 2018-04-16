--
-- AY-819x Noise Generator
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

entity noise_gen is
    port (
	-- Clock signal
	clock : in std_logic;
	-- Reset signal
	reset : in std_logic;
	-- From noise generator control register
	noise_period : in unsigned(4 downto 0);
	-- To mixer
	output : out std_logic
    );
end noise_gen;

architecture noise_gen_arch of noise_gen is
    -- Clock pre-division counter
    signal prediv_cnt : unsigned(3 downto 0);
    -- Noise counter
    signal noise_cnt : unsigned(4 downto 0);
    -- Linear Feedback Shift Register
    signal lfsr : std_logic_vector(1 to 16);
begin

    -- Pre-division counting
    process(clock, reset)
    begin
	if reset = '1' then
	    prediv_cnt <= (others => '1');
	elsif rising_edge(clock) then
	    prediv_cnt <= prediv_cnt - 1;
	end if;
    end process;

    -- Noise counting
    process(clock, reset)
    begin
	if reset = '1' then
	    noise_cnt <= (others => '1');
	elsif rising_edge(clock) and prediv_cnt = 0 then
	    if noise_cnt = 0 then
		noise_cnt <= noise_period;
	    else
		noise_cnt <= noise_cnt - 1;
	    end if;
	end if;
    end process;

    -- Noise LFSR
    process(clock, reset)
        -- LFSR output
	variable b: std_logic;
    begin
	if reset = '1' then
	    lfsr <= (others => '1');
	elsif rising_edge(clock) and noise_cnt = 0 then
	    -- A 16-bit Fibonacci LFSR
	    -- (per https://en.wikipedia.org/wiki/Linear-feedback_shift_register)
	    b := lfsr(11) xor lfsr(13) xor lfsr(14) xor lfsr(16);
	    lfsr <= b & lfsr(1 to 15);
	end if;

        output <= b;
    end process;


end noise_gen_arch;
