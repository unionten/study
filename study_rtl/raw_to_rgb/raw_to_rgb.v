`timescale 1ns / 1ps
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/26 16:27:39
// Design Name: 
// Module Name: rgb_to_raw
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


module rgb_to_raw
#( parameter C_BPP  = 8 ,
   parameter C_PORT_NUM = 4,
   parameter C_RAW_BIT_NUM = 12 ,
   parameter C_RAW_MODE =  "RGGB"
   // R G
   // G B 
)

(

input VID_CLK  ,
input VID_RSTN ,

output S_VS ,
output S_HS ,
output S_DE ,
output [C_BPP*C_PORT_NUM-1:0]  S_R,
output [C_BPP*C_PORT_NUM-1:0]  S_G,
output [C_BPP*C_PORT_NUM-1:0]  S_B,


input M_VS ,
input M_HS ,
input M_DE ,
input [C_RAW_BIT_NUM*C_PORT_NUM-1:0]  M_RAW 


);



genvar i,j,k; 

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




generate for (i=0; i<(C_PORT_NUM/2); i=i+1 )begin:blk

    if(C_RAW_MODE=="RGGB")begin
        always@(posedge VID_CLK)begin
            M_RAW[i*2*(C_RAW_BIT_NUM)+:(2*C_RAW_BIT_NUM)] <= (flip==0) ? { S_G[C_BPP*(i*2+1)+:C_BPP],{(C_RAW_BIT_NUM-C_BPP){1'b0}} , S_R[C_BPP*(i*2)+:C_BPP],{(C_RAW_BIT_NUM-C_BPP){1'b0}} } 
                                  : { S_B[C_BPP*(i*2+1)+:C_BPP],{(C_RAW_BIT_NUM-C_BPP){1'b0}} , S_G[C_BPP*(i*2)+:C_BPP],{(C_RAW_BIT_NUM-C_BPP){1'b0}} }  ;
        end
    end
    else begin //default RGGB
        always@(posedge VID_CLK)begin
            M_RAW[i*2*(C_RAW_BIT_NUM)+:(2*C_RAW_BIT_NUM)] <= (flip==0) ? { S_G[C_BPP*(i*2+1)+:C_BPP],{(C_RAW_BIT_NUM-C_BPP){1'b0}} , S_R[C_BPP*(i*2)+:C_BPP],{(C_RAW_BIT_NUM-C_BPP){1'b0}} } 
                                  : { S_B[C_BPP*(i*2+1)+:C_BPP],{(C_RAW_BIT_NUM-C_BPP){1'b0}} , S_G[C_BPP*(i*2)+:C_BPP],{(C_RAW_BIT_NUM-C_BPP){1'b0}} }  ;
        end
    end
    
end
endgenerate








endmodule



