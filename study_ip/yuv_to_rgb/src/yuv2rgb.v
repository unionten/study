`timescale 1ns / 1ps
`define  DELAY(clk_in,rst_in,data_in,data_out,C_WIDTH,C_DLY)           generate if(C_DLY==0)begin  assign data_out = data_in; end  else if(C_DLY==1)begin  reg [C_WIDTH-1:0] a_temp = 0; always@(posedge clk_in) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [C_WIDTH-1:0] a_temp [C_DLY-1:0] ;always@(posedge clk_in) begin  if(rst_in)a_temp[C_DLY-1] <= 0; else   a_temp[C_DLY-1] <= data_in; end  for(i=0;i<=C_DLY-2;i=i+1)begin  always@(posedge clk_in)begin  if(rst_in)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/03 16:58:01
// Design Name: 
// Module Name: yuv2rgb

//////////////////////////////////////////////////////////////////////////////////
//RGB转化为YUV   左右同乘256
//
//Y = 0.299 R + 0.587 G + 0.114 B
//U = - 0.1687 R - 0.3313 G + 0.5 B + 128
//V = 0.5 R - 0.4187 G - 0.0813 B + 128
//


//YUV转化为RGB
//8bit时情况
//R = Y + 1.402 (V-128)
//G = Y - 0.34414 (U-128) - 0.71414 (V-128)
//B = Y + 1.772 (U-128)
//
//R*256 = Y*256 + 359(V-128)
//G*256 = Y*256 - 88 (U-128) - 183 (V-128)
//B*256 = Y*256 + 454 (U-128)


//8bit时情况
//R = Y + 1.402 (V-128)
//G = Y - 0.34414 (U-128) - 0.71414 (V-128)
//B = Y + 1.772 (U-128)
//
//R*256 = Y*256 + 359(V-128)
//G*256 = Y*256 - 88 (U-128) - 183 (V-128)
//B*256 = Y*256 + 454 (U-128)


//R = 256Y + 256*1.402*V - 256*1.402*128
//G = 
//
//
//-
//
//R = 596*Y+  817*V - 114131
//G = 596*Y + 69370 - 200 U - 416V
//B = 596*Y + 1033 U  - 141787 


//* 256   1 00000000    << 8


module yuv2rgb(
input                      CLK_I  ,  
input                      RST_I  ,
input unsigned [C_BPC-1:0] Y_I    , 
input unsigned [C_BPC-1:0] U_I    ,
input unsigned [C_BPC-1:0] V_I    ,
output reg     [C_BPC-1:0] R_O    ,
output reg     [C_BPC-1:0] G_O    ,
output reg     [C_BPC-1:0] B_O     

    );

parameter C_BPC = 8;

genvar i,j,k;


(*use_dsp = "yes"*)
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
//BPC_I = 最大位宽色深 
//
//R = Y + 1.402 (V- (1<<(BPC_I-1)) )
//G = Y - 0.34414 (U-(1<<(BPC_I-1))) - 0.71414 (V-(1<<(BPC_I-1))) 
//B = Y + 1.772 (U-(1<<(BPC_I-1)))


//10 bit
//R*1024 = Y*1024 + 1436* (V- (1<<(BPC_I-1)) )
//G*1024 = Y*1024 - 352* (U-(1<<(BPC_I-1))) - 731* (V-(1<<(BPC_I-1))) 
//B*1024 = Y*1024 + 1815* (U-(1<<(BPC_I-1)))

//8 bit
//R*256 = Y*256 + 359(V-128)
//G*256 = Y*256 - 88 (U-128) - 183 (V-128)
//B*256 = Y*256 + 454 (U-128)




///////////////////////////////////////////////////////////////////////////////////////

reg[19:0] R_temp;
reg[19:0] G_temp;
reg[19:0] B_temp;


reg [19:0] t_596Y  ;
reg [19:0] t_817Cr ;
reg [19:0] t_200Cb ;
reg [19:0] t_416Cr ;
reg [19:0] t_1033Cb;

reg r_jud;
reg g_jud;
reg b_jud;


//stage1
always @(posedge CLK_I)
if(RST_I) begin 
	t_596Y   <= 'b0; 
    t_817Cr  <= 'b0;
    t_200Cb  <= 'b0;
	t_416Cr  <= 'b0;
    t_1033Cb <= 'b0;
end else begin 
	t_596Y     <= 255 * Y_I; 
    t_817Cr    <= 359 * V_I;
    t_200Cb    <= 88 * U_I;
	t_416Cr    <= 183 * V_I; 
    t_1033Cb   <= 454* U_I;
end 


always @(*) begin 
	r_jud<= ((t_596Y + t_817Cr) >= 45952);
	g_jud<= ((t_596Y + 34688) >= (t_200Cb + t_416Cr));
	b_jud<= ((t_596Y + t_1033Cb) >= 58112);
end


//stage2
always @(posedge CLK_I)
if(RST_I) begin 
	R_temp <= 'b0; 
    G_temp <= 'b0;
    B_temp <= 'b0;
end else 	 begin 
	R_temp <= r_jud ? t_596Y + t_817Cr - 45952 : 8'd0; 
    G_temp <= g_jud ? t_596Y + 34688 - t_200Cb - t_416Cr : 8'd0;
    B_temp <= b_jud ? t_596Y + t_1033Cb - 58112 : 8'd0; 
end 


//stage3
always@(posedge CLK_I)begin
    if(RST_I)begin
        R_O  <= 0;
        G_O  <= 0;
        B_O  <= 0;
    end
    else begin
        R_O <= (R_temp[19:17]) ? 8'd255 :  R_temp[16:8];
        G_O <= (G_temp[19:17]) ? 8'd255 :  G_temp[16:8];
        B_O <= (B_temp[19:17]) ? 8'd255 :  B_temp[16:8];
    end
end








    
endmodule


