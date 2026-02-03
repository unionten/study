

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////RAM_RTL/////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


`define SINGLE_TO_BI_Nm1To0(a,b,in,out)         for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end  
`define BI_TO_SINGLE_Nm1To0(a,b,in,out)         for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end  


module  ram_rtl
#(
  parameter       A_WR_DATA_WIDTH     = 32   ,
  parameter       A_WR_DATA_DEPTH     = 256  ,
  parameter       A_RD_DATA_WIDTH     = 32 ,
  
 
  parameter       INIT_FILE_PATH    = "./ram_init_file.txt" ,
  parameter       RD_MODE           = "fwft"    // "std"     "fwft" 
  
  
)
(
input                    clka  , 
input                    ena   ,
input                    wea   ,
input [AWI-1:0]          addra ,
input [A_WR_DATA_WIDTH-1:0]          dina   ,
output [A_WR_DATA_WIDTH-1:0]         doutba , 
input                    clkb  ,
input                    enb   ,
input                    web   ,
input  [AWO-1:0]         addrb ,
output [A_RD_DATA_WIDTH-1:0]         doutb 

);

///////////////////////////////////////////////////////////////////////////////////////
localparam       AWI = $clog2(A_WR_DATA_DEPTH);
localparam       AWO = A_WR_DATA_WIDTH>A_RD_DATA_WIDTH ? AWI+$clog2((A_WR_DATA_WIDTH/A_RD_DATA_WIDTH)) : AWI-$clog2((A_RD_DATA_WIDTH/A_WR_DATA_WIDTH));

//输出位宽大于输入位宽 时
localparam       EXTENT_DIV   = A_RD_DATA_WIDTH/A_WR_DATA_WIDTH ;
localparam       EXTENT_BIT   = AWI-AWO ;
//输入位宽大于输出位宽 时
localparam       SHRINK_DIV   = A_WR_DATA_WIDTH/A_RD_DATA_WIDTH ;
localparam       SHRINK_BIT   = AWO-AWI ;

///////////////////////////////////////////////////////////////////////////////////////

genvar i,j,k;



generate if (A_RD_DATA_WIDTH >= A_WR_DATA_WIDTH) begin  //输出位宽大于输入位宽  时
    //ram
    (*ram_style="block"*)
    reg [A_WR_DATA_WIDTH-1:0]  memory [(1<<AWI)-1 : 0] ;
    initial $readmemh(INIT_FILE_PATH,memory);

    
    //写
    always @(posedge clka) begin
       if (wea) begin
          memory[addra]  <= dina ;
       end
    end
    //读
    for (i=0; i<EXTENT_DIV; i=i+1) begin
    
       if(RD_MODE=="std")begin
            reg [A_RD_DATA_WIDTH-1:0]   Q1 = 0;
            always @(posedge clkb) begin
               if (enb) begin
                  Q1[(i+1)*A_WR_DATA_WIDTH-1: i*A_WR_DATA_WIDTH]  <= memory[(addrb*EXTENT_DIV) + i ] ;
               end
            end
            assign  doutb = Q1;
        end
        else begin
            wire [A_RD_DATA_WIDTH-1:0]   Q1 ;
            assign   Q1[(i+1)*A_WR_DATA_WIDTH-1: i*A_WR_DATA_WIDTH]   = memory[(addrb*EXTENT_DIV) + i ] ; //注意这里默认始终有enb
            assign  doutb = Q1;
        end
        
    end
end

else begin //输入位宽大于输出位宽  
       

wire [A_RD_DATA_WIDTH-1:0]  Q_m [SHRINK_DIV-1:0];
  
 
     

    (*ram_style="block"*)
    reg [A_WR_DATA_WIDTH-1:0]   memory [(1<<AWI)-1 : 0] ;
    initial $readmemh(INIT_FILE_PATH,memory);  
    
    always@(posedge clka)begin
        if (wea) begin
            memory[addra] <= dina; 
        end
    end
     
     
    if(RD_MODE=="std")begin
        reg [SHRINK_BIT-1:0] sel = 0;
        reg [A_WR_DATA_WIDTH-1:0]   Q1 = 0;
        `SINGLE_TO_BI_Nm1To0(A_RD_DATA_WIDTH,SHRINK_DIV,Q1,Q_m)   
        always@(posedge clkb)begin   //将地址打一拍，用于选择
            if(enb)begin
            sel <= addrb - ((addrb>>SHRINK_BIT)<<SHRINK_BIT) ; 
            end
        end
        always@(posedge clkb)begin
            if(enb) begin
                Q1 <= memory[addrb>>SHRINK_BIT];
            end
        end
        assign doutb = Q_m[ sel ] ; 
    end
    else begin
        wire [SHRINK_BIT-1:0] sel  ;
        wire  [A_WR_DATA_WIDTH-1:0]   Q1 ;
        `SINGLE_TO_BI_Nm1To0(A_RD_DATA_WIDTH,SHRINK_DIV,Q1,Q_m)   
        assign  sel = addrb - ((addrb>>SHRINK_BIT)<<SHRINK_BIT) ; 
        assign  Q1 = memory[addrb>>SHRINK_BIT]; 
        assign doutb = Q_m[ sel ] ; 
    end
        
    
    
end

endgenerate



endmodule
