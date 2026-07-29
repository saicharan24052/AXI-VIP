module top;
	
	import uvm_pkg::*;
	import test_pkg::*;
	
	`include "uvm_macros.svh"
	
	bit clk;
	bit rstn;
	
	initial clk = 0;
	initial begin
		rstn = 0;
		#9;
		rstn = 1; 
	end
	always #2 clk = ~clk;
	
	axi_if in0(clk, rstn);
	
	initial begin
		uvm_config_db #(virtual axi_if)::set(null, "*", "axi_if", in0);
		run_test("test2");
	end	

endmodule