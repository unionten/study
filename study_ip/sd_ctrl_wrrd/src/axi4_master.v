
`timescale 1ns / 1ns

module axi4_master#
(
	// parameter    		DDR_OFFSET_ADDRESS 	= 'h0000_0000,
	parameter  integer  M_AXI_ID_WIDTH		= 1			,
	parameter  integer  M_AXI_ID			= 0			,
	parameter  integer  M_AXI_ADDR_WIDTH	= 32		,
	parameter  integer  M_AXI_DATA_WIDTH	= 512
)
(
	input [31:0] 								i_ddr_addr_h		,
	input [31:0] 								i_ddr_addr_l		,


	input	wire [15:0]							fdma_wlen			,
	input   wire [15:0]                      	fdma_wsize          ,
	input   wire [M_AXI_ADDR_WIDTH-1 :0]      	fdma_waddr          ,
	input   wire [M_AXI_DATA_WIDTH-1 :0]       	fdma_wdata			,
	input	wire [M_AXI_DATA_WIDTH/8-1 :0]		fdma_wstrb			,	//计算显示像素的位置生成STRB
	output  wire [ 8:0]                       	fdma_wburst_cnt  	,
	output	reg  [15:0]							fdma_wleft_cnt		,
	output	wire [15:0]							fdma_cnt			,
	output	wire 								fdma_wend			,

	input                                       fdma_wareq          ,
	output                                      fdma_wbusy          ,
	output  wire                               	fdma_wvalid         ,
	input	wire                               	fdma_wready			,


	input 	wire  								M_AXI_ACLK			,
	input 	wire  								M_AXI_ARESETN		,

	input 	wire  								i_ddr_addr_rst		,

	output 	wire [M_AXI_ID_WIDTH-1 :0]		    M_AXI_AWID			,
	output 	wire [M_AXI_ADDR_WIDTH-1 :0] 	    M_AXI_AWADDR		,
	output 	wire [ 7:0]							M_AXI_AWLEN			,
	output 	wire [ 2:0] 						M_AXI_AWSIZE		,
	output 	wire [ 1:0] 						M_AXI_AWBURST		,
	output 	wire  								M_AXI_AWLOCK		,
	output 	wire [ 3:0] 						M_AXI_AWCACHE		,
	output 	wire [ 2:0] 						M_AXI_AWPROT		,
	output 	wire [ 3:0] 						M_AXI_AWQOS			,
	output 	wire  								M_AXI_AWVALID		,
	input	wire  								M_AXI_AWREADY		,

	output  wire [M_AXI_ID_WIDTH-1 :0]	 		M_AXI_WID			,
	output  wire [M_AXI_DATA_WIDTH-1 :0] 	    M_AXI_WDATA			,
	output  wire [M_AXI_DATA_WIDTH/8-1 :0]	 	M_AXI_WSTRB			,
	output  wire  								M_AXI_WLAST			,
	output  wire  								M_AXI_WVALID		,
	input   wire  								M_AXI_WREADY		,
	input   wire [M_AXI_ID_WIDTH-1 :0] 			M_AXI_BID			,
	input   wire [ 1:0] 						M_AXI_BRESP			,
	input   wire  								M_AXI_BVALID		,
	output  wire  								M_AXI_BREADY

);

localparam AXI_BYTES =  M_AXI_DATA_WIDTH / 8;//512/8=64

function integer clogb2 (input integer bit_depth);
begin
	for(clogb2 = 0; bit_depth > 0; clogb2 = clogb2 + 1)
		bit_depth = bit_depth >> 1;
end
endfunction

//fdma axi write----------------------------------------------
reg 	[M_AXI_ADDR_WIDTH-1 :0] 	axi_awaddr				;
reg  						 		axi_awvalid				;
wire 	[M_AXI_DATA_WIDTH-1 :0] 	axi_wdata				;
wire								axi_wstrb				;
wire								axi_wlast				;
reg  								axi_wvalid				;
wire                               	w_next      			;
reg   [ 8:0]                       	wburst_len  			;
reg   [ 8:0]                       	wburst_cnt  			;
reg   [31:0]                       	wfdma_cnt   			;
reg                                	axi_wstart_locked 		;
wire  [31:0] 						axi_wburst_size   		;

assign M_AXI_AWID		= M_AXI_ID;
assign M_AXI_AWADDR		= axi_awaddr + i_ddr_addr_l;
assign M_AXI_AWLEN		= wburst_len - 1;
assign M_AXI_AWSIZE		= clogb2(AXI_BYTES-1);
assign M_AXI_AWBURST	= 2'b01;
assign M_AXI_AWLOCK		= 1'b0;
assign M_AXI_AWCACHE	= 4'b0010;
assign M_AXI_AWPROT		= 3'h0;
assign M_AXI_AWQOS		= 4'h0;
assign M_AXI_AWVALID	= axi_awvalid;
assign M_AXI_WDATA		= axi_wdata;

//assign M_AXI_WSTRB	= {(AXI_BYTES){1'b1}};
assign M_AXI_WSTRB		= fdma_wstrb;//axi_wstrb

assign M_AXI_WLAST		= axi_wlast;
assign M_AXI_WVALID		= axi_wvalid & fdma_wready;
assign M_AXI_BREADY		= 1'b1;
assign axi_wburst_size  = wburst_len * AXI_BYTES;
//----------------------------------------------------------------------------
//AXI4 FULL Write

reg     fdma_wstart_locked 	;
//wire    fdma_wend			;
wire    fdma_wstart			;
reg axi_wstart_locked_r1 = 1'b0;
reg axi_wstart_locked_r2 = 1'b0;

assign  axi_wdata   = fdma_wdata			;
assign  fdma_wvalid = w_next				;
assign  fdma_wbusy 	= fdma_wstart_locked 	;//fdma_wstart_locked axi_wstart_locked_r2

always @(posedge M_AXI_ACLK)
	if(M_AXI_ARESETN == 1'b0 || axi_wlast == 1'b1 )
	// if(M_AXI_ARESETN == 1'b0 || fdma_wend == 1'b1 )
		fdma_wstart_locked <= 1'b0;
	else if(fdma_wstart)
		fdma_wstart_locked <= 1'b1;

assign fdma_wstart = (fdma_wstart_locked == 1'b0 && fdma_wareq == 1'b1);


// ila_0 ddr_master (
// 	.clk(M_AXI_ACLK), // input wire clk
// 	.probe0({fdma_wleft_cnt,wburst_len}), // input wire [255:0]  probe0
// 	.probe1({axi_wvalid,fdma_wready,fdma_wbusy,fdma_wvalid}), // input wire [31:0]  probe1
// 	.probe2({axi_awvalid,M_AXI_AWREADY,fdma_wstart,M_AXI_WVALID,M_AXI_WREADY}), // input wire [31:0]  probe2
// 	.probe3(wburst_cnt), // input wire [15:0]  probe3
// 	.probe4(axi_wlast) // input wire [0:0]  probe4
// );





// ila_0 axi4_master_ila (
// 	.clk(M_AXI_ACLK), // input wire clk
//     .probe0(fdma_wdata), // input wire [31:0]  probe0
// 	.probe1(axi_awaddr), // input wire [31:0]  probe1
// 	.probe2(), // input wire [31:0]  probe2
// 	.probe3(fdma_cnt), // input wire [15:0]  probe3
// 	.probe4(fdma_wbusy), // input wire [7:0]  probe4
// 	.probe5(axi_wvalid), // input wire [7:0]  probe5
// 	.probe6({fdma_wareq,M_AXI_AWVALID,M_AXI_AWREADY,M_AXI_WREADY,fdma_wready}),// input wire [7:0]  probe6
// 	.probe7(fdma_wstart_locked), // input wire [7:0]  probe7
// 	.probe8(fdma_wstart), // input wire [0:0]  probe8
// 	.probe9(axi_wlast) // input wire [0:0]  probe9
// );


//AXI4 write burst lenth busrt addr ------------------------------
always @(posedge M_AXI_ACLK)
	if((M_AXI_ARESETN == 1'b0) || (i_ddr_addr_rst == 0))
		axi_awaddr <= 0;
    else if(fdma_wstart)
        // axi_awaddr <= fdma_waddr + i_ddr_addr_l + (i_ddr_addr_h << 32);
		axi_awaddr <= axi_awaddr  ; //////////////////////////////////////////////////////////////////////////////////////////////////
    else if(axi_wlast == 1'b1)
        axi_awaddr <= axi_awaddr + axi_wburst_size ;


//AXI4 write cycle -----------------------------------------------


always @(posedge M_AXI_ACLK)begin
	if(M_AXI_ARESETN == 1'b0)begin
		axi_wstart_locked_r1 <= 1'b0;
		axi_wstart_locked_r2 <= 1'b0;
	end else begin
    	axi_wstart_locked_r1 <= axi_wstart_locked		;
    	axi_wstart_locked_r2 <= axi_wstart_locked_r1	;
	end
end

//always @(posedge M_AXI_ACLK)
//	if(M_AXI_ARESETN == 1'b0)begin
//		axi_wstart_locked <= 1'b0;
//	end else if((fdma_wstart_locked == 1'b1) && axi_wstart_locked == 1'b0)
//	    axi_wstart_locked <= 1'b1;
//	else if(axi_wlast == 1'b1 || fdma_wstart == 1'b1)
//	    axi_wstart_locked <= 1'b0;

always @(posedge M_AXI_ACLK)
	if(M_AXI_ARESETN == 1'b0)begin
		axi_wstart_locked <= 1'b0;
	//end else if((fdma_wstart_locked == 1'b1) && axi_wstart_locked == 1'b0)
	end else if((fdma_wstart_locked == 1'b1) && (axi_wstart_locked == 1'b0) && (b_vaild_locked == 1'b1))
	    axi_wstart_locked <= 1'b1;
	else if(axi_wlast == 1'b1 || fdma_wstart == 1'b1)
	    axi_wstart_locked <= 1'b0;

reg b_vaild_locked;
always @(posedge M_AXI_ACLK)
if(M_AXI_ARESETN == 1'b0)
  b_vaild_locked <= 1'b1;
else if((fdma_wstart_locked == 1'b1) && (axi_wstart_locked == 1'b0) && (b_vaild_locked == 1'b1) )
  b_vaild_locked <= 1'b0;
else if(M_AXI_BVALID)
  b_vaild_locked <= 1'b1;


//AXI4 addr valid and write addr-----------------------------------
always @(posedge M_AXI_ACLK)
	if(M_AXI_ARESETN == 1'b0)begin
		axi_awvalid <= 1'b0;
	end else if((axi_wstart_locked_r1 == 1'b1) && axi_wstart_locked_r2 == 1'b0)
        axi_awvalid <= 1'b1;
    else if((axi_wstart_locked == 1'b1 && M_AXI_AWREADY == 1'b1) || axi_wstart_locked == 1'b0)
        axi_awvalid <= 1'b0;

//AXI4 write data---------------------------------------------------
always @(posedge M_AXI_ACLK)
	if(M_AXI_ARESETN == 1'b0)begin
		axi_wvalid <= 1'b0;//
	end else if((axi_wstart_locked_r1 == 1'b1) && axi_wstart_locked_r2 == 1'b0)
		axi_wvalid <= 1'b1;
	else if(axi_wlast == 1'b1 || axi_wstart_locked == 1'b0)
		axi_wvalid <= 1'b0;//

//AXI4 write data burst len counter----------------------------------
always @(posedge M_AXI_ACLK)
	if(M_AXI_ARESETN == 1'b0)begin
		wburst_cnt <= 'd0;
	end else if(axi_wstart_locked == 1'b0)
		wburst_cnt <= 'd0;
	else if(w_next)
		wburst_cnt <= wburst_cnt + 1'b1;

assign w_next    = M_AXI_WVALID & M_AXI_WREADY;
assign axi_wlast = (w_next == 1'b1) && (wburst_cnt == M_AXI_AWLEN);
assign fdma_wburst_cnt = wburst_cnt;

//fdma write data burst len counter----------------------------------
reg 		wburst_len_req ;
//reg [31:0] 	fdma_wleft_cnt ;

always @(posedge M_AXI_ACLK)
	if(M_AXI_ARESETN == 1'b0)begin
		wburst_len_req <=  1'b0;
	end else
        wburst_len_req <= fdma_wstart | axi_wlast;

always @(posedge M_AXI_ACLK)
	if(M_AXI_ARESETN == 1'b0)begin
		fdma_wleft_cnt <= 32'd0;
		wfdma_cnt 	   <=   'd0;
	end else if( fdma_wstart )begin
		wfdma_cnt 	   <= 1'd0;
		fdma_wleft_cnt <= fdma_wlen ;//fdma_wsize
	end
	else if(w_next)begin
		wfdma_cnt 	   <= wfdma_cnt + 1'b1;
	    fdma_wleft_cnt <= (fdma_wlen - 1'b1) - wfdma_cnt;//fdma_wsize
    end

assign fdma_wend = w_next && (fdma_wleft_cnt == 1 );
assign fdma_cnt  = wfdma_cnt;

always @(posedge M_AXI_ACLK)begin
	if(M_AXI_ARESETN == 1'b0)begin
		wburst_len <= 1;
	end else if(wburst_len_req)begin
       	if(fdma_wleft_cnt[15:8] > 0)
			wburst_len <= 256;//256 fdma_wlen
       	else
           	wburst_len <= fdma_wleft_cnt[7:0];
    end else
	 	wburst_len <= wburst_len;
end

endmodule


