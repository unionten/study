# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_CLK_BE_TESTED_NUM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_CLK_BE_TESTED_MHZ_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI_LITE_ADDR_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_LITE_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "SYS_PRD_NS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TEST_REF_PRD_ILA_ENABLE" -parent ${Page_0}


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

proc update_PARAM_VALUE.C_CLK_BE_TESTED_MHZ_WIDTH { PARAM_VALUE.C_CLK_BE_TESTED_MHZ_WIDTH } {
	# Procedure called to update C_CLK_BE_TESTED_MHZ_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CLK_BE_TESTED_MHZ_WIDTH { PARAM_VALUE.C_CLK_BE_TESTED_MHZ_WIDTH } {
	# Procedure called to validate C_CLK_BE_TESTED_MHZ_WIDTH
	return true
}

proc update_PARAM_VALUE.C_CLK_BE_TESTED_NUM { PARAM_VALUE.C_CLK_BE_TESTED_NUM } {
	# Procedure called to update C_CLK_BE_TESTED_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CLK_BE_TESTED_NUM { PARAM_VALUE.C_CLK_BE_TESTED_NUM } {
	# Procedure called to validate C_CLK_BE_TESTED_NUM
	return true
}

proc update_PARAM_VALUE.SYS_PRD_NS { PARAM_VALUE.SYS_PRD_NS } {
	# Procedure called to update SYS_PRD_NS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SYS_PRD_NS { PARAM_VALUE.SYS_PRD_NS } {
	# Procedure called to validate SYS_PRD_NS
	return true
}

proc update_PARAM_VALUE.TEST_REF_PRD_ILA_ENABLE { PARAM_VALUE.TEST_REF_PRD_ILA_ENABLE } {
	# Procedure called to update TEST_REF_PRD_ILA_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TEST_REF_PRD_ILA_ENABLE { PARAM_VALUE.TEST_REF_PRD_ILA_ENABLE } {
	# Procedure called to validate TEST_REF_PRD_ILA_ENABLE
	return true
}


proc update_MODELPARAM_VALUE.C_CLK_BE_TESTED_NUM { MODELPARAM_VALUE.C_CLK_BE_TESTED_NUM PARAM_VALUE.C_CLK_BE_TESTED_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CLK_BE_TESTED_NUM}] ${MODELPARAM_VALUE.C_CLK_BE_TESTED_NUM}
}

proc update_MODELPARAM_VALUE.C_CLK_BE_TESTED_MHZ_WIDTH { MODELPARAM_VALUE.C_CLK_BE_TESTED_MHZ_WIDTH PARAM_VALUE.C_CLK_BE_TESTED_MHZ_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CLK_BE_TESTED_MHZ_WIDTH}] ${MODELPARAM_VALUE.C_CLK_BE_TESTED_MHZ_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH PARAM_VALUE.C_AXI_LITE_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.SYS_PRD_NS { MODELPARAM_VALUE.SYS_PRD_NS PARAM_VALUE.SYS_PRD_NS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SYS_PRD_NS}] ${MODELPARAM_VALUE.SYS_PRD_NS}
}

proc update_MODELPARAM_VALUE.TEST_REF_PRD_ILA_ENABLE { MODELPARAM_VALUE.TEST_REF_PRD_ILA_ENABLE PARAM_VALUE.TEST_REF_PRD_ILA_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TEST_REF_PRD_ILA_ENABLE}] ${MODELPARAM_VALUE.TEST_REF_PRD_ILA_ENABLE}
}

