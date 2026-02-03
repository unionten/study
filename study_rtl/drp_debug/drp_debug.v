`timescale 1ns / 1ps
`define CDC_MULTI_BIT_SIGNAL_OUTGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_SINGLE_BIT_PULSE_OUTGEN(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM,DEST_FF)               generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(DEST_FF), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/29 09:38:31
// Design Name: 
// Module Name: drp_debug
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////
//

module drp_debug(
input                 DRPCLK_I  ,
input                 DRPRSTN_I  ,
input  [C_ADDR_WIDTH-1:0] S_DRPADDR_I ,
input [C_DATA_WIDTH-1:0]  S_DRPDI_I   ,
output  [C_DATA_WIDTH-1:0] S_DRPDO_O   ,
input                 S_DRPEN_I   ,
input                 S_DRPWE_I   ,
output                S_DRPRDY_O  ,

output [C_ADDR_WIDTH-1:0] M_DRPADDR_O ,
output [C_DATA_WIDTH-1:0] M_DRPDI_O   ,
input  [C_DATA_WIDTH-1:0] M_DRPDO_I   ,
output                M_DRPEN_O   ,
output                M_DRPWE_O   ,
input                 M_DRPRDY_I  ,

input                 SYS_CLK_I ,
input                 SYS_RSTN_I ,
output                SYS_UART_O ,


input                 EYE_RST_ASYNC

);

parameter  C_ADDR_WIDTH =  12;
parameter  C_DATA_WIDTH =  16;  
parameter  C_SYS_CLK_PRD = 10;
parameter  C_BAUD_RATE   = 115200;
parameter  [0:0] C_UART_ENABLE = 0;
parameter  [0:0] C_SYS_ILA_ENABLE  = 0;
 

//write addr data \n
//wrack xxxx xxxx \n
//read  addr xxxx \n
//rdack xxxx data \n

wire uart_busy;
wire uart_finish;

wire [C_ADDR_WIDTH-1:0] DRPADDR_inter;  reg [C_ADDR_WIDTH-1:0] DRPADDR_inter_buf; 
wire [C_DATA_WIDTH-1:0] DRPDI_inter;  reg [C_DATA_WIDTH-1:0] DRPDI_inter_buf;  
reg  [C_DATA_WIDTH-1:0] DRPDO_inter;   
wire DRPEN_inter;   reg DRPEN_inter_buf;   
wire DRPWE_inter;   reg DRPWE_inter_buf;   
reg  DRPRDY_inter;  

reg  [C_ADDR_WIDTH-1:0] DRPADDR_inter2; 
reg  [C_DATA_WIDTH-1:0] DRPDI_inter2;  
wire [C_DATA_WIDTH-1:0] DRPDO_inter2; reg  [C_DATA_WIDTH-1:0] DRPDO_inter2_buf; 
reg  DRPEN_inter2;    
reg  DRPWE_inter2;    
wire DRPRDY_inter2;   reg  DRPRDY_inter2_buf;  

wire [15:0] drp_addr;
wire [15:0] drp_di;
wire [15:0] drp_do;
wire        drp_wr;
wire        drp_rd;
wire        drp_rdy;
wire EYE_RST_SYNC;
reg [7:0] state2 = 0 ;
reg [7:0] state1;

wire [15:0] addr;
wire [15:0] di;
wire [15:0] do_;


always@(posedge SYS_CLK_I)begin
    if(~SYS_RSTN_I)begin
        state1 <= 0;
        DRPADDR_inter_buf <= 0;
        DRPDI_inter_buf <= 0;
        DRPWE_inter_buf <= 0;
    end
    else begin
        case(state1)
            0:begin
                if(DRPEN_inter)begin
                    DRPADDR_inter_buf <= DRPADDR_inter ;
                    DRPDI_inter_buf  <= DRPDI_inter ;
                    DRPWE_inter_buf  <= DRPWE_inter ;
                    state1 <= 1;
                end
            end
            1:begin
                DRPEN_inter_buf <= ~uart_busy ? 1 : 0 ;
                state1 <= ~uart_busy ? 2 : state1 ;  
            end
            2:begin
                DRPEN_inter_buf <= 0;
                state1 <= 0;
            end
            default:;
        endcase
    end
end




//busy释放后，才允许打印和回传

always@(posedge SYS_CLK_I)begin
    if(~SYS_RSTN_I)begin
        DRPRDY_inter2_buf <= 0;
        DRPDO_inter2_buf   <= 0;
        state2 <= 0;
    end
    else begin
        case(state2)
            0:begin
                if(DRPRDY_inter2)begin
                    DRPDO_inter2_buf <= DRPDO_inter2; //缓存
                    state2 <= 1;
                end
            end
            1:begin
                DRPRDY_inter2_buf <= ~uart_busy ? 1 : 0 ;
                state2 <= ~uart_busy ? 2 : state2 ;
            end
            2:begin
                DRPRDY_inter2_buf <= 0;
                state2 <= 0;
            end
            default:;   
        endcase
    end
end




drp_cconverter
    #(.C_ADDR_WIDTH (C_ADDR_WIDTH) ,
      .C_DATA_WIDTH (C_DATA_WIDTH) )
    drp_cconverter_u0(
    .S_DRPCLK_I  (DRPCLK_I  ),
    .S_DRPRST_I  (~DRPRSTN_I  ),
    .S_DRPADDR_I (S_DRPADDR_I ),
    .S_DRPDI_I   (S_DRPDI_I   ),
    .S_DRPDO_O   (S_DRPDO_O   ),
    .S_DRPEN_I   (S_DRPEN_I   ),
    .S_DRPWE_I   (S_DRPWE_I   ),
    .S_DRPRDY_O  (S_DRPRDY_O  ),
    .M_DRPCLK_I  (SYS_CLK_I   ),
    .M_DRPRST_I  (~SYS_RSTN_I   ),
    .M_DRPADDR_O (DRPADDR_inter     ),
    .M_DRPDI_O   (DRPDI_inter       ),
    .M_DRPDO_I   (DRPDO_inter2_buf  ),
    .M_DRPEN_O   (DRPEN_inter       ),
    .M_DRPWE_O   (DRPWE_inter       ),
    .M_DRPRDY_I  (DRPRDY_inter2_buf ) 
    
    );





assign  drp_addr = DRPADDR_inter_buf;
assign  drp_di   = DRPDI_inter_buf ;
assign  drp_do   = DRPDO_inter2_buf;
assign  drp_wr   = DRPEN_inter_buf & DRPWE_inter_buf ;
assign  drp_rd   = DRPEN_inter_buf & ~DRPWE_inter_buf;
assign  drp_rdy  = DRPRDY_inter2_buf ;



`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(EYE_RST_ASYNC,SYS_CLK_I,EYE_RST_SYNC,1,3)

generate if(C_SYS_ILA_ENABLE)begin
    
    ila_drp_debug  ila_drp_debug_u(
    .clk    (SYS_CLK_I),
    .probe0 (drp_addr ),
    .probe1 (drp_di   ),
    .probe2 (drp_do   ),
    .probe3 (drp_wr   ),
    .probe4 (drp_rd   ),
    .probe5 (drp_rdy  ),
    .probe6 (EYE_RST_SYNC ),
    .probe7 (uart_busy   ),
    .probe8 (uart_finish )
    
    
    );



end
endgenerate

//write addr data \n
//wrack xxxx xxxx \n
//read  addr xxxx \n
//rdack xxxx data \n
    
 

assign addr = DRPADDR_inter_buf;
assign di = DRPDI_inter_buf;
assign do_ = DRPDO_inter2_buf;
 
uart_tx_wrapper 
    #(.SYS_CLK_PERIOD    (C_SYS_CLK_PRD) , 
      .BAUD_RATE         (C_BAUD_RATE  ) , 
      .BYTE_NUM          (6) , 
      .FINISH_PERIOD_NUM (2)  )
    uart_tx_wrapper_u(
    .CLK_I    (SYS_CLK_I),
    .RST_I    (~SYS_RSTN_I),
    .DATA_I   (    { 8'd10,(DRPWE_inter_buf?{di[15:8],di[7:0]}:{do_[15:8],do_[7:0]}) , {addr[15:8],addr[7:0]} ,(DRPRDY_inter2_buf?8'h00:DRPWE_inter_buf?8'hF0:8'h0F) } ),
    .START_I  (DRPEN_inter_buf  | DRPRDY_inter2_buf ),//START2UARTTXWRP_O
    .SDATA_O  (SYS_UART_O),
    .BUSY_O   (uart_busy  ),
    .FINISH_O (uart_finish)
    );


 
drp_cconverter
    #(.C_ADDR_WIDTH (C_ADDR_WIDTH) ,
      .C_DATA_WIDTH (C_DATA_WIDTH) )
    drp_cconverter_u1(
    .S_DRPCLK_I  (SYS_CLK_I),
    .S_DRPRST_I  (~SYS_RSTN_I),
    .S_DRPADDR_I (DRPADDR_inter_buf),
    .S_DRPDI_I   (DRPDI_inter_buf  ),
    .S_DRPDO_O   (DRPDO_inter2  ),
    .S_DRPEN_I   (DRPEN_inter_buf  ),
    .S_DRPWE_I   (DRPWE_inter_buf  ),
    .S_DRPRDY_O  (DRPRDY_inter2 ),
    .M_DRPCLK_I  (DRPCLK_I),
    .M_DRPRST_I  (~DRPRSTN_I),
    .M_DRPADDR_O (M_DRPADDR_O ),
    .M_DRPDI_O   (M_DRPDI_O ),
    .M_DRPDO_I   (M_DRPDO_I ),
    .M_DRPEN_O   (M_DRPEN_O ),
    .M_DRPWE_O   (M_DRPWE_O ),
    .M_DRPRDY_I  (M_DRPRDY_I)
    
    );

  
    
    
endmodule
