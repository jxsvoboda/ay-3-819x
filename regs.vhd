--
-- AY-819x Registers
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

--
-- This module/entity covers
--   - the register array
--   - bi-directional buffers
--   - register address latch/decoder
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.common.all;

entity regs is
    port (
	-- Clock
	clock : in std_logic;
	-- Data/adress
	daddr : inout unsigned(7 downto 0);
	-- Address latch
	alatch : in std_logic;
	-- Write data
	write : in std_logic;
	-- Read data
	read : in std_logic;
	-- nA9
	na9 : in std_logic;
	-- A8
	a8 : in std_logic;
	-- Register array
	rarray_out : out rarray_type(0 to 15)
    );
end regs;

architecture regs_arch of regs is

    -- Chip select
    signal chipsel : std_logic;
    -- Selected register address
    signal regaddr : unsigned(3 downto 0);
    -- Array of sixteen 8-bit registers
    signal rarray : rarray_type(0 to 15);

begin
    -- High order address bits must be 10-0000 to select chip
    chipsel <= na9 and not a8 and
	not daddr(7) and not daddr(6) and not daddr(5) and not daddr(4);

    rarray_out <= rarray;

    -- Address latching
    -- XXX is this supposed to be synchronous or asynchronous?
    process(clock)
    begin
	if rising_edge(clock) and chipsel = '1' and alatch = '1' then
	    -- Latch the address
	    regaddr <= daddr(3 downto 0);
	end if;
    end process;

    -- Writing data
    -- XXX is this supposed to be synchronous or asynchronous?
    process(clock)
    begin
	if rising_edge(clock) and chipsel = '1' and write = '1' then
	    -- Write data to the register
	    rarray(to_integer(regaddr)) <= daddr;
	end if;
    end process;

    -- Reading data
    -- XXX is this supposed to be synchronous or asynchronous?
    process(clock)
    begin
	if rising_edge(clock) then
	    if chipsel = '1' and read = '1' then
		    -- Read data from the register
		    daddr <= rarray(to_integer(regaddr));
	    else
		    -- Stop driving daddr
		    daddr <= (others => 'Z');
	    end if;
	end if;
    end process;

end regs_arch;
