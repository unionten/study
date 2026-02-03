`timescale 1ns / 1ps
`define POS_MONITOR_FF1(clk_in,rst_in,in,buf_name1,out)      reg buf_name1 = 1; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 1; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2023/01/06 14:45:06
// Design Name: 
// Module Name: fifo_sync_return
//////////////////////////////////////////////////////////////////////////////////

/*
fifo_sync_return
    #(
     .C_WR_WIDTH(32),
     .C_WR_DEPTH(6),
     .C_RD_WIDTH(256),
     .C_WR_PROG_FULL_THRESH (60),
     .C_RD_PROG_EMPTY_THRESH(10),
     .C_WR_RETURN_EN(0),
     .C_RD_RETURN_EN(0)
     .C_WR_COUNT_WIDTH(11),
     .C_RD_COUNT_WIDTH(11)
     )
    fifo_sync_return_u(
    .CLK_I              (),
    .RST_I              (),
    .WR_EN_I            (),
    .WR_EN_VALID_O      (),
    .WR_DATA_I          (),  
    .WR_SUCC_I          (),  //应和 WR_EN 错开(如果同时到，则 WR_EN 优先)
    .WR_FAIL_I          (),  //应和 WR_EN 错开(如果同时到，则 WR_EN 优先)
    .WR_FULL_O          (),
    .WR_PROG_FULL_O     (),
    .WR_DATA_COUNT_O    (), 
    .RD_EN_I            (),
    .RD_DATA_O          (),  
    .RD_DATA_VALID_O    (),
    .RD_SUCC_I          (),   //应和 RD_EN 错开(如果同时到，则 RD_EN 优先)
    .RD_FAIL_I          (),   //应和 RD_EN 错开(如果同时到，则 RD_EN 优先)
    .RD_EMPTY_O         (),
    .RD_PROG_EMPTY_O    (), 
    .RD_DATA_COUNT_O    ()    
    
    );
*/


module fifo_sync_return(
input                         CLK_I           ,
input                         RST_I           ,
                                                   
input                         WR_EN_I         ,
output                        WR_EN_VALID_O   ,
input  [C_WR_WIDTH-1:0]       WR_DATA_I       ,
input                         WR_SUCC_I       ,
input                         WR_FAIL_I       ,
output                        WR_FULL_O       ,  //【最终折算值】 
output                        WR_PROG_FULL_O  ,//【最终折算值】
output [C_WR_COUNT_WIDTH:0]   WR_DATA_COUNT_O ,//【最终折算值】

input                         RD_EN_I         ,
output [C_RD_WIDTH-1:0]       RD_DATA_O       ,
output reg                    RD_DATA_VALID_O ,
input                         RD_SUCC_I       ,
input                         RD_FAIL_I       ,
output                        RD_EMPTY_O      ,//【最终折算值】
output                        RD_PROG_EMPTY_O , //【最终折算值】
output [C_RD_COUNT_WIDTH:0]   RD_DATA_COUNT_O//【最终折算值】

);
//对RAM IP核做相同设置
parameter  C_WR_WIDTH = 16;
parameter  C_WR_DEPTH = 16; //【只考虑内部RAM】 内部ram的深度（不包含输出寄存器）; 必须为2的幂次，否则格雷码无法正常运行
parameter  C_RD_WIDTH = 8;
parameter  C_RD_MODE     = "std";// "std" "fwft"
parameter  C_WR_PROG_FULL_THRESH  = C_WR_DEPTH;  
parameter  C_RD_PROG_EMPTY_THRESH = 0;  
parameter  [0:0] C_WR_RETURN_EN = 1'b0;
parameter  [0:0] C_RD_RETURN_EN = 1'b0;
parameter  C_WR_COUNT_WIDTH =  C_WR_ADDR_WIDTH+1;//为了方便判断位宽，提供给用户自定义
parameter  C_RD_COUNT_WIDTH =  C_RD_ADDR_WIDTH+1;//为了方便判断位宽，提供给用户自定义


//no use parameters for unify
parameter  C_WR_CHANGE_COUNT = 4;


/////////////////////////////////////////////////////////////////////////////////////////

localparam C_RD_DATA_DEPTH =   (C_RD_WIDTH>C_WR_WIDTH)  ? C_WR_DEPTH/(C_RD_WIDTH/C_WR_WIDTH)   :  C_WR_DEPTH*(C_WR_WIDTH/C_RD_WIDTH)  ;//ram的地址位宽
localparam C_WR_ADDR_WIDTH = $clog2(C_WR_DEPTH) ;
localparam C_RD_ADDR_WIDTH = $clog2(C_RD_DATA_DEPTH) ;
localparam BIT_EXTENT = (C_WR_ADDR_WIDTH>=C_RD_ADDR_WIDTH) ? (C_WR_ADDR_WIDTH - C_RD_ADDR_WIDTH) : (C_RD_ADDR_WIDTH - C_WR_ADDR_WIDTH) ;
    

wire [C_WR_ADDR_WIDTH:0]  FIFO_WR_DATA_COUNT_inner_ram ;
wire [C_RD_ADDR_WIDTH:0]  FIFO_RD_DATA_COUNT_inner_ram ;

wire [C_WR_ADDR_WIDTH:0]  FIFO_WR_DATA_COUNT_outter;
wire [C_WR_ADDR_WIDTH:0]  FIFO_RD_DATA_COUNT_outter;


assign WR_DATA_COUNT_O = {0,FIFO_WR_DATA_COUNT_outter};//调整为真实值
assign RD_DATA_COUNT_O = {0,FIFO_RD_DATA_COUNT_outter};


///////////////////////////////////////////////////////////////
//
wire  fifo_rd_empty__ram;
wire  fifo_rd_en__ram ;
wire FIFO_RD_EN_I_valid;
reg  ff_valid  = 0;

generate if(C_RD_MODE=="std")begin
    assign RD_EMPTY_O = fifo_rd_empty__ram;
    assign fifo_rd_en__ram = RD_EN_I;
    always@(posedge CLK_I)begin
        if(RST_I)begin
            RD_DATA_VALID_O <= 0;
        end
        else begin
            RD_DATA_VALID_O <= actual_rd_en ;
        end
    end
end
else if(C_RD_MODE=="fwft")begin
    assign RD_EMPTY_O =  ~ff_valid ;
    assign fifo_rd_en__ram =   ~fifo_rd_empty__ram &
                              (~ff_valid | FIFO_RD_EN_I_valid ); 
    always@(*)RD_DATA_VALID_O = FIFO_RD_EN_I_valid & ~RD_EMPTY_O;   
    assign  FIFO_RD_EN_I_valid = RD_EN_I & ~RD_EMPTY_O;
    always@(posedge CLK_I)begin
        if(RST_I | FIFO_RD_FAIL_I_pos)begin //FIFO_RD_FAIL_I_pos
            ff_valid <= 0;
        end
        else case({FIFO_RD_EN_I_valid,fifo_rd_en__ram})
            2'b00:ff_valid <= ff_valid;
            2'b01:ff_valid <= 1;
            2'b10:ff_valid <= 0;
            2'b11:ff_valid <= ff_valid;
            default:;  
        endcase
    end
end
endgenerate

///////////////////////////////////////////////////////////////
wire FIFO_WR_SUCC_I_pos;
wire FIFO_WR_FAIL_I_pos;
wire FIFO_RD_SUCC_I_pos;
wire FIFO_RD_FAIL_I_pos;
`POS_MONITOR_FF1(CLK_I,0,WR_SUCC_I,buf_name1,FIFO_WR_SUCC_I_pos)   
`POS_MONITOR_FF1(CLK_I,0,WR_FAIL_I,buf_name2,FIFO_WR_FAIL_I_pos)   
`POS_MONITOR_FF1(CLK_I,0,RD_SUCC_I,buf_name3,FIFO_RD_SUCC_I_pos)   
`POS_MONITOR_FF1(CLK_I,0,RD_FAIL_I,buf_name4,FIFO_RD_FAIL_I_pos)   

   
//写端bincode计数
reg [C_WR_ADDR_WIDTH:0] wr_bincode_1 = 0;
reg [C_WR_ADDR_WIDTH:0] wr_bincode_1_init = 0;
reg [C_WR_ADDR_WIDTH:0] wr_bincode_2 = 0;
wire             wr_flag_1 = wr_bincode_1[C_WR_ADDR_WIDTH];
wire [C_WR_ADDR_WIDTH-1:0] wr_addr_1 = wr_bincode_1[C_WR_ADDR_WIDTH-1:0];
wire             wr_flag_2 = wr_bincode_2[C_WR_ADDR_WIDTH];
wire [C_WR_ADDR_WIDTH-1:0] wr_addr_2 = wr_bincode_2[C_WR_ADDR_WIDTH-1:0];
always@(posedge CLK_I)begin
    if(RST_I)begin
        wr_bincode_1 <= 0;
        wr_bincode_1_init <= 0;
    end
    else if(WR_EN_I & ~WR_FULL_O)begin
        wr_bincode_1 <= wr_bincode_1 + 1;
    end
    else if(C_WR_RETURN_EN & FIFO_WR_SUCC_I_pos )begin
        wr_bincode_1_init <= wr_bincode_1;
    end
    else if(C_WR_RETURN_EN & FIFO_WR_FAIL_I_pos)begin
        wr_bincode_1      <= wr_bincode_1_init;
    end
end   


always@(posedge CLK_I)begin
    if(RST_I)begin
        wr_bincode_2 <= 0;
    end
    else if(C_WR_RETURN_EN )begin
        if(WR_SUCC_I )begin
            wr_bincode_2      <= wr_bincode_1;
        end
    end
    else begin
        wr_bincode_2      <= wr_bincode_1;
    end 
end   



//读端bincode计数
reg [C_RD_ADDR_WIDTH:0] rd_bincode_1 = 0;
reg [C_RD_ADDR_WIDTH:0] rd_bincode_1_init = 0;
reg [C_RD_ADDR_WIDTH:0] rd_bincode_2 = 0;
wire             rd_flag_1 = rd_bincode_1[C_RD_ADDR_WIDTH];
wire [C_RD_ADDR_WIDTH-1:0] rd_addr_1 = rd_bincode_1[C_RD_ADDR_WIDTH-1:0];
wire             rd_flag_2 = rd_bincode_2[C_RD_ADDR_WIDTH];
wire [C_RD_ADDR_WIDTH-1:0] rd_addr_2 = rd_bincode_2[C_RD_ADDR_WIDTH-1:0];
always@(posedge CLK_I)begin
    if(RST_I)begin
        rd_bincode_1 <= 0;
        rd_bincode_1_init <= 0;  
    end
    else if(fifo_rd_en__ram & ~fifo_rd_empty__ram)begin //内部fifo读取
        rd_bincode_1 <= rd_bincode_1 + 1;
    end
    else if(C_RD_RETURN_EN & FIFO_RD_SUCC_I_pos )begin
        rd_bincode_1_init <= rd_bincode_1;
    end
    else if(C_RD_RETURN_EN & FIFO_RD_FAIL_I_pos)begin
        rd_bincode_1      <= rd_bincode_1_init;
    end
end   


always@(posedge CLK_I)begin
    if(RST_I)begin
        rd_bincode_2 <= 0;
    end
    else if(C_RD_RETURN_EN)begin
        if(FIFO_RD_SUCC_I_pos)begin
            rd_bincode_2   <= rd_bincode_1;
        end
    end
    else begin
        rd_bincode_2 <= rd_bincode_1;
    end  
end  


//原则：比较端使用精确值，另一端以保守方式传递到比较端
generate if(C_WR_WIDTH <= C_RD_WIDTH  )begin : rd_data_wider 
    //空满信号生成
   // assign WR_FULL_O =   ( wr_addr_1 == rd_addr_2 *(2**BIT_EXTENT) )  & ( wr_flag_1 != rd_flag_2   ) ;
    assign fifo_rd_empty__ram =  ( rd_addr_1 ==  wr_addr_2/(2**BIT_EXTENT) )  & ( rd_flag_1  ==  wr_flag_2 ) ;
    
    //data_count变量生成
    wire [C_WR_ADDR_WIDTH-1:0] rd_addr_2_conv =  rd_addr_2*(2**BIT_EXTENT);
    wire [C_RD_ADDR_WIDTH-1:0] wr_addr_2_conv =  wr_addr_2/(2**BIT_EXTENT);
    assign FIFO_WR_DATA_COUNT_inner_ram = {wr_flag_1,wr_addr_1     }  + ~({rd_flag_2,rd_addr_2_conv} ) + 1 ;
    assign FIFO_RD_DATA_COUNT_inner_ram = {wr_flag_2,wr_addr_2_conv}  + ~({rd_flag_1 ,rd_addr_1    } ) + 1 ;
end
else if(C_WR_WIDTH > C_RD_WIDTH  ) begin : wr_data_wider
    //用乘法会导致数据卡不上，一下子越过了 rd_addr 
    //assign WR_FULL_O =   ( wr_addr_1  ==  rd_addr_2/(2**BIT_EXTENT) )  & ( wr_flag_1 != rd_flag_2   ) ;
    assign fifo_rd_empty__ram =  ( rd_addr_1  ==  wr_addr_2*(2**BIT_EXTENT) )  & ( rd_flag_1  ==  wr_flag_2 ) ;

    //data_count变量生成
    wire [C_WR_ADDR_WIDTH-1:0] rd_addr_2_conv =  rd_addr_2/(2**BIT_EXTENT);
    wire [C_RD_ADDR_WIDTH-1:0] wr_addr_2_conv =  wr_addr_2*(2**BIT_EXTENT);
    assign FIFO_WR_DATA_COUNT_inner_ram = {wr_flag_1,wr_addr_1     }  + ~({rd_flag_2,rd_addr_2_conv} ) + 1  ;
    assign FIFO_RD_DATA_COUNT_inner_ram = {wr_flag_2,wr_addr_2_conv}  + ~({rd_flag_1 ,rd_addr_1    } ) + 1  ;
end
endgenerate



generate if(C_RD_MODE=="fwft")begin
     if(C_WR_WIDTH <= C_RD_WIDTH )begin
        assign WR_FULL_O =   ( wr_addr_1 == rd_addr_2 *(2**BIT_EXTENT) )  & ( wr_flag_1 != rd_flag_2   )  &   ff_valid ;
        
     end
     else begin
        assign WR_FULL_O =   ( wr_addr_1  ==  rd_addr_2/(2**BIT_EXTENT) )  & ( wr_flag_1 != rd_flag_2   ) &   ff_valid ;
     end
end
else begin
    if(C_WR_WIDTH <= C_RD_WIDTH )begin
        assign WR_FULL_O =   ( wr_addr_1 == rd_addr_2 *(2**BIT_EXTENT) )  & ( wr_flag_1 != rd_flag_2   ) ;
    end
    else begin
        assign WR_FULL_O =   ( wr_addr_1  ==  rd_addr_2/(2**BIT_EXTENT) )  & ( wr_flag_1 != rd_flag_2   ) ; 
    end
end
endgenerate




generate if(C_RD_MODE=="fwft")begin
    if(C_WR_WIDTH <= C_RD_WIDTH )begin
        assign FIFO_WR_DATA_COUNT_outter = ff_valid*(C_RD_WIDTH/C_WR_WIDTH) + FIFO_WR_DATA_COUNT_inner_ram;
    end
    else begin//(C_WR_WIDTH > C_RD_WIDTH )
        assign FIFO_WR_DATA_COUNT_outter = FIFO_WR_DATA_COUNT_inner_ram;
    end
    
    assign FIFO_RD_DATA_COUNT_outter = ff_valid ? ( ff_valid + FIFO_RD_DATA_COUNT_inner_ram ) : 0;
    
end
else begin//(C_RD_MODE=="std")
    assign FIFO_WR_DATA_COUNT_outter = FIFO_WR_DATA_COUNT_inner_ram;
    assign FIFO_RD_DATA_COUNT_outter = FIFO_RD_DATA_COUNT_inner_ram;
end
endgenerate



assign WR_PROG_FULL_O  = FIFO_WR_DATA_COUNT_outter >= C_WR_PROG_FULL_THRESH ;
assign RD_PROG_EMPTY_O = FIFO_RD_DATA_COUNT_outter <= C_RD_PROG_EMPTY_THRESH ;



 ram_rtl_fifo_sync_return
#(.WR_DATA_WIDTH (C_WR_WIDTH ),
  .WR_DATA_DEPTH (C_WR_DEPTH),
  .RD_DATA_WIDTH (C_RD_WIDTH))
  ram_u(
    .clka   (CLK_I          ),
    .wea    (actual_wr_en   ),
    .addra  (wr_addr_1      ),
    .dina   (WR_DATA_I      ),
    .clkb   (CLK_I          ),
    .enb    (actual_rd_en   ),
    .addrb  (rd_addr_1      ),
    .doutb  (RD_DATA_O      ) 
    );


wire  actual_wr_en;
wire  actual_rd_en;
assign actual_wr_en = WR_EN_I & ~WR_FULL_O ;
assign actual_rd_en = fifo_rd_en__ram & ~fifo_rd_empty__ram;//////

assign WR_EN_VALID_O = actual_wr_en ;





endmodule





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////RAM_RTL/////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


`define SINGLE_TO_BI_Nm1To0(a,b,in,out)         for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end  
`define BI_TO_SINGLE_Nm1To0(a,b,in,out)         for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end  


module  ram_rtl_fifo_sync_return
#(
  parameter       WR_DATA_WIDTH     = 32 ,
  parameter       WR_DATA_DEPTH     = 256 ,
  parameter       RD_DATA_WIDTH     = 256
)
(
input                    clka  , 
input                    wea   ,
input [AWI-1:0]          addra ,
input [WR_DATA_WIDTH-1:0]          dina  ,
input                    clkb  ,
input                    enb   ,
input  [AWO-1:0]         addrb ,
output [RD_DATA_WIDTH-1:0]         doutb 

);

///////////////////////////////////////////////////////////////////////////////////////
localparam       AWI = $clog2(WR_DATA_DEPTH);
localparam       AWO = WR_DATA_WIDTH>RD_DATA_WIDTH ? AWI+$clog2((WR_DATA_WIDTH/RD_DATA_WIDTH)) : AWI-$clog2((RD_DATA_WIDTH/WR_DATA_WIDTH));

//输出位宽大于输入位宽
localparam       EXTENT_DIV   = RD_DATA_WIDTH/WR_DATA_WIDTH ;
localparam       EXTENT_BIT   = AWI-AWO ;
//输入位宽大于输出位宽
localparam       SHRINK_DIV   = WR_DATA_WIDTH/RD_DATA_WIDTH ;
localparam       SHRINK_BIT   = AWO-AWI ;

///////////////////////////////////////////////////////////////////////////////////////

genvar i,j,k;



generate if (RD_DATA_WIDTH >= WR_DATA_WIDTH) begin  //输出位宽大于输入位宽
    //ram
    (*ram_style="block"*)
    reg [WR_DATA_WIDTH-1:0]  memory [(1<<AWI)-1 : 0] ;
    reg [RD_DATA_WIDTH-1:0]   Q1 = 0;
    //写
    always @(posedge clka) begin
       if (wea) begin
          memory[addra]  <= dina ;
       end
    end
    //读
    for (i=0; i<EXTENT_DIV; i=i+1) begin
       always @(posedge clkb) begin
          if (enb) begin
             Q1[(i+1)*WR_DATA_WIDTH-1: i*WR_DATA_WIDTH]  <= memory[(addrb*EXTENT_DIV) + i ] ;
          end
       end
    end
    assign  doutb = Q1;

end
else begin //输入位宽大于输出位宽  
           
reg [WR_DATA_WIDTH-1:0]   Q1 = 0;
wire [RD_DATA_WIDTH-1:0]  Q_m [SHRINK_DIV-1:0];
`SINGLE_TO_BI_Nm1To0(RD_DATA_WIDTH,SHRINK_DIV,Q1,Q_m)     
 
     

    (*ram_style="block"*)
    reg [WR_DATA_WIDTH-1:0]   memory [(1<<AWI)-1 : 0] ;
    always@(posedge clka)begin
        if (wea) begin
            memory[addra] <= dina; 
        end
    end
     
     
    
    always@(posedge clkb)begin
        if(enb) begin
            Q1 <= memory[addrb>>SHRINK_BIT];
        end
    end
    
    //将地址打一拍，用于选择
    reg [SHRINK_BIT-1:0] sel = 0;
    always@(posedge clkb)begin
        if(enb)begin
        sel <= addrb - ((addrb>>SHRINK_BIT)<<SHRINK_BIT) ; 
        end
    end
    
    
    assign doutb = Q_m[ sel ] ; 
     
    
end

endgenerate



endmodule
