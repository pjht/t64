PROG=prog.vvp
SV_FILES=t64_system.sv
VVP_FILES=$(SV_FILES:.sv=.vvp)
LXT_FILES=$(SV_FILES:.sv=.lxt)
IVFLAGS=-Wall -Wno-sensitivity-entire-array -g2012 -Y .sv -y lib
	
bin/%.vvp: %.sv lib/*.sv Makefile
	iverilog $(IVFLAGS) -o $@ $<

%.lxt: bin/%.vvp Makefile
	vvp $< -lxt2

run: $(LXT_FILES) Makefile
