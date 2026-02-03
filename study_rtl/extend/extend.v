`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/23 11:53:42
// Design Name: 
// Module Name: extend
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


module extend(
input  [C_IN_BIT_NUM-1:0]  i0  ,
output [C_OUT_BIT_NUM-1:0] o0

    );
   
parameter C_IN_BIT_NUM   =  8 ;
parameter C_OUT_BIT_NUM  =  10 ;
parameter C_CHANGE_SITE  = "RIGHT" ; //    "RIGHT"  "LEFT"
    

generate if(C_OUT_BIT_NUM>=C_IN_BIT_NUM)begin
    if(C_CHANGE_SITE=="RIGHT")begin
        assign  o0 = ( i0<<(C_OUT_BIT_NUM-C_IN_BIT_NUM) ) ; 
    end
    else begin
        assign  o0 =   { 256'b0, i0 }   ;  
    end
end
else begin
    if(C_CHANGE_SITE=="RIGHT")begin
        assign  o0 = ( i0[C_IN_BIT_NUM-1 -: C_OUT_BIT_NUM ] ) ; 
    end
    else begin
        assign  o0 =  ( { 256'b0,  i0[C_OUT_BIT_NUM-1:0] } )  ;  
    end


end

endgenerate


    
endmodule




