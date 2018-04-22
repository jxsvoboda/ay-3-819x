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
	daddr : inout unsigned(7 downto 0);
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
	ioa : inout unsigned(7 downto 0);
	-- Input/output B
	iob : inout unsigned(7 downto 0);
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
    signal noise_period : unsigned(4 downto 0);

    -- Tone generator A output
    signal tone_a : std_logic;
    -- Tone period A
    signal tone_period_a : unsigned(11 downto 0);

    -- Tone generator B output
    signal tone_b : std_logic;
    -- Tone period C
    signal tone_period_b : unsigned(11 downto 0);

    -- Tone generator C output
    signal tone_c : std_logic;
    -- Tone period C
    signal tone_period_c : unsigned(11 downto 0);

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

    -- Channel A Envelope Period
    signal env_period_a : unsigned(15 downto 0);
    -- Channel A Continue Envelope
    signal continue_a : std_logic;
    -- Channel A Attack Envelope
    signal attack_a : std_logic;
    -- Channel A Alternate Envelope
    signal alternate_a : std_logic;
    -- Channel A Hold Envelope
    signal hold_a : std_logic;
    -- Channel A Envelope
    signal env_a : unsigned(3 downto 0);

    -- Channel B Envelope Period
    signal env_period_b : unsigned(15 downto 0);
    -- Channel B Continue Envelope
    signal continue_b : std_logic;
    -- Channel B Attack Envelope
    signal attack_b : std_logic;
    -- Channel B Alternate Envelope
    signal alternate_b : std_logic;
    -- Channel B Hold Envelope
    signal hold_b : std_logic;
    -- Channel B Envelope
    signal env_b : unsigned(3 downto 0);

    -- Channel C Envelope Period
    signal env_period_c : unsigned(15 downto 0);
    -- Channel C Continue Envelope
    signal continue_c : std_logic;
    -- Channel C Attack Envelope
    signal attack_c : std_logic;
    -- Channel C Alternate Envelope
    signal alternate_c : std_logic;
    -- Channel C Hold Envelope
    signal hold_c : std_logic;
    -- Channel C Envelope
    signal env_c : unsigned(3 downto 0);

    -- Channel A output amplitude
    signal amp_a : unsigned(3 downto 0);
    -- Channel B output amplitude
    signal amp_b : unsigned(3 downto 0);
    -- Channel C output amplitude
    signal amp_c : unsigned(3 downto 0);

    -- Channel A envelope mode
    signal eg_mode_a : std_logic;
    -- Channel B envelope mode
    signal eg_mode_b : std_logic;
    -- Channel C envelope mode
    signal eg_mode_c : std_logic;

    -- Channel A fixed amplitude level
    signal amp_lvl_a : unsigned(3 downto 0);
    -- Channel B fixed amplitude level
    signal amp_lvl_b : unsigned(3 downto 0);
    -- Channel C fixed amplitude level
    signal amp_lvl_c : unsigned(3 downto 0);

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
	    amp_lvl : in unsigned(3 downto 0);
	    -- From envelope generator
	    eg_lvl : in unsigned(3 downto 0);
	    -- To D/A converter
	    output : out unsigned(3 downto 0)
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
	    env_period : in unsigned(15 downto 0);
	    -- From Envelope Shapy/Cycle Control Register
	    continue : in std_logic;
	    -- From Envelope Shapy/Cycle Control Register
	    attack : in std_logic;
	    -- From Envelope Shapy/Cycle Control Register
	    alternate : in std_logic;
	    -- From Envelope Shapy/Cycle Control Register
	    hold : in std_logic;
	    -- To amplitude control
	    output : out unsigned(3 downto 0)
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
	    noise_period : in unsigned(4 downto 0);
	    -- To mixer
	    output : out std_logic
	);
    end component;

    component regdec is
        port (
	    -- Raw register array
	    rarray : in rarray_psg_t;
	    -- Noise Period
	    noise_period : out unsigned(4 downto 0);
	    -- Channel A Tone Period
	    tone_period_a : out unsigned(11 downto 0);
	    -- Channel B Tone Period
	    tone_period_b : out unsigned(11 downto 0);
	    -- Channel C Tone Period
	    tone_period_c : out unsigned(11 downto 0);
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
	    amp_lvl_a : out unsigned(3 downto 0);
	    -- Channel B fixed amplitude level
	    amp_lvl_b : out unsigned(3 downto 0);
	    -- Channel C fixed amplitude level
	    amp_lvl_c : out unsigned(3 downto 0);
	    -- I/O port A input enable
	    ien_a : out std_logic;
	    -- I/O port B input enable
	    ien_b : out std_logic
	);
    end component;

    component regs is
	port (
	    -- Clock
	    clock : in std_logic;
	    -- Data/adress
	    daddr : inout unsigned(7 downto 0);
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
	    tone_period : in unsigned(11 downto 0);
	    -- To mixer
	    output : out std_logic
	);
    end component;

begin

    -- Channel A amplitude control
    amp_ctl_a : amp_ctl port map (
	eg_mode => eg_mode_a,
	amp_lvl => amp_lvl_a,
	eg_lvl => env_a,
	output => amp_a
    );

    -- Channel B amplitude control
    amp_ctl_b : amp_ctl port map (
	eg_mode => eg_mode_b,
	amp_lvl => amp_lvl_b,
	eg_lvl => env_b,
	output => amp_b
    );

    -- Channel C amplitude control
    amp_ctl_c : amp_ctl port map (
	eg_mode => eg_mode_c,
	amp_lvl => amp_lvl_c,
	eg_lvl => env_c,
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

    env_gen_a : env_gen port map (
	clock => clock,
	reset => reset,
	env_period => env_period_a,
	continue => continue_a,
	attack => attack_a,
	alternate => alternate_a,
	hold => hold_a,
	output => env_a
    );

    env_gen_b : env_gen port map (
	clock => clock,
	reset => reset,
	env_period => env_period_b,
	continue => continue_b,
	attack => attack_b,
	alternate => alternate_b,
	hold => hold_b,
	output => env_b
    );

    env_gen_c : env_gen port map (
	clock => clock,
	reset => reset,
	env_period => env_period_c,
	continue => continue_c,
	attack => attack_c,
	alternate => alternate_c,
	hold => hold_c,
	output => env_c
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
