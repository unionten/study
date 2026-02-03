`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/29 16:21:54
// Design Name: 
// Module Name: tb_axi4stream_regslice
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


module tb_reg_fifo(

    );
reg rst;
reg clk;

reg  S_WVALID ;
wire S_WREADY;
reg [7:0] S_WDATA ;
wire M_WVALID;
wire M_WREADY;
wire [7:0] M_WDATA;
wire M2_WVALID;
reg  M2_WREADY;
wire [7:0] M2_WDATA;



wire [7:0] state; 
assign state = uut.state;
wire mux_in;
wire mux_out;
assign mux_in  = uut.mux_in;
assign mux_out = uut.mux_out;
wire wr_in_valid_A;
wire wr_in_valid_B;
wire wr_out_valid_A;
wire wr_out_valid_B;
assign wr_in_valid_A =  uut.wr_in_valid_A ;
assign wr_in_valid_B =  uut.wr_in_valid_B ;
assign wr_out_valid_A = uut.wr_out_valid_A;
assign wr_out_valid_B = uut.wr_out_valid_B;


reg_fifo
uut
(
.CLK_I     (clk),
.RST_I     (rst), 
.S_WVALID  (S_WVALID),
.S_WREADY  (S_WREADY),
.S_WDATA   (S_WDATA),
.M_WVALID  (M_WVALID),
.M_WREADY  (M_WREADY),
.M_WDATA   (M_WDATA)

); 


reg_fifo
uut2
(
.CLK_I     (clk),
.RST_I     (rst), 
.S_WVALID  (M_WVALID),
.S_WREADY  (M_WREADY),
.S_WDATA   (M_WDATA),
.M_WVALID  (M2_WVALID),
.M_WREADY  (M2_WREADY),
.M_WDATA   (M2_WDATA)

); 
    
always #5 clk =~clk ;  


initial begin
    #6;
    S_WDATA  = 0;
    repeat(10000)
    begin
        S_WDATA = S_WDATA + 1;
        #10;
    end
end
 
 
initial begin
   clk = 0;
   rst = 1;
   #200;
   rst = 0;
end

 
initial begin  
    S_WVALID  = 0;
    #6;
    
    #500;
    S_WVALID  = 1;
    #100;
    S_WVALID  = 0;
    
    #500;
    S_WVALID  = 1;
    #200;
    S_WVALID  = 0;
    
    #500;
    S_WVALID  = 1;
    #10;
    S_WVALID  = 0;
    #10;
    S_WVALID  = 1;
    #10;
    S_WVALID  = 0;
    #10;
    S_WVALID  = 1;
    #10;
    S_WVALID  = 0;
    
    
end   
    
    
initial begin   
    
    M2_WREADY = 0;
    #6;

    #10;
    M2_WREADY = 0;
    #700;
    M2_WREADY = 1;
    #10;
    M2_WREADY = 0;


    #500;
    M2_WREADY = 1;
    #300;
    M2_WREADY = 0;
    
    #50;
    M2_WREADY = 1;
    #10;
    M2_WREADY = 0;
    #10;
    
    M2_WREADY = 1;
    #10;
    M2_WREADY = 0;
    #10;
    
    M2_WREADY = 1;
    #10;
    M2_WREADY = 0;
    #10;

    M2_WREADY = 1;
    #10;
    M2_WREADY = 0;
    #10;
    
    #400;
    M2_WREADY = 1;
    
   
end 
   
    
endmodule
