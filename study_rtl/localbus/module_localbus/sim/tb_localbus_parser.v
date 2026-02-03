`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/19 15:04:57
// Design Name: 
// Module Name: tb_localbus_parser
// Project Name: 
// Target Devices: 
//////////////////////////////////////////////////////////////////////////////////

module tb_localbus_parser(
);

    
reg rst;
reg clk;

always #50 clk = ~clk;

reg start;
wire dq0;
wire dq1;
wire de ;


    
//ld_parser uut(
localbus_sender
    #(.MAX_UNIT_NUM(4), 
      .UNIT_BIT_NUM(32))  
     localbus_sender_u(
    .RST_I           (rst),
    .CLK_I           (clk),
    .PDATA_I         (128'hffeeddcc_11223344_55667788_aa55aa55),//[MAX_UNIT_NUM*UNIT_BIT_NUM-1:0]
    .VALID_UNIT_NUM_I(4),//[7:0]
    .START_I         (start),
    .CLK_O           (clk_o),
    .DE_O            (de),
    .DQ0_O           (dq0),
    .DQ1_O           (dq1),
    .ALMOST_PULSE_O  (),
    .BUSY_O          (),
    .CONTINUE_I      (0)
    );


localbus_parser
    #(.MODE(1),//0:DE_I拉低时解析不终止; 1:DE_I拉低时解析终止
      .UNIT_BIT_NUM(32))
    localbus_parser_u  (
    .RST_I          (rst),
    .CLK_I         (clk_o),//【每个分组中,先收到的放在LB_低位(即LB_0)】
    .DE_I          (de),//【数据中心和CLK_I上升沿对齐】
    .DQ0_I         (dq0),//b30 ... b6 b4 b2 b0  b30 ... b6 b4 b2 b0 
    .DQ1_I         (dq1),//b31 ... b7 b5 b3 b1  b31 ... b7 b5 b3 b1   
    .ENABLE_I      (1),
    .LB_FINISH_0_O (),
    .LB_DATA_0_O   (),
    .LB_FINISH_1_O (),
    .LB_DATA_1_O   (),
    .LB_FINISH_2_O (),
    .LB_DATA_2_O   (),
    .LB_FINISH_3_O (),
    .LB_DATA_3_O   (),
    .UNIT_NUM_I    (4),//【每次UNIT数(1~4)】
    .CYCLE_NUM_I   (1) //【解析次数】
    );


initial begin  
    rst = 1;
    clk = 0;

    start = 0;
    #2000;
    rst = 0;
    
    #500;
    start = 1;
    #200;
    start = 0;
    
end 
    
    
    

    
endmodule
