class slave_monitor extends uvm_monitor;
	`uvm_component_utils(slave_monitor)
	uvm_analysis_port #(trans) channel_mon, transaction_mon;	
	agent_cfg m_cfg;
	virtual axi_if.SLAVE_MON vif; 
	
	trans q1[$], q2[$], q3[$];
	trans check_q1[$],check_q2[$], check_q3[$];
	

	semaphore s0 = new(1);
	semaphore s1 = new(1);
	
	semaphore s2 = new(1);
	
	semaphore s3 = new(1);
	semaphore s4 = new(1);
	
	semaphore s5 = new();
	semaphore s6 = new();
	semaphore s7 = new();

	
	function new(string name = "slave_monitor", uvm_component parent);
		super.new(name, parent);
		channel_mon = new("channel_mon", this);	
		transaction_mon = new("transaction_mon", this);
	endfunction     
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(agent_cfg)::get(this, "", "agent_cfg", m_cfg))
			`uvm_fatal(get_type_name, "Cannot get()")
	endfunction
	
	function void connect_phase(uvm_phase phase);
		vif = m_cfg.vif; 
	endfunction
	
		
		task mon_wr_addr();
			trans data;
			data = trans::type_id::create("data", this);
			
			wait(vif.slave_mon_cb.AWVALID && vif.slave_mon_cb.AWREADY);
			
			data.AWADDR		= vif.slave_mon_cb.AWADDR; 
			data.AWID		= vif.slave_mon_cb.AWID; 
			data.AWLEN		= vif.slave_mon_cb.AWLEN;		
		   	data.AWSIZE		= vif.slave_mon_cb.AWSIZE;
		   	data.AWBURST	= vif.slave_mon_cb.AWBURST;
		   	data.AWVALID 	= vif.slave_mon_cb.AWVALID;
		   	data.AWREADY	= vif.slave_mon_cb.AWREADY; 
		   	q1.push_back(data);
	   	check_q1.push_back(data);
	   	
	   	channel_mon.write(data);

        	@(vif.slave_mon_cb); 
	endtask
	
	task mon_wr_data(trans data);
		data.WDATA = new[data.AWLEN+1];
		data.WSTRB = new[data.AWLEN+1]; 
			
	   	for(int i=0; i<data.AWLEN+1; i++) begin  
			wait(vif.slave_mon_cb.WVALID && vif.slave_mon_cb.WREADY);	
			   	
	 		data.WDATA[i]	= vif.slave_mon_cb.WDATA;
	 	    data.WSTRB[i]	= vif.slave_mon_cb.WSTRB;	 		
	   		data.WID		= vif.slave_mon_cb.WID; 
	   		data.WLAST		= vif.slave_mon_cb.WLAST;
	   		data.WVALID		= vif.slave_mon_cb.WVALID;
	 		data.WREADY		= vif.slave_mon_cb.WREADY;  
	 		
	   		channel_mon.write(data);	 		
	 		@(vif.slave_mon_cb); 
	 	end
	 	q2.push_back(data);
	 	check_q2.push_back(data); 

	endtask	
	

	task mon_wr_resp(trans data);
	   	
		wait(vif.slave_mon_cb.BVALID && vif.slave_mon_cb.BREADY);	
			   	
  	  	data.BREADY		= vif.slave_mon_cb.BREADY; 
  	  	data.BRESP		= vif.slave_mon_cb.BRESP; 
  	  	data.BVALID		= vif.slave_mon_cb.BVALID; 
  	  	data.BID		= vif.slave_mon_cb.BID; 
  	  	
		channel_mon.write(data);
		transaction_mon.write(data);
		
  	  	`uvm_info(get_type_name, $sformatf("################# WRITE CHANNEL %s", data.sprint()), UVM_LOW) 
  	  		@(vif.slave_mon_cb); 

	endtask

	
	
	task mon_rd_addr();
		trans data;
		data = trans::type_id::create("data", this);
		
		wait(vif.slave_mon_cb.ARVALID && vif.slave_mon_cb.ARREADY);
		
		data.ARADDR		= vif.slave_mon_cb.ARADDR;
		data.ARID		= vif.slave_mon_cb.ARID;
		data.ARLEN		= vif.slave_mon_cb.ARLEN;
		data.ARSIZE		= vif.slave_mon_cb.ARSIZE; 
		data.ARBURST	= vif.slave_mon_cb.ARBURST;
		data.ARVALID	= vif.slave_mon_cb.ARVALID;
		data.ARREADY	= vif.slave_mon_cb.ARREADY;
	   	q3.push_back(data);
	   	check_q3.push_back(data);
	   	
	   	channel_mon.write(data); 
	   	
	   		@(vif.slave_mon_cb); 
	endtask	
	
	task mon_rd_data(trans data);
			data.RDATA = new[data.ARLEN+1];
			data.RRESP = new[data.ARLEN+1];			
 
		for(int i=0; i<data.ARLEN+1; i++) begin
			wait(vif.slave_mon_cb.RVALID && vif.slave_mon_cb.RREADY);
			data.RDATA[i]	= vif.slave_mon_cb.RDATA;
			data.RID		= vif.slave_mon_cb.RID;
			data.RVALID		= vif.slave_mon_cb.RVALID;
			data.RREADY		= vif.slave_mon_cb.RREADY;
			data.RLAST		= vif.slave_mon_cb.RLAST;
			data.RRESP[i]	= vif.slave_mon_cb.RRESP; 
			
			channel_mon.write(data);
			transaction_mon.write(data);
				
			@(vif.slave_mon_cb); 
		end
		`uvm_info(get_type_name, $sformatf("################# READ CHANNEL %s", data.sprint()), UVM_LOW)
	endtask		
	
	
	
	
	task collect();  
		
		fork
		begin
	 		s0.get(1); 		 		
			mon_wr_addr();
		   	s0.put(1);
		  	s5.put(1);		
		end
	 	
		 
	 	begin 
	 	
	 	   	s5.get(1);	 	
	 		s1.get(1);		 				
			mon_wr_data(q1.pop_front());
			s1.put(1);
			s7.put(1);			
	 	end	
	 	
	 	begin
	 		s7.get(1);
	 		s2.get(1); 
			mon_wr_resp(q2.pop_front());
			s2.put(1);			
	 	end		 		    
	  	 
	 	begin
	 		s3.get(1); 		 
			mon_rd_addr();
			s3.put(1);
			s6.put(1);						
	 	end	
	 	
	 	begin
	 		s6.get(1); 
	 		s4.get(1);	   	 		
			mon_rd_data(q3.pop_front());		
			s4.put(1);		
	 	end
		join_any		
		m_cfg.rcv++;	 		
	endtask
	
	task run_phase(uvm_phase phase);
		forever begin
			wait(vif.ARESETn);
			collect();
		end
	endtask
	
	function void report_phase(uvm_phase phase);
		`uvm_info(get_type_name, $sformatf("no of receives %d", m_cfg.rcv), UVM_LOW)
	endfunction		


endclass