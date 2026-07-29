class slave_agent extends uvm_agent;
	`uvm_component_utils(slave_agent)
	
	slave_monitor mon;
	slave_driver drv;
	slave_sequencer seqr;
	
	agent_cfg m_cfg;
		
	function new(string name = "slave_agent", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);   
		
		if(!uvm_config_db #(agent_cfg):: get (this,"","agent_cfg",m_cfg))
	   		`uvm_fatal("AGENT","cannot get()");
		
	   	mon = slave_monitor::type_id::create("mon", this);
		
		if(m_cfg.is_active == UVM_ACTIVE) begin
			drv		= slave_driver::type_id::create("drv", this);
			seqr 	= slave_sequencer::type_id::create("seqr", this); 
		end
	endfunction
  	
	function void connect_phase(uvm_phase phase);
		drv.seq_item_port.connect(seqr.seq_item_export);	
	endfunction
  

endclass