module Hazard_Detection_Unit (
		input logic [3:0] Ta,
		input logic [3:0] Tb,
		input logic [3:0] Ra_EX,
		input logic [1:0] WE_EX,
		input logic [3:0] Ra_MEM,
		input logic [1:0] WE_MEM,
		input logic [3:0] Ra_WB,
		input logic [1:0] WE_WB,
		input logic [1:0] load_en_EX,
	
		output logic [3:0] sel1, sel2,
		output logic [1:0] Branch_sel, stall_control,
		output logic [1:0] pc_control
	);
	
	logic ex_hazard_a, ex_hazard_b, mem_hazard_a, mem_hazard_b, wb_hazard_a, wb_hazard_b;
	
	assign ex_hazard_a = (Ra_EX == Ta) & WE_EX;
	assign mem_hazard_a = (Ra_MEM == Ta) & WE_MEM;
	assign wb_hazard_a = (Ra_WB == Ta) & WE_WB;
	
	assign ex_hazard_b = (Ra_EX == Tb) & WE_EX;
	assign mem_hazard_b = (Ra_MEM == Tb) & WE_MEM;
	assign wb_hazard_b = (Ra_WB == Tb) & WE_WB;
	
	always_comb begin
		stall_control = 2'b00;
		pc_control = 2'b01;
		sel1 = 4'b01_01;
		sel2 = 4'b01_01;
		Branch_sel = 2'b10;

		if ((load_en_EX == 2'b01) && (ex_hazard_a || ex_hazard_b)) begin
			stall_control = 2'b01;
			pc_control = 2'b00;
		end
		
		if (ex_hazard_a ==  1'b1) sel1 = 4'b10_01;
		else if (mem_hazard_a == 1'b1) sel1 = 4'b10_00;
		else if (wb_hazard_a == 1'b1) sel1 = 4'b10_10;
		
		if (ex_hazard_b ==  1'b1) sel2 = 4'b10_01;
		else if (mem_hazard_b == 1'b1) sel2 = 4'b10_00;
		else if (wb_hazard_b == 1'b1) sel2 = 4'b10_10;
				
		case ({mem_hazard_b, wb_hazard_b})
			2'b00: Branch_sel = 2'b10; // no hazard
			2'b10: Branch_sel = 2'b00; // mem -> mem_forwarding
			2'b01: Branch_sel = 2'b01; // wb -> wb_forwarding
		endcase
	end

endmodule
