`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/11/03 14:20:23
// Design Name: 
// Module Name: tb_spi_bypass_tri 
//////////////////////////////////////////////////////////////////////////////////
module tb_spi_write_bypass_tri(

);

reg clk;
reg rst;
reg start;
reg [79:0] pdata;
wire [79:0] pdata_o;
wire [7:0] State;
wire [7:0] State2;
assign State = uut.State;


reg [7:0] Num;


spi_write_bypass_tri  
    #(.MAX_BYTE_NUM(10),
      .USE_SAME_EDGE(0))
uut(  
.RST_I           (rst),
.CLK_I           (clk),//bypass  negedge
.CMD_I           (2),//
.START_I         (start),
.PDATA_I         (80'hAABBAAAAAAAAFFCC55AA ),//先发高位字节，后发低位字节，高位补0
.DATA_BYTE_NUM_I (Num),
.ROUND_NUM_I     (2),
.CS_O            (cs),
.SCK_O           (sck),
.DO_O            (do_0),
.BUSY_O          (busy),
.READ_PULSE_O    (read_pulse),
.ALMOST_PULSE_O  (almost_pulse)
);

always #20 clk = ~clk;

initial begin
    pdata = 80'hAABBAAAAAAAAFFCC55AA;
    rst = 1;
    clk = 0;
    start = 0;
    #200;
    rst = 0;
    #200;
    
    
    start = 1;
    Num = 3;
    #30;
    start = 0;
    
    
    #450;
    start = 1;
    Num = 4;
    #30;
    start = 0;
    
    
    
end

initial begin
    //#1600;
    
    //pdata = 80'hFFAACC;

end

endmodule
