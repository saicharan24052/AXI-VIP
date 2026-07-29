class base_test extends uvm_test;
	`uvm_component_utils(base_test)
	
	environment env;
	agent_cfg m_cfg;
	
	function new(string name = "base_test", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void axi_config();
		m_cfg.is_active = UVM_ACTIVE;
		if(!uvm_config_db #(virtual axi_if)::get(this,"", "axi_if", m_cfg.vif))
			`uvm_fatal(get_type_name, "cannot get();")
		
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_cfg = agent_cfg::type_id::create("m_cfg", this);
		axi_config();
		uvm_config_db #(agent_cfg)::set(this, "*", "agent_cfg", m_cfg);
		env = environment::type_id::create("env", this);
	endfunction	
  	
	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);	
		uvm_top.print_topology();
	endfunction 
	
endclass

class test0 extends base_test;
	`uvm_component_utils(test0)
	
	sequence0 m_seq0;
	
	function new(string name = "base_test", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_seq0 = sequence0::type_id::create("m_seq0", this);
       	m_seq0.env_h = env;
	endfunction
	
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
    	m_seq0.start(env.m_agnt.seqr); 
    	#3500;	
		phase.drop_objection(this);
	endtask
   	
	 function void end_of_elaboration_phase(uvm_phase phase);
	 	super.end_of_elaboration_phase(phase);           	
	 endfunction	
   	
endclass


class test1 extends base_test;
	`uvm_component_utils(test1)
	
	sequence1 m_seq1;
	
	function new(string name = "base_test", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_seq1 = sequence1::type_id::create("m_seq1", this);
       	m_seq1.env_h = env;
	endfunction
	
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
    	m_seq1.start(env.m_agnt.seqr); 
    	#3500;	
		phase.drop_objection(this);
	endtask
   	
	 function void end_of_elaboration_phase(uvm_phase phase);
	 	super.end_of_elaboration_phase(phase);           	
	 endfunction	
   	
endclass



class test2 extends base_test;
	`uvm_component_utils(test2)
	
	sequence2 m_seq2;
	
	function new(string name = "base_test", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_seq2 = sequence2::type_id::create("m_seq2", this);
       	m_seq2.env_h = env;
	endfunction
	
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
    	m_seq2.start(env.m_agnt.seqr); 
    	#3500;	
		phase.drop_objection(this);
	endtask
   	
	 function void end_of_elaboration_phase(uvm_phase phase);
	 	super.end_of_elaboration_phase(phase);           	
	 endfunction	
   	
endclass