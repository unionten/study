`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate

/*


key_debounce   
    #(.C_CLK_PRD_NS              (),
      .C_LOW_LEVEL_THRESHOLD_US  (),
      .C_HIGH_LEVEL_THRESHOLD_US (),
      .C_RST_KEY_OUT_VALUE       () )
    key_debounce_u(
     .CLK_I  (),
     .RSTN_I (),
     .EN_I () ,
     .KEY_I  (),
     .KEY_O  ()
    );

*/



module key_debounce(
    input   CLK_I    ,  
    input   EN_I     ,
    input   RSTN_I   ,      
    input   KEY_I    ,     // 原始按键输入
    output  KEY_O    // 消抖后
);


parameter C_CLK_PRD_NS              = 10 ;
parameter C_LOW_LEVEL_THRESHOLD_US  = 50 ; //>= 0; 0即只要为低，就立刻拉低(会延迟1周期)
parameter C_HIGH_LEVEL_THRESHOLD_US = 50 ;
parameter C_RST_KEY_OUT_VALUE       = 0  ;

localparam  C_LOW_LEVEL_THRESHOLD_CLK_NUM  = C_LOW_LEVEL_THRESHOLD_US*1000/C_CLK_PRD_NS;
localparam  C_HIGH_LEVEL_THRESHOLD_CLK_NUM = C_HIGH_LEVEL_THRESHOLD_US*1000/C_CLK_PRD_NS;

localparam  C_LEVEL_THRESHOLD_MAX_CLK_NUM  = C_LOW_LEVEL_THRESHOLD_CLK_NUM > C_HIGH_LEVEL_THRESHOLD_CLK_NUM 
                                               ? C_LOW_LEVEL_THRESHOLD_CLK_NUM : C_HIGH_LEVEL_THRESHOLD_CLK_NUM;


localparam CNY_BIT =  $clog2( C_LEVEL_THRESHOLD_MAX_CLK_NUM ) + 1;

reg KEY_O_r  = C_RST_KEY_OUT_VALUE ;

reg [CNY_BIT-1:0] count = 0;  
reg [7:0] state = 0;
wire KEY_I_pos ;
wire KEY_I_neg ;


`POS_MONITOR_OUTGEN(CLK_I,0,KEY_I,KEY_I_pos)  //原始结果
`NEG_MONITOR_OUTGEN(CLK_I,0,KEY_I,KEY_I_neg)  //原始结果



always @(posedge CLK_I  ) begin
    if (~RSTN_I) begin
        state    <= 0;
        count    <= 0;
        KEY_O_r    <= C_RST_KEY_OUT_VALUE ;
    end
    else if(KEY_I==0)begin //进入 low 检测状态   
        count   <= KEY_I_neg ? 0 : count==C_LOW_LEVEL_THRESHOLD_CLK_NUM ?  C_LOW_LEVEL_THRESHOLD_CLK_NUM  :  count + 1 ;
        KEY_O_r <= KEY_I_neg ? KEY_O_r :  count==C_LOW_LEVEL_THRESHOLD_CLK_NUM ? 0 :  KEY_O_r ;
    end
    else begin //进入 high 检测状态
        count   <= KEY_I_pos ? 0 : count==C_HIGH_LEVEL_THRESHOLD_CLK_NUM ?  C_HIGH_LEVEL_THRESHOLD_CLK_NUM  :  count + 1 ;
        KEY_O_r <= KEY_I_pos ? KEY_O_r : count==C_HIGH_LEVEL_THRESHOLD_CLK_NUM ? 1  :  KEY_O_r ;
    end
  
end

assign KEY_O  =  EN_I ? KEY_O_r : KEY_I ;

endmodule




