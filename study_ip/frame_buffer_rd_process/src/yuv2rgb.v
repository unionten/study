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
//
//R = Y + 1.402 (V-128)
//G = Y - 0.34414 (U-128) - 0.71414 (V-128)
//B = Y + 1.772 (U-128)

//R*256 = Y*256 + 359(V-128)
//G*256 = Y*256 - 88 (U-128) - 183 (V-128)
//B*256 = Y*256 + 454 (U-128)

//* 256   1 00000000    << 8


module yuv2rgb(
input                      CLK_I  ,  
input                      RST_I  ,
input unsigned [C_BPC-1:0] Y_I    , 
input unsigned [C_BPC-1:0] U_I    ,
input unsigned [C_BPC-1:0] V_I    ,
output         [C_BPC-1:0] R_O    ,
output         [C_BPC-1:0] G_O    ,
output         [C_BPC-1:0] B_O     

    );

parameter C_BPC = 8;
parameter C_DLY = 2;// for timing closure

genvar i,j,k;


(*use_dsp = "yes"*)
//8 bit
//R = Y + 1.402 (V-128)
//G = Y - 0.34414 (U-128) - 0.71414 (V-128)  //10位色深就不是减去128 而是减去512
//B = Y + 1.772 (U-128)

//10 bit
//R = Y + 1.402 (V-512)
//G = Y - 0.34414 (U-512) - 0.71414 (V-512) 
//B = Y + 1.772 (U-512)

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
//BPC_I
//最大位宽色深 
//R = Y + 1.402 (V- (1<<(BPC_I-1)) )
//G = Y - 0.34414 (U-(1<<(BPC_I-1))) - 0.71414 (V-(1<<(BPC_I-1))) 
//B = Y + 1.772 (U-(1<<(BPC_I-1)))

// 固定值
//R = Y + a (V-(1<<(BPC_I-1)) )
//G = Y - b (U-(1<<(BPC_I-1))) - c (V-(1<<(BPC_I-1))) 
//B = Y + d (U-(1<<(BPC_I-1)))

//10 bit
//R*1024 = Y*1024 + 1436* (V- (1<<(BPC_I-1)) )
//G*1024 = Y*1024 - 352* (U-(1<<(BPC_I-1))) - 731* (V-(1<<(BPC_I-1))) 
//B*1024 = Y*1024 + 1815* (U-(1<<(BPC_I-1)))

//8 bit
//R*256 = Y*256 + 359(V-128)
//G*256 = Y*256 - 88 (U-128) - 183 (V-128)
//B*256 = Y*256 + 454 (U-128)

//fixed Para////////////////////////////////////////////////////////////////////////////
wire unsigned [C_BPC:0] a;//because 1436 is outside 10 bit
wire unsigned [C_BPC:0] b;
wire unsigned [C_BPC:0] c;
wire unsigned [C_BPC:0] d;

generate if(C_BPC==8)begin
    assign a = 359;
    assign b = 88;
    assign c = 183;
    assign d = 454;
end
else if(C_BPC==10)begin // more high presicion
    assign a = 1436;
    assign b = 352;
    assign c = 731;
    assign d = 1815; 
end
else begin
    assign a = 359;
    assign b = 88;
    assign c = 183;
    assign d = 454; 
end
endgenerate


///////////////////////////////////////////////////////////////////////////////////////
reg unsigned [C_BPC*2:0] stage1_Ys;
reg unsigned [C_BPC*2:0] stage1_Va;
reg unsigned [C_BPC*2:0] stage1_Ub;
reg unsigned [C_BPC*2:0] stage1_Vc;
reg unsigned [C_BPC*2:0] stage1_Ud;

reg signed   [C_BPC*2:0] r_stage2; //signed , maybe = 1XXXXXX
reg signed   [C_BPC*2:0] g_stage2;
reg signed   [C_BPC*2:0] b_stage2;

reg signed   [C_BPC:0]   r_stage3; //signed , maybe = 1XXXXXX
reg signed   [C_BPC:0]   g_stage3;
reg signed   [C_BPC:0]   b_stage3;

///////////////////////////////////////////////////////////////////////////////////////
//stage 1
always@(posedge CLK_I)begin
    if(RST_I)begin
        stage1_Ys <= 0;
        stage1_Va <= 0;
        stage1_Ub <= 0;
        stage1_Vc <= 0;
        stage1_Ud <= 0;
    end
    else begin
        stage1_Ys <= Y_I<<C_BPC;//12800
        stage1_Va <= V_I*a;//17950
        stage1_Ub <= U_I*b;//4400
        stage1_Vc <= V_I*c;
        stage1_Ud <= U_I*d;
    end
end


wire [15:0] tttt;
assign tttt = a<<(C_BPC-1);


///////////////////////////////////////////////////////////////////////////////////////
//stage 2
always@(posedge CLK_I)begin
    if(RST_I)begin
        r_stage2 <= 0;
        g_stage2 <= 0;
        b_stage2 <= 0;
    end
    else begin                              //45952
       // r_stage2 <= stage1_Ys + stage1_Va - a<<(C_BPC-1);// total right is -15200
        r_stage2 <= 12800 + 17950 - tttt;
       
        g_stage2 <= stage1_Ys - stage1_Ub + b<<(C_BPC-1) - stage1_Vc + c<<(C_BPC-1);
        b_stage2 <= stage1_Ys + stage1_Ud - d<<(C_BPC-1);  
    end
end


///////////////////////////////////////////////////////////////////////////////////////
//stage 3
always@(posedge CLK_I)begin
    if(RST_I)begin
        r_stage3 <= 0;
        g_stage3 <= 0;
        b_stage3 <= 0;
    end
    else begin
        r_stage3 <= r_stage2>>>C_BPC ;
        g_stage3 <= g_stage2>>>C_BPC ;
        b_stage3 <= b_stage2>>>C_BPC ;
    end
end


assign  R_O = r_stage3;
assign  G_O = g_stage3;
assign  B_O = b_stage3;



// 问题： 如果是10位色深公式，给50，其实理解的是 10位里面给了50，那对8位来说，相当于给了 12.5 
// 10位结果如果是500，对于 8bit 模式来说，相当于 500/1024 * 256 
    
//`DELAY(CLK_I,RST_I,r_ori,R_O,C_BPC,C_DLY)  
//`DELAY(CLK_I,RST_I,g_ori,G_O,C_BPC,C_DLY)
//`DELAY(CLK_I,RST_I,b_ori,B_O,C_BPC,C_DLY)


    
endmodule


