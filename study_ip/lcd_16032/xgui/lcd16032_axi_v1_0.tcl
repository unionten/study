# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_CLK_PRD_NS" -parent ${Page_0}
  ipgui::add_static_text $IPINST -name "tip" -parent ${Page_0} -text {write to 0x0000 ->write no. 0 1 2 3 half charactors 
total 20 half charactors
read any addr always return 0x00000000}

  ipgui::add_param $IPINST -name "C_ILA_ENABLE"

}

proc update_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to update C_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_DATA_WIDTH { PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to update C_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_DATA_WIDTH { PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to validate C_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_CLK_PRD_NS { PARAM_VALUE.C_CLK_PRD_NS } {
	# Procedure called to update C_CLK_PRD_NS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CLK_PRD_NS { PARAM_VALUE.C_CLK_PRD_NS } {
	# Procedure called to validate C_CLK_PRD_NS
	return true
}

proc update_PARAM_VALUE.C_ILA_ENABLE { PARAM_VALUE.C_ILA_ENABLE } {
	# Procedure called to update C_ILA_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ILA_ENABLE { PARAM_VALUE.C_ILA_ENABLE } {
	# Procedure called to validate C_ILA_ENABLE
	return true
}


proc update_MODELPARAM_VALUE.C_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_DATA_WIDTH PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_ADDR_WIDTH PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_CLK_PRD_NS { MODELPARAM_VALUE.C_CLK_PRD_NS PARAM_VALUE.C_CLK_PRD_NS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CLK_PRD_NS}] ${MODELPARAM_VALUE.C_CLK_PRD_NS}
}

proc update_MODELPARAM_VALUE.C_ILA_ENABLE { MODELPARAM_VALUE.C_ILA_ENABLE PARAM_VALUE.C_ILA_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ILA_ENABLE}] ${MODELPARAM_VALUE.C_ILA_ENABLE}
}

