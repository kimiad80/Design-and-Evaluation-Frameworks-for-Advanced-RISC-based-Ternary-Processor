module Instruction_Decoder (
		input logic [17:0] Inst,
		input logic [1:0] HDU_stall, cond,
		
		output logic [3:0] Ta, Tb, TALU_sel,
		output logic [17:0] imm,
		output logic [1:0] funct, sel_a, sel_b, mem_sel, mem_load, mem_write,
               		     PC_sel_JALR, WE_WB, Branch_Taken, stall_out
	);
	logic [1:0] stall;
	
	always_comb begin
		Ta = Inst[3:0];
		Tb = 4'b00_00;
		{WE_WB, mem_sel, mem_load, mem_write, Branch_Taken, stall, stall_out, PC_sel_JALR} = 16'b00_00_00_00_00_00_00_00;
		case(Inst[17:14]) 
			4'b10_10:	begin // -4 R-type Instructions
						mem_sel = 2'b00;
						Tb = Inst[7:4];
						sel_a = 2'b10;
						sel_b = 2'b10;
						case (Inst[13:10])
							4'b10_10:	begin // PTI (2'b10), NTI (2'b00), STI (2'b01)
											funct = Inst[9:8];
											TALU_sel = 4'b00_01;
											WE_WB = 2'b01;
										end
							4'b10_00:	begin // AND (2'b10), OR (2'b00), XOR (2'b01)
											funct = Inst[9:8];
											TALU_sel = 4'b10_01;
											WE_WB = 2'b01;
										end
							4'b10_01:	begin // SR, SL, COMP
										case (Inst[9:8])
											2'b10:	begin // SR
													WE_WB = 2'b01;
													TALU_sel = 4'b00_00;
													funct = Inst[9:8];
												end
											2'b00:	begin // SL
													WE_WB = 2'b01;
													TALU_sel = 4'b00_00;
													funct = Inst[9:8];
												end
											2'b01: begin // COMP
													TALU_sel = 4'b00_10;
													sel_a = 2'b10;
													sel_b = 2'b10;
												end
										endcase
									end
							4'b00_10:	begin // MV, ADD, SUB
										case (Inst[9:8])
											2'b10:	begin // MV
													sel_a = 2'b01;
													WE_WB = 2'b01;
													TALU_sel = 4'b10_00;
													imm = 18'd0;
												end
											2'b00:	begin // ADD
													WE_WB = 2'b01;
													TALU_sel = 4'b10_00;
												end
											2'b01: begin // SUB
													sel_b = 2'b00;
													WE_WB = 2'b01;
													TALU_sel = 4'b10_00;
													// TRF[Ra] + STI(TRF[Rb]) =  TRF[Ra] - (TRF[Rb])
												end
										endcase
									end
						endcase
					end
			4'b10_00:	begin // -3
						case (Inst[13:12])
							2'b10:	begin // ANDI, ADDI
									sel_a = 2'b10;
									sel_b = 2'b01;
									imm = {12'd0, Inst[9:4]};
									mem_sel = 2'b00;
									WE_WB = 2'b01;
									case (Inst[11:10])
										2'b10:	begin // ANDI
												funct = Inst[11:10];
												TALU_sel = 4'b10_01;
											end
										2'b00:	begin // ADDI
												TALU_sel = 4'b10_00;
											end
									endcase
								end
							2'b00: begin // SRI (2'b10), SLI (2'b00)
									sel_a = 2'b10;
									sel_b = 2'b01;
									imm = {14'd0, Inst[7:4]};
									funct = Inst[11:10];
									TALU_sel = 4'b00_00;
									mem_sel = 2'b00;
									WE_WB = 2'b01;
								end
							2'b01:	begin // LUI
									imm = {Inst[11:4], 10'd0};
									WE_WB = 2'b01;
									TALU_sel = 4'b10_10;
									mem_sel = 2'b00;
								end
						endcase
					end
			4'b10_01: 	begin // -2 -> LI 
						imm = {8'd0, Inst[13:4]};
						sel_a = 2'b00;
						sel_b = 2'b01;
						TALU_sel = 4'b10_00;
						WE_WB = 2'b01;
						mem_sel = 2'b00;
					end
			4'b00_10: 	begin // -1 -> BEQ
						imm = {10'd0, Inst[13:6]};
						if (cond == 2'b00) begin
							Branch_Taken = 2'b01;
							stall = 2'b01; // NOP
						end
					end
			4'b00_00:  begin // 0 -> BNE
						imm = {10'd0, Inst[13:6]};
						if (~(cond == 2'b00)) begin
							Branch_Taken = 2'b01;
							stall = 2'b01; // NOP
						end
					end
			4'b00_01:  begin // 1 -> JAL
						imm = {8'd0, Inst[13:4]};
						Branch_Taken = 2'b01;
						stall = 2'b01; // NOP
						mem_sel = 2'b01;
						WE_WB = 2'b01;
					end
			4'b01_10:  begin // 2 -> JALR
						Tb = Inst[7:4];
						imm = {12'd0, Inst[13:8]};
						//Branch_Taken = 2'b01;
						stall = 2'b01; // NOP
						mem_sel = 2'b01;
						WE_WB = 2'b01;
						
						sel_a = 2'b01;
						sel_b = 2'b10;
						TALU_sel = 4'b10_00;
						PC_sel_JALR = 2'b01;
					end
			4'b01_00:  begin // 3 -> LOAD
						Tb = Inst[7:4];
						imm = {12'd0, Inst[13:8]};
						WE_WB = 2'b01;
						sel_a = 2'b01;
						sel_b = 2'b10;
						TALU_sel = 4'b10_00;
						mem_sel = 2'b10;
						mem_load = 2'b01; // Read
					end
			4'b01_01:  begin // 4 -> STORE
						Tb = Inst[7:4];
						imm = {12'd0, Inst[13:8]};
						sel_a = 2'b01;
						sel_b = 2'b10;
						TALU_sel = 4'b10_00;
						mem_write = 2'b01; // Write
					end
		endcase
		
		stall_out = ((HDU_stall == 2'b01) | (stall == 2'b01)) ? 2'b01 : 2'b00;
    end
endmodule