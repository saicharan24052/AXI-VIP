class slave_driver extends uvm_driver #(trans);
	`uvm_component_utils(slave_driver)
	
	virtual axi_if.SLAVE_DRV vif;
	agent_cfg m_cfg;
	trans data;
	
	trans q1[$], q2[$], q3[$]; 
	int a,b,c,d,e;
	int co;
	
	trans check_read_addr[$], check_write_addr[$];
	
	semaphore s0 = new(1);
	semaphore s1 = new(1);

	semaphore s2 = new(1);
	
	semaphore s3 = new(1);
	semaphore s4 = new(1);
	
	semaphore s5 = new();
	semaphore s6 = new(); 
	semaphore s7 = new();	
	
	function new(string name = "slave_driver", uvm_component parent);
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
		
	task write_addr();
		trans data;
   		data = trans::type_id::create("data", this);
   		
	    repeat($urandom_range(1,5))
	    @(vif.slave_drv_cb);
 	   vif.slave_drv_cb.AWREADY 	<= 1'b1;
 	   
 	    @(vif.slave_drv_cb); 		   
	  	wait(vif.slave_drv_cb.AWVALID);  
	  	
		data.AWADDR		= vif.slave_drv_cb.AWADDR;
		data.AWID		= vif.slave_drv_cb.AWID;
		data.AWLEN		= vif.slave_drv_cb.AWLEN;
		data.AWSIZE    	= vif.slave_drv_cb.AWSIZE;	
		data.AWBURST	= vif.slave_drv_cb.AWBURST;
		data.AWVALID	= vif.slave_drv_cb.AWVALID;  
		  	
	   	vif.slave_drv_cb.AWREADY 	<= 1'b0;
	   		   	
	   	q1.push_back(data);
	   	q2.push_back(data); 
	   	check_write_addr.push_back(data);  
	endtask
	
	task write_data(trans data);
	
	//--------- WRITE DATA --------- 
	   	for(int i = 0; i<data.AWLEN + 1; i++) begin
	   		repeat($urandom_range(1,5))
	   		@(vif.slave_drv_cb);
	   		
	 		vif.slave_drv_cb.WREADY    <= 1; 
 		
 	 	 	@(vif.slave_drv_cb);
	   		wait(vif.slave_drv_cb.WVALID);
	   		vif.slave_drv_cb.WREADY 	<= 1'b0;     		
       	end
	endtask	
 
 
   	task write_resp(trans data);

   	//--------- WRITE RESPONSE ---------
  	   	vif.slave_drv_cb.BID      	<= data.AWID;
  	  	vif.slave_drv_cb.BRESP   	<= 2'b00;   	
		vif.slave_drv_cb.BVALID  	<= 1'b1; 
		  		
  	  	@(vif.slave_drv_cb);
  	  	wait(vif.slave_drv_cb.BREADY);
  		vif.slave_drv_cb.BVALID  	<= 1'b0;
   	endtask		
  	 
  	

  	task read_addr();
  
  		trans data;
   		data = trans::type_id::create("data", this); 

	    repeat($urandom_range(1,5))
	    @(vif.slave_drv_cb);
	     
	    vif.slave_drv_cb.ARREADY 	<= 1'b1;  
	    
	    @(vif.slave_drv_cb);
	  	wait(vif.slave_drv_cb.ARVALID);
	  	
		data.ARADDR		= vif.slave_drv_cb.ARADDR;
		data.ARID		= vif.slave_drv_cb.ARID;
		data.ARLEN		= vif.slave_drv_cb.ARLEN;
		data.ARSIZE    	= vif.slave_drv_cb.ARSIZE;	
		data.ARBURST	= vif.slave_drv_cb.ARBURST;
		data.ARVALID	= vif.slave_drv_cb.ARVALID; 
		
	   	vif.slave_drv_cb.ARREADY 	<= 1'b0;
	   	
	   	check_read_addr.push_back(data);	   	
	   	q3.push_back(data); 
        co++;  
 	endtask
 		

  	task read_data(trans data); 
  	
  	//----------- READ DATA------------
  		for(int j= 0; j<data.ARLEN+1; j++) begin
	  		vif.slave_drv_cb.RDATA  	<= j;
	  		vif.slave_drv_cb.RID   		<= data.ARID;
	  		vif.slave_drv_cb.RRESP		<= 2'b0;
	  		vif.slave_drv_cb.RVALID 	<= 1'b1;
	  	
	  		if(j == data.ARLEN)
	  	 		vif.slave_drv_cb.RLAST		<= 1'b1;
	  		else
	  	  		vif.slave_drv_cb.RLAST		<= 1'b0;
	  		
	   		
	  	
	   		@(vif.slave_drv_cb);          
	   		wait(vif.slave_drv_cb.RREADY);
	   		vif.slave_drv_cb.RVALID 	<= 1'b0;
	   	end 
	  	
	endtask
	


	task send2dut();
	
	  	fork 
	 	begin 
	 	   	s0.get(1);	 	   	
			write_addr();				
			s0.put(1);
			s5.put(1);	
	 	end
		
	  	begin
	 		s5.get(1);	  	
	 		s1.get(1);	   	  	
			write_data(q1.pop_front());	
			s1.put(1);
			s7.put(1);				
	   	end
 
		begin
	 		s7.get(1);
	 		s2.get(1);
			write_resp(q2.pop_front());
			s2.put(1);
		end
	   	
	   	begin
	   		s3.get(1);   		
			read_addr(); 
			s3.put(1);
			s6.put(1);			
				
		end
		
		begin
	 		s6.get(1); 
	 		s4.get(1);		   	
			read_data(q3.pop_front()); 
			s4.put(1);							
		end

	   	join_any
	  	m_cfg.sends++;
	 
	endtask
	
	task run_phase(uvm_phase phase);
		forever begin
			wait(vif.ARESETn);
			send2dut();
		end
	endtask
	
	function void report_phase(uvm_phase phase);
 		`uvm_info(get_type_name(),$sformatf("Report transactions %d",m_cfg.sends),UVM_LOW);
	endfunction 
	
endclass