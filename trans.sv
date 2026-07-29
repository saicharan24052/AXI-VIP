class trans extends uvm_sequence_item;
	`uvm_object_utils(trans)  
	
	localparam FIXED = 0, INC = 1, WRAP = 2; 
	    
    logic ARESETn;
    
///////////////////////////////////////////////////////////////
	//WRITE ADDRESS CHANNEL
/////////////////////////////////////////////////////////////// 
   
    rand bit [3:0] AWID;
    rand bit [31:0] AWADDR;
    rand bit [3:0] AWLEN;
    rand bit [2:0] AWSIZE;
    rand bit [1:0] AWBURST;
    logic AWVALID;
    logic AWREADY;  
    
///////////////////////////////////////////////////////////////
	//WRITE DATA CHANNEL
///////////////////////////////////////////////////////////////    

	rand bit [3:0] WID;
	rand bit [31:0] WDATA[];
	rand bit [3:0] WSTRB[];
	logic WLAST;
	logic WVALID;
	logic WREADY;



																							
///////////////////////////////////////////////////////////////
	//WRITE RESPONSE CHANNEL
/////////////////////////////////////////////////////////////// 	


	rand bit [3:0] BID;
	logic [1:0] BRESP;
	logic BVALID;
	logic BREADY;
	
///////////////////////////////////////////////////////////////
	//READ ADDRESS CHANNEL
/////////////////////////////////////////////////////////////// 	

	rand bit [3:0] ARID;
	rand bit [31:0] ARADDR;
	rand bit [3:0] ARLEN;
	rand bit [2:0] ARSIZE;
	rand bit [1:0] ARBURST;
	logic ARVALID;
	logic ARREADY;




///////////////////////////////////////////////////////////////
	//READ DATA CHANNEL
/////////////////////////////////////////////////////////////// 

	rand bit [3:0] RID;
	rand bit [31:0] RDATA[];
	rand bit [1:0] RRESP[];
	bit RLAST;
	logic RVALID;
	logic RREADY;


constraint wstrob_c1 {WSTRB.size() == AWLEN+1;}
constraint wdata_c {WDATA.size() == (AWLEN +1);} 

constraint write_id_c { AWID == WID ; BID == AWID;}
constraint read_id_c { RID == ARID;} 

constraint WRAP_len_c {if (AWBURST == WRAP)
								(AWLEN+1) inside {2,4,8,16};}	
								
constraint WRAP_start_address_c_write {if (AWBURST == WRAP)
								AWADDR % (2**AWSIZE) == 0;}	
																
constraint WRAP_start_address_c_read {if (ARBURST == WRAP)
								ARADDR % (2**ARSIZE) == 0;}		
constraint rdata_c {RDATA.size() == (ARLEN +1);}  
constraint rresp_c {RRESP.size() == (ARLEN +1);}  

	
	function new(string name = "trans");
		super.new(name);
	endfunction 
	
	
	function void  add_calc(bit [31:0] address_in, bit [2:0] size, bit [7:0] len, bit [1:0] burst);// slave had to calculate the next address in burst
		bit [31:0] start_address;
		bit [31:0] address [];
		int number_bytes;
		int burst_length;
		bit [31:0] aligned_address;
		
		bit [31:0] Lower_WRAP_Boundary, Upper_WRAP_Boundary;


		start_address = address_in;
		number_bytes = 2**size;
		burst_length = len+1;
		address = new[burst_length];
		aligned_address = int'(start_address/number_bytes) * number_bytes;  
		
		Lower_WRAP_Boundary = int'(start_address/(number_bytes * burst_length)) * (number_bytes * burst_length); 
		Upper_WRAP_Boundary = Lower_WRAP_Boundary + (number_bytes * burst_length);
		
		address = new[burst_length];
		address[0] = start_address;

	    if(burst == FIXED) begin
	    	for(int i = 1; i<burst_length; i++) begin
		    	address[i] = start_address;			
			end	    
	    end
		
	    else if(burst == INC) begin
	    	for(int i = 1; i<burst_length; i++) begin
		    	address[i] = aligned_address + (i+1 - 1) * number_bytes;			
			end	    
	    end
	    
	    else if(burst == WRAP) begin
	    	for(int i = 1; i<burst_length; i++) begin
	    	    
	    	    address[i] = start_address + ((i+1 - 1) * number_bytes); 
	    	    
		    	if(address[i] == Upper_WRAP_Boundary) 
		    		address[i] = Lower_WRAP_Boundary;
		    	else if (address[i] > Upper_WRAP_Boundary) 
		    		address[i] = start_address + ((i+1 - 1) * number_bytes) - (number_bytes * burst_length);
			end	
	    end
    
	  	    
	endfunction 
	
	
	    
	function void strob_calc();
   		bit [3:0] strb;
   		int Data_Bus_Bytes = 4;
  	 	bit [31:0] Aligned_Address;
  	 	int  Number_Bytes = 2**AWSIZE; 
   	 	int first_Lower_Byte_Lane;
   	 	int first_Upper_Byte_Lane;
    	int Lower_Byte_Lane;	
		int Upper_Byte_Lane;
		bit [31:0] address [];
		
		address = new[AWLEN+1];
	
    	Aligned_Address = int'(AWADDR/Number_Bytes) * Number_Bytes;  
    
   		first_Lower_Byte_Lane = AWADDR - (AWADDR / Data_Bus_Bytes) * Data_Bus_Bytes;	
		first_Upper_Byte_Lane= Aligned_Address + (Number_Bytes - 1) - (AWADDR / Data_Bus_Bytes) * Data_Bus_Bytes;
	   	  

	     
		for(int j = 0; j<AWLEN+1; j++) begin 
	
			Lower_Byte_Lane = address[j] - (address[j] / Data_Bus_Bytes) * Data_Bus_Bytes;
			Upper_Byte_Lane= Lower_Byte_Lane + (Number_Bytes - 1);
		
	   		for(int i = 0; i<Data_Bus_Bytes; i++) begin
				if(j == 0) begin
			   		if(i <= first_Upper_Byte_Lane && i >= first_Lower_Byte_Lane)  		
   		   		   		WSTRB[j][i] = 1'b1;	
   			   		else
   				   		WSTRB[j][i] = 1'b0;				
   		   		end			
   		   		else begin
   					if(i <= Upper_Byte_Lane && i >= Lower_Byte_Lane)   		
   		   		   		WSTRB[j][i] = 1'b1;	
   					else
   				   		WSTRB[j][i] = 1'b0;
   				end	
			end
		end	
	endfunction		
	
	
	
	
	function void post_randomize();
    	add_calc(AWADDR, AWSIZE, AWLEN, AWBURST);
    	strob_calc();
	endfunction
	
	
		function void do_print(uvm_printer printer);
		//super.do_print(printer);

		printer.print_field("AWLEN",	this.AWLEN,		$bits(AWLEN), 		UVM_DEC);
		printer.print_field("AWSIZE",	this.AWSIZE,	$bits(AWSIZE), 		UVM_DEC);
		printer.print_field("AWBURST",	this.AWBURST,	$bits(AWBURST), 	UVM_DEC);
		printer.print_field("AWID",		this.AWID,		$bits(AWID),   		UVM_DEC);
		printer.print_field("AWADDR",	this.AWADDR,	$bits(AWADDR),		UVM_DEC);
		printer.print_field("AWVALID",	this.AWVALID,	$bits(AWVALID),	 	UVM_DEC);
		printer.print_field("AWREADY",	this.AWREADY, 	$bits(AWREADY),	 	UVM_DEC); 
		
        foreach(WSTRB[i])
		printer.print_field($sformatf("WSTRB[%d]", i),	this.WSTRB[i],		$bits(WSTRB[i]),UVM_DEC);
		
		printer.print_field("WID",		this.WID,		$bits(WID), 		UVM_DEC);
		
		foreach(WDATA[i])
		printer.print_field($sformatf("WDATA[%d]", i),	this.WDATA[i],		$bits(WDATA[i]),UVM_DEC);
		
		printer.print_field("WLAST",	this.WLAST,		$bits(WLAST),  		UVM_DEC);
		printer.print_field("WVALID",	this.WVALID,	$bits(WVALID), 		UVM_DEC);
		printer.print_field("WREADY",	this.WREADY,	$bits(WREADY), 		UVM_DEC);

		printer.print_field("BID",		this.BID,		$bits(BID),    		UVM_DEC);
		printer.print_field("BRESP",	this.BRESP,		$bits(BRESP),  		UVM_DEC);
		printer.print_field("BVALID",	this.BVALID,	$bits(BVALID), 		UVM_DEC);
		printer.print_field("BREADY",	this.BREADY,	$bits(BREADY), 		UVM_DEC);


		printer.print_field("ARLEN",	this.ARLEN,		$bits(ARLEN),  		UVM_DEC);
		printer.print_field("ARSIZE",	this.ARSIZE,	$bits(ARSIZE), 		UVM_DEC);
		printer.print_field("ARBURST",	this.ARBURST,	$bits(ARBURST),		UVM_DEC);
		printer.print_field("ARID",		this.ARID, 		$bits(ARID),		UVM_DEC);
		printer.print_field("ARADDR",	this.ARADDR,	$bits(ARADDR), 		UVM_DEC);
		printer.print_field("ARVALID",	this.ARVALID,	$bits(ARVALID),	 	UVM_DEC);
		printer.print_field("ARREADY",	this.ARREADY, 	$bits(ARREADY),	 	UVM_DEC);

		printer.print_field("RID",		this.RID,		$bits(RID), 		UVM_DEC);  
		
		foreach(RDATA[i])
			printer.print_field($sformatf("RDATA[%d]", i),	this.RDATA[i],		$bits(RDATA[i]),UVM_DEC);
				
		printer.print_field("RLAST",	this.RLAST,		$bits(RLAST),  		UVM_DEC);
		
		foreach(RRESP[i])
			printer.print_field($sformatf("RRESP[%d]", i),	this.RRESP[i],		$bits(RRESP[i]),UVM_DEC);  
			
		printer.print_field("RVALID",	this.RVALID,	$bits(RVALID), 		UVM_DEC);
		printer.print_field("RREADY",	this.RREADY,	$bits(RREADY), 		UVM_DEC);

	endfunction
	
	
	function bit do_compare(uvm_object rhs, uvm_comparer comparer);
		trans rhs_;
		bit status = 1;
		
		if(!$cast(rhs_, rhs)) begin
			`uvm_fatal(get_type_name(), "cast of object failed")
			return 0;		
		end
		
		
		      status &= super.do_compare(rhs, comparer);

   		 //-----------------------------
   		 // Write Address Channel
   		 //-----------------------------
    	if(AWID    != rhs_.AWID) begin
        	status = 0;
        `uvm_error("COMPARE",$sformatf("AWID mismatch exp=%0h act=%0h",AWID,rhs_.AWID))
   		 end

    	if(AWADDR  != rhs_.AWADDR) begin
        	status = 0;
        	`uvm_error("COMPARE",$sformatf("AWADDR mismatch exp=%08h act=%08h",AWADDR,rhs_.AWADDR))
    	end

    	if(AWLEN   != rhs_.AWLEN) begin
        	status = 0;
        	`uvm_error("COMPARE",$sformatf("AWLEN mismatch exp=%0d act=%0d",AWLEN,rhs_.AWLEN))
    	end

    	if(AWSIZE  != rhs_.AWSIZE) begin
        	status = 0;
        	`uvm_error("COMPARE",$sformatf("AWSIZE mismatch exp=%0d act=%0d",AWSIZE,rhs_.AWSIZE))
    	end

    	if(AWBURST != rhs_.AWBURST) begin
        	status = 0;
        	`uvm_error("COMPARE",$sformatf("AWBURST mismatch exp=%0d act=%0d",AWBURST,rhs_.AWBURST))
    	end

    	//-----------------------------
    	// Write Data Channel
    	//-----------------------------
    	if(WID != rhs_.WID) begin
        	status = 0;
        	`uvm_error("COMPARE",$sformatf("WID mismatch exp=%0h act=%0h",WID,rhs_.WID))
    	end

    	if(WLAST != rhs_.WLAST) begin
       		status = 0;
       	 	`uvm_error("COMPARE","WLAST mismatch")
   	 	end

    	if(WDATA.size()!=rhs_.WDATA.size()) begin
        	status = 0;
        	`uvm_error("COMPARE",$sformatf("WDATA size mismatch exp=%0d act=%0d",WDATA.size(),rhs_.WDATA.size()))
    	end
    	else begin
        	foreach(WDATA[i]) begin
            	if(WDATA[i]!=rhs_.WDATA[i]) begin
                	status = 0;
                	`uvm_error("COMPARE",$sformatf("WDATA[%0d] mismatch exp=%08h act=%08h",i,WDATA[i],rhs_.WDATA[i]))
            	end
        	end
    	end

    	if(WSTRB.size()!=rhs_.WSTRB.size()) begin
        	status = 0;
        	`uvm_error("COMPARE",$sformatf("WSTRB size mismatch exp=%0d act=%0d",WSTRB.size(),rhs_.WSTRB.size()))
    	end
    	else begin
        	foreach(WSTRB[i]) begin
            	if(WSTRB[i]!=rhs_.WSTRB[i]) begin
                	status = 0;
               	 	`uvm_error("COMPARE",$sformatf("WSTRB[%0d] mismatch exp=%0h act=%0h",i,WSTRB[i],rhs_.WSTRB[i]))
            	end
        	end
    	end

    	//-----------------------------
    	// Write Response Channel
    	//-----------------------------
    	if(BID!=rhs_.BID) begin
        	status=0;
        	`uvm_error("COMPARE",$sformatf("BID mismatch exp=%0h act=%0h",BID,rhs_.BID))
    	end

    	if(BRESP!=rhs_.BRESP) begin
        	status=0;
        	`uvm_error("COMPARE",$sformatf("BRESP mismatch exp=%0d act=%0d",BRESP,rhs_.BRESP))
    	end

    	//-----------------------------
    	// Read Address Channel
   	 	//-----------------------------
    	if(ARID!=rhs_.ARID) begin
        	status=0;
        	`uvm_error("COMPARE",$sformatf("ARID mismatch exp=%0h act=%0h",ARID,rhs_.ARID))
    	end

    	if(ARADDR!=rhs_.ARADDR) begin
        	status=0;
        	`uvm_error("COMPARE",$sformatf("ARADDR mismatch exp=%08h act=%08h",ARADDR,rhs_.ARADDR))
    	end

    	if(ARLEN!=rhs_.ARLEN) begin
        	status=0;
        	`uvm_error("COMPARE",$sformatf("ARLEN mismatch exp=%0d act=%0d",ARLEN,rhs_.ARLEN))
    	end

    	if(ARSIZE!=rhs_.ARSIZE) begin
        	status=0;
        	`uvm_error("COMPARE",$sformatf("ARSIZE mismatch exp=%0d act=%0d",ARSIZE,rhs_.ARSIZE))
    	end

    	if(ARBURST!=rhs_.ARBURST) begin
        	status=0;
        	`uvm_error("COMPARE",$sformatf("ARBURST mismatch exp=%0d act=%0d",ARBURST,rhs_.ARBURST))
    	end

    	//-----------------------------
    	// Read Data Channel
    	//-----------------------------
    	if(RID!=rhs_.RID) begin
        	status=0;
        	`uvm_error("COMPARE",$sformatf("RID mismatch exp=%0h act=%0h",RID,rhs_.RID))
    	end

    	if(RRESP.size() != rhs_.RRESP.size()) begin
        	status=0;
        	`uvm_error("COMPARE",$sformatf("RRESP size mismatch exp=%0d act=%0d",RRESP.size(),rhs_.RRESP.size()))
    	end
    	else begin
        	foreach(RRESP[i]) begin
            	if(RRESP[i]!=rhs_.RRESP[i]) begin
                	status=0;
                	`uvm_error("COMPARE",$sformatf("RRESP[%0d] mismatch exp=%08h act=%08h",i,RRESP[i],rhs_.RRESP[i]))
            	end
        	end
    	end
  	

    	if(RLAST!=rhs_.RLAST) begin
        	status=0;
        	`uvm_error("COMPARE","RLAST mismatch")
    	end

    	if(RDATA.size()!=rhs_.RDATA.size()) begin
        	status=0;
        	`uvm_error("COMPARE",$sformatf("RDATA size mismatch exp=%0d act=%0d",RDATA.size(),rhs_.RDATA.size()))
    	end
    	else begin
        	foreach(RDATA[i]) begin
            	if(RDATA[i]!=rhs_.RDATA[i]) begin
                	status=0;
                	`uvm_error("COMPARE",$sformatf("RDATA[%0d] mismatch exp=%08h act=%08h",i,RDATA[i],rhs_.RDATA[i]))
            	end
        	end
    	end

    return status;

	endfunction
endclass