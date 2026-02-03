`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/11/01 16:57:55
// Design Name: 
// Module Name: tb_iic_ctrl_en 
/////////////////////////////////////////////////////////////////////////////////
module tb_iic_master_en(
);

reg clk;
reg rst ;
reg rd_req = 0;
reg wr_req = 0;
wire rd_reg_finish;
wire wr_req_finish;

always #10 clk = ~clk;

iic_master_en uut(
    .RST_I          (rst),
    .CLK_I          (clk),
    .DIV_CNT_I      (4),//[9:0] must >= 4
    .READ_REQ_I     (rd_req),
    .WRITE_REQ_I    (wr_req),
    .DEV_ADDR_I     (8'hB0),//[7:0] dev addr [6:0] valid
    .REG_ADDR_I     (16'hAA55),//[15:0] first send high_addr_byte
    .IS_ADDR_2BYTE_I(1),//
    .PDATA_I        (80'hFF00FF00AA5566778899),//[MAX_BYTE_NUM*8-1:0] PDATA_I = {0000000000 low_addr_byte......high_addr_byte}
    .RD_FINISH_O    (rd_reg_finish),//read finish pulse
    .WR_FINISH_O    (wr_req_finish),
    .PDATA_O        (),//[MAX_BYTE_NUM*8-1:0] PDATA_O = {0000000000 low_addr_byte......high_addr_byte}
    .BYTE_NUM_I     (1),//[f_Data2W(MAX_BYTE_NUM)-1:0]
    .SDA_I          (0),
    .SDA_O          (SDA_O),
    .SDA_T          (),
    .SCL_I          (),
    .SCL_O          (SCL_O),
    .SCL_T          (),
    .BUSY_O         (BUSY_O),
    .ERROR_O        (ERROR_O)
    );


 
initial begin
    rst = 1;
    rd_req = 0;
    wr_req = 0;
    clk = 0;
    #500;
    rst = 0;
    #500;
    
    wr_req = 1;
    #50;
    wr_req = 0;

end   



endmodule
