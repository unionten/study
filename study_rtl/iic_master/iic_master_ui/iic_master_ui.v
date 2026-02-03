`timescale 1ns / 1ps
`define CLK_DIV_OUTGEN(clk,rst,clk_out,DIV)                                                             generate begin  reg clk_div_name = 0;reg [15:0] cnt_name = 0;always@(posedge clk)begin if(rst)begin clk_div_name <= 0;cnt_name <= 0;end else begin if(cnt_name<(DIV/2))begin cnt_name <= cnt_name + 1;clk_div_name <= 0;end else if(cnt_name<DIV-1) begin cnt_name <= cnt_name + 1;clk_div_name <= 1;end  else begin cnt_name <= 0;clk_div_name <= 1;end  end  end  assign clk_out = clk_div_name; end endgenerate
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate
`define CDC_MULTI_BIT_SIGNAL_OUTGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH)                            generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(4),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH)                            generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(4),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_SINGLE_BIT_PULSE_OUTGEN(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM)                       generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate

`define IN     1'b1
`define OUT    1'b0
`define ACK    1'b0
`define NAK    1'b1

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu 重写版
// 
// Create Date: 2023/08/09 09:41:58
// Design Name: 
// Module Name: iic_master_ui
//////////////////////////////////////////////////////////////////////////////////
/*
iic_master_ui 
    #(.WR_MAX_LEN (5  ),
      .RD_MAX_LEN (5  ),
      .CLK_DIV    (100)) 
    iic_master_ui_u(
    .SYS_CLK_I     (clk    ),
    .SYS_RST_I     (rst    ),
    .SDA_I         (0      ),
    .SDA_O         (SDA_O  ),
    .SDA_T         (SDA_T  ),
    .SCL_I         (0      ),
    .SCL_O         (SCL_O  ),
    .SCL_T         (SCL_T  ),
    .WR_BYTE_NUM_I (wr_num ),
    .WR_DATA_I     (       ),
    .RD_BYTE_NUM_I (rd_num ),
    .RD_DATA_O     (       ),
    .START_I       (start  ), 
    .BUSY_O        (busy   ),
    .FINISH_O      (finish ),
    .ERROR_O       (error  )    
    
    );
*/
  
module iic_master_ui
#( parameter  WR_MAX_LEN = 10 ,
  parameter RD_MAX_LEN = 10 ,
  parameter CLK_DIV    = 1000  
  )
(
input  SYS_CLK_I ,
input  SYS_RST_I ,
input  SDA_I,
output reg SDA_O = 1,
output reg SDA_T = `OUT,
input  SCL_I,//no use
output SCL_O,//scl always exists
output reg SCL_T = `OUT,//always out
input  [$clog2(WR_MAX_LEN):0] WR_BYTE_NUM_I , //>=0, first 
input  [WR_MAX_LEN*8-1:0]     WR_DATA_I     ,
input  [$clog2(RD_MAX_LEN):0] RD_BYTE_NUM_I , //>=0, second ; if both are 0, op will take no effect
output reg [RD_MAX_LEN*8-1:0] RD_DATA_O  = 0,
input                         START_I       , //check pulse inside
output                        BUSY_O        , //start_pos | Busy ; if wr_num and  rd_num are both zero, there is alse busy generate
output  reg                   FINISH_O =0   , //whether success or not, finish always generates
output  reg                   ERROR_O = 0     //when no ack, error generates     

    );


////////////////////////////////////////////////////////////////////////

localparam BIT_NUM = 8; 

////////////////////////////////////////////////////////////////////////
wire iic_scl;
wire iic_scl_m2;
wire iic_scl_m2_pos;
wire iic_scl_m2_neg;
wire START_I_pos;
wire scl_high_mid;
wire scl_low_mid;

reg [$clog2(WR_MAX_LEN):0] WR_BYTE_NUM_left ; //>=0, first 
reg [WR_MAX_LEN*8-1:0]     WR_DATA_reg     ;
reg [$clog2(RD_MAX_LEN):0] RD_BYTE_NUM_left ; //>=0, second
reg [7:0] state = 0;
reg Busy = 0;
reg [7:0] cnt = 0 ;

reg [7:0] WR_DATA_byte;

reg [RD_MAX_LEN*8-1:0] RD_DATA_O_buf ;

reg open_iic_clk = 0;
////////////////////////////////////////////////////////////////////////
`CLK_DIV_OUTGEN(SYS_CLK_I,SYS_RST_I,iic_scl,CLK_DIV)
`CLK_DIV_OUTGEN(SYS_CLK_I,SYS_RST_I,iic_scl_m2,(CLK_DIV/2)) //fast 
`POS_MONITOR_OUTGEN(SYS_CLK_I,0,iic_scl_m2,iic_scl_m2_pos)
`NEG_MONITOR_OUTGEN(SYS_CLK_I,0,iic_scl_m2,iic_scl_m2_neg)
`POS_MONITOR_OUTGEN(SYS_CLK_I,0,START_I,START_I_pos)

assign SCL_O = open_iic_clk ? iic_scl : 1 ;//2024年12月11日09:37:04

assign BUSY_O = Busy | START_I_pos ;

assign scl_high_mid = iic_scl & iic_scl_m2_pos;
assign scl_low_mid  = ~iic_scl & iic_scl_m2_pos;

always@(posedge SYS_CLK_I)begin
    if(SYS_RST_I)begin
        state <= 0;
        WR_BYTE_NUM_left <= 0;
        WR_DATA_reg <= 0;
        RD_BYTE_NUM_left <= 0;
        Busy <= 0;
        SDA_O <= 1;
        SDA_T <= `OUT;
        ERROR_O <= 0;
        FINISH_O <= 0;
        cnt <= 0;
        RD_DATA_O <= 0;
        RD_DATA_O_buf <= 0;
        open_iic_clk <= 0;
    end 
    else begin
        case(state)
            0:begin
                ERROR_O  <= 0;
                FINISH_O <= 0;
                if(START_I_pos)begin
                    WR_BYTE_NUM_left <= WR_BYTE_NUM_I ;
                    WR_DATA_reg      <= WR_DATA_I     ;
                    RD_BYTE_NUM_left <= RD_BYTE_NUM_I ;
                    state <= 1;
                    Busy  <= 1;
                    SDA_T <= `OUT ;
                end
            end
            1:begin
                if(scl_high_mid)begin
                    SDA_O <= 0;
                    state        <= WR_BYTE_NUM_left>0 ? 2 : RD_BYTE_NUM_left>0 ? 4: 10;
                    open_iic_clk <= WR_BYTE_NUM_left>0 ? 1 : 0 ;//
                    
                    WR_DATA_byte <= WR_DATA_reg[7:0];
                    WR_DATA_reg  <= WR_DATA_reg>>8  ;
                    cnt <= BIT_NUM;//8 check
                end
            end
            2:begin //wr process
                ERROR_O <= 0;
                if(scl_low_mid)begin
                    SDA_T <= `OUT ;
                    SDA_O <= WR_DATA_byte[7] ;
                    WR_DATA_byte <= {WR_DATA_byte[6:0],1'b0};
                    cnt   <= cnt==0 ? BIT_NUM : cnt - 1 ; //8 check
                    state <= cnt==0 ? 3 : state ;
                    WR_BYTE_NUM_left <= cnt==0 ? WR_BYTE_NUM_left - 1 : WR_BYTE_NUM_left;
                end
            end
            3:begin //wr process ack
                SDA_T <= `IN ;
                if(scl_high_mid)begin  
                    if(WR_BYTE_NUM_left>0)begin  //改为：无论是否有ack，都继续完成操作
                        state <= 2 ;
                        WR_DATA_byte <= WR_DATA_reg[7:0]; 
                        WR_DATA_reg  <= WR_DATA_reg>>8;
                    end
                    else begin
                        state <= RD_BYTE_NUM_left>0 ? 4 : 10;
                    end
                    
                    if(SDA_I==`ACK)begin//ACK   
                        ERROR_O  <= 0;
                    end
                    else begin
                        ERROR_O  <= 1;
                        //state    <= 10; //STOP
                    end
                end
                else begin
                    ERROR_O <= 0;
                end
            end
            4:begin//rd process 1 , special operation
                ERROR_O <= 0;
                if(scl_low_mid)begin
                    SDA_T <= `IN ;
                    state <= 5;
                end
            end
            5:begin//rd process 2
                if(scl_high_mid)begin
                    RD_DATA_O_buf <= {RD_DATA_O_buf[RD_MAX_LEN*8-2:0],SDA_I};
                    cnt <= cnt==1 ? BIT_NUM : cnt - 1;//left bit
                    state <= cnt==1 ? 6 : state ;
                    RD_BYTE_NUM_left <= cnt==1 ? RD_BYTE_NUM_left - 1 :RD_BYTE_NUM_left;
                end
            end
            6:begin//rd process ack
                if(scl_low_mid)begin
                    SDA_T <= `OUT ;
                    SDA_O <= 0;
                    if(RD_BYTE_NUM_left>0)begin
                        state <= 4 ;
                    end
                    else begin
                        state  <= 10;//STOP
                    end
                end
            end
            10:begin//STOP
                ERROR_O  <= 0;
                if(scl_low_mid)begin 
                    SDA_T  <= `OUT;
                    SDA_O  <= 0;
                    state  <= 11;
                end
            end
            11:begin
                if(scl_high_mid)begin
                    SDA_O     <= 1;
                    state     <= 0;
                    Busy      <= 0;
                    RD_DATA_O <= RD_DATA_O_buf;
                    FINISH_O  <= 1;
                    open_iic_clk <= 0 ;//
                end
            end
            default:;
        endcase
    end
end

  
endmodule



