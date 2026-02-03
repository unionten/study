`timescale 1ns / 1ps
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define POS_MONITOR_INGEN(clk,rst,in,out)                                                               begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  



//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2024/02/02 11:28:38
// Design Name: 
// Module Name: lvds_phy_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module lvds_phy_rx(
input  [C_LANE_NUM-1:0] LVDS_DATA_P ,
input  [C_LANE_NUM-1:0] LVDS_DATA_N ,
input  [C_LANE_NUM*C_RATIO-1:0] COMP_VAL_I ,//~CLKDIV_I
input  CLKFAST_I     ,
input  CLKDIV_I      ,//div 4
input  CLKDIV_RST_I  ,//~CLKDIV_I  , 理解：功能复位
output [C_LANE_NUM*C_RATIO-1:0] LVDS_DATA_O  ,//~CLKDIV_I
output [C_LANE_NUM-1:0] BIT_ALIGN_O  ,//~CLKDIV_I
output [C_LANE_NUM-1:0] BYTE_ALIGN_O,  //~CLKDIV_I
input  INIT_REQ_I   , //~CLKDIV_I
input  ASYNC_RST_I    

);


parameter C_DEVICE        =  "KU" ;//"KU" "KUP" "A7" "K7"
parameter C_DATA_RATE     =  "SDR";//"SDR" "DDR"
parameter C_LANE_NUM      = 2 ; 
parameter C_RATIO         = 4 ; 
parameter [0:0] C_ILA_EN  = 0 ;   
    
genvar i,j,k;


wire [C_LANE_NUM-1:0] lvds_data_s_in;
wire [C_LANE_NUM-1:0] lvds_data_s_dly;
wire [C_RATIO-1:0] lvds_data_p_bit_align [C_LANE_NUM-1:0];
wire [C_RATIO-1:0] lvds_data_p_bit_align2[C_LANE_NUM-1:0];
wire [8:0] CNTVALUE_SET[C_LANE_NUM-1:0];
wire [8:0] CNTVALUE_TRUE[C_LANE_NUM-1:0];
wire [C_LANE_NUM-1:0] BITALIGN_DONE  ;
wire [C_LANE_NUM-1:0] BYTEALIGN_DONE ;
wire [C_LANE_NUM-1:0] LD;
wire [C_RATIO-1:0] lvds_data_p_byte_align2[C_LANE_NUM-1:0];
wire [C_LANE_NUM-1:0] BITALIGN_DONE_pos;


generate for(i=0; i<C_LANE_NUM; i=i+1)begin
`POS_MONITOR_INGEN(CLKDIV_I ,CLKDIV_RST_I ,BITALIGN_DONE[i],BITALIGN_DONE_pos[i]) 
end
endgenerate


assign BIT_ALIGN_O = BITALIGN_DONE;
assign BYTE_ALIGN_O = BYTEALIGN_DONE ;


generate for(i=0;i<C_LANE_NUM;i=i+1)begin: loop

IBUFDS IBUFDS_inst2 (
   .O(lvds_data_s_in[i]),   // 1-bit output: Buffer output
   .I(LVDS_DATA_P[i]),   // 1-bit input: Diff_p buffer input (connect directly to top-level port)
   .IB(LVDS_DATA_N[i])  // 1-bit input: Diff_n buffer input (connect directly to top-level port)
);


idelay  
   #(.C_DEVICE      ( C_DEVICE  ),
     .C_DLY_SRC     ( "IDATAIN"),
     .C_DLY_FORMAT  ( "COUNT"),
     .C_DLY_TYPE    ( "VAR_LOAD"),
     .C_DLY_VALUE   ( 0     ),
     .C_REFCLK_FREQ ( 200.0 )
    )
    idelay_u(
    .DATA_I     (0),
    .IDATA_I    (lvds_data_s_in[i]),
    .CLK_I      (CLKDIV_I), //The CLK of the IDELAYE3 must be the same CLK as the ISERDESE3 CLKDIV.
    .RST_I      (0),
    .CE_I       (0),
    .INC_I      (0),
    .LD_I       (LD[i]),
    .CNTVALUE_I (CNTVALUE_SET[i]),
    .DATA_O     (lvds_data_s_dly[i]),
    .CNTVALUE_O (CNTVALUE_TRUE[i])

    );


iserdes  
   #(.C_DEVICE     ( C_DEVICE ),
     .C_DATA_RATE  (C_DATA_RATE ),
     .C_DATA_WIDTH (C_RATIO     ) )
    iserdes_u(
    .CLK_I     (CLKFAST_I),
    .CLKDIV_I  (CLKDIV_I ),
    .BITSLIP_I (0), //bitslip是在两次结果之间的位移
    .RST_I     (ASYNC_RST_I ),  
    .D_I       (lvds_data_s_dly[i]),
    .Q_O       (lvds_data_p_bit_align[i]) 
    );


wire bit_align_req;
assign bit_align_req = INIT_REQ_I ;


bit_align
    #(.C_DEVICE      ( C_DEVICE ),  
      .C_DATA_WIDTH  ( C_RATIO     ) )
    bit_align_u(
    .CLK_I            (CLKDIV_I), // (often DIVCLK) be the dependant clk controlling idelay (not the fast or slow clk of i/o serdes)
    .RST_I            (CLKDIV_RST_I), 
    .REQ_I            (INIT_REQ_I  ), // pulse, start bit align op
    .DATA_I           (lvds_data_p_bit_align[i]), // data before bit align                        
    .INC_O            (), // no use
    .LD_O             (LD[i]), // pulse, load delay tap
    .CNTVALUE_SET_O   (CNTVALUE_SET[i]), // proposed   delay tap num    0  ~  511 
    .CNTVALUE_TRUE_I  (CNTVALUE_TRUE[i]), // effective  delay tap num    0  ~  511 
    .DATA_O           (lvds_data_p_bit_align2[i]), // data after bit align 
    .BITALIGN_DONE_O  (BITALIGN_DONE[i])
                                                                        
    );


byte_align
    #(.C_DATA_WIDTH     ( C_RATIO ), //= 8 ;  
      .C_FUNCTION       ( "COMP" ), //= "COMP"  "SLIP"  
      .C_COMP_THRESHOLD ( 100    ) ) //= 100;
    byte_align_u  (
    .CLK_I           (CLKDIV_I      ),
    .RST_I           (CLKDIV_RST_I  ),
    .DATA_I          (lvds_data_p_bit_align2[i]  ),
    .BIT_SLIP_I      (0),  // 循环  d0c0b0a0   -> c0b0a0 d1 
    .COMP_VAL_I      (COMP_VAL_I[C_RATIO*i+:C_RATIO]),  //
    .COMP_TRIG_I     (BITALIGN_DONE_pos[i]),  // 
    .COMP_DONE_O     (BYTEALIGN_DONE[i] ),  // ___|————————
    .DATA_O          (LVDS_DATA_O[C_RATIO*i+:C_RATIO]  )  
    
    
    );
    
end
endgenerate




generate if( C_ILA_EN )begin
    ila_lvds_phy_rx 
        ila_lvds_phy_rx_u
    (
        .clk     (CLKDIV_I                         ),
        .probe0  ( bit_align_req                   ),
        .probe1  (CNTVALUE_SET[0]                  ),//[8:0]
        .probe2  (CNTVALUE_TRUE[0]                 ),
        .probe3  (loop[0].bit_align_u.state        ),
        .probe4  (loop[0].bit_align_u.data_mid     ),
        .probe5  (LD[0]                            ),
        .probe6  (loop[0].bit_align_u.DATA_O       ),
        .probe7  ( BITALIGN_DONE[0]                ),
        .probe8  (loop[0].byte_align_u.COMP_TRIG_I ),
        .probe9  (loop[0].byte_align_u.DATA_O      ),                  
        .probe10 (loop[0].byte_align_u.comp_result ),
        .probe11 (loop[0].byte_align_u.COMP_DONE_O )
        

    );

end
endgenerate 
    
    
endmodule
