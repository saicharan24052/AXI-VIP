class base_sequence extends uvm_sequence #(trans);
	`uvm_object_utils(base_sequence)
	environment env_h;
	function new(string name = "base_sequence");
		super.new(name);
	endfunction

endclass

class sequence0 extends base_sequence;
	`uvm_object_utils(sequence0)
	
	function new(string name = "sequence0");
		super.new(name);
	endfunction
	
	task body();
	 repeat(12) begin
			req = trans::type_id::create("req");
		   	start_item(req);
			assert(req.randomize() with { AWBURST == 0; ARBURST == 0;});
		   	finish_item(req);
		end
	endtask	

endclass

class sequence1 extends base_sequence;
	`uvm_object_utils(sequence1)
	
	function new(string name = "sequence1");
		super.new(name);
	endfunction
	
	task body();
	   //while((env_h.sb.cg_write.get_coverage() < 74) && (env_h.sb.cg_read.get_coverage() < 74)) begin
	   	repeat(12) begin
			req = trans::type_id::create("req");
		   	start_item(req);
			assert(req.randomize() with { AWBURST == 1; ARBURST == 1;});// INCR
		   	finish_item(req);
		end
	endtask	

endclass

class sequence2 extends base_sequence;
	`uvm_object_utils(sequence2)
	
	function new(string name = "sequence2");
		super.new(name);
	endfunction
	
	task body();
		//while((env_h.sb.cg_write.get_coverage() < 74) && (env_h.sb.cg_read.get_coverage() < 74)) begin 
		repeat(12) begin
			req = trans::type_id::create("req");
		   	start_item(req);
			assert(req.randomize() with { AWBURST == 2; ARBURST == 2;});//WRAP
		   	finish_item(req);
		end
	endtask	

endclass