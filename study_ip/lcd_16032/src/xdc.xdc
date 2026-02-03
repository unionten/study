set_property PACKAGE_PIN AB11 [get_ports sys_clk_p]
set_property PACKAGE_PIN AC11 [get_ports sys_clk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_p]


set_property PACKAGE_PIN N18 [get_ports LCD_MOSI_O]
set_property PACKAGE_PIN M19 [get_ports LCD_CS_O]
set_property PACKAGE_PIN U17 [get_ports LCD_SCK_O]
set_property IOSTANDARD LVCMOS33 [get_ports LCD_*]

set_property BITSTREAM.CONFIG.CONFIGRATE 40 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk50M]
