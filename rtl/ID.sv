module ID (
		input logic clk, rst,
		input logic [1:0] inp_stall_control, cond_TALU, WE_EX, WE_MEM, WE_WB, mem_load_EX,
		input logic [17:0] instruction, TALU_MEM, out_WB, Data_WB, PC,
		input logic [3:0] Ra_EX, Ra_MEM, Ra_WB,
		
		output logic [1:0] out_stall_control, PC_sel_JALR, pc_control, funct, sel_a, sel_b,
					 mem_sel, mem_load, mem_write, WE_WB_out, Branch_Taken,
		output logic [17:0] TRFTa, TRFTb, imm, Branch_Target_Addr, B_ID, TbBranch,
		output logic [3:0] Ta_out, fwd_sel1, fwd_sel2, TALU_sel
	);
	
	logic [17:0] Inst;
	logic [3:0] Ta, Tb;
	logic [1:0] forwarded_value, stall_control, Branch_sel, B;
	logic [1:0] Branch_TRFTb;
	
	// NOP is defined as ADDI by zero
	logic [17:0] NOP;
	assign NOP = 18'b10_00_10_00_00_00_00_10_10;
	
	assign Inst = (inp_stall_control == 2'b01) ? NOP : instruction;
	assign B = Inst[5:4];
		
	Instruction_Decoder inst_decoder (
			.Inst (Inst),
			.HDU_stall (stall_control),
			.cond (cond_TALU),
			.Ta (Ta),
			.Tb (Tb),
			.TALU_sel (TALU_sel),
			.imm (imm),
			.funct (funct),
			.sel_a (sel_a),
			.sel_b (sel_b),
			.mem_sel (mem_sel),
			.mem_load (mem_load),
			.mem_write (mem_write),
			.PC_sel_JALR (PC_sel_JALR),
			.WE_WB (WE_WB_out),
			.Branch_Taken (Branch_Taken),
			.stall_out (out_stall_control)
			);
	
	Hazard_Detection_Unit hdu (
			.Ta (Ta),
			.Tb (Tb),
			.Ra_EX (Ra_EX),
			.WE_EX (WE_EX),
			.Ra_MEM (Ra_MEM),
			.WE_MEM (WE_MEM),
			.Ra_WB (Ra_WB),
			.WE_WB (WE_WB),
			.load_en_EX (mem_load_EX),
			.sel1 (fwd_sel1),
			.sel2 (fwd_sel2),
			.Branch_sel (Branch_sel),
			.stall_control (stall_control),
			.pc_control (pc_control)
			);
	
	TRF trf (
			.clk (clk),
			.rst (rst),
			.Ta (Ta),
			.Tb (Tb),
			.write_addr (Ra_WB),
			.write_data (Data_WB),
			.WE_WB (WE_WB),
			.TRFTa (TRFTa),
			.TRFTb (TRFTb)
			);
	
	Branch_Target_Calculator btc (
			.PC (PC),
			.imm (imm),
			.B (B),
			.Tb0 (Branch_TRFTb),
			
			.B17 (B_ID),
			.TbBranch (TbBranch),
			.Branch_Target (Branch_Target_Addr)
			);
	
	assign Ta_out = Ta;
	
	always_comb begin
		case (Branch_sel)
			2'b10: Branch_TRFTb = TRFTb[1:0];
			2'b00: Branch_TRFTb = TALU_MEM[1:0];
			2'b01: Branch_TRFTb = out_WB[1:0];
		endcase
	end
endmodule