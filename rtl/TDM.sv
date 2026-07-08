module TDM (
		input logic clk,
		input logic [17:0] Data_in,
		input logic [17:0] address,
		input logic[1:0] mem_load, mem_write,
		
		output logic [17:0] Data_out
	);

	logic [17:0] mem [1023:0];
	
	logic [31:0] decimal;
	integer i;
	logic signed [31:0] weighted_value;
	logic signed [1:0] trit_value;
	
	always_comb begin
		decimal = 32'd0;
		for (i = 0; i < 9; i = i + 1) begin
			case (address[2*i +: 2])
				2'b00: trit_value = 0;   // Trit value is 0
				2'b01: trit_value = 1;   // Trit value is 1
				2'b10: trit_value = -1;  // Trit value is -1
				default: trit_value = 0;
			endcase

			weighted_value = trit_value * (3 ** i);
			decimal = decimal + weighted_value;
		end
	end

	// Synchronous Read
	always_ff @(posedge clk) begin
		if (mem_load == 2'b01)
			Data_out <= mem[decimal];
		else if (mem_write == 2'b01) 
			mem[decimal] <= Data_in;
	end
	
endmodule