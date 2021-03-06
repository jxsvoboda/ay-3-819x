--
-- AY-819x PSG
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

entity psg is
    port (
	-- Data/address
	daddr : inout daddr_t;
        -- nA9
	na9 : in std_logic;
	-- A8
	a8 : in std_logic;
	-- Clock signal
	clock : in std_logic;
	-- Reset signal
	reset : in std_logic;
	-- Bus direction
	bdir : in std_logic;
	-- Bus Control 2
	bc2 : in std_logic;
	-- Bus Control 1
	bc1 : in std_logic;
	-- XXX Analog channels A, B, C
	-- Input/output A
	ioa : inout daddr_t;
	-- Input/output B
	iob : inout daddr_t;
	-- Chip select
	ncsel : in std_logic
    );
end psg;

architecture psg_arch of psg is

    -- Latch address
    signal alatch : std_logic;
    -- Read data
    signal read : std_logic;
    -- Write data
    signal write : std_logic;

    -- Noise generator output
    signal noise : std_logic;

    -- Noise period
    signal noise_period : noise_period_t;

    -- Tone generator A output
    signal tone_a : std_logic;
    -- Tone period A
    signal tone_period_a : tone_period_t;

    -- Tone generator B output
    signal tone_b : std_logic;
    -- Tone period C
    signal tone_period_b : tone_period_t;

    -- Tone generator C output
    signal tone_c : std_logic;
    -- Tone period C
    signal tone_period_c : tone_period_t;

    -- Channel A noise enable
    signal noise_enable_a : std_logic;

    -- Channel B noise enable
    signal noise_enable_b : std_logic;

    -- Channel C noise enable
    signal noise_enable_c : std_logic;

    -- Channel A tone enable
    signal tone_enable_a : std_logic;

    -- Channel B tone enable
    signal tone_enable_b : std_logic;

    -- Channel C tone enable
    signal tone_enable_c : std_logic;

    -- Mixed channel A
    signal mix_a : std_logic;

    -- Mixed channel B
    signal mix_b : std_logic;

    -- Mixed channel C
    signal mix_c : std_logic;

    -- Envelope Period
    signal env_period : env_period_t;
    -- Envelope shape
    signal shape : env_shape_t;
    -- Envelope
    signal env : amp_lvl_t;

    -- Channel A output amplitude
    signal amp_a : amp_lvl_t;
    -- Channel B output amplitude
    signal amp_b : amp_lvl_t;
    -- Channel C output amplitude
    signal amp_c : amp_lvl_t;

    -- Channel A envelope mode
    signal eg_mode_a : std_logic;
    -- Channel B envelope mode
    signal eg_mode_b : std_logic;
    -- Channel C envelope mode
    signal eg_mode_c : std_logic;

    -- Channel A fixed amplitude level
    signal amp_lvl_a : amp_lvl_t;
    -- Channel B fixed amplitude level
    signal amp_lvl_b : amp_lvl_t;
    -- Channel C fixed amplitude level
    signal amp_lvl_c : amp_lvl_t;

    -- Register array
    signal rarray : rarray_psg_t;

    -- I/O port A input enable
    signal ien_a : std_logic;
    -- I/O port B input enable
    signal ien_b : std_logic;

    component amp_ctl is
	port (
	    -- From amplitude control register
	    eg_mode : in std_logic;
	    -- From amplitude control register
	    amp_lvl : in amp_lvl_t;
	    -- From envelope generator
	    eg_lvl : in amp_lvl_t;
	    -- To D/A converter
	    output : out amp_lvl_t
	);
    end component;

    component bcdec is
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
    end component;

    component env_gen is
	port (
	    -- Clock signal
	    clock : in std_logic;
	    -- Reset signal
	    reset : in std_logic;
	    -- From Envelope Coarse/Fine Tune Registers
	    env_period : in env_period_t;
	    -- From Envelope Shapy/Cycle Control Register
	    shape : in env_shape_t;
	    -- To amplitude control
	    output : out amp_lvl_t
	);
    end component;

    component mixer is
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
    end component;

    component noise_gen is
	port (
	    -- Clock signal
	    clock : in std_logic;
	    -- Reset signal
	    reset : in std_logic;
	    -- From noise generator control register
	    noise_period : in noise_period_t;
	    -- Counter value (for debugging)
	    cnt : out noise_period_t;
	    -- To mixer
	    output : out std_logic
	);
    end component;

    component regdec is
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
	    -- Envelope shape
	    shape : out env_shape_t
	);
    end component;

    component regs is
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
	    -- Register array output
	    rarray_out : out rarray_psg_t
	);
    end component;

    component tone_gen is
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
    end component;

begin

    -- Channel A amplitude control
    amp_ctl_a : amp_ctl port map (
	eg_mode => eg_mode_a,
	amp_lvl => amp_lvl_a,
	eg_lvl => env,
	output => amp_a
    );

    -- Channel B amplitude control
    amp_ctl_b : amp_ctl port map (
	eg_mode => eg_mode_b,
	amp_lvl => amp_lvl_b,
	eg_lvl => env,
	output => amp_b
    );

    -- Channel C amplitude control
    amp_ctl_c : amp_ctl port map (
	eg_mode => eg_mode_c,
	amp_lvl => amp_lvl_c,
	eg_lvl => env,
	output => amp_c
    );

    -- Bus Control Decode
    bcdec_i : bcdec port map (
	bdir => bdir,
	bc2 => bc2,
	bc1 => bc1,
	alatch => alatch,
	write => write,
	read => read
    );

    -- Envelope Generator
    env_gen_i : env_gen port map (
	clock => clock,
	reset => reset,
	env_period => env_period,
	shape => shape,
	output => env
    );

    mixer_a : mixer port map (
	noise_enable => noise_enable_a,
	noise => noise,
	tone_enable => tone_enable_a,
	tone => tone_a,
	output => mix_a
    );

    mixer_b : mixer port map (
	noise_enable => noise_enable_b,
	noise => noise,
	tone_enable => tone_enable_b,
	tone => tone_b,
	output => mix_b
    );

    mixer_c : mixer port map (
	noise_enable => noise_enable_c,
	noise => noise,
	tone_enable => tone_enable_c,
	tone => tone_c,
	output => mix_c
    );

    noise_gen_i : noise_gen port map (
	clock => clock,
	reset => reset,
	noise_period => noise_period,
	output => noise
    );

    regdec_i : regdec port map(
	rarray => rarray,
	noise_period => noise_period,
	tone_period_a => tone_period_a,
	tone_period_b => tone_period_b,
	tone_period_c => tone_period_c,
	noise_enable_a => noise_enable_a,
	noise_enable_b => noise_enable_b,
	noise_enable_c => noise_enable_c,
	tone_enable_a => tone_enable_a,
	tone_enable_b => tone_enable_b,
	tone_enable_c => tone_enable_c,
	eg_mode_a => eg_mode_a,
	eg_mode_b => eg_mode_b,
	eg_mode_c => eg_mode_c,
	amp_lvl_a => amp_lvl_a,
	amp_lvl_b => amp_lvl_b,
	amp_lvl_c => amp_lvl_c,
	ien_a => ien_a,
	ien_b => ien_b
    );

    regs_i : regs port map (
	clock => clock,
	daddr => daddr,
	ncsel => ncsel,
	alatch => alatch,
	write => write,
	read => read,
	na9 => na9,
	a8 => a8,
	rarray_out => rarray
    );

    tone_gen_a : tone_gen port map (
	    clock => clock,
	    reset => reset,
	    tone_period => tone_period_a,
	    output => tone_a
    );

    tone_gen_b : tone_gen port map (
	    clock => clock,
	    reset => reset,
	    tone_period => tone_period_b,
	    output => tone_b
    );

    tone_gen_c : tone_gen port map (
	    clock => clock,
	    reset => reset,
	    tone_period => tone_period_c,
	    output => tone_c
    );

end psg_arch;
