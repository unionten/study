package fwu_pkg;
  localparam int unsigned MAX_PAYLOAD = 1024;

  localparam logic [7:0] MSG_HELLO     = 8'h01;
  localparam logic [7:0] MSG_START     = 8'h02;
  localparam logic [7:0] MSG_ERASE     = 8'h03;
  localparam logic [7:0] MSG_DATA      = 8'h04;
  localparam logic [7:0] MSG_FINISH    = 8'h05;
  localparam logic [7:0] MSG_QUERY     = 8'h06;

  localparam logic [7:0] MSG_HELLO_RSP = 8'h81;
  localparam logic [7:0] MSG_ACK       = 8'h82;
  localparam logic [7:0] MSG_PROGRESS  = 8'h83;
  localparam logic [7:0] MSG_ERROR     = 8'h84;

  localparam logic [7:0] STATUS_OK       = 8'd0;
  localparam logic [7:0] STATUS_BUSY     = 8'd1;
  localparam logic [7:0] STATUS_BAD_CRC  = 8'd2;
  localparam logic [7:0] STATUS_BAD_STATE= 8'd3;
  localparam logic [7:0] STATUS_FLASH_ERR= 8'd4;
endpackage

