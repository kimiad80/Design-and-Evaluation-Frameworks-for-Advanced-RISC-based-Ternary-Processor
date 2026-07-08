module TALU (
		input logic [17:0] TRFRa, TRFRb,
		input logic [17:0] imm, 
		input logic [1:0] sel_a, sel_b,
		input logic [1:0] funct,
		input logic [3:0] sel,
		
		output logic [17:0] Out
	);
	
	logic [17:0] inp1, inp2;
	logic [17:0] iTRFRb, aox_out, snp_out, srl_out, add_out, cmp_out;
		
	Inverter inv (TRFRb, iTRFRb);
		
	always_comb begin
		case (sel_a)
			2'b10: inp1 = TRFRa;
			2'b00: inp1 = {TRFRa[17:10], 10'd0};
			2'b01: inp1 = imm;
			default: inp1 = 18'd0;
		endcase
		case (sel_b)
			2'b10: inp2 = TRFRb;
			2'b00: inp2 = iTRFRb;
			2'b01: inp2 = imm;
			default: inp2 = 18'd0;
		endcase
	end
	
	ADD A (inp1, inp2, add_out);
	AND_OR_XOR AOX (inp1, inp2, funct, aox_out);
	COMP CMP (inp1, inp2, cmp_out);
	SR_SL SRL (inp1, inp2, funct, srl_out);
	STI_NTI_PTI SNP (inp2, funct, snp_out);
	
	always_comb begin
	
		case (sel)
			4'b10_10: Out = imm; // -4
			4'b10_00: Out = add_out; // -3
			4'b10_01: Out = aox_out; // -2
			4'b00_10: Out = cmp_out; // -1
			4'b00_00: Out = srl_out; // 0
			4'b00_01: Out = snp_out; // 1
		endcase
	
	end

endmodule

module ADD (
    input logic [17:0] inp1, inp2,
    output logic [17:0] out
);

    integer i;
    logic signed [2:0] temp_sum;
    logic signed [1:0] carry;
    logic signed [1:0] inp1_trit, inp2_trit;

    always_comb begin
        carry = 0;
        for (i = 0; i < 9; i = i + 1) begin
            case (inp1[2*i +: 2])
                2'b00: inp1_trit = 2'b00;  // 0
                2'b01: inp1_trit = 2'b01;  // +1
                2'b10: inp1_trit = -2'b01; // -1
                default: inp1_trit = 2'b00; // Default to 0
            endcase

            case (inp2[2*i +: 2])
                2'b00: inp2_trit = 2'b00;  // 0
                2'b01: inp2_trit = 2'b01;  // +1
                2'b10: inp2_trit = -2'b01; // -1
                default: inp2_trit = 2'b00; // Default to 0
            endcase

            temp_sum = inp1_trit + inp2_trit + carry;
            case (temp_sum)
				-4: begin
                    out[2*i +: 2] = 2'b10; // -1
                    carry = -1;
                end
                -3: begin
                    out[2*i +: 2] = 2'b00; // 0
                    carry = -1;
                end
                -2: begin
                    out[2*i +: 2] = 2'b01; // +1
                    carry = -1;
                end
                -1: begin
                    out[2*i +: 2] = 2'b10; // -1
                    carry = 0;
                end
                 0: begin
                    out[2*i +: 2] = 2'b00; // 0
                    carry = 0;
                end
                 1: begin
                    out[2*i +: 2] = 2'b01; // +1
                    carry = 0;
                end
                 2: begin
                    out[2*i +: 2] = 2'b10; // -1
                    carry = 1;
                end
                 3: begin
                    out[2*i +: 2] = 2'b00; // 0
                    carry = 1;
                end
				 4: begin
                    out[2*i +: 2] = 2'b01; // +1
                    carry = 1;
                end
                default: begin
                    out[2*i +: 2] = 2'b00; // Default to 0
                    carry = 0;
                end
            endcase
        end
    end

endmodule

module AND_OR_XOR (
		input logic [17:0] inp1, inp2,
		input logic [1:0] select,
		
		output logic [17:0] out
	);
	logic [17:0] and_out, or_out, xor_out;
	
	AND a (inp1, inp2, and_out);
	OR o (inp1, inp2, or_out);
	XOR x (inp1, inp2, xor_out);
	
	always_comb begin
		case (select)
			2'b10: out = and_out;
			2'b00: out = or_out;
			2'b01: out = xor_out;
			default: out = 18'd0;
		endcase
	end
	
endmodule

module AND (
		input logic [17:0] inp1, inp2,
		
		output logic [17:0] out
	);
	integer i;
	always_comb begin
		for (i = 0; i < 9; i = i + 1) begin
			
			out[2*i] = inp1[2*i] & inp2[2*i];
			out[2*i + 1] = inp1[2*i + 1] | inp2[2*i + 1];
			
		end
	end
endmodule

module OR (
		input logic [17:0] inp1, inp2,
		
		output logic [17:0] out
	);
	integer i;
	always_comb begin
		for (i = 0; i < 9; i = i + 1) begin
			
			out[2*i] = inp1[2*i] | inp2[2*i];
			out[2*i + 1] = inp1[2*i + 1] & inp2[2*i + 1];
			
		end
	end
endmodule

module XOR (
		input logic [17:0] inp1, inp2,
		
		output logic [17:0] out
	);
	integer i;
	always_comb begin
		for (i = 0; i < 9; i = i + 1) begin
			
			out[2*i] = (inp1[2*i + 1] & inp2[2*i]) | (inp1[2*i] & inp2[2*i + 1]);
			out[2*i + 1] = (inp1[2*i + 1] & inp2[2*i + 1]) | (inp1[2*i] & inp2[2*i]);
			
		end
	end
endmodule

module COMP (
		input logic [17:0] inp1, inp2,
		
		output logic [17:0] out
	);
	
	integer i;
    logic [1:0] trit1, trit2;
	logic exit_loop;

    always_comb begin
        out = 18'd0;
        exit_loop = 0;
        for (i = 8; i >= 0 && !exit_loop; i = i - 1) begin
            trit1 = {inp1[2*i+1], inp1[2*i]};
            trit2 = {inp2[2*i+1], inp2[2*i]};
            
            if (trit1 > trit2) begin
                out[1:0] = 2'b10;
                exit_loop = 1;
            end
            else if (trit1 < trit2) begin
                out[1:0] = 2'b01;
                exit_loop = 1;
            end
        end
    end
endmodule

module SR_SL (
		input logic [17:0] inp1, inp2,
		input logic [1:0] R_L,
		
		output logic [17:0] out
	);
	// R = 2'b10, L = 2'b00
	wire [3:0] shift_num;
	logic [2:0] dec_shift;
	logic signed [1:0] trit_value;
	assign shift_num = inp2[3:0];
	
	integer i;
	
	always_comb begin
		dec_shift = 3'd0;
		for (i = 0; i < 2; i = i + 1) begin
			case (shift_num[2*i +: 2])
				2'b00: trit_value = 0;   // Trit value is 0
				2'b01: trit_value = 1;   // Trit value is 1
				2'b10: trit_value = -1;  // Trit value is -1
				default: trit_value = 0;
			endcase

			dec_shift = dec_shift + trit_value * (3 ** i);
		end
		case (R_L)
			2'b10: out = inp1 >> (2 * dec_shift);
			2'b00: out = inp1 << (2 * dec_shift);
		endcase
	end
	
	
endmodule

module STI_NTI_PTI (
		input logic [17:0] inp,
		input logic [1:0] select,
		
		output logic [17:0] out
	);
	
	integer i;

	always_comb begin
		for (i = 0; i < 9; i = i + 1) begin
			case (inp[2*i +: 2])
				2'b10: out[2*i +: 2] = 2'b01;
				2'b01: out[2*i +: 2] = 2'b10;
				2'b00:	begin
							case (select)
								2'b10: out[2*i +: 2] = 2'b01; // PTI
								2'b00: out[2*i +: 2] = 2'b10; // NTI
								2'b01: out[2*i +: 2] = 2'b00; // STI
							endcase
						end
			endcase
		end
	end
	
endmodule