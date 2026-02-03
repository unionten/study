`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/02 14:58:23
// Design Name: 
// Module Name: tb_lvds_phy_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Dependencies: 
//////////////////////////////////////////////////////////////////////////////////


module tb_lvds_phy_tx(

    );

parameter C_DEVICE    = "KUP" ;
parameter C_DATA_RATE = "SDR" ;
parameter C_LANE_NUM  = 2 ;
parameter C_DATA_WIDTH_PER_LANE = 4 ;


reg [7:0] d;
reg clkfast;
reg clkdiv;
reg align_req;

wire [C_LANE_NUM-1:0] LVDS_DATA_P;
wire [C_LANE_NUM-1:0] LVDS_DATA_N;

wire [C_LANE_NUM-1:0] BIT_ALIGN_O  ;
wire [C_LANE_NUM-1:0] BYTE_ALIGN_O ;



lvds_phy_tx  
    #(.C_DEVICE              (C_DEVICE     ),//"KU" "KUP" "A7" "K7"
      .C_DATA_RATE           (C_DATA_RATE          ),//"SDR" "DDR"
      .C_LANE_NUM            (C_LANE_NUM           ),
      .C_DATA_WIDTH_PER_LANE (C_DATA_WIDTH_PER_LANE)  )// 【单线位宽】 注意，要根据上表配置，不一定和用户认为的位宽一致  --   用户位宽
    lvds_phy_tx_u(
    .D           (8'b10011010      ),
    .CLKFAST_I   (clkfast ),
    .CLKDIV_I    (clkdiv  ), 
    .LVDS_DATA_P (LVDS_DATA_P  ),
    .LVDS_DATA_N (LVDS_DATA_N  ),
    .LVDS_CLK_P  (LVDS_CLK_P   ),
    .LVDS_CLK_N  (LVDS_CLK_N   )
    
    );   
wire [3:0] LVDS_DATA_O;

lvds_phy_rx  
    #(.C_DEVICE              (C_DEVICE ),//"KU" "KUP" "A7" "K7"
      .C_DATA_RATE           (C_DATA_RATE          ),//"SDR" "DDR"
      .C_LANE_NUM            (C_LANE_NUM           ),
      .C_DATA_WIDTH_PER_LANE (C_DATA_WIDTH_PER_LANE)  )// 【单线位宽】 注意，要根据上表配置，不一定和用户认为的位宽一致  --   用户位宽
    lvds_phy_rx_u(
    .LVDS_DATA_P   (LVDS_DATA_P  ),
    .LVDS_DATA_N   (LVDS_DATA_N  ),
    .CLKFAST_I     (clkfast),
    .CLKDIV_I      (clkdiv),//div 4
    .CLKDIV_RST_I  (0),//~CLKDIV_I
    .COMP_VAL_I    (8'b01010101),
    .LVDS_DATA_O   (LVDS_DATA_O   ),//~CLKDIV_I
    .BIT_ALIGN_O   (BIT_ALIGN_O   ),//~CLKDIV_I
    .BYTE_ALIGN_O  (BYTE_ALIGN_O  ),  //~CLKDIV_I
    .INIT_REQ_I    (align_req)

);
    




always #2.5 clkfast = ~clkfast;
always #10  clkdiv  = ~clkdiv ;

initial begin
    d = 8'b11001010;
    align_req = 0 ;
    clkfast = 1;
    clkdiv  = 1;
    
    #500;
    d = 8'b11001010;
    
    #500;
    d = 8'b11001010;
    
    #500;
    align_req= 1;
    #20;
    align_req = 0;
    
    
    #1000;
    d = 8'b11001010;


end

 
    
endmodule
