module IF (
		input logic clk,
		input logic rst,
		input logic [17:0] Br_Target, JALR_Target,
		input logic [1:0] Branch, PC_Control, PC_sel,
		
		output logic [17:0] curr_pc
	);
		
	logic [17:0] next_pc, curr1_pc;
	
	PC_Generator pc_generator (curr_pc, Br_Target, Branch, next_pc);
	Register pc_reg (clk, rst, PC_Control, next_pc, curr1_pc);
	
	assign curr_pc = (PC_sel == 2'b01) ? JALR_Target : curr1_pc;
	
endmodule