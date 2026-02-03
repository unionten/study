`timescale 1ns / 1ps

`define POS_MONITOR_FF1(clk_in,rst_in,in,buf_name1,out)      reg buf_name1 = 1; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 1; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);
`define NEG_MONITOR_FF1(clk_in,rst_in,in,buf_name1,out)      reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);
`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate
`define CDC_MULTI_BIT_SIGNAL_OUTGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH)                            generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(3),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2023/07/17 17:36:25
// Design Name: 
// Module Name: osd
// Project Name: 
// Target Devices: 

//////////////////////////////////////////////////////////////////////////////////

//注意组合逻辑路径

module osd(  
input  VID_CLK_I,
input  VID_RST_I,
input  VS_I,
input  HS_I,
input  DE_I,
input  [C_MAX_BPC*C_MAX_PORT_NUM-1:0] R_I,
input  [C_MAX_BPC*C_MAX_PORT_NUM-1:0] G_I,
input  [C_MAX_BPC*C_MAX_PORT_NUM-1:0] B_I,
output VS_O,
output HS_O,
output DE_O,
output [C_MAX_BPC*C_MAX_PORT_NUM-1:0] R_O,
output [C_MAX_BPC*C_MAX_PORT_NUM-1:0] G_O,
output [C_MAX_BPC*C_MAX_PORT_NUM-1:0] B_O,
//
input         OSD_AXI_CLK_I,//mostly AXI CLK
input         OSD_AXI_RST_I, 
input         OSD_ENABLE_I,
input         OSD_TRANSPARENT_I,
input  [3:0]  OSD_PORTS_I, // also actual valid input port num
input  [15:0] OSD_X_I ,//from 0
input  [15:0] OSD_Y_I ,//from 0
input  [15:0] OSD_H_I ,
input  [15:0] OSD_V_I ,
input  [15:0] OSD_WADDR_I ,//注意 OSD_WADDR_I 地址按1递增 
input  [31:0] OSD_WDATA_I ,
input         OSD_WREQ_I  

);

parameter  C_MAX_PORT_NUM = 4; //硬port数 must >= 4; 
parameter  C_MAX_BPC = 8;
parameter  [0:0] C_VID_OSD_ILA_EN = 0;

genvar i,j,k;

//exp: 3 为每次读取字节数(total 4)  |A| |B| 为准备好时刻
//DE_I                               ||__|————————————————
//DE_I_s1                            ||____|——————————————
//RD                                 ||__|—|______________
//wr_req                             ||____|—|____________
//打入A/B                            ||------|A|B|A|—|B|A|
//当前移位bit    (直接以组合逻辑打出)||000000|0|3|2|1|0|3| 
//当前运行bit                        ||000000|3|2|1|0|3|2|
//(当前运行bit)3+3跨越(需提前读取)   ||______|—|—|—|_|—|—|—|
//flag当前移位bit变小则需要反转      ||------|_|_|—|_|—|—|_|
//running                            ||______|——————————————


wire [C_MAX_PORT_NUM*4-1:0] osd_data; //每个像素有 4bit的 osd配置
wire [C_MAX_PORT_NUM*4-1:0] osd_data_s3;
wire osd_en_s0;
wire osd_en_s4;
reg [15:0] addrb = 0;
wire osd_de_s3;
wire rd;
wire VS_I_pos;
wire HS_I_pos;
wire DE_I_neg;
reg [15:0] cnt_x = 0;//from 0
reg [15:0] cnt_y = 0;//from 0

reg [C_MAX_BPC-1:0] osd_r_s4 [C_MAX_PORT_NUM-1:0] ;
reg [C_MAX_BPC-1:0] osd_g_s4 [C_MAX_PORT_NUM-1:0] ;
reg [C_MAX_BPC-1:0] osd_b_s4 [C_MAX_PORT_NUM-1:0] ;

wire  [C_MAX_BPC*C_MAX_PORT_NUM-1:0] R_s4;
wire  [C_MAX_BPC*C_MAX_PORT_NUM-1:0] G_s4;
wire  [C_MAX_BPC*C_MAX_PORT_NUM-1:0] B_s4;


wire        osd_enable_vid ;
wire [3:0]  osd_ports_vid  ;
reg  [3:0]  osd_ports_vid_reg  ;
wire [15:0] osd_x_vid      ;
wire [15:0] osd_y_vid      ;
wire [15:0] osd_h_vid      ;
wire [15:0] osd_v_vid      ;
wire        osd_transparent_vid;


always@(*)begin
    case(osd_ports_vid)
        1: osd_ports_vid_reg = 1;
        2: osd_ports_vid_reg = 2;
        4: osd_ports_vid_reg = 4;
        default:osd_ports_vid_reg = 4;  
    endcase
end



`CDC_MULTI_BIT_SIGNAL_OUTGEN(OSD_AXI_CLK_I,OSD_ENABLE_I,VID_CLK_I,osd_enable_vid ,1)
`CDC_MULTI_BIT_SIGNAL_OUTGEN(OSD_AXI_CLK_I,OSD_PORTS_I ,VID_CLK_I,osd_ports_vid  ,4)
`CDC_MULTI_BIT_SIGNAL_OUTGEN(OSD_AXI_CLK_I,OSD_X_I     ,VID_CLK_I,osd_x_vid      ,16)
`CDC_MULTI_BIT_SIGNAL_OUTGEN(OSD_AXI_CLK_I,OSD_Y_I     ,VID_CLK_I,osd_y_vid      ,16)
`CDC_MULTI_BIT_SIGNAL_OUTGEN(OSD_AXI_CLK_I,OSD_H_I     ,VID_CLK_I,osd_h_vid      ,16)
`CDC_MULTI_BIT_SIGNAL_OUTGEN(OSD_AXI_CLK_I,OSD_V_I     ,VID_CLK_I,osd_v_vid      ,16)
`CDC_MULTI_BIT_SIGNAL_OUTGEN(OSD_AXI_CLK_I,OSD_TRANSPARENT_I   ,VID_CLK_I,osd_transparent_vid      ,1)







`POS_MONITOR_FF1(VID_CLK_I,0,VS_I,buf_name1,VS_I_pos)
`POS_MONITOR_FF1(VID_CLK_I,0,HS_I,buf_name2,HS_I_pos)
`NEG_MONITOR_FF1(VID_CLK_I,0,DE_I,buf_name3,DE_I_neg)


`DELAY_OUTGEN(VID_CLK_I,0,R_I,R_s4,(C_MAX_BPC*C_MAX_PORT_NUM),4) 
`DELAY_OUTGEN(VID_CLK_I,0,G_I,G_s4,(C_MAX_BPC*C_MAX_PORT_NUM),4) 
`DELAY_OUTGEN(VID_CLK_I,0,B_I,B_s4,(C_MAX_BPC*C_MAX_PORT_NUM),4) 

`DELAY_OUTGEN(VID_CLK_I,0,VS_I,VS_O,1,4)
`DELAY_OUTGEN(VID_CLK_I,0,HS_I,HS_O,1,4)
`DELAY_OUTGEN(VID_CLK_I,0,DE_I,DE_O,1,4)



always@(posedge VID_CLK_I)begin
    if(VID_RST_I | VS_I_pos)begin
        addrb <= 0;
    end
    else begin
        addrb <= rd ? addrb + 1 :  addrb;
    end
end


ram_rtl
    #(.WR_DATA_WIDTH  (32),    //= 32 ,
      .WR_DATA_DEPTH  (32768), // = 256 ,
      .RD_DATA_WIDTH  (C_MAX_PORT_NUM*4))  // = 256
    ram_rtl_u(
    .clka  (OSD_AXI_CLK_I ), 
    .wea   (OSD_WREQ_I    ),
    .addra (OSD_WADDR_I    ),
    .dina  (OSD_WDATA_I   ),//fixed 32 bit
    .clkb  (VID_CLK_I  ),
    .enb   (rd      ),
    .addrb ({0,addrb} ),
    .doutb (osd_data)//  [C_MAX_PORT_NUM*4-1:0]   C_MAX_PORT_NUM pixels every time
    );



wire osd_en_s0_f = osd_en_s0 & DE_I;

rd_station_std_ram //delay 3
    #(.C_MAX_UNIT_NUM    ( C_MAX_PORT_NUM ),//4bit *8 个 osd 值
      .C_BIT_NUM_PER_UNIT( 4              ) //4bit  per  pixel osd value
    )
    rd_station_std_ram_u(
    .CLK_I   (VID_CLK_I),
    .RST_I   (VID_RST_I | VS_I_pos),
    .VS_I    (VS_I),
    .HS_I    (HS_I),
    .DE_I    (osd_en_s0_f), //需要osd输出时才读取
    .UNITS_I (osd_ports_vid_reg), 
    .RD_O    (rd),
    .DATA_I  (osd_data   ), //[C_MAX_PORT_NUM*4 -1:0]
    .DE_O    (osd_de_s3  ),   
    .DATA_O  (osd_data_s3)//  [C_MAX_PORT_NUM*4 -1:0]  but 只有 [osd_ports_vid_reg*4:0] 是有效的   note: s3 是相对于 DE_I 的 延迟
    );



//DE_I ______|——————————————
//cnt_x       0 1 2 ... 99
//osd_en_s0  |————————————|____  delay 0 according to DE_I
assign osd_en_s0 =  ((cnt_x*osd_ports_vid_reg )>= osd_x_vid) & ((cnt_x*osd_ports_vid_reg) < (osd_x_vid + osd_h_vid))
               & (cnt_y >= osd_y_vid ) &  (cnt_y < (osd_y_vid+osd_v_vid) ) ;


//
`DELAY_OUTGEN(VID_CLK_I,0,osd_en_s0,osd_en_s4,1,4) 


//DE_I    _____|————————————
//cnt_x         0 1 2 ...
always@(posedge VID_CLK_I)begin
    if(VID_RST_I | HS_I_pos)begin
        cnt_x <= 0;
    end
    else begin
        if(DE_I)begin
            cnt_x <= cnt_x + 1;
        end
    end
end



always@(posedge VID_CLK_I)begin
    if(VID_RST_I | VS_I_pos)begin
        cnt_y <= 0;
    end
    else begin
        if(DE_I_neg)begin
            cnt_y <= cnt_y + 1;
        end
    end
end




//4bit -> osd_r_s4 8bit, osd_g_s4 8bit, osd_b_s4 8bit

generate for(i=0;i<=(C_MAX_PORT_NUM-1);i=i+1)begin
    always@(posedge VID_CLK_I)begin
        if(VID_RST_I)begin
            osd_r_s4[i] <= {C_MAX_BPC{1'b0}};
            osd_g_s4[i] <= {C_MAX_BPC{1'b0}};
            osd_b_s4[i] <= {C_MAX_BPC{1'b0}};
        end
        else begin
            case(osd_data_s3[i*4+:4])
                4'h0:begin
                    osd_r_s4[i] <= {C_MAX_BPC{1'b0}};
                    osd_g_s4[i] <= {C_MAX_BPC{1'b0}};
                    osd_b_s4[i] <= {C_MAX_BPC{1'b0}};
                end
                4'h1:begin
                    osd_r_s4[i] <= {C_MAX_BPC{1'b1}};
                    osd_g_s4[i] <= {C_MAX_BPC{1'b0}};
                    osd_b_s4[i] <= {C_MAX_BPC{1'b0}};
                end
                4'h2:begin
                    osd_r_s4[i] <= {C_MAX_BPC{1'b0}};
                    osd_g_s4[i] <= {C_MAX_BPC{1'b1}};
                    osd_b_s4[i] <= {C_MAX_BPC{1'b0}};
                end
                4'h3:
                begin
                    osd_r_s4[i] <= {C_MAX_BPC{1'b0}};
                    osd_g_s4[i] <= {C_MAX_BPC{1'b0}};
                    osd_b_s4[i] <= {C_MAX_BPC{1'b1}};
                end
                4'h4:
                begin
                    osd_r_s4[i] <= {C_MAX_BPC{1'b1}};
                    osd_g_s4[i] <= {C_MAX_BPC{1'b1}};
                    osd_b_s4[i] <= {C_MAX_BPC{1'b0}};
                end
                4'h5:
                begin
                    osd_r_s4[i] <= {C_MAX_BPC{1'b1}};
                    osd_g_s4[i] <= {C_MAX_BPC{1'b0}};
                    osd_b_s4[i] <= {C_MAX_BPC{1'b1}};
                end
                4'h6:begin
                    osd_r_s4[i] <= {C_MAX_BPC{1'b0}};
                    osd_g_s4[i] <= {C_MAX_BPC{1'b1}};
                    osd_b_s4[i] <= {C_MAX_BPC{1'b1}};
                end
                4'hF:begin
                    osd_r_s4[i] <= {C_MAX_BPC{1'b1}};
                    osd_g_s4[i] <= {C_MAX_BPC{1'b1}};
                    osd_b_s4[i] <= {C_MAX_BPC{1'b1}};
                
                end
                default: begin
                    osd_r_s4[i] <= {C_MAX_BPC{1'b0}};
                    osd_g_s4[i] <= {C_MAX_BPC{1'b0}};
                    osd_b_s4[i] <= {C_MAX_BPC{1'b0}};
                
                end
            endcase
        end
    end
end
endgenerate




generate for(i=0;i<=C_MAX_PORT_NUM-1;i=i+1)begin
    assign R_O[i*C_MAX_BPC+:C_MAX_BPC]  = ( osd_enable_vid & osd_en_s4 ) ?  osd_transparent_vid  ?   R_s4[i*C_MAX_BPC+1 +:C_MAX_BPC-1] + osd_r_s4[i][C_MAX_BPC-1:1] :  osd_r_s4[i]   :   R_s4[i*C_MAX_BPC+:C_MAX_BPC];
    assign G_O[i*C_MAX_BPC+:C_MAX_BPC]  = ( osd_enable_vid & osd_en_s4 ) ?  osd_transparent_vid  ?   G_s4[i*C_MAX_BPC+1 +:C_MAX_BPC-1] + osd_g_s4[i][C_MAX_BPC-1:1] :  osd_g_s4[i]   :   G_s4[i*C_MAX_BPC+:C_MAX_BPC];
    assign B_O[i*C_MAX_BPC+:C_MAX_BPC]  = ( osd_enable_vid & osd_en_s4 ) ?  osd_transparent_vid  ?   B_s4[i*C_MAX_BPC+1 +:C_MAX_BPC-1] + osd_b_s4[i][C_MAX_BPC-1:1] :  osd_b_s4[i]   :   B_s4[i*C_MAX_BPC+:C_MAX_BPC];
end
endgenerate   




generate if(C_VID_OSD_ILA_EN)begin
    ila_vid_osd   ila_vid_osd_u
    (
        .clk    (VID_CLK_I  ),
        .probe0 (osd_en_s0_f ),
        .probe1 (osd_en_s4   ),
        .probe2 (osd_de_s3   ),
        .probe3 (osd_data    ),
        .probe4 (osd_data_s3 ),
        .probe5 (osd_ports_vid_reg ),
        .probe6 (rd),
        .probe7 (rd)
        
    
    );
    

end
endgenerate
   
endmodule



