`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  yzhu 
// 
// Create Date: 2022/08/18 10:11:01
// Design Name: 
// Module Name: spi_slave
//////////////////////////////////////////////////////////////////////////////////



module spi_slave_core(  
input   SPI_SCK_I      ,
input   SPI_CS_I       ,
input   SPI_DO_I       ,
output  SPI_DI_O       ,
output  reg [7:0] SPI_BYTE_O     ,
output            SPI_BYTE_EN_O  ,
   
input  SPI_ACK_TRIG  ,//negedge
input  [7:0] SPI_ACK_DATA   //需要和 SPI_BYTE_EN_O 对齐

);

parameter  CPHA = 0 ;//fixed 
parameter  CPOL = 0 ;//fixed 


wire  spi_ack_iv;
assign  spi_ack_iv =  ~SPI_SCK_I ;


reg [7:0] cnt_in =0;
always@(posedge SPI_SCK_I or posedge SPI_CS_I)begin
    if(SPI_CS_I)begin
        cnt_in      <= 0; 
    end
    else begin
        SPI_BYTE_O <= {SPI_BYTE_O,SPI_DO_I} ;
        cnt_in        <= cnt_in==8 ? 1 : cnt_in + 1 ; 
    end
end


assign  SPI_BYTE_EN_O  = cnt_in == 8; 



reg [7:0] spi_output_shift = 0;
reg [7:0] cnt_out =0;
always@(negedge SPI_SCK_I or posedge SPI_CS_I)begin
    if(SPI_CS_I)begin
        cnt_out      <= 0; 
    end
    else begin
        spi_output_shift <= SPI_ACK_TRIG ? SPI_ACK_DATA : spi_output_shift<<1;
    end
end

assign  SPI_DI_O = spi_output_shift [7];







endmodule