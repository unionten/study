`timescale 1ns / 1ps
`define  DELAY(clk_in,rst_in,data_in,data_out,C_WIDTH,C_DLY)           generate if(C_DLY==0)begin  assign data_out = data_in; end  else if(C_DLY==1)begin  reg [C_WIDTH-1:0] a_temp = 0; always@(posedge clk_in) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [C_WIDTH-1:0] a_temp [C_DLY-1:0] ;always@(posedge clk_in) begin  if(rst_in)a_temp[C_DLY-1] <= 0; else   a_temp[C_DLY-1] <= data_in; end  for(i=0;i<=C_DLY-2;i=i+1)begin  always@(posedge clk_in)begin  if(rst_in)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Create Date: 2023/06/20 13:37:12
// Design Name: yzhu
// Module Name: rgb2yuv
//////////////////////////////////////////////////////////////////////////////////
/*
rgb2yuv 
    #(.C_BPC (8),
       C_DLY (2))
    rgb2yuv_u(
    .RST_I (),
    .CLK_I (),       
    .R_I   (),
    .G_I   (),
    .B_I   (),
    .Y_O   (),
    .U_O   (),
    .V_O   ()
    );
*/

//RGB转化为YUV   同乘256 
//(色深为8时的算法)
//Y = 0.299 R + 0.587 G + 0.114 B
//U = - 0.1687 R - 0.3313 G + 0.5 B + 128
//V = 0.5 R - 0.4187 G - 0.0813 B + 128


module rgb2yuv(
input              RST_I ,
input              CLK_I ,       
input  [C_BPC-1:0] R_I   ,
input  [C_BPC-1:0] G_I   ,
input  [C_BPC-1:0] B_I   ,
output [C_BPC-1:0] Y_O   ,
output [C_BPC-1:0] U_O   ,
output [C_BPC-1:0] V_O   

    );

parameter C_BPC = 8;
parameter C_DLY = 2;//must >= 2

genvar i,j,k;

(*use_dsp = "yes"*)reg [C_BPC*2-1:0]y_temp1,u_temp1,v_temp1;
(*use_dsp = "yes"*)reg [C_BPC*2-1:0]y_temp2,u_temp2,v_temp2;
(*use_dsp = "yes"*)reg [C_BPC*2-1:0]y_temp3,u_temp3,v_temp3;

reg [2*C_BPC-1:0] y_o ;
reg [2*C_BPC-1:0] u_o ;
reg [2*C_BPC-1:0] v_o ;
   
//step1

//(*use_dsp = "yes"*)

//mult_gen_8b y_temp1_inst (
//    .CLK(CLK_I),    // input wire CLK
//    .A(77),       // input wire [7 : 0] A
//    .B(R_I  ),   // input wire [7 : 0] B_I
//    .P(y_temp1)      // output wire [15 : 0] P
//    );
always@(posedge CLK_I)if(RST_I)y_temp1<=0; else y_temp1 <= 77 * R_I;
    
//mult_gen_8b y_temp2_inst (
//    .CLK(CLK_I), 
//    .A(150),   
//    .B(G_I),
//    .P(y_temp2)   
//    );
always@(posedge CLK_I)if(RST_I)  y_temp2 <=0; else  y_temp2 <=  150 * G_I;
    
//mult_gen_8b y_temp3_inst (
//    .CLK(CLK_I), 
//    .A(29),    
//    .B(B_I),
//    .P(y_temp3)   
//    );
always@(posedge CLK_I)if(RST_I) y_temp3  <=0; else   y_temp3 <=  29 * B_I;



//mult_gen_8b u_temp1_inst (
//    .CLK(CLK_I), 
//    .A(43),    
//    .B(R_I),
//    .P(u_temp1)   
//    );
always@(posedge CLK_I)if(RST_I) u_temp1  <=0; else   u_temp1 <=  43 * R_I;


//mult_gen_8b u_temp2_inst (
//    .CLK(CLK_I), 
//    .A(85),    
//    .B(G_I),
//    .P(u_temp2)   
//    );
always@(posedge CLK_I)if(RST_I)  u_temp2 <=0; else   u_temp2 <=  85 * G_I;


//mult_gen_8b u_temp3_inst (
//    .CLK(CLK_I), 
//    .A(128),   
//    .B(B_I),
//    .P(u_temp3)   
//    );
always@(posedge CLK_I)if(RST_I)  u_temp3 <=0; else   u_temp3 <=  128 * B_I;


//mult_gen_8b v_temp1_inst (
//    .CLK(CLK_I), 
//    .A(128),   
//    .B(R_I),
//    .P(v_temp1)   
//    );
always@(posedge CLK_I)if(RST_I)  v_temp1 <=0; else   v_temp1 <=  128 * R_I;


//mult_gen_8b v_temp2_inst (
//    .CLK(CLK_I), 
//    .A(107),   
//    .B(G_I),
//    .P(v_temp2)   
//    );
always@(posedge CLK_I)if(RST_I) v_temp2  <=0; else   v_temp2 <=  107 * G_I;


//mult_gen_8b v_temp3_inst (
//    .CLK(CLK_I), 
//    .A(21),    
//    .B(B_I),
//    .P(v_temp3)   
//    );
always@(posedge CLK_I)if(RST_I) v_temp3  <=0; else   v_temp3 <=  21 * B_I;


//step2
wire [2*C_BPC:0] offset;
assign offset = (1'b1<<(C_BPC-1))*256; //2023年7月11日09:09:11 yzhu

always @(posedge CLK_I) begin
    if(RST_I) begin 
        y_o  <= 0;
        u_o  <= 0;
        v_o  <= 0;
    end
    else begin  
        y_o  <= y_temp1 + y_temp2 + y_temp3; 
        u_o  <= offset  - u_temp1 - u_temp2 + u_temp3; 
        v_o  <= offset  + v_temp1 - v_temp2 - v_temp3;
        
    end 
end




`DELAY(CLK_I,RST_I,(y_o/256),Y_O,C_BPC,C_DLY-2)
`DELAY(CLK_I,RST_I,(u_o/256),U_O,C_BPC,C_DLY-2)
`DELAY(CLK_I,RST_I,(v_o/256),V_O,C_BPC,C_DLY-2)
    
    
endmodule
