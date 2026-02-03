// ========================================================================
// File	Name	 : AXI_Lite_Slave.v                                          
// Module		 	: AXI_Lite_Slave                                            
// ========================================================================
// Function		 : AXI LITE Slave Interface to Local Bus
// ------------------------------------------------------------------------
// Update History:                                                         
// ------------------------------------------------------------------------
// Rev.Level   Date			  Coded	By		Contents                       
// v0.0.1	   2017/07/06	  Alittle_Liu		Create New                     
// ------------------------------------------------------------------------
// Update Details :                                                        
// ------------------------------------------------------------------------
// Date		 Contents Detail                                               
// ========================================================================
// End	revision                                                           

`timescale 1ns / 1ps

module axi_lite_slave #(
//	parameter		P_AXI_LITE_BAR = 32'hFFFF_0000	// AXI-Lite Bus base address
    parameter integer   C_S_AXI_DATA_WIDTH    =  32   ,
    parameter integer   C_S_AXI_ADDR_WIDTH    =  32    
	)(
	////////////////////////////////////////////////////
	// AXI4 Lite Slave interface
	input	 wire 													S_AXI_ACLK		,
	input	 wire 													S_AXI_ARESETN	,
	// AXI write address channel signals
	output wire 													S_AXI_AWREADY	,// Indicates slave is ready to accept 
	input	 wire [C_S_AXI_ADDR_WIDTH-1:0]	S_AXI_AWADDR	,// Write address
	input	 wire 													S_AXI_AWVALID	,// Write address valid
	input	 wire [ 2:0]										S_AXI_AWPROT	,// Write address protec
	// AXI write data channel signals
	output wire 													    S_AXI_WREADY	,// Write data ready
	input	 wire [C_S_AXI_DATA_WIDTH-1:0]	    S_AXI_WDATA		,// Write data
	input	 wire [(C_S_AXI_DATA_WIDTH/8)-1 :0]	S_AXI_WSTRB		,// Write strobes
	input	 wire																S_AXI_WVALID	,// Write valid
	// AXI write response channel signals
	output wire [ 1:0]												S_AXI_BRESP		,// Write response
	output wire 															S_AXI_BVALID	,// Write reponse valid
	input	 wire 															S_AXI_BREADY	,// Response ready
	// AXI read address channel signals
	output wire 															S_AXI_ARREADY	,// Read address ready
	input	 wire [C_S_AXI_ADDR_WIDTH-1:0]			S_AXI_ARADDR	,// Read address
	input	 wire 															S_AXI_ARVALID	,// Read address valid
	input  wire [ 2:0]												S_AXI_ARPROT	,// Write address protec
	// AXI read data channel signals	
	output wire [ 1:0]												S_AXI_RRESP		,// Read response
	output wire 															S_AXI_RVALID	,// Read reponse valid
	output wire [C_S_AXI_DATA_WIDTH-1:0]			S_AXI_RDATA		,// Read data
	input	 wire 															S_AXI_RREADY	,// Read Response ready
	
	////////////////////////////////////////////////////
	// Local Bus User interface
	output wire 															o_rx_dval,
	output wire [C_S_AXI_ADDR_WIDTH-1:0]			o_rx_addr,
	output wire [C_S_AXI_DATA_WIDTH-1:0]			o_rx_data,
	
	output wire 															o_tx_req,
	output wire [C_S_AXI_ADDR_WIDTH-1:0]			o_tx_addr,
	input  wire	[C_S_AXI_DATA_WIDTH-1:0]			i_tx_data,
	input  wire 															i_tx_dval   
		
);

	// local parameter 
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = 2 ;
	localparam integer OPT_MEM_ADDR_BITS = 5;

	reg [C_S_AXI_ADDR_WIDTH-1: 0] 	axi_awaddr		;
	reg  														axi_awready		;
	reg  														axi_wready		;
	reg [1 : 0] 										axi_bresp		  ;
	reg  														axi_bvalid		;
	reg [C_S_AXI_ADDR_WIDTH-1: 0] 	axi_araddr		;
	reg  														axi_arready		;
	reg [C_S_AXI_DATA_WIDTH-1: 0] 	axi_rdata		  ;
	reg [1 : 0] 										axi_rresp		  ;
	reg  														axi_rvalid	 	;
	wire														slv_reg_rden	;
	wire														slv_reg_wren	;
	wire [C_S_AXI_DATA_WIDTH-1:0]	  reg_data_out	  ;
	wire														w_data_out;

	// I/O Connections assignments
	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY		= axi_wready;
	assign S_AXI_BRESP		= axi_bresp;
	assign S_AXI_BVALID		= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA		= axi_rdata;
	assign S_AXI_RRESP		= axi_rresp;
	assign S_AXI_RVALID		= axi_rvalid;
	
	assign	reg_data_out= i_tx_data	  	;
	assign  w_data_out  = i_tx_dval			;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.
	always @( posedge S_AXI_ACLK ) begin
	  if ( S_AXI_ARESETN == 1'b0 ) begin
	      axi_awready <= 1'b0;
	  end else begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID) begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	      end else begin
	          axi_awready <= 1'b0;
	      end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK ) begin
	  if ( S_AXI_ARESETN == 1'b0 ) begin
	      axi_awaddr <= 0;
	  end else begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID) begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	      end else begin
	      	axi_awaddr <=  axi_awaddr;
	      end
	  end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK ) begin
	  if ( S_AXI_ARESETN == 1'b0 ) begin
	      axi_wready <= 1'b0;
	  end else begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID) begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	      end else begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK ) begin
	  if ( S_AXI_ARESETN == 1'b0 )  begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	  end else begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	      end else begin          // work error responses in future
	          if (S_AXI_BREADY && axi_bvalid) begin
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	              axi_bvalid <= 1'b0; 
	          end  
	          else begin
	          	axi_bvalid  <= 1'b0;
	          	axi_bresp   <= 2'b0;
	          end
	      end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK ) begin
	  if ( S_AXI_ARESETN == 1'b0 ) begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	  end else begin    
	      if (~axi_arready && S_AXI_ARVALID) begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	      end else begin
	          axi_arready <= 1'b0;
	      end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
/*always @( posedge S_AXI_ACLK ) begin
	  if ( S_AXI_ARESETN == 1'b0 ) begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	  end else begin    
	      if (w_data_out) begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	      end else if (axi_rvalid && S_AXI_RREADY) begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	          axi_rresp  <= 2'b0;
	      end else begin
	      		axi_rvalid <= axi_rvalid;
	          axi_rresp  <= axi_rresp;              
	    end
	end */   
always @( posedge S_AXI_ACLK ) 
	  if ( S_AXI_ARESETN == 1'b0 ) begin	
	  	axi_rvalid <= 0;
	 		axi_rresp  <= 0; end
	 	else if(w_data_out)begin
	    // Valid read data is available at the read data bus
	    axi_rvalid <= 1'b1;
	    axi_rresp  <= 2'b0; end
	  else if (axi_rvalid && S_AXI_RREADY) begin
	    // Read data is accepted by the master
	    axi_rvalid <= 1'b0;
	    axi_rresp  <= 2'b0;  end
	  else begin
	  	axi_rvalid <= 1'b0;
	    axi_rresp  <= 2'b0;  end	
 




	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid ;
	
always @ (posedge S_AXI_ACLK)
if(S_AXI_ARESETN == 1'b0 )	   
	axi_rdata  <= 0;
else if(w_data_out)
	axi_rdata <= reg_data_out ;     // register read data
else if(axi_rvalid && S_AXI_RREADY)
	axi_rdata <=  axi_rdata;
else 
	axi_rdata  <= 0;

	assign	o_rx_dval  = slv_reg_wren	;
	assign	o_rx_addr	 = axi_awaddr 	;
	assign	o_rx_data	 = S_AXI_WDATA	;
	//assign	oLB_WBEN	= S_AXI_WSTRB	;

	assign	o_tx_req 	  = slv_reg_rden	;
	assign	o_tx_addr 	= axi_araddr	  ;


endmodule

/*	// Output register or memory read data
	always @( posedge S_AXI_ACLK ) begin
	  if ( S_AXI_ARESETN == 1'b0 ) begin
	      axi_rdata  <= 0;
	  end else begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (w_data_out) begin
	          axi_rdata <= reg_data_out ;     // register read data
	      end  else if (axi_rvalid && S_AXI_RREADY) begin
	      		axi_rdata <=  axi_rdata;
	      end	else 	begin
	      		axi_rdata  <= 0;
	      end
	  end 
	  	
	end */
