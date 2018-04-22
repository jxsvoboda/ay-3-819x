--
-- AY-819x Envelope Shape
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

entity env_shape is
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
end env_shape;

architecture env_shape_arch of env_shape is
    -- '1' means the first EP, '0' is any other
    signal first : std_logic;
    -- Bit 0 of Envelope Period
    signal eper0 : std_logic;
    -- Direction, '0' is decaying, '1' is attacking
    signal dir : std_logic;
    -- Sawtooth amplitude
    signal sawamp : amp_lvl_t;
    -- Hold level, '1' is max amplitude, '0' is silence
    signal holdlvl : std_logic;
    -- Hold amplitude
    signal holdamp : amp_lvl_t;
    -- Continuation amplitude
    signal contamp : amp_lvl_t;
begin

    -- '1' if in the first Envelope Period, '0' otherwise
    first <= '1' when env_phase(5 downto 4) = "00" else '0';
    -- Bit 0 of Envelope period (0 for first period, 1 for second, etc. )
    eper0 <= env_phase(4);

    -- Direction of sawtooth in this Envelope Period
    --
    -- Attack flips around the direction
    -- If alternate is set, directions switches every EP
    -- '0' is decaying, '1' is attacking
    dir <= attack xor (eper0 and alternate);

    -- Sawtooth amplitude
    sawamp <= env_phase(3 downto 0) when dir = '1'
	else 15 - env_phase(3 downto 0);

    -- If alternate is not set, hold last level, otherwise
    -- hold the reverse
    holdlvl <= attack xor alternate;

    -- Hold amplitude
    holdamp <= "1111" when holdlvl = '1' else "0000";

    -- Current amplitude if in EP > 0
    contamp <= "0000" when continue = '0' else
	holdamp when hold = '1' else
	sawamp;

    -- Output amplitude
    amp <= sawamp when first = '1' else
	contamp;

end env_shape_arch;
