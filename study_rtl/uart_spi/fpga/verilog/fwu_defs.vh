`ifndef FWU_DEFS_VH
`define FWU_DEFS_VH

`ifndef FWU_MAX_PAYLOAD
`define FWU_MAX_PAYLOAD 1024
`endif

`define FWU_MSG_HELLO      8'h01
`define FWU_MSG_START      8'h02
`define FWU_MSG_ERASE      8'h03
`define FWU_MSG_DATA       8'h04
`define FWU_MSG_FINISH     8'h05
`define FWU_MSG_QUERY      8'h06

`define FWU_MSG_HELLO_RSP  8'h81
`define FWU_MSG_ACK        8'h82
`define FWU_MSG_PROGRESS   8'h83
`define FWU_MSG_ERROR      8'h84

`define FWU_STATUS_OK         8'd0
`define FWU_STATUS_BUSY       8'd1
`define FWU_STATUS_BAD_CRC    8'd2
`define FWU_STATUS_BAD_STATE  8'd3
`define FWU_STATUS_FLASH_ERR  8'd4

`endif

