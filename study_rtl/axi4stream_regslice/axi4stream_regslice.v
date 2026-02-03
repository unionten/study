`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2023/12/28 12:01:24
// Design Name: 
// Module Name: axi4stream_regslice
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////


module axi4stream_regslice
#( parameter AWPORT_WIDTH      = 2   ,
   parameter AWLEN_WIDTH       = 16  ,
   parameter AWSIZE_WIDTH      = 16  ,
   parameter    WIDTH          = 256 
)

(
input    CLK_I    ,
input    RST_I    , 

input [AWPORT_WIDTH-1:0]   S_AWPORT  , 
input [AWLEN_WIDTH-1:0]    S_AWLEN   ,
input [AWSIZE_WIDTH-1:0]   S_AWSIZE  , 
input                      S_AWVALID , 
output                     S_AWREADY ,

input    S_WVALID , //wvalid  
output   S_WREADY , //wready 
input  [WIDTH-1:0]  S_WDATA  ,
input    S_WLAST  ,
input  [WIDTH/8-1:0]  S_WSTRB  ,


output [AWPORT_WIDTH-1:0]   M_AWPORT  , 
output [AWLEN_WIDTH-1:0]    M_AWLEN   ,
output [AWSIZE_WIDTH-1:0]   M_AWSIZE  , 
output                      M_AWVALID , 
input                       M_AWREADY ,
 
 
output    M_WVALID ,
input    M_WREADY ,
output  [WIDTH-1:0]  M_WDATA  ,
output   M_WLAST  ,
output  [WIDTH/8-1:0]  M_WSTRB  


    );
    
assign    M_AWPORT = S_AWPORT;
assign    M_AWLEN  = S_AWLEN ;
assign    M_AWSIZE = S_AWSIZE ;
assign    M_AWVALID =  S_AWVALID;
assign    S_AWREADY = M_AWREADY;
    

reg [WIDTH+1+WIDTH/8-1:0] A_reg = 0;
reg [WIDTH+1+WIDTH/8-1:0] B_reg = 0;

wire wr_in_valid ;
wire wr_out_valid;

wire wr_in_valid_A;
wire wr_in_valid_B;
wire wr_out_valid_A;
wire wr_out_valid_B;

assign wr_in_valid_A = wr_in_valid & ~mux_in;
assign wr_in_valid_B = wr_in_valid &  mux_in;

assign wr_out_valid_A = wr_out_valid & ~mux_out;
assign wr_out_valid_B = wr_out_valid &  mux_out;


assign wr_in_valid  = S_WVALID & S_WREADY ;
assign wr_out_valid = M_WVALID & M_WREADY ;

wire [1:0] op;
assign op = {wr_in_valid ,wr_out_valid }; //

reg mux_out;
reg mux_in  = 0;


reg [7:0] state = 0; //state通过组合逻辑引出标志
//state状态的切换应该在 valid和ready一同为高
always@(posedge CLK_I)begin
    if(RST_I)begin  //要点：op为读写操作，但是根据状态的不同，实际是对不同的寄存器进行操作
        state <= 0;
    end
    else begin
        case(state)//先读取A， 再读取B
            0:begin //全空
                state <=  op==2'b00 ? state : 
                          op==2'b10 ? 1     :
                          op==2'b01 ? state :
                          op==2'b11 ? 1     : state ;
            end
            1:begin //A有 B无
                state <=  op==2'b00 ? state : 
                          op==2'b10 ? 2     :
                          op==2'b01 ? 0     :
                          op==2'b11 ? 3     : state ;
            end    
            2:begin//A有 B有 (A有 B有时，优先读A)
                state <=  op==2'b00 ? state : 
                          op==2'b10 ? state :
                          op==2'b01 ? 3     :
                          op==2'b11 ? 3     : state ;
            end
            3:begin//A无 B有
                state <=  op==2'b00 ? state : 
                          op==2'b10 ? 2     :
                          op==2'b01 ? 0     :
                          op==2'b11 ? 1     : state ;
            end    
            default:;
        endcase
    end
end


always@(*)begin
    case(state)
        0:mux_out = 0;
        1:mux_out = 0;
        2:mux_out = 0;
        3:mux_out = 1;
        default:mux_out = 0;
    endcase
end


//mux_out : 用于控制输出
assign  M_WVALID =  state != 0;
assign  M_WDATA  =  mux_out==0 ? A_reg[WIDTH-1:0]             : B_reg[WIDTH-1:0] ;
assign  M_WSTRB  =  mux_out==0 ? A_reg[WIDTH+WIDTH/8-1:WIDTH] : B_reg[WIDTH+WIDTH/8-1:WIDTH] ;
assign  M_WLAST  =  mux_out==0 ? A_reg[WIDTH+1+WIDTH/8-1]     : B_reg[WIDTH+1+WIDTH/8-1] ;

assign  S_WREADY =  state != 2 ;


always@(posedge CLK_I)begin
    if(RST_I)begin
        mux_in <= 0;
    end
    else begin 
        mux_in <= wr_in_valid ? ~mux_in : mux_in ;
    end
end


always@(posedge CLK_I)begin
    if(RST_I)begin
        A_reg <= 0;
    end
    else begin
        A_reg <= (wr_in_valid & ~mux_in) ?  { S_WLAST,S_WSTRB,S_WDATA } : A_reg ;
    end
end



always@(posedge CLK_I)begin
    if(RST_I)begin
        B_reg <= 0;
    end
    else begin
        B_reg <= (wr_in_valid & mux_in) ?  { S_WLAST,S_WSTRB,S_WDATA } : B_reg ;
    end
end



    
endmodule




