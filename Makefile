hwsrcs = $(wildcard hw/*.vhd)
hwobjs = $(hwsrcs:.vhd=.o)
hwvcd = $(wildcard *.vcd)
work = hw
vc = ghdl
vcflags = --ieee=synopsys -fexplicit
hsi = runhaskell
testbench = main_TB
asm = asm/mul.s

assemble: $(asm)
	runhaskell asm/Main.hs $^
	mv instr_mem.vhd hw/instr_mem.vhd

%.o: %.vhd
	$(vc) -a $(vcflags) --workdir=$(work) $^

elab: $(hwobjs)
	$(vc) -e $(vcflags) --workdir=$(work) $(testbench)

run:
	./$(testbench) --vcd=sim.vcd

simulate: elab run

clean:
	rm -rf $(hwobjs)
	rm -rf hw/instr_mem.vhd
	rm -rf *.vcd
	rm -rf *.o
	rm -rf hw/*.cf
	rm -rf $(testbench)