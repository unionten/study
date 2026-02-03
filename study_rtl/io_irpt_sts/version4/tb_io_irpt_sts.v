`timescale 1ns / 1ps

//`define ADDR_GPI_IRPT_STS_0  16'h0010   //gpi io 中断状态寄存器
//`define ADDR_GPI_IRPT_STS_1  16'h0014 
//`define ADDR_GPI_IRPT_STS_2  16'h0018 
//`define ADDR_GPI_IRPT_STS_3  16'h001C 
//`define ADDR_GPI_IRPT_STS_4  16'h0020 
//`define ADDR_GPI_IRPT_STS_5  16'h0024 
//`define ADDR_GPI_IRPT_STS_6  16'h0028 
//`define ADDR_GPI_IRPT_STS_7  16'h002C 



//新版本
`define ADDR_GPI_IRPT_STS_0   16'h100C    // GPI 的中断状态，例如电平中断，脉冲中断
`define ADDR_GPI_IRPT_STS_1   16'h200C 
`define ADDR_GPI_IRPT_STS_2   16'h300C 
`define ADDR_GPI_IRPT_STS_3   16'h400C 
`define ADDR_GPI_IRPT_STS_4   16'h500C 
`define ADDR_GPI_IRPT_STS_5   16'h600C 
`define ADDR_GPI_IRPT_STS_6   16'h700C 
`define ADDR_GPI_IRPT_STS_7   16'h800C 




//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/01/13 15:26:04
// Design Name: 
// Module Name: tb_io_irpt_sts
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


module tb_io_irpt_sts(

    );
    
    
reg clk ;
reg rstn ;
reg rd;
reg [15:0] rd_addr ;
reg [7:0] GPI_CH0_I ;
reg [7:0] GPI_CH1_I ;
reg [7:0] GPI_CH2_I ;
reg [7:0] GPI_CH3_I ;
reg [7:0] GPI_CH4_I ;
reg [7:0] GPI_CH5_I ;
reg [7:0] GPI_CH6_I ;
reg [7:0] GPI_CH7_I ;

wire [31:0] GPI_INT_STS_CH0_O  ;
wire [31:0] GPI_INT_STS_CH1_O  ;
wire [31:0] GPI_INT_STS_CH2_O  ;
wire [31:0] GPI_INT_STS_CH3_O  ;
wire [31:0] GPI_INT_STS_CH4_O  ;
wire [31:0] GPI_INT_STS_CH5_O  ;
wire [31:0] GPI_INT_STS_CH6_O  ;
wire [31:0] GPI_INT_STS_CH7_O  ;

wire IRPT_O ;



io_irpt_sts  
    
    #(.C_CH_NUM    (8) ,
      .C_GPI_WIDTH (8) ,
      .C_IRPT_PRD_NUM (100) ,
      .C_PRD_CLK_NS   ( 10),
      .C_PULSE_DET_THRESHOLD_MS (1) ) 
    io_irpt_sts_u(
    .CLK_I             (clk  ),
    .RSTN_I            (rstn    ), 
    .RD_I              (rd      ),
    .RD_ADDR_I         (rd_addr ),
    .GPI_CH0_I         (GPI_CH0_I   ),  
    .GPI_CH1_I         (GPI_CH1_I   ),
    .GPI_CH2_I         (GPI_CH2_I   ),
    .GPI_CH3_I         (GPI_CH3_I   ),
    .GPI_CH4_I         (GPI_CH4_I   ),
    .GPI_CH5_I         (GPI_CH5_I   ),
    .GPI_CH6_I         (GPI_CH6_I   ),
    .GPI_CH7_I         (GPI_CH7_I   ),
    .GPI_INT_STS_CH0_O (GPI_INT_STS_CH0_O ),
    .GPI_INT_STS_CH1_O (GPI_INT_STS_CH1_O ),
    .GPI_INT_STS_CH2_O (GPI_INT_STS_CH2_O ),
    .GPI_INT_STS_CH3_O (GPI_INT_STS_CH3_O ),
    .GPI_INT_STS_CH4_O (GPI_INT_STS_CH4_O ),
    .GPI_INT_STS_CH5_O (GPI_INT_STS_CH5_O ),
    .GPI_INT_STS_CH6_O (GPI_INT_STS_CH6_O ),
    .GPI_INT_STS_CH7_O (GPI_INT_STS_CH7_O ),
    
    .IRPT_MODE_CH0_I (8'b00000001), //0: IRPT_O 只输出电平中断   1: IRPT_O 只输出脉冲中断
    .IRPT_MODE_CH1_I (8'b00000000),
    .IRPT_MODE_CH2_I (8'b00000000),
    .IRPT_MODE_CH3_I (8'b00000000),
    .IRPT_MODE_CH4_I (8'b00000000),
    .IRPT_MODE_CH5_I (8'b00000000),
    .IRPT_MODE_CH6_I (8'b00000000),
    .IRPT_MODE_CH7_I (8'b00000000),
    
    .IRPT_EN_CH0_I (8'b00000001), //0: IRPT_O 只输出电平中断   1: IRPT_O 只输出脉冲中断
    .IRPT_EN_CH1_I (8'b00000000),
    .IRPT_EN_CH2_I (8'b00000000),
    .IRPT_EN_CH3_I (8'b00000000),
    .IRPT_EN_CH4_I (8'b00000000),
    .IRPT_EN_CH5_I (8'b00000000),
    .IRPT_EN_CH6_I (8'b00000000),
    .IRPT_EN_CH7_I (8'b00000000),
    
    
    .IRPT_O           (IRPT_O         )

    );
    

always #5 clk = ~clk ;

initial begin
GPI_CH0_I = 0;
GPI_CH1_I = 0;
GPI_CH2_I = 0;
GPI_CH3_I = 0;
GPI_CH4_I = 0;
GPI_CH5_I = 0;
GPI_CH6_I = 0;
GPI_CH7_I = 0;

clk = 0;
rd = 0;
rd_addr = 0;
rstn = 0;
#400;
rstn =1 ;
#4000;

GPI_CH0_I = 8'b00000001;
GPI_CH1_I = 8'b00000000;
GPI_CH2_I = 8'b00000000;
GPI_CH3_I = 8'b00000000;
GPI_CH4_I = 8'b00000000;
GPI_CH5_I = 8'b00000000;
GPI_CH6_I = 8'b00000000;
GPI_CH7_I = 8'b00000000;


#11000;
GPI_CH0_I = 8'b00000000;
GPI_CH1_I = 8'b00000000;
GPI_CH2_I = 8'b00000000;
GPI_CH3_I = 8'b00000000;
GPI_CH4_I = 8'b00000000;
GPI_CH5_I = 8'b00000000;
GPI_CH6_I = 8'b00000000;
GPI_CH7_I = 8'b00000000;

#11000;
GPI_CH0_I = 8'b00000001;
GPI_CH1_I = 8'b00000000;
GPI_CH2_I = 8'b00000000;
GPI_CH3_I = 8'b00000000;
GPI_CH4_I = 8'b00000000;
GPI_CH5_I = 8'b00000000;
GPI_CH6_I = 8'b00000000;
GPI_CH7_I = 8'b00000000;


#11000;
GPI_CH0_I = 8'b00000000;
GPI_CH1_I = 8'b00000000;
GPI_CH2_I = 8'b00000000;
GPI_CH3_I = 8'b00000000;
GPI_CH4_I = 8'b00000000;
GPI_CH5_I = 8'b00000000;
GPI_CH6_I = 8'b00000000;
GPI_CH7_I = 8'b00000000;

#11000;GPI_CH0_I = 8'b00000001;
GPI_CH1_I = 8'b00000000;
GPI_CH2_I = 8'b00000000;
GPI_CH3_I = 8'b00000000;
GPI_CH4_I = 8'b00000000;
GPI_CH5_I = 8'b00000000;
GPI_CH6_I = 8'b00000000;
GPI_CH7_I = 8'b00000000;


#11000;
GPI_CH0_I = 8'b00000000;
GPI_CH1_I = 8'b00000000;
GPI_CH2_I = 8'b00000000;
GPI_CH3_I = 8'b00000000;
GPI_CH4_I = 8'b00000000;
GPI_CH5_I = 8'b00000000;
GPI_CH6_I = 8'b00000000;
GPI_CH7_I = 8'b00000000;

#11000;GPI_CH0_I = 8'b00000001;
GPI_CH1_I = 8'b00000000;
GPI_CH2_I = 8'b00000000;
GPI_CH3_I = 8'b00000000;
GPI_CH4_I = 8'b00000000;
GPI_CH5_I = 8'b00000000;
GPI_CH6_I = 8'b00000000;
GPI_CH7_I = 8'b00000000;


#11000;
GPI_CH0_I = 8'b00000000;
GPI_CH1_I = 8'b00000000;
GPI_CH2_I = 8'b00000000;
GPI_CH3_I = 8'b00000000;
GPI_CH4_I = 8'b00000000;
GPI_CH5_I = 8'b00000000;
GPI_CH6_I = 8'b00000000;
GPI_CH7_I = 8'b00000000;

#11000;GPI_CH0_I = 8'b00000001;
GPI_CH1_I = 8'b00000000;
GPI_CH2_I = 8'b00000000;
GPI_CH3_I = 8'b00000000;
GPI_CH4_I = 8'b00000000;
GPI_CH5_I = 8'b00000000;
GPI_CH6_I = 8'b00000000;
GPI_CH7_I = 8'b00000000;


#11000;
GPI_CH0_I = 8'b00000000;
GPI_CH1_I = 8'b00000000;
GPI_CH2_I = 8'b00000000;
GPI_CH3_I = 8'b00000000;
GPI_CH4_I = 8'b00000000;
GPI_CH5_I = 8'b00000000;
GPI_CH6_I = 8'b00000000;
GPI_CH7_I = 8'b00000000;

#11000;GPI_CH0_I = 8'b00000001;
GPI_CH1_I = 8'b00000000;
GPI_CH2_I = 8'b00000000;
GPI_CH3_I = 8'b00000000;
GPI_CH4_I = 8'b00000000;
GPI_CH5_I = 8'b00000000;
GPI_CH6_I = 8'b00000000;
GPI_CH7_I = 8'b00000000;


#11000;
GPI_CH0_I = 8'b00000000;
GPI_CH1_I = 8'b00000000;
GPI_CH2_I = 8'b00000000;
GPI_CH3_I = 8'b00000000;
GPI_CH4_I = 8'b00000000;
GPI_CH5_I = 8'b00000000;
GPI_CH6_I = 8'b00000000;
GPI_CH7_I = 8'b00000000;

#11000;
rd = 1 ;
rd_addr =`ADDR_GPI_IRPT_STS_1 ;
#20;
rd =  0 ;

#5000;

rd = 1 ;
rd_addr =`ADDR_GPI_IRPT_STS_0 ;
#20;
rd =  0 ;





end








 
    
endmodule
