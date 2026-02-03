

create_clock   -period 10  -name  spi_clk_mux   [get_nets  design_1_wrapper/design_1_i/spi_slave_pg8s_pro_0/inst/spi_clk_mux  ]
create_clock   -period 20  -name  spi_clk       [get_ports  SPI_SCK_I    ]


set_property PACKAGE_PIN G24 [get_ports CLK_IN1_D_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports CLK_IN1_D_clk_p]



set_property PACKAGE_PIN AE23 [get_ports SPI_SCK_I]
set_property PACKAGE_PIN AD23 [get_ports SPI_CS_I]
set_property PACKAGE_PIN AE22 [get_ports SPI_MOSI_I]
set_property PACKAGE_PIN AF22 [get_ports SPI_MISO_O]

set_property IOSTANDARD LVCMOS18 [get_ports SPI_*]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets SPI_SCK_I_IBUF_BUFGCE]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets SPI_SCK_I_IBUF_inst/O]

#RSV0 1.8V
set_property PACKAGE_PIN AE16 [get_ports resetn]
set_property IOSTANDARD LVCMOS18 [get_ports resetn]



#RSV1 1.8V
set_property PACKAGE_PIN AD16 [get_ports INTERRUPT_O]
set_property IOSTANDARD LVCMOS18 [get_ports INTERRUPT_O]



#Debug 口
set_property PACKAGE_PIN J10 [get_ports UART_txd]
set_property IOSTANDARD LVCMOS18 [get_ports UART_txd]

set_property PACKAGE_PIN J11 [get_ports UART_rxd]
set_property IOSTANDARD LVCMOS18 [get_ports UART_rxd ]





set_property PACKAGE_PIN H23 [get_ports {C0_DDR4_ck_t[0]}]
set_property PACKAGE_PIN J26 [get_ports {C0_DDR4_cs_n[0]}]
set_property PACKAGE_PIN M25 [get_ports {C0_DDR4_odt[0]}]
# set_property PACKAGE_PIN G15 [get_ports {C0_DDR4_dm_n[7]}]
# set_property PACKAGE_PIN H18 [get_ports {C0_DDR4_dm_n[6]}]
# set_property PACKAGE_PIN C18 [get_ports {C0_DDR4_dm_n[5]}]
# set_property PACKAGE_PIN A22 [get_ports {C0_DDR4_dm_n[4]}]
set_property PACKAGE_PIN U19 [get_ports {C0_DDR4_dm_n[3]}]
set_property PACKAGE_PIN Y22 [get_ports {C0_DDR4_dm_n[2]}]
set_property PACKAGE_PIN R22 [get_ports {C0_DDR4_dm_n[1]}]
set_property PACKAGE_PIN T24 [get_ports {C0_DDR4_dm_n[0]}]
# set_property PACKAGE_PIN E16 [get_ports {C0_DDR4_dqs_t[7]}]
# set_property PACKAGE_PIN F20 [get_ports {C0_DDR4_dqs_t[6]}]
# set_property PACKAGE_PIN A17 [get_ports {C0_DDR4_dqs_t[5]}]
# set_property PACKAGE_PIN C21 [get_ports {C0_DDR4_dqs_t[4]}]
set_property PACKAGE_PIN V21 [get_ports {C0_DDR4_dqs_t[3]}]
set_property PACKAGE_PIN W25 [get_ports {C0_DDR4_dqs_t[2]}]
set_property PACKAGE_PIN N23 [get_ports {C0_DDR4_dqs_t[1]}]
set_property PACKAGE_PIN U26 [get_ports {C0_DDR4_dqs_t[0]}]
# set_property PACKAGE_PIN E15 [get_ports {C0_DDR4_dq[63]}]
# set_property PACKAGE_PIN G17 [get_ports {C0_DDR4_dq[62]}]
# set_property PACKAGE_PIN C16 [get_ports {C0_DDR4_dq[61]}]
# set_property PACKAGE_PIN H16 [get_ports {C0_DDR4_dq[60]}]
# set_property PACKAGE_PIN D15 [get_ports {C0_DDR4_dq[59]}]
# set_property PACKAGE_PIN G16 [get_ports {C0_DDR4_dq[58]}]
# set_property PACKAGE_PIN D16 [get_ports {C0_DDR4_dq[57]}]
# set_property PACKAGE_PIN H17 [get_ports {C0_DDR4_dq[56]}]
# set_property PACKAGE_PIN E18 [get_ports {C0_DDR4_dq[55]}]
# set_property PACKAGE_PIN G20 [get_ports {C0_DDR4_dq[54]}]
# set_property PACKAGE_PIN D18 [get_ports {C0_DDR4_dq[53]}]
# set_property PACKAGE_PIN G21 [get_ports {C0_DDR4_dq[52]}]
# set_property PACKAGE_PIN D19 [get_ports {C0_DDR4_dq[51]}]
# set_property PACKAGE_PIN F19 [get_ports {C0_DDR4_dq[50]}]
# set_property PACKAGE_PIN D20 [get_ports {C0_DDR4_dq[49]}]
# set_property PACKAGE_PIN F18 [get_ports {C0_DDR4_dq[48]}]
# set_property PACKAGE_PIN A15 [get_ports {C0_DDR4_dq[47]}]
# set_property PACKAGE_PIN A19 [get_ports {C0_DDR4_dq[46]}]
# set_property PACKAGE_PIN B17 [get_ports {C0_DDR4_dq[45]}]
# set_property PACKAGE_PIN B20 [get_ports {C0_DDR4_dq[44]}]
# set_property PACKAGE_PIN B15 [get_ports {C0_DDR4_dq[43]}]
# set_property PACKAGE_PIN B19 [get_ports {C0_DDR4_dq[42]}]
# set_property PACKAGE_PIN C17 [get_ports {C0_DDR4_dq[41]}]
# set_property PACKAGE_PIN A20 [get_ports {C0_DDR4_dq[40]}]
# set_property PACKAGE_PIN A25 [get_ports {C0_DDR4_dq[39]}]
# set_property PACKAGE_PIN E21 [get_ports {C0_DDR4_dq[38]}]
# set_property PACKAGE_PIN A24 [get_ports {C0_DDR4_dq[37]}]
# set_property PACKAGE_PIN D21 [get_ports {C0_DDR4_dq[36]}]
# set_property PACKAGE_PIN B24 [get_ports {C0_DDR4_dq[35]}]
# set_property PACKAGE_PIN C23 [get_ports {C0_DDR4_dq[34]}]
# set_property PACKAGE_PIN B22 [get_ports {C0_DDR4_dq[33]}]
# set_property PACKAGE_PIN C22 [get_ports {C0_DDR4_dq[32]}]
set_property PACKAGE_PIN T23 [get_ports {C0_DDR4_dq[31]}]
set_property PACKAGE_PIN U21 [get_ports {C0_DDR4_dq[30]}]
set_property PACKAGE_PIN T22 [get_ports {C0_DDR4_dq[29]}]
set_property PACKAGE_PIN W19 [get_ports {C0_DDR4_dq[28]}]
set_property PACKAGE_PIN U22 [get_ports {C0_DDR4_dq[27]}]
set_property PACKAGE_PIN U20 [get_ports {C0_DDR4_dq[26]}]
set_property PACKAGE_PIN T20 [get_ports {C0_DDR4_dq[25]}]
set_property PACKAGE_PIN W20 [get_ports {C0_DDR4_dq[24]}]
set_property PACKAGE_PIN W23 [get_ports {C0_DDR4_dq[23]}]
set_property PACKAGE_PIN Y26 [get_ports {C0_DDR4_dq[22]}]
set_property PACKAGE_PIN V23 [get_ports {C0_DDR4_dq[21]}]
set_property PACKAGE_PIN AA24 [get_ports {C0_DDR4_dq[20]}]
set_property PACKAGE_PIN V24 [get_ports {C0_DDR4_dq[19]}]
set_property PACKAGE_PIN AA25 [get_ports {C0_DDR4_dq[18]}]
set_property PACKAGE_PIN W24 [get_ports {C0_DDR4_dq[17]}]
set_property PACKAGE_PIN Y25 [get_ports {C0_DDR4_dq[16]}]
set_property PACKAGE_PIN N19 [get_ports {C0_DDR4_dq[15]}]
set_property PACKAGE_PIN P21 [get_ports {C0_DDR4_dq[14]}]
set_property PACKAGE_PIN P19 [get_ports {C0_DDR4_dq[13]}]
set_property PACKAGE_PIN R20 [get_ports {C0_DDR4_dq[12]}]
set_property PACKAGE_PIN N21 [get_ports {C0_DDR4_dq[11]}]
set_property PACKAGE_PIN P20 [get_ports {C0_DDR4_dq[10]}]
set_property PACKAGE_PIN N22 [get_ports {C0_DDR4_dq[9]}]
set_property PACKAGE_PIN R21 [get_ports {C0_DDR4_dq[8]}]
set_property PACKAGE_PIN N24 [get_ports {C0_DDR4_dq[7]}]
set_property PACKAGE_PIN P26 [get_ports {C0_DDR4_dq[6]}]
set_property PACKAGE_PIN P25 [get_ports {C0_DDR4_dq[5]}]
set_property PACKAGE_PIN R25 [get_ports {C0_DDR4_dq[4]}]
set_property PACKAGE_PIN P24 [get_ports {C0_DDR4_dq[3]}]
set_property PACKAGE_PIN T25 [get_ports {C0_DDR4_dq[2]}]
set_property PACKAGE_PIN R26 [get_ports {C0_DDR4_dq[1]}]
set_property PACKAGE_PIN U25 [get_ports {C0_DDR4_dq[0]}]

set_property PACKAGE_PIN J24 [get_ports {C0_DDR4_adr[16]}]
set_property PACKAGE_PIN G26 [get_ports {C0_DDR4_adr[15]}]
set_property PACKAGE_PIN L25 [get_ports {C0_DDR4_adr[14]}]
set_property PACKAGE_PIN J23 [get_ports {C0_DDR4_adr[3]}]
set_property PACKAGE_PIN H22 [get_ports {C0_DDR4_adr[5]}]
set_property PACKAGE_PIN K21 [get_ports {C0_DDR4_adr[0]}]
set_property PACKAGE_PIN M19 [get_ports {C0_DDR4_adr[2]}]
set_property PACKAGE_PIN L24 [get_ports {C0_DDR4_adr[10]}]
set_property PACKAGE_PIN K22 [get_ports {C0_DDR4_adr[4]}]
set_property PACKAGE_PIN H21 [get_ports {C0_DDR4_adr[9]}]
set_property PACKAGE_PIN F25 [get_ports {C0_DDR4_adr[1]}]
set_property PACKAGE_PIN H26 [get_ports {C0_DDR4_adr[12]}]
set_property PACKAGE_PIN L20 [get_ports {C0_DDR4_adr[6]}]
set_property PACKAGE_PIN K18 [get_ports {C0_DDR4_adr[11]}]
set_property PACKAGE_PIN J21 [get_ports {C0_DDR4_adr[7]}]
set_property PACKAGE_PIN J20 [get_ports {C0_DDR4_adr[13]}]
set_property PACKAGE_PIN L19 [get_ports {C0_DDR4_adr[8]}]





set_property PACKAGE_PIN M24 [get_ports {C0_DDR4_bg[0]}]
set_property PACKAGE_PIN K23 [get_ports {C0_DDR4_ba[0]}]
set_property PACKAGE_PIN F24 [get_ports {C0_DDR4_ba[1]}]
set_property PACKAGE_PIN M26 [get_ports {C0_DDR4_cke[0]}]
set_property PACKAGE_PIN K20 [get_ports C0_DDR4_reset_n]
set_property PACKAGE_PIN K26 [get_ports C0_DDR4_act_n]





set_property BITSTREAM.CONFIG.CONFIGRATE 36.4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
