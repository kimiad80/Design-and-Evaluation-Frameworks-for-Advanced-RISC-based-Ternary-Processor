`timescale 1ns/1ns

module Testbench ();
	
	logic clk, rst;
	
	ART9 ternary_riscv (clk, rst);
	
	initial begin
		clk = 1'b1;
		rst = 1'b1;
		#5 rst = 1'b0;
		#2000 $stop;
	end
	
	always begin
        #10 clk = ~clk;
    end

endmodule