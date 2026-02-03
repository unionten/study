`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/29 10:15:01
// Design Name: 
// Module Name: tb_axi4stream2serdes
// Project Name: 
// Target Devices: 
//////////////////////////////////////////////////////////////////////////////////

module tb_axi4stream2serdes(

    );
 
reg mclk;
reg mrst;
reg sclk;
reg srst;

reg [63:0] sdata;
reg        svalid;
reg [7:0]  strb = 8'b00001111;
reg slast;


always #20 mclk = ~mclk;
always #5 sclk = ~sclk;
 
axi4stream2serdes
#(.SDATA_WIDTH      (64  ),
  .MDATA_WIDTH      (8   ), 
  .AWPORT_WIDTH     (2   ),
  .AWLEN_WIDTH      (16  ),
  .AWSIZE_WIDTH     (16  ),
  .WAIT_ACK_TIME_OUT(1000),
  .RX_CHECK_CRC_EN  (0  )
  )
axi4stream2serdes_u
(
.M_CLK_I       (mclk) ,  
.M_RST_I       (mrst ) ,
.M_DATA_O      () ,
.M_SEND_ACK_I  () ,
.M_SEND_SUCC_O () ,
.M_WAIT_ACK_O  () ,
.M_WAIT_SUCC_I () ,
.S_CLK_I       (sclk) ,
.S_RST_I       (srst) ,
.S_AWPORT      () ,
.S_AWLEN       () ,
.S_AWSIZE      () ,
.S_AWVALID     (1) ,
.S_AWREADY     () ,
.S_WVALID      (svalid) , 
.S_WREADY      () ,
.S_WDATA       (sdata) ,  
.S_WSTRB       (strb ) ,
.S_WLAST       (slast) 
);
 
        

initial begin
    sdata = 0;
    strb = 0;
    slast = 0;
    svalid = 0;
    mclk = 0;
    sclk = 0;
    srst = 1;
    mrst = 1;
    #501;
    srst = 0;
    mrst = 0;
    #905;
    
    strb = 0;
    slast = 0;
    svalid = 1;
    sdata  = 64'hee0700aa0100a5a5;#10;
    sdata  = 64'h0000000000CC0201;
    strb   = 8'b00000111;
    slast  = 1;
    #10;
    slast  = 0;
    svalid = 0;
    #500;

end
    
    
endmodule
