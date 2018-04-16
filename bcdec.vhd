--
-- AY-819x Bus Control Decode
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

entity bcdec is
    port (
	-- Bus direction
	bdir : in std_logic;
	-- Bus Control 2
	bc2 : in std_logic;
	-- Bus Control 1
	bc1 : in std_logic;
	-- Address latch
	alatch : out std_logic;
	-- Write to PSG
	write : out std_logic;
	-- Read from PSG
	read : out std_logic
    );
end bcdec;

architecture bcdec_arch of bcdec is
begin

    -- Address latch
    alatch <=
	-- 0 0 0
	(not bdir and not bc2 and     bc1) or
	-- 1 0 0
	(    bdir and not bc2 and not bc1) or
	-- 1 1 1
	(    bdir and     bc2 and     bc1);

    -- Write to PSG
    write <=
	-- 1 1 0
	(    bdir and     bc2 and not bc1);

    -- Read from PSG
    read <=
	-- 0 1 1
	(not bdir and     bc2 and     bc1);

    -- Inactive
	-- 0 0 0
	-- 0 1 0
	-- 1 0 1

end bcdec_arch;
