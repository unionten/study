`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2023/12/28 12:01:24
// Design Name: 
// Module Name: reg_fifo
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////
module reg_fifo_cas
#( parameter    WIDTH   = 8 ,
   parameter    CAS_NUM = 2 
 )
(
input                CLK_I    ,
input                RST_I    , 
input                S_WVALID  ,  
output               S_WREADY  , 
input   [WIDTH-1:0]  S_WDATA   ,

output               M_WVALID ,
input                M_WREADY ,
output  [WIDTH-1:0]  M_WDATA  

);


genvar i,j,k ;

wire S_WVALID_cas [CAS_NUM:0] ;
wire S_WREADY_cas  [CAS_NUM:0] ;
wire [WIDTH-1:0] S_WDATA_cas   [CAS_NUM:0] ;
wire M_WVALID_cas  [CAS_NUM:0] ; 
wire M_WREADY_cas    [CAS_NUM:0] ;
wire [WIDTH-1:0] M_WDATA_cas    [CAS_NUM:0] ;



assign  S_WVALID_cas[0]  =  S_WVALID;
assign  S_WREADY         = S_WREADY_cas[0] ;
assign  S_WDATA_cas[0]   =  S_WDATA ;


generate for(i=0;i<=CAS_NUM-1;i=i+1)begin
reg_fifo
    #( .WIDTH(WIDTH) )
    reg_fifo_u(
    .CLK_I     (CLK_I  ),
    .RST_I     (RST_I  ), 
    .S_WVALID  (S_WVALID_cas[i]  ),  
    .S_WREADY  (S_WREADY_cas[i]  ), 
    .S_WDATA   (S_WDATA_cas[i]   ),
    .M_WVALID  (M_WVALID_cas [i] ),
    .M_WREADY  (M_WREADY_cas[i]  ),
    .M_WDATA   (M_WDATA_cas[i]   )
     );

    assign S_WVALID_cas[i+1] = M_WVALID_cas[i] ;
    assign S_WDATA_cas [i+1] = M_WDATA_cas[i] ;
    assign S_WREADY_cas[i] = M_WREADY_cas[i+1] ;

end
endgenerate

assign  M_WVALID = S_WVALID_cas[CAS_NUM] ;
assign  M_WREADY_cas[CAS_NUM] =  M_WREADY;
assign  M_WDATA  = S_WDATA_cas[CAS_NUM] ;



endmodule




module reg_fifo
#( parameter    WIDTH  = 8 
 )

(
input                CLK_I    ,
input                RST_I    , 
input                S_WVALID  ,  
input   [WIDTH-1:0]  S_WDATA   ,
 
output               S_WREADY  , 
output               M_WVALID ,
input                M_WREADY ,
output  [WIDTH-1:0]  M_WDATA  

);
reg [WIDTH-1:0] A_reg = 0;


reg [WIDTH-1:0] B_reg = 0;

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

localparam  A0B0_A = 0 ,
            A1B0   = 1 ,
            A1B1_A = 2 ,
            A0B0_B = 3 ,
            A0B1   = 4 ,
            A1B1_B = 5 ; 
            
reg [7:0] state = A0B0_A; //state通过组合逻辑引出标志
//state状态的切换应该在 valid和ready一同为高
//写选择通过mux来回切换，不需要状态机参与
//读选择通过状态机判断


            
            
always@(posedge CLK_I)begin
    if(RST_I)begin  //要点：op为读写操作，但是根据状态的不同，实际是对不同的寄存器进行操作
        state <= A0B0_A;
    end
    else begin
        case(state) 
            //A0B0 A1B1  需要加后缀，接下来是写A还是写B；A1B1需要加后缀，接下来是读A还是读B
            A0B0_A:begin 
                state <=  op[1]==1'b1 ? A1B0 : state ;
            end
            A1B0:begin 
                state <=  op==2'b00 ? state  : 
                          op==2'b10 ? A1B1_A :
                          op==2'b01 ? A0B0_B :
                          op==2'b11 ? A0B1   : state ;
            end  
            A1B1_A :begin
                state <= op[0]==1'b1 ? A0B1  : state ;
            end
            A0B0_B : begin
                state <=  op[1]==1'b1 ? A0B1 : state ;
            end
            A0B1: begin
                state <=  op==2'b00 ? state  : 
                          op==2'b10 ? A1B1_B :
                          op==2'b01 ? A0B0_A :
                          op==2'b11 ? A1B0   : state ;
            end
            A1B1_B :begin
                state <= op[0]==1'b1 ? A1B0  : state ;
            end
            default:;
        endcase
    end
end


always@(*)begin
    case(state) // mux_out 0 选择 A , 1 选择 B
        A0B0_A : mux_out = 0 ;
        A1B0   : mux_out = 0 ;
        A1B1_A : mux_out = 0 ;
        A0B0_B : mux_out = 0 ;
        A0B1   : mux_out = 1 ;
        A1B1_B : mux_out = 1 ;
        default:mux_out  = 0;
    endcase
end


//mux_out : 用于控制输出
assign  M_WVALID =  (state != A0B0_A) & (state != A0B0_B)   ;
assign  S_WREADY =  (state != A1B1_A) & (state != A1B1_B)   ;
assign  M_WDATA  =  mux_out==0 ? A_reg[WIDTH-1:0]             : B_reg[WIDTH-1:0] ;


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
        A_reg <= (wr_in_valid & ~mux_in) ?  { S_WDATA } : A_reg ;
    end
end



always@(posedge CLK_I)begin
    if(RST_I)begin
        B_reg <= 0;
    end
    else begin
        B_reg <= (wr_in_valid & mux_in) ?  { S_WDATA } : B_reg ;
    end
end



    
endmodule




