# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "BPC" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M_AXI_ID_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEBUG_READ_SD_EN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEBUG_WRITE_SD_EN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "READ_BURST_LENGTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WRITE_BURST_LENGTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.BPC { PARAM_VALUE.BPC } {
	# Procedure called to update BPC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BPC { PARAM_VALUE.BPC } {
	# Procedure called to validate BPC
	return true
}

proc update_PARAM_VALUE.C_M_AXI_ADDR_WIDTH { PARAM_VALUE.C_M_AXI_ADDR_WIDTH } {
	# Procedure called to update C_M_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ADDR_WIDTH { PARAM_VALUE.C_M_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_M_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_DATA_WIDTH { PARAM_VALUE.C_M_AXI_DATA_WIDTH } {
	# Procedure called to update C_M_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_DATA_WIDTH { PARAM_VALUE.C_M_AXI_DATA_WIDTH } {
	# Procedure called to validate C_M_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_ID_WIDTH { PARAM_VALUE.C_M_AXI_ID_WIDTH } {
	# Procedure called to update C_M_AXI_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ID_WIDTH { PARAM_VALUE.C_M_AXI_ID_WIDTH } {
	# Procedure called to validate C_M_AXI_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.DEBUG_READ_SD_EN { PARAM_VALUE.DEBUG_READ_SD_EN } {
	# Procedure called to update DEBUG_READ_SD_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEBUG_READ_SD_EN { PARAM_VALUE.DEBUG_READ_SD_EN } {
	# Procedure called to validate DEBUG_READ_SD_EN
	return true
}

proc update_PARAM_VALUE.DEBUG_WRITE_SD_EN { PARAM_VALUE.DEBUG_WRITE_SD_EN } {
	# Procedure called to update DEBUG_WRITE_SD_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEBUG_WRITE_SD_EN { PARAM_VALUE.DEBUG_WRITE_SD_EN } {
	# Procedure called to validate DEBUG_WRITE_SD_EN
	return true
}

proc update_PARAM_VALUE.READ_BURST_LENGTH { PARAM_VALUE.READ_BURST_LENGTH } {
	# Procedure called to update READ_BURST_LENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.READ_BURST_LENGTH { PARAM_VALUE.READ_BURST_LENGTH } {
	# Procedure called to validate READ_BURST_LENGTH
	return true
}

proc update_PARAM_VALUE.S_AXI_ADDR_WIDTH { PARAM_VALUE.S_AXI_ADDR_WIDTH } {
	# Procedure called to update S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_AXI_ADDR_WIDTH { PARAM_VALUE.S_AXI_ADDR_WIDTH } {
	# Procedure called to validate S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.S_AXI_DATA_WIDTH { PARAM_VALUE.S_AXI_DATA_WIDTH } {
	# Procedure called to update S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_AXI_DATA_WIDTH { PARAM_VALUE.S_AXI_DATA_WIDTH } {
	# Procedure called to validate S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.WRITE_BURST_LENGTH { PARAM_VALUE.WRITE_BURST_LENGTH } {
	# Procedure called to update WRITE_BURST_LENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WRITE_BURST_LENGTH { PARAM_VALUE.WRITE_BURST_LENGTH } {
	# Procedure called to validate WRITE_BURST_LENGTH
	return true
}


proc update_MODELPARAM_VALUE.S_AXI_DATA_WIDTH { MODELPARAM_VALUE.S_AXI_DATA_WIDTH PARAM_VALUE.S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.S_AXI_ADDR_WIDTH PARAM_VALUE.S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_ID_WIDTH { MODELPARAM_VALUE.C_M_AXI_ID_WIDTH PARAM_VALUE.C_M_AXI_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_ID_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_M_AXI_ADDR_WIDTH PARAM_VALUE.C_M_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_M_AXI_DATA_WIDTH PARAM_VALUE.C_M_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.READ_BURST_LENGTH { MODELPARAM_VALUE.READ_BURST_LENGTH PARAM_VALUE.READ_BURST_LENGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.READ_BURST_LENGTH}] ${MODELPARAM_VALUE.READ_BURST_LENGTH}
}

proc update_MODELPARAM_VALUE.WRITE_BURST_LENGTH { MODELPARAM_VALUE.WRITE_BURST_LENGTH PARAM_VALUE.WRITE_BURST_LENGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WRITE_BURST_LENGTH}] ${MODELPARAM_VALUE.WRITE_BURST_LENGTH}
}

proc update_MODELPARAM_VALUE.DEBUG_READ_SD_EN { MODELPARAM_VALUE.DEBUG_READ_SD_EN PARAM_VALUE.DEBUG_READ_SD_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEBUG_READ_SD_EN}] ${MODELPARAM_VALUE.DEBUG_READ_SD_EN}
}

proc update_MODELPARAM_VALUE.DEBUG_WRITE_SD_EN { MODELPARAM_VALUE.DEBUG_WRITE_SD_EN PARAM_VALUE.DEBUG_WRITE_SD_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEBUG_WRITE_SD_EN}] ${MODELPARAM_VALUE.DEBUG_WRITE_SD_EN}
}

proc update_MODELPARAM_VALUE.BPC { MODELPARAM_VALUE.BPC PARAM_VALUE.BPC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BPC}] ${MODELPARAM_VALUE.BPC}
}

