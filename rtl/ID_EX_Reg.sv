module ID_EX_Reg (
		input logic clk,
		input logic rst,
		input logic [17:0] imm, PC, TRFTa, TRFTb, out_WB,
		input logic [3:0] Ta,
		input logic [19:0] control,
		input logic [7:0] HDU_Out,
		
		output logic [17:0] imm_out, PC_out, TRFTa_out, TRFTb_out, out_WB_reg,
		output logic [3:0] Ta_out,
		output logic [19:0] control_out,
		output logic [7:0] HDU_Out2
	);
	
	always_ff @(posedge clk, posedge rst) begin
		if (rst == 1'b1) begin
			imm_out <= 18'd0;
			PC_out <=18'd0;
			TRFTa_out <= 18'd0;
			TRFTb_out <= 18'd0;
			Ta_out <= 4'd0;
			control_out <= 18'd0;
			HDU_Out2 <= 8'd0;
			out_WB_reg <= 18'd0;
		end
		else begin
			imm_out <= imm;
			PC_out <= PC;
			TRFTa_out <= TRFTa;
			TRFTb_out <= TRFTb;
			Ta_out <= Ta;
			control_out <= control;
			HDU_Out2 <= HDU_Out;
			out_WB_reg <= out_WB;
		end
	end
	
endmodule