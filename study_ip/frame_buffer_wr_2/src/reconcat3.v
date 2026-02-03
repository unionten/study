`timescale 1ns / 1ps

`define SINGLE_TO_BI_Nm1To0(a,b,in,out)       generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define BI_TO_SINGLE_Nm1To0(a,b,in,out)       generate for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end endgenerate
`define SINGLE_TO_TRI_Nm1To0(a,b,c,in,out)    generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[b-i][c-j] = in[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ];end end endgenerate
`define TRI_TO_SINGLE_Nm1To0(a,b,c,in,out)    generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ] = in[b-i][c-j];end end endgenerate
`define SINGLE_TO_FOUR_Nm1To0(a,b,c,d,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[b-i][c-j][d-k] = in[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1]; end end end endgenerate
`define FOUR_TO_SINGLE_Nm1To0(a,b,c,d,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1] = in[b-i][c-j][d-k]; end end end endgenerate


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2023/06/22 20:47:37
// Design Name: 
// Module Name: reconcat3

//////////////////////////////////////////////////////////////////////////////////

/*
reconcat3
    #(.C_MAX_PORT_NUM(),
      .C_DDR_PIXEL_MAX_BYTE_NUM())
    reconcat3_u(
    .CLK_I                 (),
    .RST_I                 (),
    .PIXEL_VS_I            (),
    .PIXEL_HS_I            (),
    .PIXEL_DE_I            (),
    .PIXEL_VS_O            (),
    .PIXEL_HS_O            (),
    .PIXEL_DE_O            (),
    .PIXEL_DATA_I          (),// [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0]   {R8  G8   B8  8'b0},{R8  G8   B8  8'b0},{R8  G8   B8  8'b0},{R8  G8   B8  8'b0}
    .ACTUAL_DDR_BYTE_NUM_I (), //[7:0]             ;2 3 4 8  valid : <= C_DDR_PIXEL_MAX_BYTE_NUM
    .PIXEL_DATA_O          () // [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] 紧凑拼接 when autual_num is 3 ->    {R8 G8 B8 },{R8 G8 B8 },{R8 G8 B8 },{R8 G8 B8 }


    );

*/

//对每个像素内部，进一步削减到“实际”写入ddr的宽度
module reconcat3(
input                                                  CLK_I,
input                                                  RST_I,
input                                  PIXEL_VS_I,
input                                  PIXEL_HS_I,
input                                  PIXEL_DE_I,
output     reg                          PIXEL_VS_O=0,
output     reg                          PIXEL_HS_O=0,
output     reg                          PIXEL_DE_O=0,
input [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0]  PIXEL_DATA_I,//    {R8  G8   B8  8'b0},{R8  G8   B8  8'b0},{R8  G8   B8  8'b0},{R8  G8   B8  8'b0}
input [7:0] ACTUAL_DDR_BYTE_NUM_I,              //2 3 4 8  valid : <= C_DDR_PIXEL_MAX_BYTE_NUM
output  reg [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0]  PIXEL_DATA_O = 0 // 紧凑拼接 when autual_num is 3 ->    {R8 G8 B8 },{R8 G8 B8 },{R8 G8 B8 },{R8 G8 B8 }


);

parameter  C_MAX_PORT_NUM =  4;
parameter  C_DDR_PIXEL_MAX_BYTE_NUM = 4;

genvar i,j,k;

always@(posedge CLK_I)PIXEL_VS_O <= PIXEL_VS_I;
always@(posedge CLK_I)PIXEL_HS_O <= PIXEL_HS_I;
always@(posedge CLK_I)PIXEL_DE_O <= PIXEL_DE_I;



wire [C_DDR_PIXEL_MAX_BYTE_NUM*8-1:0] pixel_data_i_m [C_MAX_PORT_NUM-1:0];
`SINGLE_TO_BI_Nm1To0((C_DDR_PIXEL_MAX_BYTE_NUM*8),C_MAX_PORT_NUM,PIXEL_DATA_I,pixel_data_i_m)

//reg [C_DDR_PIXEL_MAX_BYTE_NUM*8-1:0] pixel_data_o_m [C_MAX_PORT_NUM-1:0];


reg [7:0] ii;

// important :  [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] is right
reg [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] pixel_data_tmp [C_MAX_PORT_NUM-1:0];

//pixel_data_tmp 0 1 2 3 


always@(*)begin
case(ACTUAL_DDR_BYTE_NUM_I) //choose different combinational logic  when different adtual ddr byte
    2:begin
        pixel_data_tmp[0] = ( C_DDR_PIXEL_MAX_BYTE_NUM>=2 ) ? {128'b0,pixel_data_i_m[C_MAX_PORT_NUM-1][15:0]} : 0;
        for(ii=1;ii<=C_MAX_PORT_NUM-1;ii=ii+1)begin
            pixel_data_tmp[ii] = ( C_DDR_PIXEL_MAX_BYTE_NUM>=2 ) ? {128'b0,pixel_data_tmp[ii-1],pixel_data_i_m[C_MAX_PORT_NUM-1-ii][15:0]} : 0;
        end
    end
    3:begin
        pixel_data_tmp[0] = ( C_DDR_PIXEL_MAX_BYTE_NUM>=3 ) ? {128'b0,pixel_data_i_m[C_MAX_PORT_NUM-1][23:0]} : 0;
        for(ii=1;ii<=C_MAX_PORT_NUM-1;ii=ii+1)begin
            pixel_data_tmp[ii] =( C_DDR_PIXEL_MAX_BYTE_NUM>=3 ) ? {128'b0,pixel_data_tmp[ii-1],pixel_data_i_m[C_MAX_PORT_NUM-1-ii][23:0]}:0;
        end
    end
    4:begin
        pixel_data_tmp[0] = ( C_DDR_PIXEL_MAX_BYTE_NUM>=4 ) ?{128'b0,pixel_data_i_m[C_MAX_PORT_NUM-1][31:0]}:0;
        for(ii=1;ii<=C_MAX_PORT_NUM-1;ii=ii+1)begin
            pixel_data_tmp[ii] = ( C_DDR_PIXEL_MAX_BYTE_NUM>=4 ) ?{128'b0,pixel_data_tmp[ii-1],pixel_data_i_m[C_MAX_PORT_NUM-1-ii][31:0]}:0;
        end
    end
    8:begin
        pixel_data_tmp[0] = ( C_DDR_PIXEL_MAX_BYTE_NUM>=8 ) ?{128'b0,pixel_data_i_m[C_MAX_PORT_NUM-1][63:0]}:0;
        for(ii=1;ii<=C_MAX_PORT_NUM-1;ii=ii+1)begin
            pixel_data_tmp[ii] = ( C_DDR_PIXEL_MAX_BYTE_NUM>=8 ) ?{128'b0,pixel_data_tmp[ii-1],pixel_data_i_m[C_MAX_PORT_NUM-1-ii][63:0]}:0;
        end
    end
    default:
    begin
        pixel_data_tmp[0] = ( C_DDR_PIXEL_MAX_BYTE_NUM>=4 ) ?{128'b0,pixel_data_i_m[C_MAX_PORT_NUM-1][31:0]}:0;
        for(ii=1;ii<=C_MAX_PORT_NUM-1;ii=ii+1)begin
            pixel_data_tmp[ii] =( C_DDR_PIXEL_MAX_BYTE_NUM>=4 ) ? {128'b0,pixel_data_i_m[ii][31:0],pixel_data_tmp[ii-1]}:0;
        end
    end
endcase
end



//assign pixel_data_tmp[0] = {128'b0,pixel_data_i_m[0][15:0]};
//for(i=1;i<=C_MAX_PORT_NUM-1;i=i+1)begin
//    assign pixel_data_tmp[i] = {128'b0,pixel_data_tmp[i-1],pixel_data_i_m[i][15:0]};
//end
//
//
//
//endgenerate


always@(posedge CLK_I)begin
    if(RST_I)begin
        PIXEL_DATA_O <= 0;
    end
    else begin
        PIXEL_DATA_O <= pixel_data_tmp[C_MAX_PORT_NUM-1];
    end
end




////  思路 ： 建立 几个 中间变量， 用generate 套 assign 实现
//always@(*)begin
//for(ii=0;ii<=C_MAX_PORT_NUM-1;ii=ii+1)begin
//                  PIXEL_DATA_O = {PIXEL_DATA_O,pixel_data_i_m[ii][15:0]};
//                end
//end
//


// always@(posedge CLK_I)begin//拼接 
    // if(RST_I)begin 
        // PIXEL_DATA_O <= {(C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM){1'b0}};
    // end
    // else begin
        // case(ACTUAL_DDR_BYTE_NUM_I)
            // 2:if(C_DDR_PIXEL_MAX_BYTE_NUM>=2)begin //imp parallel op with cycle op
                // for(ii=0;ii<=C_MAX_PORT_NUM-1;ii=ii+1)begin
                    // PIXEL_DATA_O <= {PIXEL_DATA_O,pixel_data_i_m[ii][15:0]};
                // end
            // end
            // 3:if(C_DDR_PIXEL_MAX_BYTE_NUM>=3)begin  //imp parallel op with cycle op
                // for(ii=0;ii<=C_MAX_PORT_NUM-1;ii=ii+1)begin
                    // PIXEL_DATA_O <= {PIXEL_DATA_O,pixel_data_i_m[ii][15:0]};
                // end
            // end
            // 4:if(C_DDR_PIXEL_MAX_BYTE_NUM>=4)begin  //imp parallel op with cycle op
                // for(ii=0;ii<=C_MAX_PORT_NUM-1;ii=ii+1)begin
                    // PIXEL_DATA_O <= {PIXEL_DATA_O,pixel_data_i_m[ii][15:0]};
                // end
            // end
            // 8:if(C_DDR_PIXEL_MAX_BYTE_NUM>=8)begin  //imp parallel op with cycle op
                // for(ii=0;ii<=C_MAX_PORT_NUM-1;ii=ii+1)begin
                    // PIXEL_DATA_O <= {PIXEL_DATA_O,pixel_data_i_m[ii][15:0]};
                // end
            // end
            // default:;
        // endcase
    // end
// end




endmodule




