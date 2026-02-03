`timescale 1ns / 1ps
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/02 18:22:55
// Design Name: 
// Module Name: byte_align
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////
//  

module byte_align(
input                      CLK_I       ,
input                      RST_I       ,
input  [C_DATA_WIDTH-1:0]  DATA_I      ,
input                      BIT_SLIP_I  ,  // 循环  d0c0b0a0   -> c0b0a0 d1 
input  [C_DATA_WIDTH-1:0]  COMP_VAL_I  ,  //
input                      COMP_TRIG_I ,  // 
output                     COMP_DONE_O,  // ___|————————
output  [C_DATA_WIDTH-1:0] DATA_O         


);
    
parameter  C_DATA_WIDTH = 8 ;  // 4 or 8 ,default 4
parameter  C_FUNCTION   = "COMP" ;// "COMP" , "SLIP"  
parameter  C_COMP_THRESHOLD = 100; //连续多少个周期比较结果一致，则认为一致


genvar i,j,k;
reg [7:0] ii;

reg [C_DATA_WIDTH-1:0] FF_s1 = 0;
reg [C_DATA_WIDTH-1:0] FF_s2 = 0;
reg [C_DATA_WIDTH-1:0] FF_s3 [C_DATA_WIDTH-1:0];

initial begin
    for(ii=0; ii<=(C_DATA_WIDTH-1) ; ii=ii+1)begin
        FF_s3[ii] <= 0;
    end
end

reg [7:0] cnt = 0;
wire [C_DATA_WIDTH-1:0] comp_result_immi ;
(*keep="true"*)reg  [C_DATA_WIDTH-1:0] comp_result = 0 ;
wire COMP_TRIG_I_pos ;
reg COMP_DONE_R  = 0;
reg [7:0] cnt_cpmp_result_immi[C_DATA_WIDTH-1:0] ;

initial begin
    for(ii=0;ii<=(C_DATA_WIDTH-1);ii=ii+1)begin
        cnt_cpmp_result_immi[ii] <= 0;
    end
end

`POS_MONITOR_OUTGEN(CLK_I,0,COMP_TRIG_I,COMP_TRIG_I_pos)



always@(posedge CLK_I)begin
    if(RST_I)FF_s1 <= 0;
    else FF_s1 <= DATA_I;
end    
 
always@(posedge CLK_I)begin
    if(RST_I)FF_s2 <= 0;
    else FF_s2 <= FF_s1;
end


generate if(C_DATA_WIDTH==4)begin

    always@(posedge CLK_I)begin
        if(RST_I)FF_s3[0] <= 0;
        else FF_s3[0] <= {FF_s2[3],FF_s2[2],FF_s2[1],FF_s2[0]};
    end

    always@(posedge CLK_I)begin
        if(RST_I)FF_s3[1] <= 0;
        else FF_s3[1] <= {FF_s2[2],FF_s2[1],FF_s2[0],FF_s1[3]};
    end

    always@(posedge CLK_I)begin
        if(RST_I)FF_s3[2] <= 0;
        else FF_s3[2] <= {FF_s2[1],FF_s2[0],FF_s2[3],FF_s1[2]};
    end

    always@(posedge CLK_I)begin
        if(RST_I)FF_s3[3] <= 0;
        else FF_s3[3] <= {FF_s2[0],FF_s2[3],FF_s2[2],FF_s1[1]};
    end




    always@(posedge CLK_I)begin
        if(RST_I)begin
            cnt <= 0;
        end
        else begin
            cnt <= BIT_SLIP_I ? cnt == 3 ? 0 : cnt + 1 : cnt ;
        end
    end


    if(C_FUNCTION=="SLIP")begin // C_FUNCTION  = "SLIP"
        assign  DATA_O = cnt==0 ? FF_s3[0] :
                         cnt==1 ? FF_s3[1] :
                         cnt==2 ? FF_s3[2] :
                         cnt==3 ? FF_s3[3] :  FF_s3[0] ;
    end      
    else begin// C_FUNCTION = "COMP"    
        for(i=0 ; i<=(C_DATA_WIDTH-1) ; i=i+1  )begin
   
            assign comp_result_immi[i] = FF_s3[i] == COMP_VAL_I ;

            always@(posedge CLK_I)begin
                if(RST_I | COMP_TRIG_I_pos  )begin
                    cnt_cpmp_result_immi[i] <= 0;
                end
                else begin
                    cnt_cpmp_result_immi[i] <=  comp_result_immi[i] ==0 ? 0 : ( comp_result_immi[i] ? cnt_cpmp_result_immi[i] + 1 :  cnt_cpmp_result_immi[i] );
                end
            end
        
            always@(posedge CLK_I)begin
                if(RST_I | COMP_TRIG_I_pos)begin 
                    comp_result[i] <= 0;
                end
                else begin
                    comp_result[i] <= comp_result[i] ? 1 : cnt_cpmp_result_immi[i]== C_COMP_THRESHOLD;
                end
            end
        end
    
        assign  DATA_O = comp_result[0] ? FF_s3[0] :
                         comp_result[1] ? FF_s3[1] :
                         comp_result[2] ? FF_s3[2] :
                         comp_result[3] ? FF_s3[3] :  FF_s3[0] ;
    end                     
end
else begin 


    always@(posedge CLK_I)begin
        if(RST_I)FF_s3[0] <= 0;
        else FF_s3[0] <= {FF_s2[7],FF_s2[6],FF_s2[5],FF_s2[4],FF_s2[3],FF_s2[2],FF_s2[1],FF_s2[0]};
    end

    always@(posedge CLK_I)begin
        if(RST_I)FF_s3[1] <= 0;
        else FF_s3[1] <= {FF_s2[6],FF_s2[5],FF_s2[4],FF_s2[3],FF_s2[2],FF_s2[1],FF_s2[0],FF_s1[7]};
    end

    always@(posedge CLK_I)begin
        if(RST_I)FF_s3[2] <= 0;
        else FF_s3[2] <= {FF_s2[5],FF_s2[4],FF_s2[3],FF_s2[2],FF_s2[1],FF_s2[0],FF_s1[7],FF_s1[6]};
    end

    always@(posedge CLK_I)begin
        if(RST_I)FF_s3[3] <= 0;
        else FF_s3[3] <= {FF_s2[4],FF_s2[3],FF_s2[2],FF_s2[1],FF_s2[0],FF_s1[7],FF_s1[6],FF_s1[5]};
    end

    always@(posedge CLK_I)begin
        if(RST_I)FF_s3[4] <= 0;
        else FF_s3[4] <= {FF_s2[3],FF_s2[2],FF_s2[1],FF_s2[0],FF_s1[7],FF_s1[6],FF_s1[5],FF_s1[4]};
    end

    always@(posedge CLK_I)begin
        if(RST_I)FF_s3[5] <= 0;
        else FF_s3[5] <= {FF_s2[2],FF_s2[1],FF_s2[0],FF_s1[7],FF_s1[6],FF_s1[5],FF_s1[4],FF_s1[3]};
    end

    always@(posedge CLK_I)begin
        if(RST_I)FF_s3[6] <= 0;
        else FF_s3[6] <= {FF_s2[1],FF_s2[0],FF_s1[7],FF_s1[6],FF_s1[5],FF_s1[4],FF_s1[3],FF_s1[2]};
    end

    always@(posedge CLK_I)begin
        if(RST_I)FF_s3[7] <= 0;
        else FF_s3[7] <= {FF_s2[0],FF_s1[7],FF_s1[6],FF_s1[5],FF_s1[4],FF_s1[3],FF_s1[2],FF_s1[1]};
    end


    always@(posedge CLK_I)begin
        if(RST_I)begin
            cnt <= 0;
        end
        else begin
            cnt <= BIT_SLIP_I ? cnt == 7 ? 0 : cnt + 1 : cnt ;     
        end
    end


    if(C_FUNCTION=="SLIP")begin// C_FUNCTION  = "SLIP"
        assign  DATA_O = cnt==0 ? FF_s3[0] :
                     cnt==1 ? FF_s3[1] :
                     cnt==2 ? FF_s3[2] :
                     cnt==3 ? FF_s3[3] : 
                     cnt==4 ? FF_s3[4] : 
                     cnt==5 ? FF_s3[5] : 
                     cnt==6 ? FF_s3[6] : 
                     cnt==7 ? FF_s3[7] :  FF_s3[0] ;
    end       
    else begin // C_FUNCTION = "COMP" 
        for(i=0 ; i<=(C_DATA_WIDTH-1) ; i=i+1  )begin
        
            assign comp_result_immi[i] = FF_s3[i] == COMP_VAL_I ;
        
            always@(posedge CLK_I)begin
                if(RST_I | COMP_TRIG_I_pos | comp_result_immi[i] ==0 )begin
                    cnt_cpmp_result_immi[i] <= 0;
                end
                else begin
                    cnt_cpmp_result_immi[i] <=  comp_result_immi[i] ? cnt_cpmp_result_immi[i] + 1 :  cnt_cpmp_result_immi[i] ;
                end
            end
            
            always@(posedge CLK_I)begin
                if(RST_I | COMP_TRIG_I_pos)begin 
                    comp_result[i] <= 0;
                end
                else begin
                    comp_result[i] <= comp_result[i] ? 1 : cnt_cpmp_result_immi[i]== C_COMP_THRESHOLD;
                end
            end
        end
        
        assign  DATA_O = comp_result[0] ? FF_s3[0] :
                         comp_result[1] ? FF_s3[1] :
                         comp_result[2] ? FF_s3[2] :
                         comp_result[3] ? FF_s3[3] : 
                         comp_result[4] ? FF_s3[4] : 
                         comp_result[5] ? FF_s3[5] : 
                         comp_result[6] ? FF_s3[6] : 
                         comp_result[7] ? FF_s3[7] :  FF_s3[0] ;
       
    end                     

end
endgenerate
   



//
//assign  DATA_O = DATA_I ;



/////////////////////////////////////////////////// 8 ////////////////////////////////////////////////////////////////////////

//



always@(posedge CLK_I)begin
    if(RST_I | COMP_TRIG_I_pos)begin
        COMP_DONE_R <= 0;
    end
    else begin
        COMP_DONE_R <= COMP_DONE_R ? 1 : | comp_result ;
    end
end

assign  COMP_DONE_O = COMP_DONE_R & ~COMP_TRIG_I_pos  ;






endmodule
