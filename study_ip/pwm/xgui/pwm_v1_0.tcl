# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {Base}]
  ipgui::add_param $IPINST -name "LB_ENABLE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_ADDR_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_S_AXI_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "DEBUG_ENABLE" -parent ${Page_0}
  ipgui::add_static_text $IPINST -name "reg space" -parent ${Page_0} -text {ADDR_R_ENABLE_CH0  16'h0000

ADDR_R_DIV_CH0     16'h0004

ADDR_R_DUTY_CH0    16'h0008

 ADDR_R_ENABLE_CH1  16'h000C

 ADDR_R_DIV_CH1     16'h0010

 ADDR_R_DUTY_CH1    16'h0014}

  #Adding Page
  set CH0_Default_Para [ipgui::add_page $IPINST -name "CH0 Default Para"]
  ipgui::add_param $IPINST -name "DEFAULT_EN_CH0" -parent ${CH0_Default_Para}
  ipgui::add_param $IPINST -name "DEFAULT_DIV_CH0" -parent ${CH0_Default_Para}
  ipgui::add_param $IPINST -name "DEFAULT_DUTY_CH0" -parent ${CH0_Default_Para}

  #Adding Page
  set CH1_Default_Para [ipgui::add_page $IPINST -name "CH1 Default Para"]
  ipgui::add_param $IPINST -name "DEFAULT_EN_CH1" -parent ${CH1_Default_Para}
  ipgui::add_param $IPINST -name "DEFAULT_DIV_CH1" -parent ${CH1_Default_Para}
  ipgui::add_param $IPINST -name "DEFAULT_DUTY_CH1" -parent ${CH1_Default_Para}


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

proc update_PARAM_VALUE.DEBUG_ENABLE { PARAM_VALUE.DEBUG_ENABLE } {
	# Procedure called to update DEBUG_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEBUG_ENABLE { PARAM_VALUE.DEBUG_ENABLE } {
	# Procedure called to validate DEBUG_ENABLE
	return true
}

proc update_PARAM_VALUE.DEFAULT_DIV_CH0 { PARAM_VALUE.DEFAULT_DIV_CH0 } {
	# Procedure called to update DEFAULT_DIV_CH0 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_DIV_CH0 { PARAM_VALUE.DEFAULT_DIV_CH0 } {
	# Procedure called to validate DEFAULT_DIV_CH0
	return true
}

proc update_PARAM_VALUE.DEFAULT_DIV_CH1 { PARAM_VALUE.DEFAULT_DIV_CH1 } {
	# Procedure called to update DEFAULT_DIV_CH1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_DIV_CH1 { PARAM_VALUE.DEFAULT_DIV_CH1 } {
	# Procedure called to validate DEFAULT_DIV_CH1
	return true
}

proc update_PARAM_VALUE.DEFAULT_DUTY_CH0 { PARAM_VALUE.DEFAULT_DUTY_CH0 } {
	# Procedure called to update DEFAULT_DUTY_CH0 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_DUTY_CH0 { PARAM_VALUE.DEFAULT_DUTY_CH0 } {
	# Procedure called to validate DEFAULT_DUTY_CH0
	return true
}

proc update_PARAM_VALUE.DEFAULT_DUTY_CH1 { PARAM_VALUE.DEFAULT_DUTY_CH1 } {
	# Procedure called to update DEFAULT_DUTY_CH1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_DUTY_CH1 { PARAM_VALUE.DEFAULT_DUTY_CH1 } {
	# Procedure called to validate DEFAULT_DUTY_CH1
	return true
}

proc update_PARAM_VALUE.DEFAULT_EN_CH0 { PARAM_VALUE.DEFAULT_EN_CH0 } {
	# Procedure called to update DEFAULT_EN_CH0 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_EN_CH0 { PARAM_VALUE.DEFAULT_EN_CH0 } {
	# Procedure called to validate DEFAULT_EN_CH0
	return true
}

proc update_PARAM_VALUE.DEFAULT_EN_CH1 { PARAM_VALUE.DEFAULT_EN_CH1 } {
	# Procedure called to update DEFAULT_EN_CH1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_EN_CH1 { PARAM_VALUE.DEFAULT_EN_CH1 } {
	# Procedure called to validate DEFAULT_EN_CH1
	return true
}

proc update_PARAM_VALUE.LB_ENABLE { PARAM_VALUE.LB_ENABLE } {
	# Procedure called to update LB_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LB_ENABLE { PARAM_VALUE.LB_ENABLE } {
	# Procedure called to validate LB_ENABLE
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.DEFAULT_DIV_CH0 { MODELPARAM_VALUE.DEFAULT_DIV_CH0 PARAM_VALUE.DEFAULT_DIV_CH0 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_DIV_CH0}] ${MODELPARAM_VALUE.DEFAULT_DIV_CH0}
}

proc update_MODELPARAM_VALUE.DEFAULT_DUTY_CH0 { MODELPARAM_VALUE.DEFAULT_DUTY_CH0 PARAM_VALUE.DEFAULT_DUTY_CH0 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_DUTY_CH0}] ${MODELPARAM_VALUE.DEFAULT_DUTY_CH0}
}

proc update_MODELPARAM_VALUE.DEFAULT_EN_CH0 { MODELPARAM_VALUE.DEFAULT_EN_CH0 PARAM_VALUE.DEFAULT_EN_CH0 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_EN_CH0}] ${MODELPARAM_VALUE.DEFAULT_EN_CH0}
}

proc update_MODELPARAM_VALUE.DEFAULT_DIV_CH1 { MODELPARAM_VALUE.DEFAULT_DIV_CH1 PARAM_VALUE.DEFAULT_DIV_CH1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_DIV_CH1}] ${MODELPARAM_VALUE.DEFAULT_DIV_CH1}
}

proc update_MODELPARAM_VALUE.DEFAULT_DUTY_CH1 { MODELPARAM_VALUE.DEFAULT_DUTY_CH1 PARAM_VALUE.DEFAULT_DUTY_CH1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_DUTY_CH1}] ${MODELPARAM_VALUE.DEFAULT_DUTY_CH1}
}

proc update_MODELPARAM_VALUE.DEFAULT_EN_CH1 { MODELPARAM_VALUE.DEFAULT_EN_CH1 PARAM_VALUE.DEFAULT_EN_CH1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_EN_CH1}] ${MODELPARAM_VALUE.DEFAULT_EN_CH1}
}

proc update_MODELPARAM_VALUE.DEBUG_ENABLE { MODELPARAM_VALUE.DEBUG_ENABLE PARAM_VALUE.DEBUG_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEBUG_ENABLE}] ${MODELPARAM_VALUE.DEBUG_ENABLE}
}

proc update_MODELPARAM_VALUE.LB_ENABLE { MODELPARAM_VALUE.LB_ENABLE PARAM_VALUE.LB_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LB_ENABLE}] ${MODELPARAM_VALUE.LB_ENABLE}
}

