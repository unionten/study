# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {Base}]
  set_property tooltip {Base} ${Page_0}
  ipgui::add_param $IPINST -name "PORT_NUM" -parent ${Page_0} -widget comboBox
  set MODE [ipgui::add_param $IPINST -name "MODE" -parent ${Page_0} -widget comboBox]
  set_property tooltip {if hs is 0 when de is not ready} ${MODE}
  ipgui::add_param $IPINST -name "OUTPUT_REGISTER_EN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SHOW_DBG_INFO" -parent ${Page_0}
  ipgui::add_param $IPINST -name "VS_ALLIGN_EN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DE_ALLIGN_EN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "HARD_TIMING_EN" -parent ${Page_0}

  #Adding Page
  set jghj [ipgui::add_page $IPINST -name "jghj" -display_name {Hard TIming Para}]
  set_property tooltip {Hard TIming Para} ${jghj}
  set HFP [ipgui::add_param $IPINST -name "HFP" -parent ${jghj}]
  set_property tooltip {4k 4p: 44  2k 4p: 22} ${HFP}
  set HSYNC [ipgui::add_param $IPINST -name "HSYNC" -parent ${jghj}]
  set_property tooltip {4k 4p: 22   2k 4p: 11} ${HSYNC}
  set HACTIVE [ipgui::add_param $IPINST -name "HACTIVE" -parent ${jghj}]
  set_property tooltip {4k 4p: 960  2k 4p: 480} ${HACTIVE}
  set HBP [ipgui::add_param $IPINST -name "HBP" -parent ${jghj}]
  set_property tooltip {4k 4p: 74   2k 4p: 37} ${HBP}
  set VFP [ipgui::add_param $IPINST -name "VFP" -parent ${jghj}]
  set_property tooltip {4k 4p: 8  2k 4p: 4} ${VFP}
  set VSYNC [ipgui::add_param $IPINST -name "VSYNC" -parent ${jghj}]
  set_property tooltip {4k 4p: 10  2k 4p: 5} ${VSYNC}
  set VACTIVE [ipgui::add_param $IPINST -name "VACTIVE" -parent ${jghj}]
  set_property tooltip {4k 4p: 2160  2k 4p: 1080} ${VACTIVE}
  set VBP [ipgui::add_param $IPINST -name "VBP" -parent ${jghj}]
  set_property tooltip {4k 4p: 72  2k 4p: 36} ${VBP}


}

proc update_PARAM_VALUE.DE_ALLIGN_EN { PARAM_VALUE.DE_ALLIGN_EN } {
	# Procedure called to update DE_ALLIGN_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DE_ALLIGN_EN { PARAM_VALUE.DE_ALLIGN_EN } {
	# Procedure called to validate DE_ALLIGN_EN
	return true
}

proc update_PARAM_VALUE.HACTIVE { PARAM_VALUE.HACTIVE } {
	# Procedure called to update HACTIVE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HACTIVE { PARAM_VALUE.HACTIVE } {
	# Procedure called to validate HACTIVE
	return true
}

proc update_PARAM_VALUE.HARD_TIMING_EN { PARAM_VALUE.HARD_TIMING_EN } {
	# Procedure called to update HARD_TIMING_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HARD_TIMING_EN { PARAM_VALUE.HARD_TIMING_EN } {
	# Procedure called to validate HARD_TIMING_EN
	return true
}

proc update_PARAM_VALUE.HBP { PARAM_VALUE.HBP } {
	# Procedure called to update HBP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HBP { PARAM_VALUE.HBP } {
	# Procedure called to validate HBP
	return true
}

proc update_PARAM_VALUE.HFP { PARAM_VALUE.HFP } {
	# Procedure called to update HFP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HFP { PARAM_VALUE.HFP } {
	# Procedure called to validate HFP
	return true
}

proc update_PARAM_VALUE.HSYNC { PARAM_VALUE.HSYNC } {
	# Procedure called to update HSYNC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HSYNC { PARAM_VALUE.HSYNC } {
	# Procedure called to validate HSYNC
	return true
}

proc update_PARAM_VALUE.ILA_ENABLE { PARAM_VALUE.ILA_ENABLE } {
	# Procedure called to update ILA_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ILA_ENABLE { PARAM_VALUE.ILA_ENABLE } {
	# Procedure called to validate ILA_ENABLE
	return true
}

proc update_PARAM_VALUE.MODE { PARAM_VALUE.MODE } {
	# Procedure called to update MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MODE { PARAM_VALUE.MODE } {
	# Procedure called to validate MODE
	return true
}

proc update_PARAM_VALUE.OUTPUT_REGISTER_EN { PARAM_VALUE.OUTPUT_REGISTER_EN } {
	# Procedure called to update OUTPUT_REGISTER_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUTPUT_REGISTER_EN { PARAM_VALUE.OUTPUT_REGISTER_EN } {
	# Procedure called to validate OUTPUT_REGISTER_EN
	return true
}

proc update_PARAM_VALUE.PORT_NUM { PARAM_VALUE.PORT_NUM } {
	# Procedure called to update PORT_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PORT_NUM { PARAM_VALUE.PORT_NUM } {
	# Procedure called to validate PORT_NUM
	return true
}

proc update_PARAM_VALUE.SHOW_DBG_INFO { PARAM_VALUE.SHOW_DBG_INFO } {
	# Procedure called to update SHOW_DBG_INFO when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SHOW_DBG_INFO { PARAM_VALUE.SHOW_DBG_INFO } {
	# Procedure called to validate SHOW_DBG_INFO
	return true
}

proc update_PARAM_VALUE.VACTIVE { PARAM_VALUE.VACTIVE } {
	# Procedure called to update VACTIVE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VACTIVE { PARAM_VALUE.VACTIVE } {
	# Procedure called to validate VACTIVE
	return true
}

proc update_PARAM_VALUE.VBP { PARAM_VALUE.VBP } {
	# Procedure called to update VBP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VBP { PARAM_VALUE.VBP } {
	# Procedure called to validate VBP
	return true
}

proc update_PARAM_VALUE.VFP { PARAM_VALUE.VFP } {
	# Procedure called to update VFP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VFP { PARAM_VALUE.VFP } {
	# Procedure called to validate VFP
	return true
}

proc update_PARAM_VALUE.VSYNC { PARAM_VALUE.VSYNC } {
	# Procedure called to update VSYNC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VSYNC { PARAM_VALUE.VSYNC } {
	# Procedure called to validate VSYNC
	return true
}

proc update_PARAM_VALUE.VS_ALLIGN_EN { PARAM_VALUE.VS_ALLIGN_EN } {
	# Procedure called to update VS_ALLIGN_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VS_ALLIGN_EN { PARAM_VALUE.VS_ALLIGN_EN } {
	# Procedure called to validate VS_ALLIGN_EN
	return true
}


proc update_MODELPARAM_VALUE.OUTPUT_REGISTER_EN { MODELPARAM_VALUE.OUTPUT_REGISTER_EN PARAM_VALUE.OUTPUT_REGISTER_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUTPUT_REGISTER_EN}] ${MODELPARAM_VALUE.OUTPUT_REGISTER_EN}
}

proc update_MODELPARAM_VALUE.MODE { MODELPARAM_VALUE.MODE PARAM_VALUE.MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MODE}] ${MODELPARAM_VALUE.MODE}
}

proc update_MODELPARAM_VALUE.HARD_TIMING_EN { MODELPARAM_VALUE.HARD_TIMING_EN PARAM_VALUE.HARD_TIMING_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HARD_TIMING_EN}] ${MODELPARAM_VALUE.HARD_TIMING_EN}
}

proc update_MODELPARAM_VALUE.VS_ALLIGN_EN { MODELPARAM_VALUE.VS_ALLIGN_EN PARAM_VALUE.VS_ALLIGN_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VS_ALLIGN_EN}] ${MODELPARAM_VALUE.VS_ALLIGN_EN}
}

proc update_MODELPARAM_VALUE.DE_ALLIGN_EN { MODELPARAM_VALUE.DE_ALLIGN_EN PARAM_VALUE.DE_ALLIGN_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DE_ALLIGN_EN}] ${MODELPARAM_VALUE.DE_ALLIGN_EN}
}

proc update_MODELPARAM_VALUE.HSYNC { MODELPARAM_VALUE.HSYNC PARAM_VALUE.HSYNC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HSYNC}] ${MODELPARAM_VALUE.HSYNC}
}

proc update_MODELPARAM_VALUE.HBP { MODELPARAM_VALUE.HBP PARAM_VALUE.HBP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HBP}] ${MODELPARAM_VALUE.HBP}
}

proc update_MODELPARAM_VALUE.HACTIVE { MODELPARAM_VALUE.HACTIVE PARAM_VALUE.HACTIVE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HACTIVE}] ${MODELPARAM_VALUE.HACTIVE}
}

proc update_MODELPARAM_VALUE.HFP { MODELPARAM_VALUE.HFP PARAM_VALUE.HFP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HFP}] ${MODELPARAM_VALUE.HFP}
}

proc update_MODELPARAM_VALUE.VSYNC { MODELPARAM_VALUE.VSYNC PARAM_VALUE.VSYNC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VSYNC}] ${MODELPARAM_VALUE.VSYNC}
}

proc update_MODELPARAM_VALUE.VBP { MODELPARAM_VALUE.VBP PARAM_VALUE.VBP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VBP}] ${MODELPARAM_VALUE.VBP}
}

proc update_MODELPARAM_VALUE.VACTIVE { MODELPARAM_VALUE.VACTIVE PARAM_VALUE.VACTIVE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VACTIVE}] ${MODELPARAM_VALUE.VACTIVE}
}

proc update_MODELPARAM_VALUE.VFP { MODELPARAM_VALUE.VFP PARAM_VALUE.VFP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VFP}] ${MODELPARAM_VALUE.VFP}
}

proc update_MODELPARAM_VALUE.SHOW_DBG_INFO { MODELPARAM_VALUE.SHOW_DBG_INFO PARAM_VALUE.SHOW_DBG_INFO } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SHOW_DBG_INFO}] ${MODELPARAM_VALUE.SHOW_DBG_INFO}
}

proc update_MODELPARAM_VALUE.ILA_ENABLE { MODELPARAM_VALUE.ILA_ENABLE PARAM_VALUE.ILA_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ILA_ENABLE}] ${MODELPARAM_VALUE.ILA_ENABLE}
}

proc update_MODELPARAM_VALUE.PORT_NUM { MODELPARAM_VALUE.PORT_NUM PARAM_VALUE.PORT_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PORT_NUM}] ${MODELPARAM_VALUE.PORT_NUM}
}

