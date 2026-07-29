class master_driver extends uvm_driver #(trans);
	`uvm_component_utils(master_driver)
	
	virtual axi_if.MASTER_DRV vif;
	agent_cfg m_cfg;
	int a,b,c,d,e;	
	semaphore s0 = new(1);
	semaphore s1 = new(1);
	
	semaphore s2 = new(1);
	
	semaphore s3 = new(1);
	semaphore s4 = new(1);
	
	semaphore s5 = new();
	semaphore s6 = new();
	semaphore s7 = new();
	
	trans q1[$], q2[$], q3[$], q4[$], q5[$]; 
	
	function new(string name = "master_driver", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		if(!uvm_config_db #(agent_cfg)::get(this, "", "agent_cfg", m_cfg))
			`uvm_fatal(get_type_name, "cannot get()")	
	endfunction
	
	function void connect_phase(uvm_phase phase);
		vif = m_cfg.vif;	
	endfunction
		
	task write_addr(trans data);
  		
	//----------- write address --------- 	
		vif.master_drv_cb.AWADDR	<= data.AWADDR; 
		vif.master_drv_cb.AWID		<= data.AWID; 
		vif.master_drv_cb.AWLEN		<= data.AWLEN;		
	   	vif.master_drv_cb.AWSIZE	<= data.AWSIZE;
	   	vif.master_drv_cb.AWBURST	<= data.AWBURST;
	   	vif.master_drv_cb.AWVALID 	<= 1'b1;
	   	
	   	@(vif.master_drv_cb);
	  	wait(vif.master_drv_cb.AWREADY);
	   	vif.master_drv_cb.AWVALID 	<= 1'b0; 
	endtask
	
	task write_data(trans data);
	
	//--------- WRITE DATA --------- 
	   	foreach(data.WDATA[i]) begin 
	   	vif.master_drv_cb.WDATA		<= data.WDATA[i];
	 	vif.master_drv_cb.WVALID    <= 1;
	 	vif.master_drv_cb.WID       <= data.WID;
	 	vif.master_drv_cb.WSTRB     <= data.WSTRB[i];  
	 	
	 	if(i == (data.AWLEN))
	 		vif.master_drv_cb.WLAST   	<= 1'b1;
	 	else
	 	 	vif.master_drv_cb.WLAST   	<= 1'b0;	
		 		 	
	 	@(vif.master_drv_cb);
	   	wait(vif.master_drv_cb.WREADY);
	   	vif.master_drv_cb.WVALID 	<= 1'b0;

       end
	endtask	

   	task write_resp(trans data);  
   	
   	//--------- WRITE RESPONSE ---------
		repeat($urandom_range(1,5))
		@(vif.master_drv_cb);
	  	vif.master_drv_cb.BREADY	<= 1'b1;  	
	  		
	  	@(vif.master_drv_cb);
	  	wait(vif.master_drv_cb.BVALID);
	  	vif.master_drv_cb.BREADY	 <= 1'b0;
	  	
   	endtask	  	
 
  	task read_addr(trans data);
 
  	//---------- READ ADDRESS -------
		vif.master_drv_cb.ARADDR  	<= data.ARADDR;
		vif.master_drv_cb.ARID   	<= data.ARID;      
		vif.master_drv_cb.ARLEN 	<= data.ARLEN; 	
		vif.master_drv_cb.ARSIZE 	<= data.ARSIZE;
		vif.master_drv_cb.ARBURST 	<= data.ARBURST;
		vif.master_drv_cb.ARVALID  	<= 1'b1;
		
	  	@(vif.master_drv_cb);		
	  	wait(vif.master_drv_cb.ARREADY);
	   	vif.master_drv_cb.ARVALID 	<= 1'b0;

 	endtask
 			

  	task read_data(trans data); 
  	
  	//----------- READ DATA------------
  		foreach(data.RDATA[i]) begin
  		   	repeat($urandom_range(1,5))
  			@(vif.master_drv_cb);
	  		vif.master_drv_cb.RREADY	<= 1'b1;  	
	  	
	  		@(vif.master_drv_cb);
	  		wait(vif.master_drv_cb.RVALID);
	  		vif.master_drv_cb.RREADY	 <= 1'b0;
	  	
      	end
	  	
   	endtask
 	
	task send2dut(trans data);
	q1.push_front(data);
	q2.push_front(data);
	q3.push_front(data);
	q4.push_front(data);
	q5.push_front(data);
	
	
		fork 
	 	begin	 	
	 		s0.get(1); 		 		
			write_addr(q1.pop_back());
		   	s0.put(1);
		  	s5.put(1);			  	
	 	end
		    
		 
	 	begin 
	 	
	 	   	s5.get(1);	 	
	 		s1.get(1); 		 				
			write_data(q2.pop_back());
			s1.put(1);
			s7.put(1);			
	 	end	
	 	
	 	begin
	 		s7.get(1);
	 		s2.get(1);
			write_resp(q3.pop_back());
			s2.put(1);			
	 	end		 		    
	  	 
	 	begin
	 		s3.get(1);	 		 
			read_addr(q4.pop_back());
			s3.put(1);
			s6.put(1);						
	 	end	
	 	
	 	begin
	 		s6.get(1); 
	 		s4.get(1); 	   	 		
			read_data(q5.pop_back());		
			s4.put(1);		
	 	end
		join_any
	  	m_cfg.sends++;
	 
	endtask
	
	task run_phase(uvm_phase phase);
		forever begin
			wait(vif.ARESETn);
			seq_item_port.get_next_item(req);
			send2dut(req);
			seq_item_port.item_done();
		end
	endtask
	
	function void report_phase(uvm_phase phase);
 		`uvm_info(get_type_name(),$sformatf("Report transactions %0d",m_cfg.sends),UVM_LOW);
	endfunction 
	
endclass