interface axi_if(input bit ACLK, ARESETn);

//write address channel
logic [3:0] AWID;
logic [31:0] AWADDR;
logic [3:0] AWLEN;
logic [2:0] AWSIZE;
logic [1:0] AWBURST;
logic AWVALID;
logic AWREADY;

//write data channel
logic [3:0] WID;
logic [31:0] WDATA;
logic [3:0] WSTRB;
logic WLAST;
logic WVALID;
logic WREADY;

//Write response channe
logic [3:0] BID;
logic [1:0] BRESP;
logic BVALID;
logic BREADY;

//Read address channel
logic [3:0] ARID;
logic [31:0] ARADDR;
logic [3:0] ARLEN;
logic [2:0] ARSIZE;
logic [1:0] ARBURST;
logic ARVALID;
logic ARREADY;

//Read data channel
logic [3:0] RID;
logic [31:0] RDATA;
logic [1:0] RRESP;
logic RLAST;
logic RVALID;
logic RREADY;

//driver master
clocking master_drv_cb @(posedge ACLK);

//----------- write address ---------
	default input #1 output #1;
	output AWADDR;
	output AWID;
	output AWLEN;
	output AWSIZE;
	output AWBURST;
	output AWVALID;
	input AWREADY;


//--------- WRITE DATA ---------

	output WDATA;
	output WID;
	output WSTRB;
	output WLAST;
	output WVALID;
	input WREADY;


//--------- WRITE RESPONSE ---------

	output BREADY;
	input BRESP;
	input BVALID;
	input BID;

//---------- READ ADDRESS -------

	output ARADDR;
	output ARID;
	output ARLEN;
	output ARSIZE;
	output ARBURST;
	output ARVALID;
	input ARREADY;

//----------- READ DATA------------

	input RDATA;
	input RID;
	input RRESP;
	input RLAST;
	input RVALID;
	output RREADY;	
endclocking

//monitor master UVM_ALL_ON||UVM_ 
clocking master_mon_cb @(posedge ACLK);
	default input #1 output #1;
//----------- write address ---------
	input AWADDR;
	input AWID;
	input AWLEN;
	input AWSIZE;
	input AWBURST;
	input AWVALID;
	input AWREADY;


//--------- WRITE DATA ---------

	input WDATA;
	input WID;
	input WSTRB;
	input WLAST;
	input WVALID;
	input WREADY;


//--------- WRITE RESPONSE ---------

	input BREADY;
	input BRESP;
	input BVALID;
	input BID;

//---------- READ ADDRESS -------

	input ARADDR;
	input ARID;
	input ARLEN;
	input ARSIZE;
	input ARBURST;
	input ARVALID;
	input ARREADY;

//----------- READ DATA------------

	input RDATA;
	input RID;
	input RRESP;
	input RVALID;
	input RREADY;
	input RLAST;	
endclocking

//Read slave
clocking slave_mon_cb @(posedge ACLK);
	default input #1 output #1;
//...........Write Address.........

	input AWID;
	input AWADDR;
	input AWLEN;
	input AWSIZE;
	input AWBURST;
	input AWVALID;
	input AWREADY;


//...........Write Data.......

	input WID;
	input WDATA;
	input WSTRB;
	input WLAST;
	input WVALID;
	input WREADY;

//.........write response........

	input BID;
	input BRESP;
	input BVALID;
	input BREADY;


//.......Read Address.........

	input ARID;
	input ARADDR;
	input ARLEN;
	input ARSIZE;
	input ARBURST;
	input ARVALID;
	input ARREADY;


//..............Read Data..........

	input RID;
	input RDATA;
	input RRESP;
	input RLAST;
	input RVALID;
	input RREADY;		
endclocking

//Write slave
clocking slave_drv_cb @(posedge ACLK);
	default input #1 output #1;	
//----------- write address ---------

	input AWADDR;
	input AWID;
	input AWLEN;
	input AWSIZE;
	input AWBURST;
	input AWVALID;
	output AWREADY;


//--------- WRITE DATA ---------

	input WDATA;
	input WID;
	input WSTRB;
	input WLAST;
	input WVALID;
	output WREADY;


//--------- WRITE RESPONSE ---------

	input BREADY;
	output BRESP;
	output BVALID;
	output BID;

//---------- READ ADDRESS -------

	input ARADDR;
	input ARID;
	input ARLEN;
	input ARSIZE;
	input ARBURST;
	input ARVALID;
	output ARREADY;

//----------- READ DATA------------

	output RDATA;
	output RID;
	output RRESP;
	output RLAST;
	output RVALID;
	input RREADY;
	
endclocking


modport MASTER_DRV(clocking master_drv_cb, input ARESETn);
modport MASTER_MON(clocking master_mon_cb, input ARESETn);
modport SLAVE_DRV(clocking slave_drv_cb, input ARESETn);
modport SLAVE_MON(clocking slave_mon_cb, input ARESETn);


property awvalid;
    @(posedge ACLK) disable iff  (!ARESETn)
    (AWVALID && !AWREADY)
        |=> $stable({AWADDR, AWID, AWLEN, AWSIZE, AWBURST});
endproperty

property wvalid;
    @(posedge ACLK) disable iff  (!ARESETn)
    (WVALID && !WREADY)
        |=> $stable({WDATA, WSTRB, WLAST});
endproperty

property bvalid;
    @(posedge ACLK) disable iff  (!ARESETn)
    (BVALID && !BREADY)
        |=> $stable({BRESP, BID}); // Remove BID for AXI4
endproperty

property arvalid;
    @(posedge ACLK) disable iff  (!ARESETn)
    (ARVALID && !ARREADY)
        |=> $stable({ARADDR, ARID, ARLEN, ARSIZE, ARBURST});
endproperty

property rvalid;
    @(posedge ACLK) disable iff  (!ARESETn)
    (RVALID && !RREADY)
        |=> $stable({RDATA, RID, RRESP, RLAST});
endproperty


A1: assert property (awvalid)
	$display(" AWVALID successful");
else
	$display("AWVALID failed");

A2: assert property (wvalid)
	$display(" WVALID successful");
else
	$display("WVALID failed");

A3: assert property (arvalid)
	$display(" ARVALID successful");
else
	$display("ARVALID failed");

A4: assert property (rvalid)
	$display(" RVALID successful");
else
	$display("RVALID failed");

A5: assert property (bvalid)
	$display(" BVALID successful");
else
	$display("BAVLID failed");

endinterface
