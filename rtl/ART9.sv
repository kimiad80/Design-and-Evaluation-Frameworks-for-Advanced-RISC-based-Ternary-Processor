module ART9 (
		input logic clk,
		input logic rst
	);
	
	logic [17:0] Branch_Target, PC_IF, PC_ID, PC_EX, PC_MEM, Instruction_ID, TRFTa_ID,
				TRFTb_ID, TALU_EX, TRFTa_EX, TRFTa_EX1, TRFTb_EX, Mem_Data, TALU_MEM,
				Data_WB, Data_WB_reg, imm_ID, imm_EX, MEM_out, B_ID, TbBranch;
				
	logic [3:0]	Ta_ID, Ta_EX, Ta_MEM, Ta_WB, TALU_sel_ID, TALU_sel_EX, fwd_sel1_ID,
				fwd_sel2_ID, fwd_sel1_EX, fwd_sel2_EX;
				
	logic [1:0]	WE_ID, WE_WB, funct_ID, sel_a_ID, sel_a_EX, sel_b_ID, sel_b_EX,
				funct_EX, mem_sel_ID, mem_load_ID, mem_write_ID, mem_sel_EX, mem_load_EX,
				mem_write_EX, WE_EX, WE_MEM, mem_sel_MEM, Branch_Taken, PC_Control, stall_IF,
				stall_ID, PC_sel_JALR_ID, PC_sel_JALR_EX;
	
	IF if_stage (
			.clk (clk),
			.rst (rst),
			.Br_Target (Branch_Target),
			.JALR_Target (TALU_EX),
			.Branch (Branch_Taken),
			.PC_Control (PC_Control),
			.PC_sel (PC_sel_JALR_EX),
			.curr_pc (PC_IF)
			);
			
	IF_ID_Reg if_id_reg (
			.clk (clk),
			.rst (rst),
			.in_stall (stall_IF),
			.PC_in (PC_IF),
			.out_stall (stall_ID),
			.PC_out (PC_ID)
			);
	
	TIM tim (
			.clk (clk),
			.address (PC_IF),
			.instruction (Instruction_ID)
			);
	
	ID id_stage (
			.clk (clk),
			.rst (rst),
			.inp_stall_control (stall_ID),
			.cond_TALU (TALU_EX[1:0]),
			.WE_EX (WE_EX),
			.WE_MEM (WE_MEM),
			.WE_WB (WE_WB),
			.mem_load_EX (mem_load_EX),
			.instruction (Instruction_ID),
			.TALU_MEM (MEM_out),
			.out_WB (Data_WB),
			.Data_WB (Data_WB),
			.PC (PC_ID),
			.Ra_EX (Ta_EX),
			.Ra_MEM (Ta_MEM),
			.Ra_WB (Ta_WB),
			.out_stall_control (stall_IF),
			.PC_sel_JALR (PC_sel_JALR_ID),
			.pc_control (PC_Control),
			.funct (funct_ID),
			.sel_a (sel_a_ID),
			.sel_b (sel_b_ID),
			.mem_sel (mem_sel_ID),
			.mem_load (mem_load_ID),
			.mem_write (mem_write_ID),
			.WE_WB_out (WE_ID),
			.Branch_Taken (Branch_Taken),
			.TRFTa (TRFTa_ID),
			.TRFTb (TRFTb_ID),
			.imm (imm_ID),
			.Branch_Target_Addr (Branch_Target),
			.B_ID (B_ID),
			.TbBranch (TbBranch),
			.Ta_out (Ta_ID),
			.fwd_sel1 (fwd_sel1_ID),
			.fwd_sel2 (fwd_sel2_ID),
			.TALU_sel (TALU_sel_ID)
			);
	
	ID_EX_Reg id_ex_reg (
			.clk (clk),
			.rst (rst),
			.imm (imm_ID),
			.PC (PC_IF),
			.TRFTa (TRFTa_ID),
			.TRFTb (TRFTb_ID),
			.out_WB (Data_WB),
			.Ta (Ta_ID),
			.control ({funct_ID, sel_a_ID, sel_b_ID, TALU_sel_ID, mem_sel_ID, mem_load_ID, mem_write_ID, WE_ID, PC_sel_JALR_ID}),
			.HDU_Out ({fwd_sel1_ID, fwd_sel2_ID}),
			.imm_out (imm_EX),
			.PC_out (PC_EX),
			.TRFTa_out (TRFTa_EX),
			.TRFTb_out (TRFTb_EX),
			.out_WB_reg (Data_WB_reg),
			.Ta_out (Ta_EX),
			.control_out ({funct_EX, sel_a_EX, sel_b_EX, TALU_sel_EX, mem_sel_EX, mem_load_EX, mem_write_EX, WE_EX, PC_sel_JALR_EX}),
			.HDU_Out2 ({fwd_sel1_EX, fwd_sel2_EX})
			);
	
	EX ex_stage (
			.TRFTa_EX (TRFTa_EX),
			.TRFTb_EX (TRFTb_EX),
			.out_MEM (MEM_out),
			.out_WB (Data_WB),
			.out_WB_reg (Data_WB_reg),
			.imm (imm_EX),
			.B_ID (B_ID),
			.Tb0 (TbBranch),
			.inp1_sel (fwd_sel1_EX),
			.inp2_sel (fwd_sel2_EX),
			.TALU_sel (TALU_sel_EX),
			.TRFTb_ID_lst (TRFTb_ID[1:0]),
			.sel_a (sel_a_EX),
			.sel_b (sel_b_EX),
			.funct (funct_EX),
			.TRFTa_EX_fwd (TRFTa_EX1),
			.TALU_Out (TALU_EX)
			);
			
	TDM tdm (
			.clk (clk),
			.Data_in (TRFTa_EX1),
			.address (TALU_EX),
			.mem_load (mem_load_EX),
			.mem_write (mem_write_EX),
			.Data_out(Mem_Data)
			);
	
	EX_MEM_Reg ex_mem_reg (
			.clk (clk),
			.rst (rst),
			.WE (WE_EX),
			.mem_sel (mem_sel_EX),
			.TALU_out (TALU_EX),
			.PC (PC_EX),
			.Ta (Ta_EX),
			.WE_out (WE_MEM),
			.TALU_out2 (TALU_MEM),
			.PC_out (PC_MEM),
			.Ta_out (Ta_MEM),
			.mem_sel_out (mem_sel_MEM)
			);
	
	MEM mem_stage (
			.TALU_Out (TALU_MEM),
			.TDM_Out (Mem_Data),
			.PC (PC_MEM),
			.sel (mem_sel_MEM),
			.Data_Out (MEM_out)
			);
	
	MEM_WB_Reg mem_wb_reg (
			.clk (clk),
			.rst (rst),
			.WE (WE_MEM),
			.MEM_out (MEM_out),
			.Ta (Ta_MEM),
			.WE_out(WE_WB),
			.MEM_out2 (Data_WB),
			.Ta_out (Ta_WB)
			);
	

endmodule