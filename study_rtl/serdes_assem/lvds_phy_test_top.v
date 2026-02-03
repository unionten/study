`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/19 17:40:38
// Design Name: 
// Module Name: lvds_phy_test_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module lvds_phy_test_top(
input sys_clk_p ,
input sys_clk_n ,

output [1:0] LVDS_DATA_P_O ,
output [1:0] LVDS_DATA_N_O ,
output       LVDS_CLK_P_O  ,
output       LVDS_CLK_N_O  ,

input  [1:0] LVDS_DATA_P_I ,
input  [1:0] LVDS_DATA_N_I ,
input        LVDS_CLK_P_I  ,
input        LVDS_CLK_N_I  



    );


parameter C_DEVICE    = "KUP" ;
parameter C_DATA_RATE = "DDR" ;
parameter C_LANE_NUM  = 2 ;
parameter C_DATA_WIDTH_PER_LANE = 8 ;


    
    

wire align_req;

wire [C_LANE_NUM-1:0] LVDS_DATA_P;
wire [C_LANE_NUM-1:0] LVDS_DATA_N;

wire [C_LANE_NUM-1:0] BIT_ALIGN_O  ;
wire [C_LANE_NUM-1:0] BYTE_ALIGN_O ;

wire clkfast;
wire clkdiv;



clk_wiz_0  clk_wiz_0_u(
  .clk_out1  (clk200),
  .clk_out2  (clk50),
  .clk_out3  (clk400),
  .reset     (0),
  .locked    (),
  .clk_in1_p (sys_clk_p ),
  .clk_in1_n (sys_clk_n )
 );


assign clkfast = clk200;
assign clkdiv  = clk50;

wire [7:0] d;
wire [7:0] COMP_VAL;

wire [7:0] LVDS_DATA  ;
wire [1:0] BIT_ALIGN  ;
wire [1:0] BYTE_ALIGN ;


lvds_phy_tx  
    #(.C_DEVICE              (C_DEVICE     ),//"KU" "KUP" "A7" "K7"
      .C_DATA_RATE           (C_DATA_RATE          ),//"SDR" "DDR"
      .C_DATA_WIDTH_PER_LANE            (C_LANE_NUM  ) )// 【单线位宽】 注意，要根据上表配置，不一定和用户认为的位宽一致  --   用户位宽
    lvds_phy_tx_u(
    .D           (d       ),
    .CLKFAST_I   (clkfast ),
    .CLKDIV_I    (clkdiv  ), 
    .LVDS_DATA_P (LVDS_DATA_P_O  ),
    .LVDS_DATA_N (LVDS_DATA_N_O  ),
    .LVDS_CLK_P  (LVDS_CLK_P_O   ),
    .LVDS_CLK_N  (LVDS_CLK_N_O   )

    );   
    
vio_0 vio_0_u(
    .clk         (clkdiv ) ,
    .probe_out0  (d ),
    .probe_out1  (COMP_VAL),
    .probe_out2  (align_req)
    
    );  
    
    
    


//lvds_phy_rx  
//    #(.C_DEVICE              (C_DEVICE ),//"KU" "KUP" "A7" "K7"
//      .C_DATA_RATE           (C_DATA_RATE          ),//"SDR" "DDR"
//      .C_DATA_WIDTH_PER_LANE            (C_LANE_NUM  ) )
//    lvds_phy_rx_u(
//    .LVDS_DATA_P   (LVDS_DATA_P_I  ),
//    .LVDS_DATA_N   (LVDS_DATA_N_I  ),
//    .CLKFAST_I     (clkfast),
//    .CLKDIV_I      (clkdiv),//div 4
//    .CLKDIV_RST_I  (0),//~CLKDIV_I
//    .COMP_VAL_I    (COMP_VAL),
//    .LVDS_DATA_O   (LVDS_DATA   ),//~CLKDIV_I
//    .BIT_ALIGN_O   (BIT_ALIGN   ),//~CLKDIV_I
//    .BYTE_ALIGN_O  (BYTE_ALIGN  ),  //~CLKDIV_I
//    .INIT_REQ_I    (align_req)
//
//);
    
   wire [1:0] lvds_data_p ;

   IBUFDS IBUFDS_inst (
      .O(lvds_data_p[0]     ),   // 1-bit output: Buffer output
      .I( LVDS_DATA_P_I[0]  ),   // 1-bit input: Diff_p buffer input (connect directly to top-level port)
      .IB(LVDS_DATA_N_I[0]  )  // 1-bit input: Diff_n buffer input (connect directly to top-level port)
   );
   IBUFDS IBUFDS_inst2 (
      .O(lvds_data_p[1]     ),   // 1-bit output: Buffer output
      .I( LVDS_DATA_P_I[1]  ),   // 1-bit input: Diff_p buffer input (connect directly to top-level port)
      .IB(LVDS_DATA_N_I[1]  )  // 1-bit input: Diff_n buffer input (connect directly to top-level port)
   );
   
   
    
    

ila_0 ila_0
(
.clk    (clk400  ),
.probe0 (LVDS_DATA ),
.probe1 (BIT_ALIGN ),
.probe2 (BYTE_ALIGN ),
.probe3 (lvds_data_p[0]),
.probe4 (lvds_data_p[1])

);






    
    
endmodule
