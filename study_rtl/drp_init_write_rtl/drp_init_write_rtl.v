`timescale 1ns / 1ps
`define HANDSHAKE_OUTGEN(aclk,arst,apulse_in,adata_in,bclk,brst,bpulse_out,bdata_out,DATA_WIDTH,SIM)    generate  if(SIM==0) begin  handshake  #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ); end  else  begin  handshake2 #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end  endgenerate   
`define CDC_MULTI_BIT_SIGNAL_OUTGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate



//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 18:15:19
// Design Name: 
// Module Name: drp_init_write_rtl
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
//drp_init_write_rtl
//    #(.C_DRP_ADDR_INIT_FILE_PATH (),
//      .C_DRP_DATA_INIT_FILE_PATH (),
//      .C_DRP_ADDR_WIDTH          (),
//      .C_DRP_DATA_WIDTH          (),
//      .C_ROM_DEPTH               (),
//      .C_DRP_DEPTH               () )
//    drp_init_write_rtl_u
//    (
//    .DRPCLK_I          (),
//    .DRPRSTN_I         (),
//    .M_DRPADDR_O       (),
//    .M_DRPDI_O         (),
//    .M_DRPDO_I         (),
//    .M_DRPEN_O         (),
//    .M_DRPWE_O         (),
//    .M_DRPRDY_I        (),
//    .VIO_TRIG_vio_drp  ()
//
//    );
//
//

module drp_init_write_rtl(
input                             DRPCLK_I         ,
input                             DRPRSTN_I        ,
output reg [C_DRP_ADDR_WIDTH-1:0] M_DRPADDR_O  = 0 ,
output reg [C_DRP_DATA_WIDTH-1:0] M_DRPDI_O    = 0 ,
input  [C_DRP_DATA_WIDTH-1:0]     M_DRPDO_I        ,
output reg                        M_DRPEN_O    = 0 ,
output reg                        M_DRPWE_O    = 0 ,
input                             M_DRPRDY_I       ,
input                             VIO_TRIG_vio_drp

    );
    
parameter C_DRP_ADDR_INIT_FILE_PATH = "G:/_0_MY_RTL_/drp_init_write_rtl/C_DRP_ADDR_INIT_FILE_PATH.txt";
parameter C_DRP_DATA_INIT_FILE_PATH = "G:/_0_MY_RTL_/drp_init_write_rtl/C_DRP_DATA_INIT_FILE_PATH.txt";
parameter C_DRP_ADDR_WIDTH = 16;
parameter C_DRP_DATA_WIDTH = 16;
parameter C_ROM_DEPTH      = 256;//两个rom的深度
parameter C_DRP_DEPTH      = 10 ;//>= 0  需要写入drp的数量



reg         drp_addr_rom_enb   ; 
reg  [15:0] drp_addr_rom_addrb ;
wire [31:0] drp_addr_rom_doutb ;

reg         drp_data_rom_enb   ; 
reg  [15:0] drp_data_rom_addrb ;
wire [31:0] drp_data_rom_doutb ;


ram_rtl  
   #(
    .WR_DATA_WIDTH  (32  ),
    .WR_DATA_DEPTH  (512 ), 
    .RD_DATA_WIDTH  (32  ),
    .INIT_FILE_PATH (C_DRP_ADDR_INIT_FILE_PATH ) )   
    drp_addr_rom_u
    (
    .clka   (DRPCLK_I ), 
    .wea    (0),
    .addra  (0),
    .dina   (0),
    .clkb   (DRPCLK_I ),
    .enb    (drp_addr_rom_enb   ),
    .addrb  (drp_addr_rom_addrb ),
    .doutb  (drp_addr_rom_doutb )
    
    );
    

ram_rtl  
   #(
    .WR_DATA_WIDTH  (32  ),
    .WR_DATA_DEPTH  (512 ), 
    .RD_DATA_WIDTH  (32  ),
    .INIT_FILE_PATH (C_DRP_DATA_INIT_FILE_PATH ) )   
     drp_data_rom_u
    (
    .clka   (DRPCLK_I ), 
    .wea    (0),
    .addra  (0),
    .dina   (0),
    .clkb   (DRPCLK_I ),
    .enb    (drp_data_rom_enb   ),
    .addrb  (drp_data_rom_addrb ),
    .doutb  (drp_data_rom_doutb )
    
    );

reg [7:0] state = 0;

wire VIO_TRIG_vio_drp_pos;

`POS_MONITOR_OUTGEN(DRPCLK_I,0,VIO_TRIG_vio_drp,VIO_TRIG_vio_drp_pos) 

reg [7:0] cnt = 0;

reg [15:0] drp_wr_addr = 0;
reg [15:0] drp_wr_data = 0;

always@(posedge DRPCLK_I)begin
    if(~DRPRSTN_I)begin
        M_DRPADDR_O   <= 0;
        M_DRPEN_O     <= 0;
        M_DRPDI_O     <= 0;
        M_DRPWE_O     <= 0;
        state               <= 0;  
        drp_addr_rom_enb    <= 0;
        drp_addr_rom_addrb  <= 0;
        drp_data_rom_enb    <= 0;
        drp_data_rom_addrb  <= 0;
    end
    else begin
        case(state)
            0:begin
                state   <= VIO_TRIG_vio_drp_pos ? 1 : state ;
                cnt     <= 0;
            end
            1:begin //
                if( (cnt+1) > C_DRP_DEPTH )begin
                    state <= 0;
                end
                else begin
                    drp_addr_rom_enb   <= 1   ;
                    drp_data_rom_enb   <= 1   ;
                    drp_addr_rom_addrb <= cnt ;
                    drp_data_rom_addrb <= cnt ;
                    state <= 2;
                end
            end
            2:begin
                drp_addr_rom_enb <= 0;
                drp_data_rom_enb <= 0;
                state <= 3;
            end
            3:begin
                M_DRPADDR_O <= drp_addr_rom_doutb;
                M_DRPDI_O   <= drp_data_rom_doutb;
                M_DRPEN_O   <= 1;
                M_DRPWE_O   <= 1;
                state       <= 4;
            end
            4:begin
                M_DRPEN_O  <= 0;
                M_DRPWE_O  <= 0;
                state      <= M_DRPRDY_I ? 1 :state;
                cnt        <= M_DRPRDY_I ? (cnt+1) : cnt ;
            end
           
            default:; 
        endcase
    end
end



endmodule



