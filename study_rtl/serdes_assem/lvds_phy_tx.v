`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/02 14:22:20
// Design Name: 
// Module Name: lvds_phy_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module lvds_phy_tx
#( parameter C_DEVICE  =  "KU" ,//"KU" "KUP" "A7" "K7"
parameter C_DATA_RATE  =  "SDR",//"SDR" "DDR"
parameter C_LANE_NUM   =  2 ,
parameter C_RATIO =  4 // 【单线位宽】 注意，要根据上表配置，不一定和用户认为的位宽一致  --   用户位宽
 )
(
input  [C_RATIO*C_LANE_NUM-1:0] D     ,
input  CLKFAST_I   ,//input fast clk 
input  CLKDIV_I    ,//input div  clk  
output [C_LANE_NUM-1:0] LVDS_DATA_P ,
output [C_LANE_NUM-1:0] LVDS_DATA_N ,
output                  LVDS_CLK_P  ,
output                  LVDS_CLK_N  ,
input                   ASYNC_RST_I            


);

 
genvar i,j,k;

wire                  lvds_clk  ;
wire [C_LANE_NUM-1:0] lvds_data ;

generate for(i=0; i<C_LANE_NUM ;i=i+1)begin
   OBUFDS OBUFDS_inst (
      .O(LVDS_DATA_P[i] ),   // 1-bit output: Diff_p output (connect directly to top-level port)
      .OB(LVDS_DATA_N[i]), // 1-bit output: Diff_n output (connect directly to top-level port)
      .I(lvds_data[i])    // 1-bit input: Buffer input
   );
end
endgenerate
   
   

   OBUFDS OBUFDS_inst2 (
      .O(LVDS_CLK_P),   // 1-bit output: Diff_p output (connect directly to top-level port)
      .OB(LVDS_CLK_N), // 1-bit output: Diff_n output (connect directly to top-level port)
      .I(lvds_clk)    // 1-bit input: Buffer input
   );

generate for(i=0; i<C_LANE_NUM ;i=i+1) begin
oserdes  
    #(.C_DEVICE     (C_DEVICE     ) ,//=  "K7" ;//"KU" "KUP" "A7" "K7"
      .C_DATA_RATE  (C_DATA_RATE  ) ,//=  "DDR";
      .C_DATA_WIDTH (C_RATIO )   )//= 8; 
    oserdes_data_u(
    .D_I     (D[C_RATIO*i+:C_RATIO]), //[7:0] 
    .T_I     (0), //[3:0]
    .OQ_O    (lvds_data[i]),
    .TQ_O    (),
    .CLK_I   (CLKFAST_I ),
    .CLKDIV_I(CLKDIV_I  ),
    .RST_I   (ASYNC_RST_I)

    );
end
endgenerate



oserdes  
    #(.C_DEVICE     (C_DEVICE     ) ,//=  "K7" ;//"KU" "KUP" "A7" "K7"
      .C_DATA_RATE  (C_DATA_RATE  ) ,//=  "DDR";
      .C_DATA_WIDTH (C_RATIO ) )  
    oserdes_clk_u(
    .D_I     (8'b01010101), //[7:0] 
    .T_I     (0), //[3:0]
    .OQ_O    (lvds_clk),
    .TQ_O    (),
    .CLK_I   (CLKFAST_I ),
    .CLKDIV_I(CLKDIV_I),
    .RST_I   (ASYNC_RST_I)

    );
 
    
    
endmodule
