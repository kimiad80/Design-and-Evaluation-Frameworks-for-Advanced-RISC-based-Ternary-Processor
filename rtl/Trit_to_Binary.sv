module Trit_to_Binary (
		input logic [17:0] trit_in,
		
		output logic [31:0] binary_out
	);
		
	logic [31:0] decimal;
	integer i;
	logic signed [31:0] weighted_value;
	logic signed [1:0] trit_value;
	
	always_comb begin
		decimal = 32'd0;
		for (i = 0; i < 9; i = i + 1) begin
			case (trit_in[2*i +: 2])
				2'b00: trit_value = 0;   // Trit value is 0
				2'b01: trit_value = 1;   // Trit value is 1
				2'b10: trit_value = -1;  // Trit value is -1
				default: trit_value = 0;
			endcase

			weighted_value = trit_value * (3 ** i);
			decimal = (3 ** i) + decimal + weighted_value;
		end
	end
	assign binary_out = decimal;
endmodule