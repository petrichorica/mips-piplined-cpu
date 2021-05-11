cpu : InstructionRAM.v ID.v control.v alu.v MainMemory.v WB.v forwarding.v forwarding_id.v hazard_detection.v pc_src.v jump.v pipline.v pipline_test.v
	iverilog -o cpu InstructionRAM.v ID.v control.v alu.v MainMemory.v WB.v forwarding.v forwarding_id.v hazard_detection.v pc_src.v jump.v pipline.v pipline_test.v
clean :
	rm -rf cpu