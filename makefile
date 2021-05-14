cpu : InstructionRAM.v ID.v control.v alu.v MainMemory.v WB.v forwarding_alu.v forwarding_id.v hazard_detection.v pc_src.v jump.v pipeline.v pipeline_test.v
	iverilog -o cpu InstructionRAM.v ID.v control.v alu.v MainMemory.v WB.v forwarding_alu.v forwarding_id.v hazard_detection.v pc_src.v jump.v pipeline.v pipeline_test.v
clean :
	rm -rf cpu