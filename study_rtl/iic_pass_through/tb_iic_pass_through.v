`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/11 14:48:23
// Design Name: 
// Module Name: tb
//////////////////////////////////////////////////////////////////////////////////


module tb_iic_pass_through(

    );
    
parameter REG_ADDR_BYTE_NUM   = 2;
parameter UNF_ADDR_BYTE_NUM   = 2 ; 
parameter UNIT_DATA_BYTE_NUM  = 2;  
parameter UNIT_NUM = 2;
   

initial begin
    rd_req = 0;
    clk = 0;
    wr_req = 0;
    rst = 1;
    #3000;
    rst = 0;
    #400000;
    
    
    
    wr_req = 1;
    dev_addr = 8'h50;
    reg_addr = 16'haabb;
    num = UNIT_DATA_BYTE_NUM*UNIT_NUM;
    #50;
    wr_req = 0;



    //#900000;
    //wr_req = 1;
    //dev_addr = 8'h50;
    //reg_addr = 16'h0080;
    //num = UNIT_DATA_BYTE_NUM*UNIT_NUM;
    //#50;
    //wr_req = 0;
    
    
    
    #3500000;
    rd_req = 1;
    dev_addr = 8'h50;
    reg_addr = 16'haabb;
    num = UNIT_DATA_BYTE_NUM*UNIT_NUM;
    #50;
    rd_req = 0;
    


end 


   
    
reg clk = 0;
reg  wr_req =0;
reg  rd_req = 0;
reg rst ;
wire [7:0] state ; assign state = uut.state;
wire [3:0] bit_id; assign bit_id = uut.bit_id;
wire flag_wr;assign flag_wr = uut.flag_wr;
wire flag_rd; assign flag_rd =uut.flag_rd;
wire start_flag; assign start_flag = uut.start_flag;
wire stop_flag;  assign stop_flag = uut.stop_flag;
wire scl_in_pos; assign scl_in_pos = uut.scl_in_pos;
wire scl_in_neg; assign scl_in_neg = uut.scl_in_neg;


wire REG_ADDR_L_beat;assign REG_ADDR_L_beat = uut.REG_ADDR_L_beat;
wire update_read_addr_beat_1;
wire update_read_addr_beat_2;
wire update_read_dout_beat;
assign update_read_addr_beat_1 = uut.update_read_addr_beat_1;
assign update_read_addr_beat_2 = uut.update_read_addr_beat_2;
assign update_read_dout_beat = uut.update_read_dout_beat;


reg [7:0] dev_addr ;
reg [15:0] reg_addr;
reg [15:0] num;
 
 
iic_master_en #(.MAX_BYTE_NUM( UNIT_NUM*UNIT_DATA_BYTE_NUM ))

    iic_ctrl_u(
    .RST_I          (0),      //do not need to rst
    .CLK_I          (clk),      
    .DIV_CNT_I      (100),      //[9:0] 【 must >= 4 】
    .WRITE_REQ_I    (wr_req),      //prior to READ_REQ_I
    .READ_REQ_I     (rd_req),      
    .DEV_ADDR_I     (dev_addr),      //[6:0] dev addr 【注意只有7位】
    .REG_ADDR_I     (reg_addr),      //[15:0] first send high byte , when  IS_ADDR_2BYTE_I == 1
    .IS_ADDR_2BYTE_I(REG_ADDR_BYTE_NUM-1),      //
    .PDATA_I        (4096'hddccbbaa4433221111223344aabb0091),      //[MAX_BYTE_NUM*8-1:0] PDATA_I = {0000000000 low byte(first send)......high byte}
    .RD_FINISH_O    (),      //read finish pulse
    .WR_FINISH_O    (),      
    .PDATA_O        (),      //[MAX_BYTE_NUM*8-1:0] PDATA_O = {0000000000 low byte......high byte}
    .BYTE_NUM_I     (num),      //[f_Data2W(MAX_BYTE_NUM)-1:0]  【must >= 0, 新版本支持0字节】
    .SDA_I          (sda_i),      
    .SDA_O          (sda_o),      
    .SDA_T          (sda_t),      
    .SCL_I          (scl_i),      
    .SCL_O          (scl_o),      
    .SCL_T          (scl_t),      
    .BUSY_O         (),      
    .ERROR_O        ()       
    ); 
    

   IOBUF #(
      .DRIVE(12), // Specify the output drive strength
      .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
      .IOSTANDARD("DEFAULT"), // Specify the I/O standard
      .SLEW("SLOW") // Specify the output slew rate
   ) IOBUF_insts (
      .O(sda_i),     // Buffer output
      .IO(s_sda),   // Buffer inout port (connect directly to top-level port)
      .I(sda_o),     // Buffer input
      .T(sda_t)      // 3-state enable input, high=input, low=output
   );

    IOBUF #(
      .DRIVE(12), // Specify the output drive strength
      .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
      .IOSTANDARD("DEFAULT"), // Specify the I/O standard
      .SLEW("SLOW") // Specify the output slew rate
   ) IOBUF_insts1 (
      .O(scl_i),     // Buffer output
      .IO(s_scl),   // Buffer inout port (connect directly to top-level port)
      .I(scl_o),     // Buffer input
      .T(scl_t)      // 3-state enable input, high=input, low=output
   );





   
wire WR_EN_O;
wire [UNF_ADDR_BYTE_NUM*8-1:0]  WR_ADDR_O;
wire [UNIT_DATA_BYTE_NUM*8-1:0]  WR_DATA_O;

wire RD_EN_O;
wire [UNF_ADDR_BYTE_NUM*8-1:0] RD_ADDR_O;
reg [UNIT_DATA_BYTE_NUM*8-1:0] RD_DATA_I;




iic_pass_through  iic_pass_through_u(
.CLK_I      (clk ),
.RST_I      (rst ),
.S_SCL_IO   (s_scl),
.S_SDA_IO   (s_sda),
.M_SCL_IO   (m_scl),
.M_SDA_IO   (m_sda)

);


   IOBUF #(
      .DRIVE(12), // Specify the output drive strength
      .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
      .IOSTANDARD("DEFAULT"), // Specify the I/O standard
      .SLEW("SLOW") // Specify the output slew rate
   ) IOBUF_instm (
      .O(sda2_i),     // Buffer output
      .IO(m_sda),   // Buffer inout port (connect directly to top-level port)
      .I(sda2_o),     // Buffer input
      .T(sda2_t)      // 3-state enable input, high=input, low=output
   );

    IOBUF #(
      .DRIVE(12), // Specify the output drive strength
      .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
      .IOSTANDARD("DEFAULT"), // Specify the I/O standard
      .SLEW("SLOW") // Specify the output slew rate
   ) IOBUF_instm1 (
      .O(scl2_i),     // Buffer output
      .IO(m_scl),   // Buffer inout port (connect directly to top-level port)
      .I(scl2_o),     // Buffer input
      .T(scl2_t)      // 3-state enable input, high=input, low=output
   );





iic_multi_slave_clk 


    #(.C_REG_ADDR_BYTE_NUM (REG_ADDR_BYTE_NUM )  ,//= 2 ;//1 2 
      .C_RAM_ADDR_BYTE_NUM (UNF_ADDR_BYTE_NUM ) ,
      .C_RAM_DATA_BYTE_NUM (UNIT_DATA_BYTE_NUM) ,
      .C_WR_ENABLE(1),
      .C_RD_ENABLE(1)
      )//= 1 ;//1 2 4 ... 
 uut(
.SYS_CLK_I (clk), //sync
.SYS_RST_I (rst), //sync
.SDA_I     (sda2_i),
.SDA_O     (sda2_o),
.SDA_T     (sda2_t), 
.SCL_I     (scl2_i),
.SCL_O     (scl2_o),
.SCL_T     (scl2_t), //always in
.BUSY_O    (), //sync
.WR_EN_O   (WR_EN_O   ), //~ SYS_CLK_I pos  
.WR_ADDR_O (WR_ADDR_O ), //~ SYS_CLK_I pos  
.WR_DATA_O (WR_DATA_O ), //~ SYS_CLK_I pos  
.RD_EN_O   (RD_EN_O   ), //~ SYS_CLK_I pos  
.RD_ADDR_O (RD_ADDR_O ), //~ SYS_CLK_I pos  
.RD_DATA_I (RD_DATA_I )  //~ SYS_CLK_I pos  
 

);


initial begin
    RD_DATA_I = 0;
    #2321726.260;
    RD_DATA_I = 64'h1122334455667788;

end



always #2 clk = ~clk;


    
    
endmodule



