# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_LB_ENABLE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI_LITE_ADDR_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_LITE_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_PORT_NUM" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_CPNTS_PER_PIXEL" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_BITS_PER_CPNT" -parent ${Page_0} -widget comboBox

  #Adding Page
  set Default [ipgui::add_page $IPINST -name "Default"]
  ipgui::add_param $IPINST -name "C_TRANSFER_MODE_OUTSIDE_CTRL_EN_DEFAULT" -parent ${Default} -widget comboBox
  ipgui::add_param $IPINST -name "C_DT_OUTSIDE_CTRL_EN_DEFAULT" -parent ${Default} -widget comboBox
  ipgui::add_param $IPINST -name "C_WC_OUTSIDE_CTRL_EN_DEFAULT" -parent ${Default} -widget comboBox
  ipgui::add_param $IPINST -name "C_VC_OUTSIDE_CTRL_EN_DEFAULT" -parent ${Default} -widget comboBox
  set C_INSIDE_TRANSFER_MODE_DEFAULT [ipgui::add_param $IPINST -name "C_INSIDE_TRANSFER_MODE_DEFAULT" -parent ${Default} -widget comboBox]
  set_property tooltip {0 ori  1 yuv422  2 raw} ${C_INSIDE_TRANSFER_MODE_DEFAULT}
  ipgui::add_param $IPINST -name "C_INSIDE_DT_DEFAULT" -parent ${Default}
  ipgui::add_param $IPINST -name "C_INSIDE_WC_DEFAULT" -parent ${Default}
  ipgui::add_param $IPINST -name "C_INSIDE_VC_DEFAULT" -parent ${Default} -widget comboBox


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

proc update_PARAM_VALUE.C_BITS_PER_CPNT { PARAM_VALUE.C_BITS_PER_CPNT } {
	# Procedure called to update C_BITS_PER_CPNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_BITS_PER_CPNT { PARAM_VALUE.C_BITS_PER_CPNT } {
	# Procedure called to validate C_BITS_PER_CPNT
	return true
}

proc update_PARAM_VALUE.C_CPNTS_PER_PIXEL { PARAM_VALUE.C_CPNTS_PER_PIXEL } {
	# Procedure called to update C_CPNTS_PER_PIXEL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CPNTS_PER_PIXEL { PARAM_VALUE.C_CPNTS_PER_PIXEL } {
	# Procedure called to validate C_CPNTS_PER_PIXEL
	return true
}

proc update_PARAM_VALUE.C_DT_OUTSIDE_CTRL_EN_DEFAULT { PARAM_VALUE.C_DT_OUTSIDE_CTRL_EN_DEFAULT } {
	# Procedure called to update C_DT_OUTSIDE_CTRL_EN_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DT_OUTSIDE_CTRL_EN_DEFAULT { PARAM_VALUE.C_DT_OUTSIDE_CTRL_EN_DEFAULT } {
	# Procedure called to validate C_DT_OUTSIDE_CTRL_EN_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_INSIDE_DT_DEFAULT { PARAM_VALUE.C_INSIDE_DT_DEFAULT } {
	# Procedure called to update C_INSIDE_DT_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_INSIDE_DT_DEFAULT { PARAM_VALUE.C_INSIDE_DT_DEFAULT } {
	# Procedure called to validate C_INSIDE_DT_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_INSIDE_TRANSFER_MODE_DEFAULT { PARAM_VALUE.C_INSIDE_TRANSFER_MODE_DEFAULT } {
	# Procedure called to update C_INSIDE_TRANSFER_MODE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_INSIDE_TRANSFER_MODE_DEFAULT { PARAM_VALUE.C_INSIDE_TRANSFER_MODE_DEFAULT } {
	# Procedure called to validate C_INSIDE_TRANSFER_MODE_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_INSIDE_VC_DEFAULT { PARAM_VALUE.C_INSIDE_VC_DEFAULT } {
	# Procedure called to update C_INSIDE_VC_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_INSIDE_VC_DEFAULT { PARAM_VALUE.C_INSIDE_VC_DEFAULT } {
	# Procedure called to validate C_INSIDE_VC_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_INSIDE_WC_DEFAULT { PARAM_VALUE.C_INSIDE_WC_DEFAULT } {
	# Procedure called to update C_INSIDE_WC_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_INSIDE_WC_DEFAULT { PARAM_VALUE.C_INSIDE_WC_DEFAULT } {
	# Procedure called to validate C_INSIDE_WC_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_LB_ENABLE { PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to update C_LB_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_LB_ENABLE { PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to validate C_LB_ENABLE
	return true
}

proc update_PARAM_VALUE.C_PORT_NUM { PARAM_VALUE.C_PORT_NUM } {
	# Procedure called to update C_PORT_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PORT_NUM { PARAM_VALUE.C_PORT_NUM } {
	# Procedure called to validate C_PORT_NUM
	return true
}

proc update_PARAM_VALUE.C_TRANSFER_MODE_OUTSIDE_CTRL_EN_DEFAULT { PARAM_VALUE.C_TRANSFER_MODE_OUTSIDE_CTRL_EN_DEFAULT } {
	# Procedure called to update C_TRANSFER_MODE_OUTSIDE_CTRL_EN_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_TRANSFER_MODE_OUTSIDE_CTRL_EN_DEFAULT { PARAM_VALUE.C_TRANSFER_MODE_OUTSIDE_CTRL_EN_DEFAULT } {
	# Procedure called to validate C_TRANSFER_MODE_OUTSIDE_CTRL_EN_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_VC_OUTSIDE_CTRL_EN_DEFAULT { PARAM_VALUE.C_VC_OUTSIDE_CTRL_EN_DEFAULT } {
	# Procedure called to update C_VC_OUTSIDE_CTRL_EN_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VC_OUTSIDE_CTRL_EN_DEFAULT { PARAM_VALUE.C_VC_OUTSIDE_CTRL_EN_DEFAULT } {
	# Procedure called to validate C_VC_OUTSIDE_CTRL_EN_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_WC_OUTSIDE_CTRL_EN_DEFAULT { PARAM_VALUE.C_WC_OUTSIDE_CTRL_EN_DEFAULT } {
	# Procedure called to update C_WC_OUTSIDE_CTRL_EN_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_WC_OUTSIDE_CTRL_EN_DEFAULT { PARAM_VALUE.C_WC_OUTSIDE_CTRL_EN_DEFAULT } {
	# Procedure called to validate C_WC_OUTSIDE_CTRL_EN_DEFAULT
	return true
}


proc update_MODELPARAM_VALUE.C_LB_ENABLE { MODELPARAM_VALUE.C_LB_ENABLE PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_LB_ENABLE}] ${MODELPARAM_VALUE.C_LB_ENABLE}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH PARAM_VALUE.C_AXI_LITE_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_PORT_NUM { MODELPARAM_VALUE.C_PORT_NUM PARAM_VALUE.C_PORT_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PORT_NUM}] ${MODELPARAM_VALUE.C_PORT_NUM}
}

proc update_MODELPARAM_VALUE.C_BITS_PER_CPNT { MODELPARAM_VALUE.C_BITS_PER_CPNT PARAM_VALUE.C_BITS_PER_CPNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_BITS_PER_CPNT}] ${MODELPARAM_VALUE.C_BITS_PER_CPNT}
}

proc update_MODELPARAM_VALUE.C_CPNTS_PER_PIXEL { MODELPARAM_VALUE.C_CPNTS_PER_PIXEL PARAM_VALUE.C_CPNTS_PER_PIXEL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CPNTS_PER_PIXEL}] ${MODELPARAM_VALUE.C_CPNTS_PER_PIXEL}
}

proc update_MODELPARAM_VALUE.C_TRANSFER_MODE_OUTSIDE_CTRL_EN_DEFAULT { MODELPARAM_VALUE.C_TRANSFER_MODE_OUTSIDE_CTRL_EN_DEFAULT PARAM_VALUE.C_TRANSFER_MODE_OUTSIDE_CTRL_EN_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_TRANSFER_MODE_OUTSIDE_CTRL_EN_DEFAULT}] ${MODELPARAM_VALUE.C_TRANSFER_MODE_OUTSIDE_CTRL_EN_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_DT_OUTSIDE_CTRL_EN_DEFAULT { MODELPARAM_VALUE.C_DT_OUTSIDE_CTRL_EN_DEFAULT PARAM_VALUE.C_DT_OUTSIDE_CTRL_EN_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DT_OUTSIDE_CTRL_EN_DEFAULT}] ${MODELPARAM_VALUE.C_DT_OUTSIDE_CTRL_EN_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_VC_OUTSIDE_CTRL_EN_DEFAULT { MODELPARAM_VALUE.C_VC_OUTSIDE_CTRL_EN_DEFAULT PARAM_VALUE.C_VC_OUTSIDE_CTRL_EN_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VC_OUTSIDE_CTRL_EN_DEFAULT}] ${MODELPARAM_VALUE.C_VC_OUTSIDE_CTRL_EN_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_WC_OUTSIDE_CTRL_EN_DEFAULT { MODELPARAM_VALUE.C_WC_OUTSIDE_CTRL_EN_DEFAULT PARAM_VALUE.C_WC_OUTSIDE_CTRL_EN_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_WC_OUTSIDE_CTRL_EN_DEFAULT}] ${MODELPARAM_VALUE.C_WC_OUTSIDE_CTRL_EN_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_INSIDE_TRANSFER_MODE_DEFAULT { MODELPARAM_VALUE.C_INSIDE_TRANSFER_MODE_DEFAULT PARAM_VALUE.C_INSIDE_TRANSFER_MODE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_INSIDE_TRANSFER_MODE_DEFAULT}] ${MODELPARAM_VALUE.C_INSIDE_TRANSFER_MODE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_INSIDE_DT_DEFAULT { MODELPARAM_VALUE.C_INSIDE_DT_DEFAULT PARAM_VALUE.C_INSIDE_DT_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_INSIDE_DT_DEFAULT}] ${MODELPARAM_VALUE.C_INSIDE_DT_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_INSIDE_VC_DEFAULT { MODELPARAM_VALUE.C_INSIDE_VC_DEFAULT PARAM_VALUE.C_INSIDE_VC_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_INSIDE_VC_DEFAULT}] ${MODELPARAM_VALUE.C_INSIDE_VC_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_INSIDE_WC_DEFAULT { MODELPARAM_VALUE.C_INSIDE_WC_DEFAULT PARAM_VALUE.C_INSIDE_WC_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_INSIDE_WC_DEFAULT}] ${MODELPARAM_VALUE.C_INSIDE_WC_DEFAULT}
}

