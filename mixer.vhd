--
-- AY-819x Mixer
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

entity mixer is
    port (
	-- From mixer control register
	noise_enable : in std_logic;
	-- From noise generator
	noise : in std_logic;
	-- From mixer control register
	tone_enable : in std_logic;
	-- From tone generator
	tone : in std_logic;
	-- To D/A converter
	output : out std_logic
    );
end mixer;

architecture mixer_arch of mixer is
begin
    output <=
	(noise and noise_enable) xor
	(tone and tone_enable);
end mixer_arch;
