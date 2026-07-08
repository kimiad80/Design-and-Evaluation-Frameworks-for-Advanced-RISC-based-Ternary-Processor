module IF_ID_Reg (
		input logic clk,
		input logic rst,
		input logic [1:0] in_stall,
		input logic[17:0] PC_in,
		
		output logic [1:0] out_stall,
		output logic [17:0] PC_out
	);
	
	always_ff @(posedge clk, posedge rst) begin
		if (rst == 1'b1) begin
			out_stall <= 2'b00;
			PC_out <= 18'd9841;
		end
		else begin
			out_stall <= in_stall;
			PC_out <= PC_in;
		end
	end
	
endmodule