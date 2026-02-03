`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/19 18:09:15
// Design Name: 
// Module Name: iic_mux_3
//////////////////////////////////////////////////////////////////////////////////
module iic_mux_3(
input [1:0] SEL_I,

input SDA_0_O_I,
output  SDA_0_I_O,
input SDA_0_T_I,
input SCL_0_O_I,
output  SCL_0_I_O,
input SCL_0_T_I,

input SDA_1_O_I,
output  SDA_1_I_O,
input SDA_1_T_I,
input SCL_1_O_I,
output  SCL_1_I_O,
input SCL_1_T_I,

input SDA_2_O_I,
output  SDA_2_I_O,
input SDA_2_T_I,
input SCL_2_O_I,
output  SCL_2_I_O,
input SCL_2_T_I,

output SDA_O,
input  SDA_I,
output SDA_T,
output SCL_O,
input  SCL_I,
output SCL_T

);

assign SDA_O   = (SEL_I==2'd0) ? SDA_0_O_I : (SEL_I==2'd1) ? SDA_1_O_I : (SEL_I==2'd2) ? SDA_2_O_I : 0;
assign SDA_T   = (SEL_I==2'd0) ? SDA_0_T_I : (SEL_I==2'd1) ? SDA_1_T_I : (SEL_I==2'd2) ? SDA_2_T_I : 0;
assign SDA_0_I_O = (SEL_I==2'd0) ? SDA_I   : 1;
assign SDA_1_I_O = (SEL_I==2'd1) ? SDA_I   : 1;
assign SDA_2_I_O = (SEL_I==2'd2) ? SDA_I   : 1;


assign SCL_O   = (SEL_I==2'd0) ? SCL_0_O_I : (SEL_I==2'd1) ? SCL_1_O_I : (SEL_I==2'd2) ? SCL_2_O_I : 0;
assign SCL_T   = (SEL_I==2'd0) ? SCL_0_T_I : (SEL_I==2'd1) ? SCL_1_T_I : (SEL_I==2'd2) ? SCL_2_T_I : 0;
assign SCL_0_I_O = (SEL_I==2'd0) ? SCL_I   : 1;
assign SCL_1_I_O = (SEL_I==2'd1) ? SCL_I   : 1;
assign SCL_2_I_O = (SEL_I==2'd2) ? SCL_I   : 1;


endmodule
