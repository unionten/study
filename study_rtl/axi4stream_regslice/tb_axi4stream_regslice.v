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


module tb_axi4stream_regslice(

    );
reg rst;
reg clk;

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





reg S_WVALID ;
wire S_WREADY;
reg [255:0] S_WDATA ;
reg [31:0] S_WSTRB ;
reg S_WLAST ;

wire M_WVALID;
wire M_WREADY;
wire [255:0] M_WDATA;
wire [31:0]  M_WSTRB;
wire M_WLAST;


wire M2_WVALID;
reg M2_WREADY;
wire [255:0] M2_WDATA;
wire [31:0]  M2_WSTRB;
wire M2_WLAST;





 
axi4stream_regslice
uut
(
.CLK_I     (clk),
.RST_I     (rst), 
.S_WVALID  (S_WVALID),
.S_WREADY  (S_WREADY),
.S_WDATA   (S_WDATA),
.S_WLAST   (S_WLAST),
.S_WSTRB   (S_WSTRB),
.M_WVALID  (M_WVALID),
.M_WREADY  (M_WREADY),
.M_WDATA   (M_WDATA),
.M_WLAST   (M_WLAST),
.M_WSTRB   (M_WSTRB)

); 





axi4stream_regslice
uut2
(
.CLK_I     (clk),
.RST_I     (rst), 
.S_WVALID  (M_WVALID),
.S_WREADY  (M_WREADY),
.S_WDATA   (M_WDATA),
.S_WLAST   (M_WLAST),
.S_WSTRB   (M_WSTRB),
.M_WVALID  (M2_WVALID),
.M_WREADY  (M2_WREADY),
.M_WDATA   (M2_WDATA),
.M_WLAST   (M2_WLAST),
.M_WSTRB   (M2_WSTRB)

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
    S_WVALID  = 0;
    
    S_WLAST  = 0;
    S_WSTRB = 0;
    M2_WREADY = 0;

   clk = 0;
   rst = 1;
   #200;
   rst = 0;
   #505.1;
   
    S_WVALID = 1;
   // S_WDATA  = 256'h1122334455667788112233445566778811223344556677881122334455667788;
    S_WSTRB  = 32'h11111111 ;
    #10;
    ///S_WDATA  =  256'haaaaccccddddffffaaaaccccddddffffaaaaccccddddffffaaaaccccddddffff;
    S_WLAST  = 0;
    S_WSTRB  = 32'hffffffff ;
    M2_WREADY = 0;
    #2000;
    
    S_WVALID = 1;
    //S_WDATA  = 256'h1122334455667788112233445566778811223344556677881122334455667788;
    S_WLAST  = 0;
    S_WSTRB  = 32'hffffffff ;
    M2_WREADY = 0;
    
    #200;
    
    M2_WREADY = 1;


    S_WVALID = 1;
    //S_WDATA  = 256'h1122334455667788112233445566778811223344556677881122334455667788;
    S_WSTRB  = 32'h11111111 ;
    #10;
//S_WDATA  =  256'haaaaccccddddffffaaaaccccddddffffaaaaccccddddffffaaaaccccddddffff;
    S_WLAST  = 0;
    S_WSTRB  = 32'hffffffff ;
    M2_WREADY = 1;
    #200;
    #50
    S_WVALID = 0;
    //S_WDATA  = 256'h1122334455667788112233445566778811223344556677881122334455667788;
    S_WLAST  = 0;
    S_WSTRB  = 32'hffffffff ;
    M2_WREADY = 1;


#2000;
S_WVALID = 1;
#20;
S_WVALID = 0;








   
end 
   
    
endmodule
