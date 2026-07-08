module Branch_Target_Calculator (
		input logic [17:0] PC, imm,
		input logic [1:0] B, Tb0,
		
		output logic [17:0] B17, TbBranch,
		output logic [17:0] Branch_Target
	);
	
	integer i;
	logic signed [2:0] temp_sum;
	logic signed [1:0] carry;
	logic signed [1:0] inp1_trit;
	logic signed [1:0] inp2_trit;
	
	assign B17 = {16'd0, B[1:0]};
	assign TbBranch = {16'd0, Tb0[1:0]};

	always_comb begin
        carry = 0;
        for (i = 0; i < 9; i = i + 1) begin
            case (PC[2*i +: 2])
                2'b00: inp1_trit = 2'b00;  // 0
                2'b01: inp1_trit = 2'b01;  // +1
                2'b10: inp1_trit = -2'b01; // -1
                default: inp1_trit = 2'b00; // Default to 0
            endcase

            case (imm[2*i +: 2])
                2'b00: inp2_trit = 2'b00;  // 0
                2'b01: inp2_trit = 2'b01;  // +1
                2'b10: inp2_trit = -2'b01; // -1
                default: inp2_trit = 2'b00; // Default to 0
            endcase

            temp_sum = inp1_trit + inp2_trit + carry;
            case (temp_sum)
				-4: begin
                    Branch_Target[2*i +: 2] = 2'b10; // -1
                    carry = -1;
                end
                -3: begin
                    Branch_Target[2*i +: 2] = 2'b00; // 0
                    carry = -1;
                end
                -2: begin
                    Branch_Target[2*i +: 2] = 2'b01; // +1
                    carry = -1;
                end
                -1: begin
                    Branch_Target[2*i +: 2] = 2'b10; // -1
                    carry = 0;
                end
                 0: begin
                    Branch_Target[2*i +: 2] = 2'b00; // 0
                    carry = 0;
                end
                 1: begin
                    Branch_Target[2*i +: 2] = 2'b01; // +1
                    carry = 0;
                end
                 2: begin
                    Branch_Target[2*i +: 2] = 2'b10; // -1
                    carry = 1;
                end
                 3: begin
                    Branch_Target[2*i +: 2] = 2'b00; // 0
                    carry = 1;
                end
				 4: begin
                    Branch_Target[2*i +: 2] = 2'b01; // +1
                    carry = 1;
                end
                default: begin
                    Branch_Target[2*i +: 2] = 2'b00; // Default to 0
                    carry = 0;
                end
            endcase
        end
    end
	
	
endmodule