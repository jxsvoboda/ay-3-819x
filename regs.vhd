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
	daddr : inout daddr_t;
	-- Chip select
	ncsel : in std_logic;
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
	-- I/O port A input
	ioa_in : in daddr_t;
	-- I/O port A input
	iob_in : in daddr_t;
	-- I/O port A output
	ioa_out : out daddr_t;
	-- I/O port B output
	iob_out : out daddr_t;
	-- Register array
	rarray_out : out rarray_psg_t
    );
end regs;

architecture regs_arch of regs is

    -- Address is valid
    signal valid_addr : std_logic;
    -- Chip is selected
    signal chipsel: std_logic;
    -- Selected register address
    signal regaddr : unsigned(3 downto 0);
    -- Array of sixteen 8-bit registers
    signal rarray : rarray_psg_t;

    -- I/O port input enable
    signal ien_a : std_logic;
    signal ien_b : std_logic;

begin
    -- High order address bits must be 10-0000 to select chip
    valid_addr <= na9 and not a8 and
	not daddr(7) and not daddr(6) and not daddr(5) and not daddr(4);

    -- Chip is selected and address is valid
    chipsel <= valid_addr and not ncsel;

    -- Register array output
    rarray_out <= rarray;

    -- I/O port input enable
    ien_a <= not rarray(7)(6);
    ien_b <= not rarray(7)(7);

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
	variable do_write : boolean;
    begin
	if rising_edge(clock) and chipsel = '1' and write = '1' then
	    -- If input is enabled then we may not write to I/O registers
	    if regaddr = "10000" then
		do_write := ien_a = '0';
	    elsif regaddr = "10001" then
		do_write := ien_b = '0';
	    else
		do_write := true;
	    end if;

	    if do_write then
		-- Write data to the register
		rarray(to_integer(regaddr)) <= daddr;
	    end if;
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

    -- I/O port input / output
    -- XXX is this supposed to be synchronous or asynchronous?
    process(clock)
    begin
	if rising_edge(clock) then
	    -- I/O port A
	    if ien_a = '1' then
		-- Read input to R16
		rarray(16) <= ioa_in;
		-- Provide internal pull-up on all pins
		ioa_out <= (others => 'H');
	    else
		ioa_out <= rarray(16);
	    end if;

	    -- I/O port B
	    if ien_b = '1' then
		-- Read input to R17
		rarray(17) <= iob_in;
		-- Provide internal pull-up on all pins
		ioa_out <= (others => 'H');
	    else
		ioa_out <= rarray(17);
	    end if;
	end if;
    end process;

end regs_arch;
