`timescale 1ns / 1ps
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  yzhu
// 
// Create Date: 2025/09/26 16:27:39
// Design Name: 
// Module Name: rgb_to_raw
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////





module rgb_to_raw
#( 
   parameter C_PORT_NUM             = 4  ,
   parameter C_BITS_PER_CPNT        = 14 ,   // 在component中右对齐   目前只支持 >= 8
   parameter C_CPNTS_PER_PIXEL      = 3  
   // R G
   // G B 
)

(

input VID_CLK  ,
input VID_RSTN ,


input S_VS ,
input S_HS ,
input S_DE ,
input [8*C_PORT_NUM-1:0]  S_R_Y,
input [8*C_PORT_NUM-1:0]  S_G_U,
input [8*C_PORT_NUM-1:0]  S_B_V,


output reg M_VS = 0,
output reg M_HS = 0,
output reg M_DE = 0,
output reg [C_BITS_PER_CPNT*C_CPNTS_PER_PIXEL*C_PORT_NUM-1:0]  M_VID_DATA = 0, //硬配置  -- 典型输出 当cpnt maxbit=12   { 000 BB0 GG0 RR0  }  { 000 BB0 GG0 RR0  } { 000 BB0 GG0 RR0  } { 000 BB0 GG0 RR0  }  -- 注意 cpnt内部靠左对齐
                                                                                           // -- 典型输出                  { 000 000 000 RAW12}  { 000 000 000 RAW12} { 000 000 000 RAW12} { 000 000 000 RAW12} 


input  [1:0] TRANSFER_MODE  // 转换方式 0 1 2 :  "ORIGINAL"  "YUV_TO_YUV422"   "RGB_TO_RGGB"



);



genvar   i,j,k; 

wire S_VS_pos ;
wire S_HS_pos ;
reg  flip = 0;
reg has_de = 0;



always@(posedge VID_CLK)begin
    if(~VID_RSTN)begin
        has_de <= 0;
    end
    else begin
        has_de <= S_VS_pos ? 0 : S_DE ? 1 : has_de ;
    
    end
end



always@(posedge VID_CLK)begin
    if(~VID_RSTN)begin
        M_VS  <= 0;
        M_HS  <= 0;
        M_DE  <= 0;
    end
    else begin
        M_VS <= S_VS ;
        M_HS <= S_HS ;
        M_DE <= S_DE ;
    end   
  
end



`POS_MONITOR_OUTGEN(VID_CLK,0,S_VS,S_VS_pos) 
`POS_MONITOR_OUTGEN(VID_CLK,0,S_HS,S_HS_pos) 


always@(posedge VID_CLK) begin
    if(~VID_RSTN)begin
        flip <= 0;
    end
    else begin
        flip <= S_VS_pos ? 0 :  ( S_HS_pos & has_de ) ? (~flip) : flip  ;
    end
end



localparam  BIT_NUM = C_BITS_PER_CPNT*C_CPNTS_PER_PIXEL ;


generate for (i=0; i<=(C_PORT_NUM-1); i=i+1 )begin:blk
    
    
    always@(posedge VID_CLK)begin
        M_VID_DATA[C_BITS_PER_CPNT*C_CPNTS_PER_PIXEL*i+:(C_BITS_PER_CPNT*C_CPNTS_PER_PIXEL)]

        
              <= (TRANSFER_MODE==0) ? (  {    S_B_V[8*(i)+:8] , {(C_BITS_PER_CPNT-8){1'b0}}    
                                        ,S_G_U[8*(i)+:8], {(C_BITS_PER_CPNT-8){1'b0}}  
                                        , S_R_Y[8*(i)+:8], {(C_BITS_PER_CPNT-8){1'b0}}  }    ) :
                 (TRANSFER_MODE==1) ? (   //奇像素
                                   (i[0]==0) ?  { 0,    S_G_U[8*(i)+:8],{(C_BITS_PER_CPNT-8){1'b0}}    ,S_R_Y[8*(i)+:8],{(C_BITS_PER_CPNT-8){1'b0}} } :
                                   //偶像素          
                                                { 0,   S_B_V[8*(i-1)+:8], {(C_BITS_PER_CPNT-8){1'b0}}    ,S_R_Y[8*(i)+:8],{(C_BITS_PER_CPNT-8){1'b0}}  } 
                                 )  :
                                 
                                 
                ((TRANSFER_MODE==2)  ) ?  (  (flip==0)   ?  (    (i[0]==0) ?{   S_R_Y[8*(i)+:8],{(C_BITS_PER_CPNT-8){1'b0}}  }  :
                                                                 (i[0]==1) ? {S_G_U[8*(i)+:8],{(C_BITS_PER_CPNT-8){1'b0}}}  :   {   S_R_Y[8*(i)+:8],{(C_BITS_PER_CPNT-8){1'b0}}  }  
                                                                    )
                                                                 :                                                                   
                                                                 (    (i[0]==0) ?{   S_G_U[8*(i)+:8],{(C_BITS_PER_CPNT-8){1'b0}}  }  :
                                                                      (i[0]==1) ? {S_B_V[8*(i)+:8],{(C_BITS_PER_CPNT-8){1'b0}}}  :   {   S_G_U[8*(i)+:8],{(C_BITS_PER_CPNT-8){1'b0}}  }  
                                                                  
                                                                  )
                                                  ) :


                                                  (  {    S_B_V[8*(i)+:8] , {(C_BITS_PER_CPNT-8){1'b0}}    
                                                    ,S_G_U[8*(i)+:8], {(C_BITS_PER_CPNT-8){1'b0}}  
                                                    , S_R_Y[8*(i)+:8], {(C_BITS_PER_CPNT-8){1'b0}}  }    )    ;
          
    end
    

end  

endgenerate








endmodule



