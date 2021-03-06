--
-- AY-819x Register Decoding
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
-- Decode individual fields from the register array
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.common.all;

entity regdec is
    port (
	-- Raw register array
	rarray : in rarray_psg_t;
	-- Noise Period
	noise_period : out noise_period_t;
	-- Channel A Tone Period
	tone_period_a : out tone_period_t;
	-- Channel B Tone Period
	tone_period_b : out tone_period_t;
	-- Channel C Tone Period
	tone_period_c : out tone_period_t;
	-- Channel A noise enable
	noise_enable_a : out std_logic;
	-- Channel B noise enable
	noise_enable_b : out std_logic;
	-- Channel C noise enable
	noise_enable_c : out std_logic;
	-- Channel A tone enable
	tone_enable_a : out std_logic;
	-- Channel B tone enable
	tone_enable_b : out std_logic;
	-- Channel C tone enable
	tone_enable_c : out std_logic;
	-- Channel A envelope mode
	eg_mode_a : out std_logic;
	-- Channel B envelope mode
	eg_mode_b : out std_logic;
	-- Channel C envelope mode
	eg_mode_c : out std_logic;
	-- Channel A fixed amplitude level
	amp_lvl_a : out amp_lvl_t;
	-- Channel B fixed amplitude level
	amp_lvl_b : out amp_lvl_t;
	-- Channel C fixed amplitude level
	amp_lvl_c : out amp_lvl_t;
	-- I/O port A input enable
	ien_a : out std_logic;
	-- I/O port B input enable
	ien_b : out std_logic;
	-- Envelope Period
	env_period : out env_period_t;
	-- Continue envelope
	shape : out env_shape_t
    );
end regdec;

architecture regdec_arch of regdec is

begin

    noise_period <= rarray(6)(4 downto 0);

    tone_period_a <= rarray(1)(3 downto 0) & rarray(0)(7 downto 0);
    tone_period_b <= rarray(3)(3 downto 0) & rarray(2)(7 downto 0);
    tone_period_c <= rarray(5)(3 downto 0) & rarray(4)(7 downto 0);

    noise_enable_a <= not rarray(7)(3);
    noise_enable_b <= not rarray(7)(4);
    noise_enable_c <= not rarray(7)(5);

    tone_enable_a <= not rarray(7)(0);
    tone_enable_b <= not rarray(7)(1);
    tone_enable_c <= not rarray(7)(2);

    ien_a <= not rarray(7)(6);
    ien_b <= not rarray(7)(7);

    eg_mode_a <= rarray(10)(4);
    eg_mode_b <= rarray(11)(4);
    eg_mode_c <= rarray(12)(4);

    amp_lvl_a <= rarray(10)(3 downto 0);
    amp_lvl_b <= rarray(11)(3 downto 0);
    amp_lvl_c <= rarray(12)(3 downto 0);

    env_period <= rarray(14) & rarray(13);

    shape.continue <= rarray(15)(3);
    shape.attack <= rarray(15)(2);
    shape.alternate <= rarray(15)(1);
    shape.hold <= rarray(15)(0);

end regdec_arch;
