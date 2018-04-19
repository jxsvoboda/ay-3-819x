#
# AY-3-819x core in VHDL
#
# Copyright 2018 Jiri Svoboda
#
# Permission is hereby granted, free of charge, to any person obtaining 
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
#

GHDL = ghdl
sources_dep = \
	amp_ctl.vhd \
	bcdec.vhd \
	env_gen.vhd \
	env_shape.vhd \
	mixer.vhd \
	noise_gen.vhd \
	psg.vhd \
	regdec.vhd \
	regs.vhd \
	tone_gen.vhd

sources = \
	common.vhd \
	$(sources_dep)

objects_dep = $(sources_dep:.vhd=.o)
objects = $(sources:.vhd=.o)

all: $(objects)

%.o: %.vhd
	$(GHDL) -a $<

$(objects_dep): common.o

clean:
	rm -f $(objects) work-obj93.cf
