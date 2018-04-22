--
-- AY-819x Common Definitions
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

package common is

    -- Data/address
    subtype daddr_t is unsigned(7 downto 0);
    -- Register array type
    type rarray_t is array(integer range <>) of daddr_t;
    -- AY-3-819x register array
    subtype rarray_psg_t is rarray_t(0 to 17);

    -- AY amplitude level (0 to 15)
    subtype amp_lvl_t is unsigned(3 downto 0);
    -- AY tone period (12 bits)
    subtype tone_period_t is unsigned(11 downto 0);
    -- AY noise period (5 bits)
    subtype noise_period_t is unsigned(4 downto 0);
    -- AY envelope period (16 bits)
    subtype env_period_t is unsigned(15 downto 0);
    -- AY envelope phase (00-0000 to 10-1111)
    subtype env_phase_t is unsigned(5 downto 0);

    -- Envelope shape
    type env_shape_t is record
	continue : std_logic;
	attack : std_logic;
	alternate : std_logic;
	hold : std_logic;
    end record;

end common;
