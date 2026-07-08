module MEM_WB_Reg (
		input logic clk,
		input logic rst,
		input logic [1:0] WE,
		input logic [17:0] MEM_out,
		input logic [3:0] Ta,
		
		output logic [1:0] WE_out,
		output logic [17:0] MEM_out2,
		output logic [3:0] Ta_out
	);
	
	always_ff @(posedge clk, posedge rst) begin
		if (rst == 1'b1) begin
			WE_out <= 2'd0;
			MEM_out2 <= 18'd0;
			Ta_out <= 4'd0;
		end
		else begin
			WE_out <= WE;
			MEM_out2 <= MEM_out;
			Ta_out <= Ta;
		end
	end
	
endmodule