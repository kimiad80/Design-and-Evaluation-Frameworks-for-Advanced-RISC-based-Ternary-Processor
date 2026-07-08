module Inverter(
		input logic [17:0] inp,
		output logic [17:0] out
	);

	integer i;
	
	always_comb begin
		for (i = 0; i < 9; i = i + 1) begin
			case (inp[2*i +: 2])
				2'b10: out[2*i +: 2] = 2'b01;
				2'b01: out[2*i +: 2] = 2'b10;
				2'b00: out[2*i +: 2] = 2'b00;
			endcase
		end
	end

endmodule
