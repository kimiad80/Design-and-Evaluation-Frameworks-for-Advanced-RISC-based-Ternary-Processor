module Register (
		input logic clk, rst,
		input logic [1:0] enable, 
		input logic[17:0] In, 
		
		output logic [17:0] Out
	);

	always_ff @(posedge clk, posedge rst) begin
		if (rst == 1'b1)
			Out <= 18'b101010101010101010;
		else if (enable == 2'b01) begin
			Out <= In;
		end
	end

endmodule