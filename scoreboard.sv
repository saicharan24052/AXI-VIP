class scoreboard extends uvm_scoreboard;
	`uvm_component_utils(scoreboard)
	uvm_tlm_analysis_fifo #(trans) m_channel_mon, m_transaction_mon;
	uvm_tlm_analysis_fifo #(trans) s_channel_mon, s_transaction_mon;
	
	trans m_ch_data;
	trans cov_trans_data, m_trans_data; 
	
	trans s_ch_data;
	trans s_trans_data; 
	
	covergroup cg_write; 
	
		option.per_instance = 1;
		AWADDR_cp 		: coverpoint cov_trans_data.AWADDR 		{bins awaddr_bins = {[0:32'hffff_ffff]};}
		AWSIZE_cp 		: coverpoint cov_trans_data.AWSIZE 		{bins awsize_bins[] = {[0:2]};}
		AWLEN_cp  		: coverpoint cov_trans_data.AWLEN 		{bins awlen_bins[4] = {[0:11]};}
		AWBURST_cp  	: coverpoint cov_trans_data.AWBURST 	{bins awburst_bins[] = {[0:2]};}
		write_channel 	: cross AWADDR_cp, AWSIZE_cp, AWLEN_cp, AWBURST_cp;
	endgroup
	
	covergroup cg_write1 with function sample(int i);
		option.per_instance = 1; 
		WSTRB_cp 	: coverpoint cov_trans_data.WSTRB[i] {bins wstrb[] = {1,2,3,4,7,8,12,15};}
	endgroup
	
	covergroup cg_read; 
	
		option.per_instance = 1;
		ARADDR_cp 		: coverpoint cov_trans_data.ARADDR		{bins araddr_bins = {[0:32'hffff_ffff]};}
		ARSIZE_cp 		: coverpoint cov_trans_data.ARSIZE 		{bins arsize_bins = {[0:2]};}
		ARLEN_cp  		: coverpoint cov_trans_data.ARLEN 		{bins arlen_bins = {[0:11]};}
		ARBURST_cp  	: coverpoint cov_trans_data.ARBURST 	{bins arburst_bins[] = {[0:2]};}
		write_channel 	: cross ARADDR_cp, ARSIZE_cp, ARLEN_cp, ARBURST_cp;
	endgroup
	
	covergroup cg_read1 with function sample(int i);
		option.per_instance = 1; 
		RRESP_cp 	: coverpoint cov_trans_data.RRESP[i] {bins rresp = {0};}
	endgroup		
	
 	
	function new(string name = "scoreboard", uvm_component parent);
		super.new(name, parent);
		
		m_channel_mon = new("m_channel_mon", this);
		m_transaction_mon = new("m_transaction_mon", this); 
		
		s_channel_mon = new("s_channel_mon", this);
		s_transaction_mon = new("s_transaction_mon", this);
		
								
	   	cg_write = new();
	   	cg_write1 = new();	
	   	
	   	cg_read = new();
		cg_read1 = new();
	endfunction
	
	
	task compare_channel();
		forever begin
	   		m_channel_mon.get(m_ch_data);
			s_channel_mon.get(s_ch_data);
		
			if(!(m_ch_data.compare(s_ch_data)))
		   		`uvm_warning(get_type_name(), "DUDE!! NOT MATCHING THE CAHNNEL DATA")
		   	else
		   		`uvm_info(get_type_name(), " MATCHING THE CAHNNEL DATA", UVM_LOW)  
        end
	endtask
	
	task compare_transaction();
		forever begin
	   		m_transaction_mon.get(m_trans_data);
			s_transaction_mon.get(s_trans_data); 
		
			if(!(m_trans_data.compare(s_trans_data)))
		   		`uvm_warning(get_type_name(), "DUDE!! NOT MATCHING THE TRANSACTION DATA")
		   	else begin
		   		`uvm_info(get_type_name(), " MATCHING THE TRANSACTION DATA", UVM_LOW) 
		   		cov_trans_data = m_trans_data;
		   	    cg_write.sample();
		   	    cg_read.sample();
		   	    `uvm_info(get_type_name, "Coverage sampling started", UVM_LOW)
		   	    if(m_trans_data.WVALID)begin
		   	    	foreach(m_trans_data.WSTRB[i])
		   	    		cg_write1.sample(i);		
		   	    end
		   	    if(m_trans_data.RVALID)begin
		   	    	foreach(m_trans_data.RRESP[i])
		   	    		cg_read1.sample(i);		
		   	    end		   	    
		   	end 
        end
	endtask	
	
	task run_phase(uvm_phase phase);
    	fork
    		compare_channel();
    		compare_transaction();	
    	join
	endtask
	
   	function void report_phase(uvm_phase phase);
		`uvm_info(get_type_name, $sformatf("Total Coverage write channel %0.2f \n", cg_write.get_coverage()), UVM_LOW)
		`uvm_info(get_type_name, $sformatf("Total Coverage write strb %0.2f \n", cg_write1.get_coverage()), UVM_LOW)
		
		`uvm_info(get_type_name, $sformatf("Total Coverage read channel %0.2f \n", cg_read.get_coverage()), UVM_LOW)
		`uvm_info(get_type_name, $sformatf("Total Coverage read resp %0.2f \n", cg_read1.get_coverage()), UVM_LOW)		
   	endfunction
	
endclass