# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "BIT_RATE_VALUE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLKIN_PERIOD" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DCD_CORRECT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ENABLE_MONITOR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ENABLE_PHASE_DETECTOR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "HIGH_PERFORMANCE_MODE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INTER_CLOCK" -parent ${Page_0}
  ipgui::add_param $IPINST -name "LANE_NUM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MMCM_MODE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PIXEL_CLOCK" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PORT_NUM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "REF_FREQ" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SAMPL_CLOCK" -parent ${Page_0}
  ipgui::add_param $IPINST -name "USE_PLL" -parent ${Page_0}


}

proc update_PARAM_VALUE.BIT_RATE_VALUE { PARAM_VALUE.BIT_RATE_VALUE } {
	# Procedure called to update BIT_RATE_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BIT_RATE_VALUE { PARAM_VALUE.BIT_RATE_VALUE } {
	# Procedure called to validate BIT_RATE_VALUE
	return true
}

proc update_PARAM_VALUE.CLKIN_PERIOD { PARAM_VALUE.CLKIN_PERIOD } {
	# Procedure called to update CLKIN_PERIOD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLKIN_PERIOD { PARAM_VALUE.CLKIN_PERIOD } {
	# Procedure called to validate CLKIN_PERIOD
	return true
}

proc update_PARAM_VALUE.DCD_CORRECT { PARAM_VALUE.DCD_CORRECT } {
	# Procedure called to update DCD_CORRECT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DCD_CORRECT { PARAM_VALUE.DCD_CORRECT } {
	# Procedure called to validate DCD_CORRECT
	return true
}

proc update_PARAM_VALUE.ENABLE_MONITOR { PARAM_VALUE.ENABLE_MONITOR } {
	# Procedure called to update ENABLE_MONITOR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ENABLE_MONITOR { PARAM_VALUE.ENABLE_MONITOR } {
	# Procedure called to validate ENABLE_MONITOR
	return true
}

proc update_PARAM_VALUE.ENABLE_PHASE_DETECTOR { PARAM_VALUE.ENABLE_PHASE_DETECTOR } {
	# Procedure called to update ENABLE_PHASE_DETECTOR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ENABLE_PHASE_DETECTOR { PARAM_VALUE.ENABLE_PHASE_DETECTOR } {
	# Procedure called to validate ENABLE_PHASE_DETECTOR
	return true
}

proc update_PARAM_VALUE.HIGH_PERFORMANCE_MODE { PARAM_VALUE.HIGH_PERFORMANCE_MODE } {
	# Procedure called to update HIGH_PERFORMANCE_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HIGH_PERFORMANCE_MODE { PARAM_VALUE.HIGH_PERFORMANCE_MODE } {
	# Procedure called to validate HIGH_PERFORMANCE_MODE
	return true
}

proc update_PARAM_VALUE.INTER_CLOCK { PARAM_VALUE.INTER_CLOCK } {
	# Procedure called to update INTER_CLOCK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INTER_CLOCK { PARAM_VALUE.INTER_CLOCK } {
	# Procedure called to validate INTER_CLOCK
	return true
}

proc update_PARAM_VALUE.LANE_NUM { PARAM_VALUE.LANE_NUM } {
	# Procedure called to update LANE_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LANE_NUM { PARAM_VALUE.LANE_NUM } {
	# Procedure called to validate LANE_NUM
	return true
}

proc update_PARAM_VALUE.MMCM_MODE { PARAM_VALUE.MMCM_MODE } {
	# Procedure called to update MMCM_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MMCM_MODE { PARAM_VALUE.MMCM_MODE } {
	# Procedure called to validate MMCM_MODE
	return true
}

proc update_PARAM_VALUE.PIXEL_CLOCK { PARAM_VALUE.PIXEL_CLOCK } {
	# Procedure called to update PIXEL_CLOCK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PIXEL_CLOCK { PARAM_VALUE.PIXEL_CLOCK } {
	# Procedure called to validate PIXEL_CLOCK
	return true
}

proc update_PARAM_VALUE.PORT_NUM { PARAM_VALUE.PORT_NUM } {
	# Procedure called to update PORT_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PORT_NUM { PARAM_VALUE.PORT_NUM } {
	# Procedure called to validate PORT_NUM
	return true
}

proc update_PARAM_VALUE.REF_FREQ { PARAM_VALUE.REF_FREQ } {
	# Procedure called to update REF_FREQ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.REF_FREQ { PARAM_VALUE.REF_FREQ } {
	# Procedure called to validate REF_FREQ
	return true
}

proc update_PARAM_VALUE.SAMPL_CLOCK { PARAM_VALUE.SAMPL_CLOCK } {
	# Procedure called to update SAMPL_CLOCK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SAMPL_CLOCK { PARAM_VALUE.SAMPL_CLOCK } {
	# Procedure called to validate SAMPL_CLOCK
	return true
}

proc update_PARAM_VALUE.USE_PLL { PARAM_VALUE.USE_PLL } {
	# Procedure called to update USE_PLL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_PLL { PARAM_VALUE.USE_PLL } {
	# Procedure called to validate USE_PLL
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

proc update_MODELPARAM_VALUE.SAMPL_CLOCK { MODELPARAM_VALUE.SAMPL_CLOCK PARAM_VALUE.SAMPL_CLOCK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SAMPL_CLOCK}] ${MODELPARAM_VALUE.SAMPL_CLOCK}
}

proc update_MODELPARAM_VALUE.INTER_CLOCK { MODELPARAM_VALUE.INTER_CLOCK PARAM_VALUE.INTER_CLOCK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INTER_CLOCK}] ${MODELPARAM_VALUE.INTER_CLOCK}
}

proc update_MODELPARAM_VALUE.PIXEL_CLOCK { MODELPARAM_VALUE.PIXEL_CLOCK PARAM_VALUE.PIXEL_CLOCK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PIXEL_CLOCK}] ${MODELPARAM_VALUE.PIXEL_CLOCK}
}

proc update_MODELPARAM_VALUE.MMCM_MODE { MODELPARAM_VALUE.MMCM_MODE PARAM_VALUE.MMCM_MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MMCM_MODE}] ${MODELPARAM_VALUE.MMCM_MODE}
}

proc update_MODELPARAM_VALUE.ENABLE_PHASE_DETECTOR { MODELPARAM_VALUE.ENABLE_PHASE_DETECTOR PARAM_VALUE.ENABLE_PHASE_DETECTOR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ENABLE_PHASE_DETECTOR}] ${MODELPARAM_VALUE.ENABLE_PHASE_DETECTOR}
}

proc update_MODELPARAM_VALUE.ENABLE_MONITOR { MODELPARAM_VALUE.ENABLE_MONITOR PARAM_VALUE.ENABLE_MONITOR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ENABLE_MONITOR}] ${MODELPARAM_VALUE.ENABLE_MONITOR}
}

proc update_MODELPARAM_VALUE.DCD_CORRECT { MODELPARAM_VALUE.DCD_CORRECT PARAM_VALUE.DCD_CORRECT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DCD_CORRECT}] ${MODELPARAM_VALUE.DCD_CORRECT}
}

proc update_MODELPARAM_VALUE.USE_PLL { MODELPARAM_VALUE.USE_PLL PARAM_VALUE.USE_PLL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USE_PLL}] ${MODELPARAM_VALUE.USE_PLL}
}

proc update_MODELPARAM_VALUE.HIGH_PERFORMANCE_MODE { MODELPARAM_VALUE.HIGH_PERFORMANCE_MODE PARAM_VALUE.HIGH_PERFORMANCE_MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HIGH_PERFORMANCE_MODE}] ${MODELPARAM_VALUE.HIGH_PERFORMANCE_MODE}
}

proc update_MODELPARAM_VALUE.REF_FREQ { MODELPARAM_VALUE.REF_FREQ PARAM_VALUE.REF_FREQ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.REF_FREQ}] ${MODELPARAM_VALUE.REF_FREQ}
}

proc update_MODELPARAM_VALUE.CLKIN_PERIOD { MODELPARAM_VALUE.CLKIN_PERIOD PARAM_VALUE.CLKIN_PERIOD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLKIN_PERIOD}] ${MODELPARAM_VALUE.CLKIN_PERIOD}
}

proc update_MODELPARAM_VALUE.BIT_RATE_VALUE { MODELPARAM_VALUE.BIT_RATE_VALUE PARAM_VALUE.BIT_RATE_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BIT_RATE_VALUE}] ${MODELPARAM_VALUE.BIT_RATE_VALUE}
}

