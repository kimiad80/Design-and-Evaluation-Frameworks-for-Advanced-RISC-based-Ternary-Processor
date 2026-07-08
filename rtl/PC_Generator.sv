module PC_Generator (
		input logic [17:0] In_PC, Br_Target, 
		input logic [1:0] Branch,
		
		output logic [17:0] Out_PC
	);

	integer i;
	logic carry;
	logic [17:0] PC_Incr;
	logic signed [1:0] trit_in;
	
	always_comb begin
		carry = 1'b1;
		for (i = 0; i < 9; i = i + 1) begin
			case (In_PC[2*i +: 2])
				2'b00: trit_in = 2'b00; // 0
				2'b01: trit_in = 2'b01; // +1
				2'b10: trit_in = 2'b10; // -1
				default: trit_in = 2'b00;
			endcase

			if (carry) begin
				case (trit_in)
					2'b00: begin
						PC_Incr[2*i +: 2] = 2'b01; // 0 + 1 -> +1
						carry = 1'b0;
					end
					2'b01: begin
						PC_Incr[2*i +: 2] = 2'b10; // +1 -> -1
						carry = 1'b1;
					end
					2'b10: begin
						PC_Incr[2*i +: 2] = 2'b00; // -1 + 1 -> 0
						carry = 1'b0;
					end
					default: PC_Incr[2*i +: 2] = 2'b00;
				endcase
			end else begin
				PC_Incr[2*i +: 2] = In_PC[2*i +: 2];
			end
		end
	end
	
	assign Out_PC = (Branch == 2'b01) ? Br_Target : PC_Incr;
	
endmodule