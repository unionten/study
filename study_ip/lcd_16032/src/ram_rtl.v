
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)         for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end  
`define BI_TO_SINGLE_Nm1To0(a,b,in,out)         for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end  

module  ram_rtl
//综合结果不如xilinx IP核，且是否使用ram不确定（位宽差距大时可能使用LUT）
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
