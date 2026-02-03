`timescale 1ns / 1ps
`define  DELAY(clk_in,rst_in,data_in,data_out,C_WIDTH,C_DLY)            generate if(C_DLY==0)begin  assign data_out = data_in; end  else if(C_DLY==1)begin  reg [C_WIDTH-1:0] a_temp = 0; always@(posedge clk_in) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [C_WIDTH-1:0] a_temp [C_DLY-1:0] ;always@(posedge clk_in) begin  if(rst_in)a_temp[C_DLY-1] <= 0; else   a_temp[C_DLY-1] <= data_in; end  for(i=0;i<=C_DLY-2;i=i+1)begin  always@(posedge clk_in)begin  if(rst_in)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate
`define  DELAY_InGen(clk_in,rst_in,data_in,data_out,C_WIDTH,C_DLY)      if(C_DLY==0)begin  assign data_out = data_in; end  else if(C_DLY==1)begin  reg [C_WIDTH-1:0] a_temp = 0; always@(posedge clk_in) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [C_WIDTH-1:0] a_temp [C_DLY-1:0] ;always@(posedge clk_in) begin  if(rst_in)a_temp[C_DLY-1] <= 0; else   a_temp[C_DLY-1] <= data_in; end  for(i=0;i<=C_DLY-2;i=i+1)begin  always@(posedge clk_in)begin  if(rst_in)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end
`define  POS_MONITOR(clk_in,rst_in,in,out)                              generate  begin  reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)                                 generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define BI_TO_SINGLE_Nm1To0(a,b,in,out)                                 generate for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end endgenerate



//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:  yzhu
// Create Date: 2023/07/14 12:18:23
// Design Name:
// Module Name: csc_rd
// Project Name:
// Target Devices:

//////////////////////////////////////////////////////////////////////////////////


module csc_rd(
input                             CLK_I             ,
input                             RST_I             ,
input  [3:0]                      ISPACE_I          , //input color space :  0:RGB(也可以理解为不做转换) , 1:YUV444 , 2:YUV422 , 3:YUV420
output                            VS_O              ,
output                            HS_O              ,
output                            DE_O              ,
output reg [C_BPC*C_PORT_NUM-1:0]    R_O               ,
output reg  [C_BPC*C_PORT_NUM-1:0]   G_O               ,
output reg  [C_BPC*C_PORT_NUM-1:0]   B_O               ,
input                             PIXEL_VS_I        , //simulate vs hs de
input                             PIXEL_HS_I        ,
input                             PIXEL_DE_I  , //__|——————|____________________ (420)
input                             PIXEL_DE_TOTAL_I  , //__|——————|_______|——————|_____
input  [C_BPC*3*C_PORT_NUM-1:0]   PIXEL_DATA_I        //exp: {BGR}{BGR}{BGR}{BGR} ; {VUY}{VUY}{VUY}{VUY} ; {0UY}{0UY}{0UY}{0UY} ; {VYY}{UYY}{VYY}{UYY}

);
parameter C_PORT_NUM            = 4;
parameter C_BPC                 = 8;
parameter [0:0] C_OUTPUT_FORMAT = 0;//0: RGB  1:YUV

parameter [0:0] C_YUV2RGB_EN = 1 ;
parameter [0:0] C_RGB2YUV_EN= 1 ;
parameter [0:0] C_420FIFO_EN= 1 ;
parameter       DDR_Video_Format = "xRGB888";


genvar i,j,k;

wire VS_I_pos;
`POS_MONITOR(CLK_I,0,PIXEL_VS_I,VS_I_pos)



wire [(C_BPC*3)-1:0] pixel_data_i_m [C_PORT_NUM-1:0];



reg [C_BPC-1:0] YR_s0 [2*C_PORT_NUM-1:0] ; //原始输入重拼接
reg [C_BPC-1:0] UG_s0 [2*C_PORT_NUM-1:0] ;
reg [C_BPC-1:0] VB_s0 [2*C_PORT_NUM-1:0] ;

wire [C_BPC*2*C_PORT_NUM-1:0] YR_s0_s;
wire [C_BPC*2*C_PORT_NUM-1:0] UG_s0_s;
wire [C_BPC*2*C_PORT_NUM-1:0] VB_s0_s;

wire [C_BPC*C_PORT_NUM-1:0] YR_s0_s_h; //420时用于写入FIFO
wire [C_BPC*C_PORT_NUM-1:0] UG_s0_s_h;
wire [C_BPC*C_PORT_NUM-1:0] VB_s0_s_h;

wire [C_BPC*C_PORT_NUM-1:0] YR_s0_s_h_n;//经过FIFO延迟的结果
wire [C_BPC*C_PORT_NUM-1:0] UG_s0_s_h_n;
wire [C_BPC*C_PORT_NUM-1:0] VB_s0_s_h_n;

wire [C_BPC*C_PORT_NUM-1:0] YR_s0_s_f;//mux后的最终结果
wire [C_BPC*C_PORT_NUM-1:0] UG_s0_s_f;
wire [C_BPC*C_PORT_NUM-1:0] VB_s0_s_f;

wire [C_BPC-1:0] R_sDm1_loop [C_PORT_NUM-1:0] ; //环出
wire [C_BPC-1:0] G_sDm1_loop [C_PORT_NUM-1:0] ;
wire [C_BPC-1:0] B_sDm1_loop [C_PORT_NUM-1:0] ;

wire [C_BPC-1:0] R_sDm1_r2y [C_PORT_NUM-1:0] ; //经过RGB2YUV处理
wire [C_BPC-1:0] G_sDm1_r2y [C_PORT_NUM-1:0] ;
wire [C_BPC-1:0] B_sDm1_r2y [C_PORT_NUM-1:0] ;

wire [C_BPC-1:0] R_sDm1_y2r [C_PORT_NUM-1:0] ; //经过YUV2RGB处理
wire [C_BPC-1:0] G_sDm1_y2r [C_PORT_NUM-1:0] ;
wire [C_BPC-1:0] B_sDm1_y2r [C_PORT_NUM-1:0] ;


reg [C_BPC-1:0] r_o_m [C_PORT_NUM-1:0] ;
reg [C_BPC-1:0] g_o_m [C_PORT_NUM-1:0] ;
reg [C_BPC-1:0] b_o_m [C_PORT_NUM-1:0] ;

wire [C_BPC*C_PORT_NUM-1:0] r_o_s;
wire [C_BPC*C_PORT_NUM-1:0] g_o_s;
wire [C_BPC*C_PORT_NUM-1:0] b_o_s;


/////////////////////////////////////////////////////////////////////////////////



`DELAY(CLK_I,0,PIXEL_VS_I,VS_O,1,3)
`DELAY(CLK_I,0,PIXEL_HS_I,HS_O,1,3)
`DELAY(CLK_I,0,PIXEL_DE_TOTAL_I,DE_O,1,3)


/////////////////////////////////////////////////////////////////////////////////
//重拼接
wire  [C_BPC*3*C_PORT_NUM-1:0]   PIXEL_DATA_remap;
`SINGLE_TO_BI_Nm1To0((C_BPC*3),C_PORT_NUM,PIXEL_DATA_remap,pixel_data_i_m)

`BI_TO_SINGLE_Nm1To0(C_BPC,(2*C_PORT_NUM),YR_s0,YR_s0_s)
`BI_TO_SINGLE_Nm1To0(C_BPC,(2*C_PORT_NUM),UG_s0,UG_s0_s)
`BI_TO_SINGLE_Nm1To0(C_BPC,(2*C_PORT_NUM),VB_s0,VB_s0_s)

assign YR_s0_s_h = YR_s0_s[C_BPC*C_PORT_NUM +: C_BPC*C_PORT_NUM];
assign UG_s0_s_h = UG_s0_s[C_BPC*C_PORT_NUM +: C_BPC*C_PORT_NUM];
assign VB_s0_s_h = VB_s0_s[C_BPC*C_PORT_NUM +: C_BPC*C_PORT_NUM];

generate if(DDR_Video_Format=="xRGB888")begin
    assign PIXEL_DATA_remap[C_BPC*0+:C_BPC] = PIXEL_DATA_I[C_BPC*2+:C_BPC];
    assign PIXEL_DATA_remap[C_BPC*1+:C_BPC] = PIXEL_DATA_I[C_BPC*1+:C_BPC];
    assign PIXEL_DATA_remap[C_BPC*2+:C_BPC] = PIXEL_DATA_I[C_BPC*0+:C_BPC];
end else if(DDR_Video_Format=="xBGR888")begin
    assign  PIXEL_DATA_remap = PIXEL_DATA_I;
end else if(DDR_Video_Format=="xYUV444")begin
        assign  PIXEL_DATA_remap = PIXEL_DATA_I;
end else if(DDR_Video_Format=="xYUV422")begin
    assign  PIXEL_DATA_remap = PIXEL_DATA_I;
end else if(DDR_Video_Format=="xYUV420")begin
    assign  PIXEL_DATA_remap = PIXEL_DATA_I;
end
endgenerate



//以下可手动增删分支，以节约代码
generate for(i=0;i<=C_PORT_NUM-1;i=i+1)begin
always@(*)begin
    case(ISPACE_I)
        0:begin
            YR_s0[i] = pixel_data_i_m[i][C_BPC*0+:C_BPC];
            UG_s0[i] = pixel_data_i_m[i][C_BPC*1+:C_BPC];
            VB_s0[i] = pixel_data_i_m[i][C_BPC*2+:C_BPC];

        end
        1:begin
            YR_s0[i] = pixel_data_i_m[i][C_BPC*0+:C_BPC];
            UG_s0[i] = pixel_data_i_m[i][C_BPC*1+:C_BPC];
            VB_s0[i] = pixel_data_i_m[i][C_BPC*2+:C_BPC];

        end
        2:begin
            if(i==((i>>1)<<1))begin
                YR_s0[i] = pixel_data_i_m[i][C_BPC*0+:C_BPC];
                UG_s0[i] = pixel_data_i_m[i][C_BPC*1+:C_BPC];
                VB_s0[i] = pixel_data_i_m[i+1][C_BPC*1+:C_BPC];

            end
            else begin
                YR_s0[i] = pixel_data_i_m[i][C_BPC*0+:C_BPC];
                UG_s0[i] = pixel_data_i_m[i-1][C_BPC*1+:C_BPC];
                VB_s0[i] = pixel_data_i_m[i][C_BPC*1+:C_BPC];


            end
        end
        //3:begin
        //    if(i==((i>>1)<<1))begin // i= 0 2
        //        YR_s0[i] = pixel_data_i_m[i][C_BPC*0+:C_BPC];
        //        UG_s0[i] = pixel_data_i_m[i][C_BPC*2+:C_BPC];
        //        VB_s0[i] = pixel_data_i_m[i+1][C_BPC*2+:C_BPC];
        //
        //        YR_s0[i+C_PORT_NUM] = pixel_data_i_m[i][C_BPC*1+:C_BPC];
        //        UG_s0[i+C_PORT_NUM] = pixel_data_i_m[i][C_BPC*2+:C_BPC];
        //        VB_s0[i+C_PORT_NUM] = pixel_data_i_m[i+1][C_BPC*2+:C_BPC];
        //
        //    end
        //    else begin // i= 1 3
        //        YR_s0[i] = pixel_data_i_m[i][C_BPC*0+:C_BPC];
        //        UG_s0[i] = pixel_data_i_m[i-1][C_BPC*2+:C_BPC];
        //        VB_s0[i] = pixel_data_i_m[i][C_BPC*2+:C_BPC];
        //
        //        YR_s0[i+C_PORT_NUM] = pixel_data_i_m[i][C_BPC*1+:C_BPC];
        //        UG_s0[i+C_PORT_NUM] = pixel_data_i_m[i-1][C_BPC*2+:C_BPC];
        //        VB_s0[i+C_PORT_NUM] = pixel_data_i_m[i][C_BPC*2+:C_BPC];
        //    end
        //
        //end
        default: begin
            YR_s0[i] = pixel_data_i_m[i][C_BPC*2+:C_BPC];
            UG_s0[i] = pixel_data_i_m[i][C_BPC*1+:C_BPC];
            VB_s0[i] = pixel_data_i_m[i][C_BPC*0+:C_BPC];
        end

    endcase
end
end
endgenerate



/////////////////////////////////////////////////////////////////////////////////
//如果为正常模式 就始终以 PIXEL_DE_I 对应的数据为准
//如果为420模式，就使用交替的数据
assign  YR_s0_s_f = PIXEL_DE_I ? YR_s0_s : PIXEL_DE_TOTAL_I ? YR_s0_s_h_n : YR_s0_s;
assign  UG_s0_s_f = PIXEL_DE_I ? UG_s0_s : PIXEL_DE_TOTAL_I ? UG_s0_s_h_n : UG_s0_s;
assign  VB_s0_s_f = PIXEL_DE_I ? VB_s0_s : PIXEL_DE_TOTAL_I ? VB_s0_s_h_n : VB_s0_s;

generate if(C_420FIFO_EN)begin
fifo_async_xpm
    #(.C_WR_WIDTH             (C_BPC*3*C_PORT_NUM),// ratio must be 1:1, 1:2, 1:4, 1:8,
      .C_WR_DEPTH             (4096),// must>=16 ; actual depth = C_WR_DEPTH - 1;  must be power of 2
      .C_RD_WIDTH             (C_BPC*3*C_PORT_NUM),
      .C_WR_COUNT_WIDTH       (16),
      .C_RD_COUNT_WIDTH       (16),
      .C_RD_MODE              ("fwft" ) //"std" "fwft"
     )
    fifo_async_xpm_u(
    .WR_RST_I         (RST_I | VS_I_pos), // clear the FIFO
    .WR_CLK_I         (CLK_I ),
    .WR_EN_I          (PIXEL_DE_I ),
    .WR_DATA_I        ({VB_s0_s_h,UG_s0_s_h,YR_s0_s_h  } ),
    .WR_FULL_O        (),
    .WR_DATA_COUNT_O  (),
    .WR_PROG_FULL_O   (),
    .WR_RST_BUSY_O    (),

    .RD_RST_I         (RST_I | VS_I_pos),
    .RD_CLK_I         (CLK_I ),
    .RD_EN_I          (PIXEL_DE_TOTAL_I & ~PIXEL_DE_I),
    .RD_DATA_O        ({VB_s0_s_h_n,UG_s0_s_h_n,YR_s0_s_h_n}),
    .RD_EMPTY_O       (),
    .RD_DATA_COUNT_O  (),
    .RD_PROG_EMPTY_O  (),
    .RD_RST_BUSY_O    ()

    );
end
endgenerate



generate for(j=0;j<=C_PORT_NUM-1;j=j+1)begin: pixel_csc_block

`DELAY_InGen(CLK_I,RST_I,YR_s0_s_f[C_BPC*j+:C_BPC],R_sDm1_loop[j],C_BPC,2)  //note: i has been used by `DELAY_InGen
`DELAY_InGen(CLK_I,RST_I,UG_s0_s_f[C_BPC*j+:C_BPC],G_sDm1_loop[j],C_BPC,2)
`DELAY_InGen(CLK_I,RST_I,VB_s0_s_f[C_BPC*j+:C_BPC],B_sDm1_loop[j],C_BPC,2)

//关键在于属于该模块的值，会根据color空间的不同而不同
if(C_YUV2RGB_EN)begin
yuv2rgb
    #(.C_BPC(C_BPC),
      .C_DLY(2))
    yuv2rgb_u(
    .CLK_I  (CLK_I),
    .RST_I  (RST_I),
    .Y_I    (YR_s0_s_f[C_BPC*j+:C_BPC]),  //[C_BPC-1:0]
    .U_I    (UG_s0_s_f[C_BPC*j+:C_BPC]),  //[C_BPC-1:0]
    .V_I    (VB_s0_s_f[C_BPC*j+:C_BPC]),  //[C_BPC-1:0]
    .R_O    (R_sDm1_y2r[j]),  //[C_BPC-1:0]
    .G_O    (G_sDm1_y2r[j]),  //[C_BPC-1:0]
    .B_O    (B_sDm1_y2r[j])   //[C_BPC-1:0]
    );
end


if(C_RGB2YUV_EN)begin
rgb2yuv
    #(.C_BPC(C_BPC),
      .C_DLY(2))
    rgb2yuv_u(
    .CLK_I  (CLK_I),
    .RST_I  (RST_I),
    .R_I    (YR_s0_s_f[C_BPC*j+:C_BPC]),  //[C_BPC-1:0]
    .G_I    (UG_s0_s_f[C_BPC*j+:C_BPC]),  //[C_BPC-1:0]
    .B_I    (VB_s0_s_f[C_BPC*j+:C_BPC]),  //[C_BPC-1:0]
    .Y_O    (R_sDm1_r2y[j]),  //[C_BPC-1:0]
    .U_O    (G_sDm1_r2y[j]),  //[C_BPC-1:0]
    .V_O    (B_sDm1_r2y[j])   //[C_BPC-1:0]
    );
end



end
endgenerate


generate for(i=0;i<=C_PORT_NUM-1;i=i+1)begin
always@(* )begin
    if((C_OUTPUT_FORMAT==0 & ISPACE_I==0) |
       (C_OUTPUT_FORMAT==1 & ISPACE_I!=0)
      ) begin
        r_o_m[i] =  R_sDm1_loop[i];
        g_o_m[i] =  G_sDm1_loop[i];
        b_o_m[i] =  B_sDm1_loop[i];
    end
    else if(C_OUTPUT_FORMAT==0 & ISPACE_I!=0)begin
        r_o_m[i] =  R_sDm1_y2r[i];
        g_o_m[i] =  G_sDm1_y2r[i];
        b_o_m[i] =  B_sDm1_y2r[i];
    end
    else begin
        r_o_m[i] =  R_sDm1_r2y[i];
        g_o_m[i] =  G_sDm1_r2y[i];
        b_o_m[i] =  B_sDm1_r2y[i];
    end
end
end
endgenerate



`BI_TO_SINGLE_Nm1To0(C_BPC,C_PORT_NUM,r_o_m,r_o_s)
`BI_TO_SINGLE_Nm1To0(C_BPC,C_PORT_NUM,g_o_m,g_o_s)
`BI_TO_SINGLE_Nm1To0(C_BPC,C_PORT_NUM,b_o_m,b_o_s)

always@(posedge CLK_I)begin
    R_O  <= r_o_s ;
    G_O  <= g_o_s ;
    B_O  <= b_o_s ;
end



endmodule



