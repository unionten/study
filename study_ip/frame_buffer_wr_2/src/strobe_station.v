`timescale 1ns / 1ps
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)       generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define BI_TO_SINGLE_Nm1To0(a,b,in,out)       generate for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end endgenerate
`define POS_MONITOR(clk_in,rst_in,in,out)          generate  begin  reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR(clk_in,rst_in,in,out)          generate  begin  reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Create Date: 2023/06/19 09:48:23
// Design Name: 
// Module Name: strobe_station
//////////////////////////////////////////////////////////////////////////////////

/*
strobe_station_unify 
    #(.C_BYTE_NUM( 16 ))
    strobe_station_u(
    .RST_I       (  ),
    .CLK_I       (  ),
    .DATA_I      (  ),
    .DATA_EN_I   (  ),  //note： BYTE_NUM_I = 0, represents C_BYTE_NUM
    .BYTE_NUM_I  (  ),  //natual num ; for example  1  2  3  4(0) when C_BYTE_NUM is 4 
    .DATA_O      (  ),
    .DATA_EN_O   (  )
    );
*/

module strobe_station_unify(
input                           RST_I       ,
input                           CLK_I       ,
input  [C_BYTE_NUM*8-1:0]       DATA_I      ,
input                           DATA_EN_I   ,  //note： BYTE_NUM_I = 0, represents C_BYTE_NUM
input  [$clog2(C_BYTE_NUM):0] BYTE_NUM_I  ,  //natual num ; for example  1  2  3  4(0) when C_BYTE_NUM is 4    ($clog2(C_BYTE_NUM) dont minus 1 for mux num   )
output [C_BYTE_NUM*8-1:0]       DATA_O      ,
output                          DATA_EN_O   

);


//C_BYTE_NUM       LUT     FF
//     16          692     274
parameter  C_BYTE_NUM = 4 ;

genvar i,j,k;
reg flag  = 0;//切换操作




//输入端的两个data进行上下切换，
//外部输入端进行了上下data的互换，然后内部输入端也需要进行上下颠倒
//然后内部取数据永远取第一个data



wire [C_BYTE_NUM*8*2-1:0] dual_data;
assign dual_data = DATA_I<<(byte_id_start*8); //本轮

//reg [C_BYTE_NUM*8*2-1:0] dual_data;
//always@(* )begin
//    case(byte_id_start) 
//        
//    
//    
//    
//    endcase
//end
//

//in example of C_BYTE_NUM==4: byte_id_start is in cycle of  0  1  2  3  0  1  2  3 ......
reg [$clog2(C_BYTE_NUM)-1:0] byte_id_start = 0;//移位记号, 超过 C_BYTE_NUM 即循环, 之前移位单位
wire [$clog2(C_BYTE_NUM)-1:0] byte_id_start__p__BYTE_NUM_I;
assign byte_id_start__p__BYTE_NUM_I = byte_id_start + BYTE_NUM_I;

always@(posedge CLK_I)begin
    if(RST_I)begin  
        byte_id_start <= 0;flag  <= 0;
    end
    else begin  
        byte_id_start <= DATA_EN_I ? byte_id_start__p__BYTE_NUM_I : byte_id_start; //note:  2bit + 3bit will result 3bit
        flag          <= DATA_EN_I & (byte_id_start__p__BYTE_NUM_I <= byte_id_start) ? ~flag : flag;
    end
end

wire flag_pos;
wire flag_neg;
`POS_MONITOR(CLK_I,RST_I,flag,flag_pos)
`NEG_MONITOR(CLK_I,RST_I,flag,flag_neg)

wire [C_BYTE_NUM*1*2-1:0] data_en_valid_ori;
wire [C_BYTE_NUM*1*2-1:0] data_en_valid;
assign data_en_valid_ori =   (  1'b1<<( BYTE_NUM_I )  )  -  1 ;
assign  data_en_valid = data_en_valid_ori <<< (byte_id_start*1);


wire [C_BYTE_NUM*8-1:0] data0;
wire [C_BYTE_NUM*8-1:0] data1;
data_mux   
    #(.C_BYTE_NUM(C_BYTE_NUM))
    data_mux_u(
    .CLK_I       (CLK_I                  ), // 
    .DUAL_DATA_I (dual_data              ), // double width data
    .DUAL_EN_I   (data_en_valid          ), // double width en
    .FLAG_I      (flag                   ), // select  "assign  {data1,data0} = dual_data"; or  "assign  {data0,data1} = dual_data";
    .DATA_0_O    (data0                  ), // single width data
    .DATA_1_O    (data1                  )  // single width data

    );


reg flag1 = 0;
always@(posedge CLK_I)flag1 <= flag ;

assign DATA_O = flag1==0 ?  data0 :  data1;
assign DATA_EN_O = flag_pos | flag_neg;


endmodule





//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/19 13:28:00
// Design Name: 
// Module Name: inner
//////////////////////////////////////////////////////////////////////////////////

/*
data_mux   
    #(.C_BYTE_NUM(4))
    data_mux_u(
    .CLK_I       (clk     ),
    .DUAL_DATA_I (data    ), // 两个data
    .DUAL_EN_I   (en      ), // 两个en
    .FLAG_I      (flag    ),
    .DATA_0_O    (data0   ),
    .DATA_1_O    (data1   ) 

    );
*/



module data_mux(
input                          CLK_I       ,
input [8*C_BYTE_NUM*2-1:0]     DUAL_DATA_I , // 两个data
input [1*C_BYTE_NUM*2-1:0]     DUAL_EN_I   , // 两个en
input                          FLAG_I      ,
output reg  [C_BYTE_NUM*8-1:0] DATA_0_O =0 ,
output reg  [C_BYTE_NUM*8-1:0] DATA_1_O =0    

    );
parameter C_BYTE_NUM = 32;

genvar i,j,k;
generate for(i=0;i<=C_BYTE_NUM-1;i=i+1)begin
    always@(posedge CLK_I) begin 
        if(FLAG_I==0)begin
            DATA_0_O[8*(i+1)-1:8*(i)] <= DUAL_EN_I[i]            ? DUAL_DATA_I[8*(i+1)-1:8*(i)]                           : DATA_0_O[8*(i+1)-1:8*(i)];
            DATA_1_O[8*(i+1)-1:8*(i)] <= DUAL_EN_I[C_BYTE_NUM+i] ? DUAL_DATA_I[C_BYTE_NUM*8+8*(i+1)-1:C_BYTE_NUM*8+8*(i)] : DATA_1_O[8*(i+1)-1:8*(i)];
        end
        else begin
            DATA_1_O[8*(i+1)-1:8*(i)] <= DUAL_EN_I[i]            ? DUAL_DATA_I[8*(i+1)-1:8*(i)]                           : DATA_1_O[8*(i+1)-1:8*(i)];
            DATA_0_O[8*(i+1)-1:8*(i)] <= DUAL_EN_I[C_BYTE_NUM+i] ? DUAL_DATA_I[C_BYTE_NUM*8+8*(i+1)-1:C_BYTE_NUM*8+8*(i)] : DATA_0_O[8*(i+1)-1:8*(i)];
        end
    end
end
endgenerate

endmodule



