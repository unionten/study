`timescale 1ns / 1ps
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)       generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define BI_TO_SINGLE_Nm1To0(a,b,in,out)       generate for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end endgenerate
`define SINGLE_TO_TRI_Nm1To0(a,b,c,in,out)    generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[b-i][c-j] = in[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ];end end endgenerate
`define TRI_TO_SINGLE_Nm1To0(a,b,c,in,out)    generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ] = in[b-i][c-j];end end endgenerate
`define SINGLE_TO_FOUR_Nm1To0(a,b,c,d,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[b-i][c-j][d-k] = in[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1]; end end end endgenerate
`define FOUR_TO_SINGLE_Nm1To0(a,b,c,d,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1] = in[b-i][c-j][d-k]; end end end endgenerate

 
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2023/07/13 13:03:12
// Design Name: 
// Module Name: reconcat_2
// Project Name: 
// Target Devices: 
// Tool Versions: 
//////////////////////////////////////////////////////////////////////////////////

/*
 reconcat_2   
     #(.C_PORT_NUM        () ,
       .C_BITS_PER_CPNT   () ,
       .C_MAX_CPNTS_PER_PIXEL () )
     reconcat_2_u
     (
         .ACTUAL_CPNTS_PER_PIXEL_I  () ,     
         .DATA_I                    () , 
         .DATA_O                    ()  
     );
*/



 
module vid2mipi_concat(
input [7:0]                                                       ACTUAL_CPNTS_PER_PIXEL_I   ,     
input [C_MAX_CPNTS_PER_PIXEL*C_BITS_PER_CPNT*C_PORT_NUM-1:0]      DATA_I             , 
output  reg [C_MAX_CPNTS_PER_PIXEL*C_BITS_PER_CPNT*C_PORT_NUM-1:0] DATA_O            
    );
parameter  C_PORT_NUM        = 4; // 1 2 4
parameter  C_BITS_PER_CPNT   = 8;

parameter  C_MAX_CPNTS_PER_PIXEL = 3; // 1 2 3 4 



genvar i,j,k;

// {} 字节数为参数动态配置  [ ] 为硬配置
// {xxxxxxxxxxxxxxxxxx[aa][bb][cc][dd]} -> {{xxxxaa}{xxxxxbb}{xxxxxxcc}{xxxxxxdd}} 

// 例如如果输入为  { 000 000 000 RAW12}  { 000 000 000 RAW12} { 000 000 000 RAW12} { 000 000 000 RAW12}  -- 则直接通过 DATA_I_m 截取其所需的 cpnt，然后拼接 （cpnt 内部已经靠左对齐）


wire [C_MAX_CPNTS_PER_PIXEL*C_BITS_PER_CPNT-1:0] DATA_I_m [C_PORT_NUM-1:0];

`SINGLE_TO_BI_Nm1To0((C_MAX_CPNTS_PER_PIXEL*C_BITS_PER_CPNT),C_PORT_NUM,DATA_I,DATA_I_m)



generate 
if(C_PORT_NUM==1 && C_MAX_CPNTS_PER_PIXEL==1)begin

    always@(*)begin
        case(ACTUAL_CPNTS_PER_PIXEL_I)
            1 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
            end
            default : begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
            end
        endcase
    end
    
end
else if(C_PORT_NUM==1 && C_MAX_CPNTS_PER_PIXEL==2)begin

    always@(*)begin
        case(ACTUAL_CPNTS_PER_PIXEL_I)
            1 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
            end
            2 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*2] <= DATA_I_m[0] ;
            end
            default : begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
            end
        endcase
    end
    
end
else if(C_PORT_NUM==1 && C_MAX_CPNTS_PER_PIXEL==3)begin

    always@(*)begin
        case(ACTUAL_CPNTS_PER_PIXEL_I)
            1 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
            end
            2 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*2] <= DATA_I_m[0] ;
            end
            3 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*3] <= DATA_I_m[0] ;
            end
            default : begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
            end
        endcase
    end
    
end
else if(C_PORT_NUM==1 && C_MAX_CPNTS_PER_PIXEL==4)begin

    always@(*)begin
        case(ACTUAL_CPNTS_PER_PIXEL_I)
            1 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
            end
            2 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*2] <= DATA_I_m[0] ;
            end
            3 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*3] <= DATA_I_m[0] ;
            end
            4 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*4] <= DATA_I_m[0] ;
            end
            default : begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
            end
        endcase
    end
    
end
else if(C_PORT_NUM==2  && C_MAX_CPNTS_PER_PIXEL==1 )begin


    always@(*)begin
        case(ACTUAL_CPNTS_PER_PIXEL_I)
            1 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
            end
            default : begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
            end
        endcase
    end

end
else if(C_PORT_NUM==2  && C_MAX_CPNTS_PER_PIXEL==2 )begin


    always@(*)begin
        case(ACTUAL_CPNTS_PER_PIXEL_I)
            1 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
            end
            2 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*2] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*2] <= DATA_I_m[1] ;
            end
            default : begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
            end
        endcase
    end

end
else if(C_PORT_NUM==2  && C_MAX_CPNTS_PER_PIXEL==3 )begin


    always@(*)begin
        case(ACTUAL_CPNTS_PER_PIXEL_I)
            1 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
            end
            2 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*2] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*2] <= DATA_I_m[1] ;
            end
            3 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*3] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*3] <= DATA_I_m[1] ;
            end
            default : begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
            end
        endcase
    end

end
else if(C_PORT_NUM==2  && C_MAX_CPNTS_PER_PIXEL==4 )begin


    always@(*)begin
        case(ACTUAL_CPNTS_PER_PIXEL_I)
            1 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
            end
            2 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*2] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*2] <= DATA_I_m[1] ;
            end
            3 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*3] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*3] <= DATA_I_m[1] ;
            end
            4 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*4] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*4 +: C_BITS_PER_CPNT*4] <= DATA_I_m[1] ;
            end
            default : begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
            end
        endcase
    end

end
else if(C_PORT_NUM==2  && C_MAX_CPNTS_PER_PIXEL==3 )begin


    always@(*)begin
        case(ACTUAL_CPNTS_PER_PIXEL_I)
            1 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
            end
            2 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*2] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*2] <= DATA_I_m[1] ;
            end
            3 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*3] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*3] <= DATA_I_m[1] ;
            end
            4 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*4] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*4 +: C_BITS_PER_CPNT*4] <= DATA_I_m[1] ;
            end
            default : begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
            end
        endcase
    end

end
else if(C_PORT_NUM==4  && C_MAX_CPNTS_PER_PIXEL==1  )begin

    always@(*)begin
        case(ACTUAL_CPNTS_PER_PIXEL_I)
            1 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*1] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*1] <= DATA_I_m[3] ;
            end
            default : begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*1] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*1] <= DATA_I_m[3] ;
            end
        endcase
    end

end
else if(C_PORT_NUM==4  && C_MAX_CPNTS_PER_PIXEL==2  )begin

    always@(*)begin
        case(ACTUAL_CPNTS_PER_PIXEL_I)
            1 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*1] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*1] <= DATA_I_m[3] ;
            end
            2 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*2] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*2] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*4 +: C_BITS_PER_CPNT*2] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*6 +: C_BITS_PER_CPNT*2] <= DATA_I_m[3] ;
            end
            default : begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*1] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*1] <= DATA_I_m[3] ;
            end
        endcase
    end

end
else if(C_PORT_NUM==4  && C_MAX_CPNTS_PER_PIXEL==3  )begin

    always@(*)begin
        case(ACTUAL_CPNTS_PER_PIXEL_I)
            1 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*1] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*1] <= DATA_I_m[3] ;
            end
            2 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*2] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*2] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*4 +: C_BITS_PER_CPNT*2] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*6 +: C_BITS_PER_CPNT*2] <= DATA_I_m[3] ;
            end
            3 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*3] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*3] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*6 +: C_BITS_PER_CPNT*3] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*9 +: C_BITS_PER_CPNT*3] <= DATA_I_m[3] ;
            end
            
            default : begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*1] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*1] <= DATA_I_m[3] ;
            end
        endcase
    end

end
else if(C_PORT_NUM==4  && C_MAX_CPNTS_PER_PIXEL==4  )begin

    always@(*)begin
        case(ACTUAL_CPNTS_PER_PIXEL_I)
            1 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*1] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*1] <= DATA_I_m[3] ;
            end
            2 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*2] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*2] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*4 +: C_BITS_PER_CPNT*2] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*6 +: C_BITS_PER_CPNT*2] <= DATA_I_m[3] ;
            end
            3 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*3] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*3] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*6 +: C_BITS_PER_CPNT*3] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*9 +: C_BITS_PER_CPNT*3] <= DATA_I_m[3] ;
            end
            4 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*4] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*4 +: C_BITS_PER_CPNT*4] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*8 +: C_BITS_PER_CPNT*4] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*12 +: C_BITS_PER_CPNT*4] <= DATA_I_m[3] ;
            end
            default : begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*1] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*1] <= DATA_I_m[3] ;
            end
        endcase
    end

end
else begin


    always@(*)begin
        case(ACTUAL_CPNTS_PER_PIXEL_I)
            1 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*1] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*1] <= DATA_I_m[3] ;
            end
            2 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*2] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*2] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*4 +: C_BITS_PER_CPNT*2] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*6 +: C_BITS_PER_CPNT*2] <= DATA_I_m[3] ;
            end
            3 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*3] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*3] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*6 +: C_BITS_PER_CPNT*3] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*9 +: C_BITS_PER_CPNT*3] <= DATA_I_m[3] ;
            end
            4 :begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*4] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*4 +: C_BITS_PER_CPNT*4] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*8 +: C_BITS_PER_CPNT*4] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*12 +: C_BITS_PER_CPNT*4] <= DATA_I_m[3] ;
            end
            default : begin
                DATA_O[C_BITS_PER_CPNT*0 +: C_BITS_PER_CPNT*1] <= DATA_I_m[0] ;
                DATA_O[C_BITS_PER_CPNT*1 +: C_BITS_PER_CPNT*1] <= DATA_I_m[1] ;
                DATA_O[C_BITS_PER_CPNT*2 +: C_BITS_PER_CPNT*1] <= DATA_I_m[2] ;
                DATA_O[C_BITS_PER_CPNT*3 +: C_BITS_PER_CPNT*1] <= DATA_I_m[3] ;
            end
        endcase
    end



end

endgenerate



  
endmodule



