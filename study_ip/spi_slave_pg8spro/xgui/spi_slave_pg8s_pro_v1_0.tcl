# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_LB_ENABLE" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_S_AXI_ADDR_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_S_AXI_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI4_ADDR_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI4_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_DDR_BURST_LEN" -parent ${Page_0} -widget comboBox
  set C_SNAP_ENABLE [ipgui::add_param $IPINST -name "C_SNAP_ENABLE" -parent ${Page_0} -widget comboBox]
  set_property tooltip {0:disable ddr fifo  1(default): enable ddr fifo} ${C_SNAP_ENABLE}
  set C_RD_NORM_DATA_SOURCE [ipgui::add_param $IPINST -name "C_RD_NORM_DATA_SOURCE" -parent ${Page_0} -widget comboBox]
  set_property tooltip {0(default): ddr data 1: inner data} ${C_RD_NORM_DATA_SOURCE}

  ipgui::add_param $IPINST -name "C_ILA_ACLK_ENABLE"
  ipgui::add_param $IPINST -name "C_ILA_MCLK_ENABLE"
  ipgui::add_param $IPINST -name "C_ILA_SCLK_ENABLE"
  ipgui::add_param $IPINST -name "C_ILA_SPIIF_ACLK_ENABLE"

}

proc update_PARAM_VALUE.C_AXI4_ADDR_WIDTH { PARAM_VALUE.C_AXI4_ADDR_WIDTH } {
	# Procedure called to update C_AXI4_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI4_ADDR_WIDTH { PARAM_VALUE.C_AXI4_ADDR_WIDTH } {
	# Procedure called to validate C_AXI4_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI4_DATA_WIDTH { PARAM_VALUE.C_AXI4_DATA_WIDTH } {
	# Procedure called to update C_AXI4_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI4_DATA_WIDTH { PARAM_VALUE.C_AXI4_DATA_WIDTH } {
	# Procedure called to validate C_AXI4_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_DDR_BURST_LEN { PARAM_VALUE.C_DDR_BURST_LEN } {
	# Procedure called to update C_DDR_BURST_LEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DDR_BURST_LEN { PARAM_VALUE.C_DDR_BURST_LEN } {
	# Procedure called to validate C_DDR_BURST_LEN
	return true
}

proc update_PARAM_VALUE.C_ILA_ACLK_ENABLE { PARAM_VALUE.C_ILA_ACLK_ENABLE } {
	# Procedure called to update C_ILA_ACLK_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ILA_ACLK_ENABLE { PARAM_VALUE.C_ILA_ACLK_ENABLE } {
	# Procedure called to validate C_ILA_ACLK_ENABLE
	return true
}

proc update_PARAM_VALUE.C_ILA_MCLK_ENABLE { PARAM_VALUE.C_ILA_MCLK_ENABLE } {
	# Procedure called to update C_ILA_MCLK_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ILA_MCLK_ENABLE { PARAM_VALUE.C_ILA_MCLK_ENABLE } {
	# Procedure called to validate C_ILA_MCLK_ENABLE
	return true
}

proc update_PARAM_VALUE.C_ILA_SCLK_ENABLE { PARAM_VALUE.C_ILA_SCLK_ENABLE } {
	# Procedure called to update C_ILA_SCLK_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ILA_SCLK_ENABLE { PARAM_VALUE.C_ILA_SCLK_ENABLE } {
	# Procedure called to validate C_ILA_SCLK_ENABLE
	return true
}

proc update_PARAM_VALUE.C_ILA_SPIIF_ACLK_ENABLE { PARAM_VALUE.C_ILA_SPIIF_ACLK_ENABLE } {
	# Procedure called to update C_ILA_SPIIF_ACLK_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ILA_SPIIF_ACLK_ENABLE { PARAM_VALUE.C_ILA_SPIIF_ACLK_ENABLE } {
	# Procedure called to validate C_ILA_SPIIF_ACLK_ENABLE
	return true
}

proc update_PARAM_VALUE.C_LB_ENABLE { PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to update C_LB_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_LB_ENABLE { PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to validate C_LB_ENABLE
	return true
}

proc update_PARAM_VALUE.C_RD_NORM_DATA_SOURCE { PARAM_VALUE.C_RD_NORM_DATA_SOURCE } {
	# Procedure called to update C_RD_NORM_DATA_SOURCE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_RD_NORM_DATA_SOURCE { PARAM_VALUE.C_RD_NORM_DATA_SOURCE } {
	# Procedure called to validate C_RD_NORM_DATA_SOURCE
	return true
}

proc update_PARAM_VALUE.C_SNAP_ENABLE { PARAM_VALUE.C_SNAP_ENABLE } {
	# Procedure called to update C_SNAP_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SNAP_ENABLE { PARAM_VALUE.C_SNAP_ENABLE } {
	# Procedure called to validate C_SNAP_ENABLE
	return true
}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_TX_FIFO_TYPE { PARAM_VALUE.C_TX_FIFO_TYPE } {
	# Procedure called to update C_TX_FIFO_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_TX_FIFO_TYPE { PARAM_VALUE.C_TX_FIFO_TYPE } {
	# Procedure called to validate C_TX_FIFO_TYPE
	return true
}


proc update_MODELPARAM_VALUE.C_LB_ENABLE { MODELPARAM_VALUE.C_LB_ENABLE PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_LB_ENABLE}] ${MODELPARAM_VALUE.C_LB_ENABLE}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI4_DATA_WIDTH { MODELPARAM_VALUE.C_AXI4_DATA_WIDTH PARAM_VALUE.C_AXI4_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI4_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI4_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI4_ADDR_WIDTH PARAM_VALUE.C_AXI4_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI4_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_DDR_BURST_LEN { MODELPARAM_VALUE.C_DDR_BURST_LEN PARAM_VALUE.C_DDR_BURST_LEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DDR_BURST_LEN}] ${MODELPARAM_VALUE.C_DDR_BURST_LEN}
}

proc update_MODELPARAM_VALUE.C_SNAP_ENABLE { MODELPARAM_VALUE.C_SNAP_ENABLE PARAM_VALUE.C_SNAP_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SNAP_ENABLE}] ${MODELPARAM_VALUE.C_SNAP_ENABLE}
}

proc update_MODELPARAM_VALUE.C_ILA_ACLK_ENABLE { MODELPARAM_VALUE.C_ILA_ACLK_ENABLE PARAM_VALUE.C_ILA_ACLK_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ILA_ACLK_ENABLE}] ${MODELPARAM_VALUE.C_ILA_ACLK_ENABLE}
}

proc update_MODELPARAM_VALUE.C_ILA_MCLK_ENABLE { MODELPARAM_VALUE.C_ILA_MCLK_ENABLE PARAM_VALUE.C_ILA_MCLK_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ILA_MCLK_ENABLE}] ${MODELPARAM_VALUE.C_ILA_MCLK_ENABLE}
}

proc update_MODELPARAM_VALUE.C_ILA_SCLK_ENABLE { MODELPARAM_VALUE.C_ILA_SCLK_ENABLE PARAM_VALUE.C_ILA_SCLK_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ILA_SCLK_ENABLE}] ${MODELPARAM_VALUE.C_ILA_SCLK_ENABLE}
}

proc update_MODELPARAM_VALUE.C_TX_FIFO_TYPE { MODELPARAM_VALUE.C_TX_FIFO_TYPE PARAM_VALUE.C_TX_FIFO_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_TX_FIFO_TYPE}] ${MODELPARAM_VALUE.C_TX_FIFO_TYPE}
}

proc update_MODELPARAM_VALUE.C_ILA_SPIIF_ACLK_ENABLE { MODELPARAM_VALUE.C_ILA_SPIIF_ACLK_ENABLE PARAM_VALUE.C_ILA_SPIIF_ACLK_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ILA_SPIIF_ACLK_ENABLE}] ${MODELPARAM_VALUE.C_ILA_SPIIF_ACLK_ENABLE}
}

proc update_MODELPARAM_VALUE.C_RD_NORM_DATA_SOURCE { MODELPARAM_VALUE.C_RD_NORM_DATA_SOURCE PARAM_VALUE.C_RD_NORM_DATA_SOURCE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_RD_NORM_DATA_SOURCE}] ${MODELPARAM_VALUE.C_RD_NORM_DATA_SOURCE}
}

