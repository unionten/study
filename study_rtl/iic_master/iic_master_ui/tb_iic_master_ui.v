`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/09 11:35:05
// Design Name: 
// Module Name: tb_iic_master_ui
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


//`CLK_DIV_OUTGEN(SYS_CLK_I,SYS_RST_I,iic_scl,CLK_DIV)
//`CLK_DIV_OUTGEN(SYS_CLK_I,SYS_RST_I,iic_scl_m2,(CLK_DIV/2)) //fast 
//`POS_MONITOR_OUTGEN(SYS_CLK_I,0,iic_scl_m2,iic_scl_m2_pos)
//`NEG_MONITOR_OUTGEN(SYS_CLK_I,0,iic_scl_m2,iic_scl_m2_neg)
//`POS_MONITOR_OUTGEN(SYS_CLK_I,0,START_I,START_I_pos)
//
//assign SCL_O = iic_scl ;
//
//assign BUSY_O = Busy | START_I_pos ;
//
//assign scl_high_mid = iic_scl & iic_scl_m2_pos;
//assign scl_low_mid  = ~iic_scl & iic_scl_m2_pos;
//



module tb_iic_master_ui(

    );

reg clk;
reg rst;
reg start ;

reg [7:0] wr_num;
reg [7:0] rd_num;




wire iic_scl_m2     ;
wire iic_scl_m2_pos ;
wire iic_scl_m2_neg ;
wire scl_high_mid   ;
wire scl_low_mid    ;
wire [7:0] state ;


assign  iic_scl_m2 = iic_master_ui_u.iic_scl_m2;
assign  iic_scl_m2_pos = iic_master_ui_u.iic_scl_m2_pos;
assign  iic_scl_m2_neg = iic_master_ui_u.iic_scl_m2_neg;
assign  scl_high_mid   = iic_master_ui_u.scl_high_mid;
assign  scl_low_mid   = iic_master_ui_u.scl_high_mid;
assign  state = iic_master_ui_u.state ;



 
iic_master_ui 
#( .WR_MAX_LEN (7),
   .RD_MAX_LEN (1),
   .CLK_DIV    (1000)) 
    iic_master_ui_u(
    .SYS_CLK_I     (clk),
    .SYS_RST_I     (rst),
    .SDA_I         (1),
    .SDA_O         (SDA_O),
    .SDA_T         (SDA_T),
    .SCL_I         (0),//no use
    .SCL_O         (SCL_O),
    .SCL_T         (SCL_T),//always out
    .WR_BYTE_NUM_I (7 ), //>=0, first 
    .WR_DATA_I     (80'hbbaa77665544332255aa),
    .RD_BYTE_NUM_I (0), //>=0, second
    .RD_DATA_O     (),
    .START_I       (start    ),//pulse
    .BUSY_O        (BUSY_O   ),
    .FINISH_O      (FINISH_O ),
    .ERROR_O       (ERROR_O  )    
    
    );
    
always #5 clk = ~clk;

initial begin
    wr_num = 0;
    rd_num = 0;
    clk = 0;
    start = 0;
    rst = 1;
    #500;
    rst = 0;
    #5000;
    

    start  = 1 ;
    wr_num = 5;
    rd_num = 5;
    #50 ;
    start = 0;
    #200000;
    
    start  = 1 ;
    wr_num = 5;
    rd_num = 0;
    #50 ;
    start = 0;
    #200000;
    
    
    start  = 1 ;
    wr_num = 0;
    rd_num = 5;
    #50 ;
    start = 0;
    #200000;
    
    start  = 1 ;
    wr_num = 0;
    rd_num = 0;
    #50 ;
    start = 0;
    #200000;
    
    
    

end  
    
    
    
endmodule
