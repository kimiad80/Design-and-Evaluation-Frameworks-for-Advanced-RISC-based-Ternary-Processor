module TRF (
		input logic clk,
		input logic rst,
		input logic [3:0] Ta,
		input logic [3:0] Tb,
		input logic [3:0] write_addr,
		input logic [17:0] write_data,
		input logic [1:0] WE_WB,

		output logic [17:0] TRFTa,
		output logic [17:0] TRFTb
	);

	logic [17:0] reg_file [8:0];
	
	logic signed [3:0] decimal_Ta, decimal_Tb, decimal_addr;
	integer i;
	logic signed [1:0] trit_value;
	
	always_comb begin
		decimal_Ta = 4'd0;
		for (i = 0; i < 2; i = i + 1) begin
			case (Ta[2*i +: 2])
				2'b00: trit_value = 0;   // Trit value is 0
				2'b01: trit_value = 1;   // Trit value is 1
				2'b10: trit_value = -1;  // Trit value is -1
			endcase

			decimal_Ta = decimal_Ta + trit_value * (3 ** i);
		end
		
		decimal_Tb = 4'd0;
		for (i = 0; i < 2; i = i + 1) begin
			case (Tb[2*i +: 2])
				2'b00: trit_value = 0;   // Trit value is 0
				2'b01: trit_value = 1;   // Trit value is 1
				2'b10: trit_value = -1;  // Trit value is -1
			endcase

			decimal_Tb = decimal_Tb + trit_value * (3 ** i);
		end
		
		decimal_addr = 4'd0;
		for (i = 0; i < 2; i = i + 1) begin
			case (write_addr[2*i +: 2])
				2'b00: trit_value = 0;   // Trit value is 0
				2'b01: trit_value = 1;   // Trit value is 1
				2'b10: trit_value = -1;  // Trit value is -1
			endcase

			decimal_addr = decimal_addr + (trit_value * (3 ** i));
		end
	end
	
	// Synchronous Write
	always_ff @(posedge clk, posedge rst) begin
		if (rst) begin
			reg_file[0] <= 18'b0;
			reg_file[1] <= 18'b0;
			reg_file[2] <= 18'b0;
			reg_file[3] <= 18'b0;
			reg_file[4] <= 18'b0;
			reg_file[5] <= 18'b0;
			reg_file[6] <= 18'b0;
			reg_file[7] <= 18'b0;
			reg_file[8] <= 18'b0;
			reg_file[9] <= 18'b0;
		end else if (WE_WB == 2'b01 && decimal_addr != -4'd4) begin
			reg_file[decimal_addr + 4'd4] <= write_data;
		end
	end
	
	// Asynchronous Read
	assign TRFTa = reg_file[decimal_Ta + 4'd4];
    assign TRFTb = reg_file[decimal_Tb + 4'd4];

endmodule
