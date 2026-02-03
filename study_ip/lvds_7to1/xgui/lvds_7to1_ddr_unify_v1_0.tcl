# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "LANE_NUM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PORT_NUM" -parent ${Page_0} -widget comboBox


}

proc update_PARAM_VALUE.LANE_NUM { PARAM_VALUE.LANE_NUM } {
	# Procedure called to update LANE_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LANE_NUM { PARAM_VALUE.LANE_NUM } {
	# Procedure called to validate LANE_NUM
	return true
}

proc update_PARAM_VALUE.PORT_NUM { PARAM_VALUE.PORT_NUM } {
	# Procedure called to update PORT_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PORT_NUM { PARAM_VALUE.PORT_NUM } {
	# Procedure called to validate PORT_NUM
	return true
}


proc update_MODELPARAM_VALUE.PORT_NUM { MODELPARAM_VALUE.PORT_NUM PARAM_VALUE.PORT_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PORT_NUM}] ${MODELPARAM_VALUE.PORT_NUM}
}

proc update_MODELPARAM_VALUE.LANE_NUM { MODELPARAM_VALUE.LANE_NUM PARAM_VALUE.LANE_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LANE_NUM}] ${MODELPARAM_VALUE.LANE_NUM}
}

