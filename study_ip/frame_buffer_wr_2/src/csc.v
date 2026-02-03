`timescale 1ns / 1ps
`define  DELAY(clk_in,rst_in,data_in,data_out,C_WIDTH,C_DLY)            generate if(C_DLY==0)begin  assign data_out = data_in; end  else if(C_DLY==1)begin  reg [C_WIDTH-1:0] a_temp = 0; always@(posedge clk_in) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [C_WIDTH-1:0] a_temp [C_DLY-1:0] ;always@(posedge clk_in) begin  if(rst_in)a_temp[C_DLY-1] <= 0; else   a_temp[C_DLY-1] <= data_in; end  for(i=0;i<=C_DLY-2;i=i+1)begin  always@(posedge clk_in)begin  if(rst_in)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate
`define  DELAY_InGen(clk_in,rst_in,data_in,data_out,C_WIDTH,C_DLY)      if(C_DLY==0)begin  assign data_out = data_in; end  else if(C_DLY==1)begin  reg [C_WIDTH-1:0] a_temp = 0; always@(posedge clk_in) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [C_WIDTH-1:0] a_temp [C_DLY-1:0] ;always@(posedge clk_in) begin  if(rst_in)a_temp[C_DLY-1] <= 0; else   a_temp[C_DLY-1] <= data_in; end  for(i=0;i<=C_DLY-2;i=i+1)begin  always@(posedge clk_in)begin  if(rst_in)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  
`define  POS_MONITOR(clk_in,rst_in,in,out)                              generate  begin  reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)                                 generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define BI_TO_SINGLE_Nm1To0(a,b,in,out)                                 generate for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end endgenerate


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  yzhu
// Create Date: 2023/06/20 10:02:11
// Design Name:  
// Module Name: csc
//////////////////////////////////////////////////////////////////////////////////

/*
csc  
    #(.C_PORT_NUM(),
      .C_BPC     (),
      .C_DLY_SRL () )  // must >= 3
    csc_u  (
    .CLK_I        (),
    .RST_I        (),
    .OSPACE_I     (), //output color space :  0:RGB , 1:YUV444 , 2:YUV422 , 3:YUV420 
    .VS_I         (),
    .HS_I         (),
    .DE_I         (),
    .R_I          (),
    .G_I          (),
    .B_I          (),    
    .PIXEL_VS_O   (), //simulate vs hs de
    .PIXEL_HS_O   (),
    .PIXEL_DE_O   (), 
    .PIXEL_DATA_O ()  //{BGR}{BGR}{BGR}{BGR} ; {VUY}{VUY}{VUY}{VUY} ;   {0VY}{0UY}{0VY}{0UY} ; {VYY}{UYY}{VYY}{UYY}                            
                                                                     or {0YV}{0YU}{0YV}{0YU} 
                                                                        可能需要根据DP SRC 的逻辑调整以上各字节的顺序
                                                                       
);


*/


module csc(
input                            CLK_I        ,
input                            RST_I        ,
input  [3:0]                     OSPACE_I     , //output color space :  0:RGB , 1:YUV444 , 2:YUV422 , 3:YUV420 
input                            VS_I         ,
input                            HS_I         ,
input                            DE_I         ,
input  [C_BPC*C_PORT_NUM-1:0]    R_I          ,
input  [C_BPC*C_PORT_NUM-1:0]    G_I          ,
input  [C_BPC*C_PORT_NUM-1:0]    B_I          ,    
output                           PIXEL_VS_O   , //simulate vs hs de
output                           PIXEL_HS_O   ,
output                           PIXEL_DE_O   , 
output [C_BPC*3*C_PORT_NUM-1:0]  PIXEL_DATA_O , //exp: {BGR}{BGR}{BGR}{BGR} ; {VUY}{VUY}{VUY}{VUY} ; {0UY}{0UY}{0UY}{0UY} ; {VYY}{UYY}{VYY}{UYY}                            
input  [3:0]                     ACTUAL_PORT_NUM_I 
);
parameter C_PORT_NUM = 4;
parameter C_BPC      = 8;
parameter [0:0] C_RGB2YUV_EN = 1;
parameter [0:0] C_FIFO_EN = 1 ;
parameter C_DLY_SRL  = 3; // must >= 3

//////////////////////////////////////////////////////////////////////////////////
genvar i,j,k;

wire  vs_sDm1;
wire  hs_sDm1;
wire  de_sDm1;

wire  vs_sD;
wire  hs_sD;
wire  de_sD;

wire  VS_I_pos;
wire  DE_I_pos;
reg   yuv420_valid = 1;

wire  de_sDm1_420rd;
assign de_sDm1_420rd = yuv420_valid & de_sDm1;



`DELAY(CLK_I,RST_I,VS_I,vs_sDm1,1,C_DLY_SRL-1)
`DELAY(CLK_I,RST_I,HS_I,hs_sDm1,1,C_DLY_SRL-1)
`DELAY(CLK_I,RST_I,DE_I,de_sDm1,1,C_DLY_SRL-1)

`DELAY(CLK_I,RST_I,vs_sDm1,vs_sD,1,1)
`DELAY(CLK_I,RST_I,hs_sDm1,hs_sD,1,1)
`DELAY(CLK_I,RST_I,de_sDm1,de_sD,1,1)


`BI_TO_SINGLE_Nm1To0((C_BPC*3),C_PORT_NUM,PIXEL_sD,PIXEL_DATA_O) 
assign PIXEL_VS_O = vs_sD;
assign PIXEL_HS_O = hs_sD;
//数据一直都有，420模式使用屏蔽de方式来输出
assign PIXEL_DE_O = ( OSPACE_I==3 & yuv420_valid ) | ( OSPACE_I!=3 ) ? de_sD : 0 ;

`POS_MONITOR(CLK_I,RST_I,VS_I,VS_I_pos)
`POS_MONITOR(CLK_I,RST_I,DE_I,DE_I_pos)
    
   
//vs_sDm1
//hs_sDm1   
//de_sDm1   

wire hs_sDm1_pos;
`POS_MONITOR(CLK_I,0,hs_sDm1,hs_sDm1_pos)


reg one_port_flag = 0; 
always@(posedge CLK_I)begin
    if(RST_I | hs_sDm1_pos)begin
        one_port_flag <= 0;
    end
    else begin
        one_port_flag <= de_sDm1 ? ~one_port_flag : one_port_flag ;
 
    end
end


    
always@(posedge CLK_I)begin
    if(RST_I | VS_I_pos)begin
        yuv420_valid <= 1;
    end
    else begin
        yuv420_valid <= DE_I_pos ? ~yuv420_valid : yuv420_valid;
    end
end


wire [C_BPC-1:0] Y_sDm1 [C_PORT_NUM-1:0] ;
wire [C_BPC-1:0] U_sDm1 [C_PORT_NUM-1:0] ;
wire [C_BPC-1:0] V_sDm1 [C_PORT_NUM-1:0] ;

wire [C_BPC*C_PORT_NUM-1:0] Y_sDm1_s;
wire [C_BPC*C_PORT_NUM-1:0] U_sDm1_s;
wire [C_BPC*C_PORT_NUM-1:0] V_sDm1_s;
wire [C_BPC*C_PORT_NUM-1:0] Y_sDm1_s_d1;
wire [C_BPC*C_PORT_NUM-1:0] U_sDm1_s_d1;
wire [C_BPC*C_PORT_NUM-1:0] V_sDm1_s_d1;
wire [C_BPC-1:0] Y_sDm1_d1 [C_PORT_NUM-1:0] ; //port num为1时，打拍
wire [C_BPC-1:0] U_sDm1_d1 [C_PORT_NUM-1:0] ;
wire [C_BPC-1:0] V_sDm1_d1 [C_PORT_NUM-1:0] ;

wire [C_BPC*C_PORT_NUM-1:0] Y_sDm1_last_s;
wire [C_BPC*C_PORT_NUM-1:0] U_sDm1_last_s;
wire [C_BPC*C_PORT_NUM-1:0] V_sDm1_last_s;
wire [C_BPC-1:0] Y_sDm1_last [C_PORT_NUM-1:0] ; //上一行的值
wire [C_BPC-1:0] U_sDm1_last [C_PORT_NUM-1:0] ;
wire [C_BPC-1:0] V_sDm1_last [C_PORT_NUM-1:0] ;


`BI_TO_SINGLE_Nm1To0(C_BPC,C_PORT_NUM,Y_sDm1,Y_sDm1_s)
`BI_TO_SINGLE_Nm1To0(C_BPC,C_PORT_NUM,U_sDm1,U_sDm1_s)
`BI_TO_SINGLE_Nm1To0(C_BPC,C_PORT_NUM,V_sDm1,V_sDm1_s)

`DELAY(CLK_I,RST_I,Y_sDm1_s,Y_sDm1_s_d1,(C_BPC*C_PORT_NUM),1)
`DELAY(CLK_I,RST_I,U_sDm1_s,U_sDm1_s_d1,(C_BPC*C_PORT_NUM),1)
`DELAY(CLK_I,RST_I,V_sDm1_s,V_sDm1_s_d1,(C_BPC*C_PORT_NUM),1)


`SINGLE_TO_BI_Nm1To0(C_BPC,C_PORT_NUM,Y_sDm1_s_d1,Y_sDm1_d1) 
`SINGLE_TO_BI_Nm1To0(C_BPC,C_PORT_NUM,U_sDm1_s_d1,U_sDm1_d1) 
`SINGLE_TO_BI_Nm1To0(C_BPC,C_PORT_NUM,V_sDm1_s_d1,V_sDm1_d1) 

`SINGLE_TO_BI_Nm1To0(C_BPC,C_PORT_NUM,Y_sDm1_last_s,Y_sDm1_last) 
`SINGLE_TO_BI_Nm1To0(C_BPC,C_PORT_NUM,U_sDm1_last_s,U_sDm1_last) 
`SINGLE_TO_BI_Nm1To0(C_BPC,C_PORT_NUM,V_sDm1_last_s,V_sDm1_last) 


wire [C_BPC-1:0] R_sDm1 [C_PORT_NUM-1:0] ;
wire [C_BPC-1:0] G_sDm1 [C_PORT_NUM-1:0] ;
wire [C_BPC-1:0] B_sDm1 [C_PORT_NUM-1:0] ;


reg  [C_BPC*3-1:0] PIXEL_sD [C_PORT_NUM-1:0] ;



reg  [7:0] ii = 0;


generate for(j=0;j<=C_PORT_NUM-1;j=j+1)begin : rgb2yuv_block

`DELAY_InGen(CLK_I,RST_I,R_I[(j+1)*C_BPC-1:(j)*C_BPC],R_sDm1[j],C_BPC,(C_DLY_SRL-1))  //note: i has been used by `DELAY_InGen
`DELAY_InGen(CLK_I,RST_I,G_I[(j+1)*C_BPC-1:(j)*C_BPC],G_sDm1[j],C_BPC,(C_DLY_SRL-1))
`DELAY_InGen(CLK_I,RST_I,B_I[(j+1)*C_BPC-1:(j)*C_BPC],B_sDm1[j],C_BPC,(C_DLY_SRL-1))

rgb2yuv 
    #(.C_BPC (C_BPC),
      .C_DLY (C_DLY_SRL-1)) //must >= 2
    rgb2yuv_u(
    .RST_I (RST_I  ),
    .CLK_I (CLK_I ),       
    .R_I   (R_I[(j+1)*C_BPC-1:(j)*C_BPC]),
    .G_I   (G_I[(j+1)*C_BPC-1:(j)*C_BPC]),
    .B_I   (B_I[(j+1)*C_BPC-1:(j)*C_BPC]),
    .Y_O   (Y_sDm1[j]),
    .U_O   (U_sDm1[j]),
    .V_O   (V_sDm1[j])
    );


end
endgenerate

//奇数行
//-> yuv0 ->  yuv4 -> 
//-> yuv1 ->  yuv5 -> 
//-> yuv2 ->  yuv6 -> 
//-> yuv3 ->  yuv7 -> 

//偶数行
//-> yuv0 ->  yuv4 -> 
//-> yuv1 ->  yuv5 -> 
//-> yuv2 ->  yuv6 -> 
//-> yuv3 ->  yuv7 -> 

//奇偶合并
//-> yyu ->   yyu -> 
//-> yyv ->   yyv -> 
//-> yyu ->   yyu -> 
//-> yyv ->   yyv -> 
 

//YUV420 FIFO

wire fifo420_wr;
wire [C_BPC*C_PORT_NUM*3-1:0] fifo420_wr_data;
assign fifo420_wr = ~yuv420_valid & de_sDm1 ;
assign fifo420_wr_data = {V_sDm1_s,U_sDm1_s,Y_sDm1_s};

wire fifo420_rd;
wire [C_BPC*C_PORT_NUM*3-1:0] fifo420_rd_data;
assign fifo420_rd = yuv420_valid & de_sDm1;
assign fifo420_rd_data = {V_sDm1_last_s,U_sDm1_last_s,Y_sDm1_last_s};


generate if(C_FIFO_EN==1)begin :csc_fifo
fifo_async_xpm  
    #(.C_WR_WIDTH             (C_BPC*3*C_PORT_NUM),// ratio must be 1:1, 1:2, 1:4, 1:8,
      .C_WR_DEPTH             (4096),// must>=16 ; actual depth = C_WR_DEPTH - 1;  must be power of 2
      .C_RD_WIDTH             (C_BPC*3*C_PORT_NUM),
      .C_WR_COUNT_WIDTH       (16),
      .C_RD_COUNT_WIDTH       (16),
      //.C_RD_PROG_EMPTY_THRESH (),
      //.C_WR_PROG_FULL_THRESH  (),
      .C_RD_MODE              ("fwft" ) //"std" "fwft"  
     )
    fifo_async_xpm_u(
    .WR_RST_I         (RST_I | VS_I_pos), // clear the FIFO
    .WR_CLK_I         (CLK_I ),
    .WR_EN_I          (fifo420_wr),
    .WR_DATA_I        (fifo420_wr_data),
    .WR_FULL_O        (),
    .WR_DATA_COUNT_O  (),
    .WR_PROG_FULL_O   (),
    .WR_RST_BUSY_O    (),

    .RD_RST_I         (RST_I | VS_I_pos), 
    .RD_CLK_I         (CLK_I ),
    .RD_EN_I          (fifo420_rd ),
    .RD_DATA_O        ({V_sDm1_last_s,U_sDm1_last_s,Y_sDm1_last_s}),
    .RD_EMPTY_O       (),
    .RD_DATA_COUNT_O  (),
    .RD_PROG_EMPTY_O  (),
    .RD_RST_BUSY_O    ()
    
    );
end
endgenerate



//re concat
always@(posedge CLK_I)begin
    if(RST_I )begin
        for(ii=0;ii<=C_PORT_NUM-1;ii=ii+1)begin // note: acts as parrllel behaviour ; sim  is right
            PIXEL_sD[ii] <= 0; 
        end        
    end
    else case(OSPACE_I)
        0:begin//RGB888拼接方式
            for(ii=0;ii<=C_PORT_NUM-1;ii=ii+1)begin
               PIXEL_sD[ii] <=  {B_sDm1[ii],G_sDm1[ii],R_sDm1[ii]};
            end
        end
        1:begin//YUV888拼接方式
            for(ii=0;ii<=C_PORT_NUM-1;ii=ii+1)begin
               PIXEL_sD[ii] <=  {V_sDm1[ii],U_sDm1[ii],Y_sDm1[ii]};
            end
        end
        2:begin//YUV422拼接方式
            for(ii=0;ii<=C_PORT_NUM-1;ii=ii+1)begin
               if(ii[0]==1'b0)PIXEL_sD[ii] <= ACTUAL_PORT_NUM_I!=1 ?  ({0,U_sDm1[ii]  ,Y_sDm1[ii]} ) :  (one_port_flag==0 ?  ({0,U_sDm1[ii]  ,Y_sDm1[ii]}) :  ({0,V_sDm1_d1[ii]  ,Y_sDm1[ii]} )  )  ; 
               else           PIXEL_sD[ii] <= ACTUAL_PORT_NUM_I!=1 ?  ({0,V_sDm1[ii-1],Y_sDm1[ii]} ) :  (one_port_flag==0 ?  ({0,U_sDm1[ii]  ,Y_sDm1[ii]}) :  ({0,V_sDm1_d1[ii]  ,Y_sDm1[ii]} )  )  ;
            end
        end
       //3:begin
       //    for(ii=0;ii<=C_PORT_NUM-1;ii=ii+1)begin//PIXEL_sD 是始终有值的，外部是使用de去屏蔽的
       //        if(ii[0]==1'b0)PIXEL_sD[ii] <=  {U_sDm1_last[ii],Y_sDm1[ii],Y_sDm1_last[ii]}  ; //note: need used with PIXEL_DE_O
       //        else           PIXEL_sD[ii] <=  {V_sDm1[ii]     ,Y_sDm1[ii],Y_sDm1_last[ii]}  ;
       //    end
       //end
        default:begin
            for(ii=0;ii<=C_PORT_NUM-1;ii=ii+1)begin
               if(ii[0]==1'b0)PIXEL_sD[ii] <= ACTUAL_PORT_NUM_I!=1 ?  ({0,U_sDm1[ii]  ,Y_sDm1[ii]} ) :  (one_port_flag==0 ?  ({0,U_sDm1[ii]  ,Y_sDm1[ii]}) :  ({0,V_sDm1_d1[ii]  ,Y_sDm1[ii]} )  )  ; 
               else           PIXEL_sD[ii] <= ACTUAL_PORT_NUM_I!=1 ?  ({0,V_sDm1[ii-1],Y_sDm1[ii]} ) :  (one_port_flag==0 ?  ({0,U_sDm1[ii]  ,Y_sDm1[ii]}) :  ({0,V_sDm1_d1[ii]  ,Y_sDm1[ii]} )  )  ;
            end
        end
    endcase
end



 
    
endmodule



