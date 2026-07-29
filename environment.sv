class environment extends uvm_env;
	`uvm_component_utils(environment)
	
	master_agent m_agnt;
	slave_agent	 s_agnt;
	scoreboard sb;
	
	function new(string name = "environment", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);		
		m_agnt = master_agent::type_id::create("m_agnt", this);
		s_agnt = slave_agent::type_id::create("s_agnt", this);
		
		sb = scoreboard::type_id::create("sb", this);
	endfunction
 
	
 	function void connect_phase(uvm_phase phase);
	 	m_agnt.mon.channel_mon.connect(sb.m_channel_mon.analysis_export);
	 	m_agnt.mon.transaction_mon.connect(sb.m_transaction_mon.analysis_export); 
	 	
	 	s_agnt.mon.channel_mon.connect(sb.s_channel_mon.analysis_export);
	 	s_agnt.mon.transaction_mon.connect(sb.s_transaction_mon.analysis_export); 	
	endfunction
	
	


endclass