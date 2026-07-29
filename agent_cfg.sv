class agent_cfg extends uvm_object;
	`uvm_object_utils(agent_cfg)
	
	virtual axi_if vif;
	
	static int sends = 0;
	static int rcv = 0;
	
	uvm_active_passive_enum is_active = UVM_ACTIVE;
	
	function new(string name = "agent_cfg");
		super.new(name);
	endfunction
	

endclass