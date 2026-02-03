`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/28 16:43:20
// Design Name: 
// Module Name: tb_native_deskew
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


module tb_native_deskew(

    );
    
    reg clk =0;
    reg rst = 0;
reg vs0,vs1,vs2,vs3; 
wire [3:0] vs_o;
wire [3:0] hs_o;
wire [3:0] de_o;

wire [31:0] r_o;
wire [31:0] g_o;
wire [31:0] b_o;

native_deskew
    #(.C_LANE_NUM(4), 
      .C_PORT_NUM(4))
    uut
(
.PCLK_I(clk),
.PRST_I(rst),
.VS_I(564547),
.HS_I(34252532),
.DE_I({vs3,vs2,vs1,vs0}),
.R_I(34252532),
.G_I(34252532),
.B_I(34252532),
.VS_O(vs_o),
.HS_O(hs_o),
.DE_O(de_o),
.R_O(r_o),
.G_O(g_o),
.B_O(b_o),
.SYS_CLK_I(clk),
.RESET_1TO7_O(RESET_1TO7_O)


);


always #5 clk = ~clk;

initial begin
    vs0 = 0;
    vs1 = 0;
    vs2 = 0;
    vs3 = 0;
    clk =0;
    rst =1;
    #500;
    rst =0;
    #500;
end 

initial begin
#2000;
vs0 = 1;
#2000;
vs0 = 0;

end

initial begin
#2000;
#20;
vs1 = 1;
#2000;
vs1 = 0;

end

initial begin
#2000;
#30;
vs2 = 1;
#2000;
vs2 = 0;

end

initial begin
#2000;
#20;
vs3 = 1;
#1990;
vs3 = 0;

end

    
endmodule




