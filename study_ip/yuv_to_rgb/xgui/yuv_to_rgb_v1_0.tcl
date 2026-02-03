# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_BPC" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_PORT_NUM" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_DLY" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_BPC { PARAM_VALUE.C_BPC } {
	# Procedure called to update C_BPC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_BPC { PARAM_VALUE.C_BPC } {
	# Procedure called to validate C_BPC
	return true
}

proc update_PARAM_VALUE.C_DLY { PARAM_VALUE.C_DLY } {
	# Procedure called to update C_DLY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DLY { PARAM_VALUE.C_DLY } {
	# Procedure called to validate C_DLY
	return true
}

proc update_PARAM_VALUE.C_PORT_NUM { PARAM_VALUE.C_PORT_NUM } {
	# Procedure called to update C_PORT_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PORT_NUM { PARAM_VALUE.C_PORT_NUM } {
	# Procedure called to validate C_PORT_NUM
	return true
}


proc update_MODELPARAM_VALUE.C_BPC { MODELPARAM_VALUE.C_BPC PARAM_VALUE.C_BPC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_BPC}] ${MODELPARAM_VALUE.C_BPC}
}

proc update_MODELPARAM_VALUE.C_PORT_NUM { MODELPARAM_VALUE.C_PORT_NUM PARAM_VALUE.C_PORT_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PORT_NUM}] ${MODELPARAM_VALUE.C_PORT_NUM}
}

proc update_MODELPARAM_VALUE.C_DLY { MODELPARAM_VALUE.C_DLY PARAM_VALUE.C_DLY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DLY}] ${MODELPARAM_VALUE.C_DLY}
}

