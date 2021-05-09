cpu : InstructionRAM.v ID.v control.v alu.v MainMemory.v WB.v hazard.v pipline.v pipline_test.v
	iverilog -o cpu InstructionRAM.v ID.v control.v alu.v MainMemory.v WB.v hazard.v pipline.v pipline_test.v
clean :
	rm -rf cpu