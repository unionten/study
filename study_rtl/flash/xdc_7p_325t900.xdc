

#set_property PACKAGE_PIN B22 [get_ports FLASH_WP_O  ]
#set_property PACKAGE_PIN A22 [get_ports FLASH_HOLD_O]


set_property PACKAGE_PIN AD12 [get_ports clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports clk_p]

set_property PACKAGE_PIN P24 [get_ports FLASH_D0_O]
set_property PACKAGE_PIN R25 [get_ports FLASH_D1_I]
set_property PACKAGE_PIN U19 [get_ports FLASH_CS_O]

set_property IOSTANDARD LVCMOS33 [get_ports FLASH_D0_O]
set_property IOSTANDARD LVCMOS33 [get_ports FLASH_D1_I]
set_property IOSTANDARD LVCMOS33 [get_ports FLASH_CS_O]




