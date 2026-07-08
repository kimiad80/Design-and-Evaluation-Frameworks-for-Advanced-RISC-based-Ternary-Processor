module EX_MEM_Reg (
		input logic clk,
		input logic rst,
		input logic [1:0] WE, mem_sel,
		input logic [17:0] TALU_out, PC,
		input logic [3:0] Ta,
		
		output logic [1:0] WE_out,
		output logic [17:0] TALU_out2, PC_out,
		output logic [3:0] Ta_out,
		output logic [1:0] mem_sel_out
	);
	
	always_ff @(posedge clk, posedge rst) begin
		if (rst == 1'b1) begin
			WE_out <= 2'd0;
			TALU_out2 <= 18'd0;
			PC_out <= 18'd0;
			Ta_out <= 4'd0;
			mem_sel_out <= 2'd0;
		end
		else begin
			WE_out <= WE;
			TALU_out2 <= TALU_out;
			PC_out <= PC;
			Ta_out <= Ta;
			mem_sel_out <= mem_sel;
		end
	end
	
endmodule