# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_ILA_ENABLE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI_LITE_ADDR_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_LITE_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_GPIO_O_DEFAULT" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH { PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH } {
	# Procedure called to update C_AXI_LITE_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH { PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH } {
	# Procedure called to validate C_AXI_LITE_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_LITE_DATA_WIDTH { PARAM_VALUE.C_AXI_LITE_DATA_WIDTH } {
	# Procedure called to update C_AXI_LITE_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_LITE_DATA_WIDTH { PARAM_VALUE.C_AXI_LITE_DATA_WIDTH } {
	# Procedure called to validate C_AXI_LITE_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_GPIO_O_DEFAULT { PARAM_VALUE.C_GPIO_O_DEFAULT } {
	# Procedure called to update C_GPIO_O_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_GPIO_O_DEFAULT { PARAM_VALUE.C_GPIO_O_DEFAULT } {
	# Procedure called to validate C_GPIO_O_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_ILA_ENABLE { PARAM_VALUE.C_ILA_ENABLE } {
	# Procedure called to update C_ILA_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ILA_ENABLE { PARAM_VALUE.C_ILA_ENABLE } {
	# Procedure called to validate C_ILA_ENABLE
	return true
}


proc update_MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH PARAM_VALUE.C_AXI_LITE_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_GPIO_O_DEFAULT { MODELPARAM_VALUE.C_GPIO_O_DEFAULT PARAM_VALUE.C_GPIO_O_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_GPIO_O_DEFAULT}] ${MODELPARAM_VALUE.C_GPIO_O_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_ILA_ENABLE { MODELPARAM_VALUE.C_ILA_ENABLE PARAM_VALUE.C_ILA_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ILA_ENABLE}] ${MODELPARAM_VALUE.C_ILA_ENABLE}
}

