class master_agent extends uvm_agent;
	`uvm_component_utils(master_agent)
	
	master_monitor mon;
	master_driver drv;
	master_sequencer seqr;
	
	agent_cfg m_cfg;
		
	function new(string name = "master_agent", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);   
		
		if(!uvm_config_db #(agent_cfg):: get (this,"","agent_cfg",m_cfg))
	   		`uvm_fatal("AGENT","cannot get()");
		
	   	mon = master_monitor::type_id::create("mon", this);
		
		if(m_cfg.is_active == UVM_ACTIVE) begin
			drv		= master_driver::type_id::create("drv", this);
			seqr 	= master_sequencer::type_id::create("seqr", this); 
		end
	endfunction
  	
	function void connect_phase(uvm_phase phase);
		drv.seq_item_port.connect(seqr.seq_item_export);	
	endfunction
  

endclass