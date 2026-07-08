module Index_Checker (
		input logic [17:0] res, ex_dest, mem_dest, wb_dest,
		
		output logic forward_sel
	);
	
	assign hazard = (ex_dest == res || mem_dest == res || wb_dest == res);
	
endmodule