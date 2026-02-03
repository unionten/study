`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/16 12:39:31
// Design Name: 
// Module Name: tb_scaler
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


module tb_scaler(

    );
reg  [63:0] rd_1_data  = 0;
wire [63:0] data_2 ;
wire rd_1 ;
reg rd_2 ;
reg clk;
reg clk_slow;
reg vs ;
reg rst ;
wire rd_valid ;

always #5 clk = ~clk ;
always #20 clk_slow = ~clk_slow ;

always #10 rd_1_data  = rd_1_data + 64'h0F0B0A0102080C04;



initial begin


    rd_2 = 0;
    clk = 0;
    clk_slow = 0;
    rst = 1;
    vs = 0;
    #200;
    
    rst = 0;
    #200;
    vs =1 ;
    #20;
    vs = 0;
    
    #50000;
    
    
    vs =1 ;
    #20;
    vs = 0;
    
    
    
    
    
    
    
end
    
    
scaler  
    #(.C_PORT_NUM         (4)    ,
      .C_BYTES_PER_PIXEL  (2)    ,
      .C_FIFO_DEPTH       (1024) )
    scaler_u
    (
    .AXI4_CLK_I          (clk)   ,
    .AXI4_RSTN_I         (~rst)    ,
    .VS_AXI4_I           (vs)    ,
    .HACTIVE_AXI4_I      (64)   , // 11  
    .VACTIVE_AXI4_I      (16) ,   // 
    .SCALE_ENABLE_AXI4_I (1)  ,
    .HSCALE_MODE_AXI4_I  (2), //0:原始bypass  1:/2   2:4 
    .VSCALE_MODE_AXI4_I  (2), //0:原始bypass  1:/2   2:4 
    .RD_EMPTY_AXI4_I     (0),
    .RD_RST_BUSY_AXI4_I  (0),
    .RD_AXI4_O           (rd_1) ,//对于上级读；  上级模式假定为fwft  ; 一般为从axi4 拉取
    .RD_DATA_AXI4_I      (rd_1_data)   ,
    .VID_CLK_I           (clk_slow),
    .VID_RSTN_I          (~rst)   ,
    .VS_VID_I            (vs)  ,
    .RD_VID_I            (1),
    .RD_DATA_VALID_VID_O (rd_valid),
    .RD_EMPTY_VID_O      (),
    .RD_RST_BUSY_VID_O   (),
    .DATA_VID_O          (data_2)//内部结构为fifo;  外部强行拉数据

    );
    
   
    
    
    
endmodule
