AY-3-819x in VHDL
=================
Copyright 2018 Jiri Svoboda

This is an attempt to create a design compatible with the AY-3-819x
programmable sound generator in synthesizable VHDL.

Compiling
---------
You need Linux or similar OS with GHDL and GNU Make.
Simply type:

    $ make

This builds all the units and the test binaries.

Running tests
-------------
Simply run the individual test_xxx binaries. Typically, the output must
be verified manually for correctness.

Synthesizing
------------
I haven't attempted to synthesize the design yet. There is more than 100
bits worth of registers so if you are targeting a CPLD, it would have to
be a pretty big one.

The top level unit is psg (in psg.vhd). It should allow synthesizing
a signal-compatible circuit to the original AY-3-819x, except that
it does not provide analog outputs. Instead it provides digital volume
level and polarity for each channel. I am looking into whether it is
possible to provide PWM output as well.

TODO
----
Register file test bench
PSG test bench
IOR playback
