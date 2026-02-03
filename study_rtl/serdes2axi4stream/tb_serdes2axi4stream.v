`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/28 14:12:23
// Design Name: 
// Module Name: tb_serdes2axi4stream
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_serdes2axi4stream(

    );
  
reg sclk;
reg mclk;
reg srst;
reg mrst;
reg [7:0] sdata;
  

always #5 sclk = ~sclk;
always #20 mclk = ~mclk;


initial begin
    sdata = 8'hff;
    sclk = 0;
    mclk = 0;
    srst = 1;
    mrst = 1;
    #204;
    srst = 0;
    mrst = 0;
    
    #2040;
    
    sdata = 8'hff; #10;
    sdata = 8'hff; #10;
    sdata = 8'h00; #10;
    sdata = 8'h00; #10;
    sdata = 8'hA5; #10;
    sdata = 8'hA5; #10;
    sdata = 8'h00; #10;
    sdata = 8'h02; #10;
    sdata = 8'haa; #10;
    sdata = 8'h00; #10;
    sdata = 8'h07; #10;
    sdata = 8'hee; #10;
    sdata = 8'h01; #10;
    sdata = 8'h02; #10;
    sdata = 8'h03; #10;
    sdata = 8'h04; #10;
    sdata = 8'h05; #10;
    sdata = 8'h06; #10;
    sdata = 8'h07; #10;
    sdata = 8'hcc; #10;
    sdata = 8'h00; #10;
    sdata = 8'h00; #10;
    sdata = 8'hff; #10;
    sdata = 8'hff; #10;
    
    
    
    
end



serdes2axi4stream 
#( .SDATA_WIDTH        (8   ) ,
   .MDATA_WIDTH        (8 ) ,
   .AWPORT_WIDTH       (2   ) ,
   .AWLEN_WIDTH        (16  ) ,
   .AWSIZE_WIDTH       (16  ) ,
   .WAIT_ACK_TIME_OUT  (1000) ,
   .RX_CHECK_CRC_EN    (0   )
)
serdes2axi4stream_uut(
.S_CLK_I        (sclk ),  
.S_RST_I        (srst ),
.S_DATA_I       (sdata),//check CRC in this module
.S_SEND_ACK_O   (),
.S_SEND_SUCC_I  (1),
.S_WAIT_ACK_I   (0),
.S_WAIT_SUCC_O  (),
             
.M_CLK_I        (mclk ) ,
.M_RST_I        (mrst) ,
.M_AWPORT       () ,
.M_AWLEN        () ,
.M_AWSIZE       () ,
.M_AWVALID      () ,
.M_AWREADY      (1) ,
.M_WVALID       () ,
.M_WREADY       (1) ,
.M_WDATA        () ,  
.M_WSTRB        () ,
.M_WLAST        ()  


);
    

    
    
endmodule
