# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_PORT_NUM" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_MAX_CPNTS_PER_PIXEL" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_BITS_PER_CPNT" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "FIFO_DEPTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_ILA_AXILITE_CLK_ENABLE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_ILA_PCLK_CLK_ENABLE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_ILA_AXIS_CLK_ENABLE" -parent ${Page_0}

  #Adding Page
  set Default [ipgui::add_page $IPINST -name "Default"]
  ipgui::add_param $IPINST -name "C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT" -parent ${Default} -widget comboBox
  ipgui::add_param $IPINST -name "C_CPNT_NUM_DEAFULT" -parent ${Default} -widget comboBox
  ipgui::add_param $IPINST -name "C_DT_OUTSIDE_CTRL_DEFAULT" -parent ${Default} -widget comboBox
  ipgui::add_param $IPINST -name "C_WC_OUTSIDE_CTRL_DEFAULT" -parent ${Default}
  ipgui::add_param $IPINST -name "C_VC_OUTSIDE_CTRL_DEFAULT" -parent ${Default}
  ipgui::add_param $IPINST -name "C_DT_DEAFULT" -parent ${Default}
  ipgui::add_param $IPINST -name "C_WC_DEAFULT" -parent ${Default}
  ipgui::add_param $IPINST -name "C_VC_DEAFULT" -parent ${Default} -widget comboBox


}

proc update_PARAM_VALUE.C_BITS_PER_CPNT { PARAM_VALUE.C_BITS_PER_CPNT } {
	# Procedure called to update C_BITS_PER_CPNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_BITS_PER_CPNT { PARAM_VALUE.C_BITS_PER_CPNT } {
	# Procedure called to validate C_BITS_PER_CPNT
	return true
}

proc update_PARAM_VALUE.C_CPNT_NUM_DEAFULT { PARAM_VALUE.C_CPNT_NUM_DEAFULT } {
	# Procedure called to update C_CPNT_NUM_DEAFULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CPNT_NUM_DEAFULT { PARAM_VALUE.C_CPNT_NUM_DEAFULT } {
	# Procedure called to validate C_CPNT_NUM_DEAFULT
	return true
}

proc update_PARAM_VALUE.C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT { PARAM_VALUE.C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT } {
	# Procedure called to update C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT { PARAM_VALUE.C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT } {
	# Procedure called to validate C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT
	return true
}

proc update_PARAM_VALUE.C_DT_DEAFULT { PARAM_VALUE.C_DT_DEAFULT } {
	# Procedure called to update C_DT_DEAFULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DT_DEAFULT { PARAM_VALUE.C_DT_DEAFULT } {
	# Procedure called to validate C_DT_DEAFULT
	return true
}

proc update_PARAM_VALUE.C_DT_OUTSIDE_CTRL_DEFAULT { PARAM_VALUE.C_DT_OUTSIDE_CTRL_DEFAULT } {
	# Procedure called to update C_DT_OUTSIDE_CTRL_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DT_OUTSIDE_CTRL_DEFAULT { PARAM_VALUE.C_DT_OUTSIDE_CTRL_DEFAULT } {
	# Procedure called to validate C_DT_OUTSIDE_CTRL_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_ILA_AXILITE_CLK_ENABLE { PARAM_VALUE.C_ILA_AXILITE_CLK_ENABLE } {
	# Procedure called to update C_ILA_AXILITE_CLK_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ILA_AXILITE_CLK_ENABLE { PARAM_VALUE.C_ILA_AXILITE_CLK_ENABLE } {
	# Procedure called to validate C_ILA_AXILITE_CLK_ENABLE
	return true
}

proc update_PARAM_VALUE.C_ILA_AXIS_CLK_ENABLE { PARAM_VALUE.C_ILA_AXIS_CLK_ENABLE } {
	# Procedure called to update C_ILA_AXIS_CLK_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ILA_AXIS_CLK_ENABLE { PARAM_VALUE.C_ILA_AXIS_CLK_ENABLE } {
	# Procedure called to validate C_ILA_AXIS_CLK_ENABLE
	return true
}

proc update_PARAM_VALUE.C_ILA_PCLK_CLK_ENABLE { PARAM_VALUE.C_ILA_PCLK_CLK_ENABLE } {
	# Procedure called to update C_ILA_PCLK_CLK_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ILA_PCLK_CLK_ENABLE { PARAM_VALUE.C_ILA_PCLK_CLK_ENABLE } {
	# Procedure called to validate C_ILA_PCLK_CLK_ENABLE
	return true
}

proc update_PARAM_VALUE.C_MAX_CPNTS_PER_PIXEL { PARAM_VALUE.C_MAX_CPNTS_PER_PIXEL } {
	# Procedure called to update C_MAX_CPNTS_PER_PIXEL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MAX_CPNTS_PER_PIXEL { PARAM_VALUE.C_MAX_CPNTS_PER_PIXEL } {
	# Procedure called to validate C_MAX_CPNTS_PER_PIXEL
	return true
}

proc update_PARAM_VALUE.C_PORT_NUM { PARAM_VALUE.C_PORT_NUM } {
	# Procedure called to update C_PORT_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PORT_NUM { PARAM_VALUE.C_PORT_NUM } {
	# Procedure called to validate C_PORT_NUM
	return true
}

proc update_PARAM_VALUE.C_VC_DEAFULT { PARAM_VALUE.C_VC_DEAFULT } {
	# Procedure called to update C_VC_DEAFULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VC_DEAFULT { PARAM_VALUE.C_VC_DEAFULT } {
	# Procedure called to validate C_VC_DEAFULT
	return true
}

proc update_PARAM_VALUE.C_VC_OUTSIDE_CTRL_DEFAULT { PARAM_VALUE.C_VC_OUTSIDE_CTRL_DEFAULT } {
	# Procedure called to update C_VC_OUTSIDE_CTRL_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VC_OUTSIDE_CTRL_DEFAULT { PARAM_VALUE.C_VC_OUTSIDE_CTRL_DEFAULT } {
	# Procedure called to validate C_VC_OUTSIDE_CTRL_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_WC_DEAFULT { PARAM_VALUE.C_WC_DEAFULT } {
	# Procedure called to update C_WC_DEAFULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_WC_DEAFULT { PARAM_VALUE.C_WC_DEAFULT } {
	# Procedure called to validate C_WC_DEAFULT
	return true
}

proc update_PARAM_VALUE.C_WC_OUTSIDE_CTRL_DEFAULT { PARAM_VALUE.C_WC_OUTSIDE_CTRL_DEFAULT } {
	# Procedure called to update C_WC_OUTSIDE_CTRL_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_WC_OUTSIDE_CTRL_DEFAULT { PARAM_VALUE.C_WC_OUTSIDE_CTRL_DEFAULT } {
	# Procedure called to validate C_WC_OUTSIDE_CTRL_DEFAULT
	return true
}

proc update_PARAM_VALUE.FIFO_DEPTH { PARAM_VALUE.FIFO_DEPTH } {
	# Procedure called to update FIFO_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FIFO_DEPTH { PARAM_VALUE.FIFO_DEPTH } {
	# Procedure called to validate FIFO_DEPTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.FIFO_DEPTH { MODELPARAM_VALUE.FIFO_DEPTH PARAM_VALUE.FIFO_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FIFO_DEPTH}] ${MODELPARAM_VALUE.FIFO_DEPTH}
}

proc update_MODELPARAM_VALUE.C_MAX_CPNTS_PER_PIXEL { MODELPARAM_VALUE.C_MAX_CPNTS_PER_PIXEL PARAM_VALUE.C_MAX_CPNTS_PER_PIXEL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MAX_CPNTS_PER_PIXEL}] ${MODELPARAM_VALUE.C_MAX_CPNTS_PER_PIXEL}
}

proc update_MODELPARAM_VALUE.C_PORT_NUM { MODELPARAM_VALUE.C_PORT_NUM PARAM_VALUE.C_PORT_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PORT_NUM}] ${MODELPARAM_VALUE.C_PORT_NUM}
}

proc update_MODELPARAM_VALUE.C_BITS_PER_CPNT { MODELPARAM_VALUE.C_BITS_PER_CPNT PARAM_VALUE.C_BITS_PER_CPNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_BITS_PER_CPNT}] ${MODELPARAM_VALUE.C_BITS_PER_CPNT}
}

proc update_MODELPARAM_VALUE.C_DT_DEAFULT { MODELPARAM_VALUE.C_DT_DEAFULT PARAM_VALUE.C_DT_DEAFULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DT_DEAFULT}] ${MODELPARAM_VALUE.C_DT_DEAFULT}
}

proc update_MODELPARAM_VALUE.C_WC_DEAFULT { MODELPARAM_VALUE.C_WC_DEAFULT PARAM_VALUE.C_WC_DEAFULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_WC_DEAFULT}] ${MODELPARAM_VALUE.C_WC_DEAFULT}
}

proc update_MODELPARAM_VALUE.C_VC_DEAFULT { MODELPARAM_VALUE.C_VC_DEAFULT PARAM_VALUE.C_VC_DEAFULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VC_DEAFULT}] ${MODELPARAM_VALUE.C_VC_DEAFULT}
}

proc update_MODELPARAM_VALUE.C_CPNT_NUM_DEAFULT { MODELPARAM_VALUE.C_CPNT_NUM_DEAFULT PARAM_VALUE.C_CPNT_NUM_DEAFULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CPNT_NUM_DEAFULT}] ${MODELPARAM_VALUE.C_CPNT_NUM_DEAFULT}
}

proc update_MODELPARAM_VALUE.C_DT_OUTSIDE_CTRL_DEFAULT { MODELPARAM_VALUE.C_DT_OUTSIDE_CTRL_DEFAULT PARAM_VALUE.C_DT_OUTSIDE_CTRL_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DT_OUTSIDE_CTRL_DEFAULT}] ${MODELPARAM_VALUE.C_DT_OUTSIDE_CTRL_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_WC_OUTSIDE_CTRL_DEFAULT { MODELPARAM_VALUE.C_WC_OUTSIDE_CTRL_DEFAULT PARAM_VALUE.C_WC_OUTSIDE_CTRL_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_WC_OUTSIDE_CTRL_DEFAULT}] ${MODELPARAM_VALUE.C_WC_OUTSIDE_CTRL_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_VC_OUTSIDE_CTRL_DEFAULT { MODELPARAM_VALUE.C_VC_OUTSIDE_CTRL_DEFAULT PARAM_VALUE.C_VC_OUTSIDE_CTRL_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VC_OUTSIDE_CTRL_DEFAULT}] ${MODELPARAM_VALUE.C_VC_OUTSIDE_CTRL_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_ILA_AXIS_CLK_ENABLE { MODELPARAM_VALUE.C_ILA_AXIS_CLK_ENABLE PARAM_VALUE.C_ILA_AXIS_CLK_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ILA_AXIS_CLK_ENABLE}] ${MODELPARAM_VALUE.C_ILA_AXIS_CLK_ENABLE}
}

proc update_MODELPARAM_VALUE.C_ILA_PCLK_CLK_ENABLE { MODELPARAM_VALUE.C_ILA_PCLK_CLK_ENABLE PARAM_VALUE.C_ILA_PCLK_CLK_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ILA_PCLK_CLK_ENABLE}] ${MODELPARAM_VALUE.C_ILA_PCLK_CLK_ENABLE}
}

proc update_MODELPARAM_VALUE.C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT { MODELPARAM_VALUE.C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT PARAM_VALUE.C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT}] ${MODELPARAM_VALUE.C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT}
}

proc update_MODELPARAM_VALUE.C_ILA_AXILITE_CLK_ENABLE { MODELPARAM_VALUE.C_ILA_AXILITE_CLK_ENABLE PARAM_VALUE.C_ILA_AXILITE_CLK_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ILA_AXILITE_CLK_ENABLE}] ${MODELPARAM_VALUE.C_ILA_AXILITE_CLK_ENABLE}
}

