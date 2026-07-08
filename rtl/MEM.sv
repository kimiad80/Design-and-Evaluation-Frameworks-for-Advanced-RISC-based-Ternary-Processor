module MEM (
		input logic [17:0] TALU_Out, TDM_Out, PC,
		input logic [1:0] sel,
		
		output logic [17:0] Data_Out
	);
	
	always_comb begin
		case (sel)
			2'b10: Data_Out = TDM_Out;
			2'b00: Data_Out = TALU_Out;
			2'b01: Data_Out = PC;
		endcase
	end
	
endmodule