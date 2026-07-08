module EX (
		input logic [17:0] TRFTa_EX, TRFTb_EX, out_MEM, out_WB, out_WB_reg, imm, B_ID, Tb0,
		input logic [3:0] inp1_sel, inp2_sel, TALU_sel,
		input logic [1:0] TRFTb_ID_lst, sel_a, sel_b, funct,
		
		output logic [17:0] TRFTa_EX_fwd, TALU_Out
	);
	
	logic [17:0] inp1, inp2;
	
	TALU talu (
			.TRFRa (inp1),
			.TRFRb (inp2),
			.imm (imm),
			.sel_a (sel_a),
			.sel_b (sel_b),
			.funct (funct),
			.sel (TALU_sel),
			.Out (TALU_Out)
			);
	
	always_comb begin
		if (TALU_sel == 4'b00_10) begin
			inp2 = B_ID;
			inp1 = Tb0;
		end
		else begin
			case (inp2_sel)
				4'b01_01: inp2 = TRFTb_EX;
				4'b00_10: inp2 = B_ID;
				4'b10_01: inp2 = out_MEM;
				4'b10_00: inp2 = out_WB;
				4'b10_10: inp2 = out_WB_reg;
			endcase
			
			case (inp1_sel)
				4'b01_01: inp1 = TRFTa_EX;
				4'b00_10: inp1 = Tb0;
				4'b10_01: inp1 = out_MEM;
				4'b10_00: inp1 = out_WB;
				4'b10_10: inp1 = out_WB_reg;
			endcase
		end
	end
	
	assign TRFTa_EX_fwd = inp1;
	
endmodule