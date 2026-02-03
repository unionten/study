# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_CLKPRD_DET_BLOCK_EN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_TIMEOUT_DET_BLOCK_EN" -parent ${Page_0}
  set C_VS_POLARITY [ipgui::add_param $IPINST -name "C_VS_POLARITY" -parent ${Page_0} -widget comboBox]
  set_property tooltip {default 0} ${C_VS_POLARITY}
  ipgui::add_param $IPINST -name "C_VS_NUM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI_LITE_ADDR_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_LITE_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_THRESHHOLD_CLKPRD_BW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_TIMEOUT_TIME_CLKNUM_BW" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_FSYNC_CNT_BW" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_CLK_PRD_NS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_TIMEOUT_TIME_US" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_EN_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_THRESHHOLD_CLKPRD_1_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_THRESHHOLD_CLKPRD_0_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_THRESHHOLD_CLKPRD_2_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_THRESHHOLD_CLKPRD_3_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_THRESHHOLD_CLKPRD_4_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_THRESHHOLD_CLKPRD_5_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_THRESHHOLD_CLKPRD_6_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_THRESHHOLD_CLKPRD_7_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_TIMES_0_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_TIMES_1_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_TIMES_2_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_TIMES_3_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_TIMES_4_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_TIMES_5_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_TIMES_6_DEFAULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FILTER_TIMES_7_DEFAULT" -parent ${Page_0}

  ipgui::add_param $IPINST -name "C_ILA_AXILITE_EN"

}

proc update_PARAM_VALUE.C_AXI_CLK_PRD_NS { PARAM_VALUE.C_AXI_CLK_PRD_NS } {
	# Procedure called to update C_AXI_CLK_PRD_NS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_CLK_PRD_NS { PARAM_VALUE.C_AXI_CLK_PRD_NS } {
	# Procedure called to validate C_AXI_CLK_PRD_NS
	return true
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

proc update_PARAM_VALUE.C_CLKPRD_DET_BLOCK_EN { PARAM_VALUE.C_CLKPRD_DET_BLOCK_EN } {
	# Procedure called to update C_CLKPRD_DET_BLOCK_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CLKPRD_DET_BLOCK_EN { PARAM_VALUE.C_CLKPRD_DET_BLOCK_EN } {
	# Procedure called to validate C_CLKPRD_DET_BLOCK_EN
	return true
}

proc update_PARAM_VALUE.C_FILTER_EN_DEFAULT { PARAM_VALUE.C_FILTER_EN_DEFAULT } {
	# Procedure called to update C_FILTER_EN_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_EN_DEFAULT { PARAM_VALUE.C_FILTER_EN_DEFAULT } {
	# Procedure called to validate C_FILTER_EN_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_0_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_0_DEFAULT } {
	# Procedure called to update C_FILTER_THRESHHOLD_CLKPRD_0_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_0_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_0_DEFAULT } {
	# Procedure called to validate C_FILTER_THRESHHOLD_CLKPRD_0_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_1_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_1_DEFAULT } {
	# Procedure called to update C_FILTER_THRESHHOLD_CLKPRD_1_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_1_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_1_DEFAULT } {
	# Procedure called to validate C_FILTER_THRESHHOLD_CLKPRD_1_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_2_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_2_DEFAULT } {
	# Procedure called to update C_FILTER_THRESHHOLD_CLKPRD_2_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_2_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_2_DEFAULT } {
	# Procedure called to validate C_FILTER_THRESHHOLD_CLKPRD_2_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_3_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_3_DEFAULT } {
	# Procedure called to update C_FILTER_THRESHHOLD_CLKPRD_3_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_3_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_3_DEFAULT } {
	# Procedure called to validate C_FILTER_THRESHHOLD_CLKPRD_3_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_4_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_4_DEFAULT } {
	# Procedure called to update C_FILTER_THRESHHOLD_CLKPRD_4_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_4_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_4_DEFAULT } {
	# Procedure called to validate C_FILTER_THRESHHOLD_CLKPRD_4_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_5_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_5_DEFAULT } {
	# Procedure called to update C_FILTER_THRESHHOLD_CLKPRD_5_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_5_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_5_DEFAULT } {
	# Procedure called to validate C_FILTER_THRESHHOLD_CLKPRD_5_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_6_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_6_DEFAULT } {
	# Procedure called to update C_FILTER_THRESHHOLD_CLKPRD_6_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_6_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_6_DEFAULT } {
	# Procedure called to validate C_FILTER_THRESHHOLD_CLKPRD_6_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_7_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_7_DEFAULT } {
	# Procedure called to update C_FILTER_THRESHHOLD_CLKPRD_7_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_7_DEFAULT { PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_7_DEFAULT } {
	# Procedure called to validate C_FILTER_THRESHHOLD_CLKPRD_7_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_TIMES_0_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_0_DEFAULT } {
	# Procedure called to update C_FILTER_TIMES_0_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_TIMES_0_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_0_DEFAULT } {
	# Procedure called to validate C_FILTER_TIMES_0_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_TIMES_1_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_1_DEFAULT } {
	# Procedure called to update C_FILTER_TIMES_1_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_TIMES_1_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_1_DEFAULT } {
	# Procedure called to validate C_FILTER_TIMES_1_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_TIMES_2_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_2_DEFAULT } {
	# Procedure called to update C_FILTER_TIMES_2_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_TIMES_2_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_2_DEFAULT } {
	# Procedure called to validate C_FILTER_TIMES_2_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_TIMES_3_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_3_DEFAULT } {
	# Procedure called to update C_FILTER_TIMES_3_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_TIMES_3_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_3_DEFAULT } {
	# Procedure called to validate C_FILTER_TIMES_3_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_TIMES_4_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_4_DEFAULT } {
	# Procedure called to update C_FILTER_TIMES_4_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_TIMES_4_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_4_DEFAULT } {
	# Procedure called to validate C_FILTER_TIMES_4_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_TIMES_5_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_5_DEFAULT } {
	# Procedure called to update C_FILTER_TIMES_5_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_TIMES_5_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_5_DEFAULT } {
	# Procedure called to validate C_FILTER_TIMES_5_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_TIMES_6_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_6_DEFAULT } {
	# Procedure called to update C_FILTER_TIMES_6_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_TIMES_6_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_6_DEFAULT } {
	# Procedure called to validate C_FILTER_TIMES_6_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FILTER_TIMES_7_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_7_DEFAULT } {
	# Procedure called to update C_FILTER_TIMES_7_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FILTER_TIMES_7_DEFAULT { PARAM_VALUE.C_FILTER_TIMES_7_DEFAULT } {
	# Procedure called to validate C_FILTER_TIMES_7_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FSYNC_CNT_BW { PARAM_VALUE.C_FSYNC_CNT_BW } {
	# Procedure called to update C_FSYNC_CNT_BW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FSYNC_CNT_BW { PARAM_VALUE.C_FSYNC_CNT_BW } {
	# Procedure called to validate C_FSYNC_CNT_BW
	return true
}

proc update_PARAM_VALUE.C_ILA_AXILITE_EN { PARAM_VALUE.C_ILA_AXILITE_EN } {
	# Procedure called to update C_ILA_AXILITE_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ILA_AXILITE_EN { PARAM_VALUE.C_ILA_AXILITE_EN } {
	# Procedure called to validate C_ILA_AXILITE_EN
	return true
}

proc update_PARAM_VALUE.C_THRESHHOLD_CLKPRD_BW { PARAM_VALUE.C_THRESHHOLD_CLKPRD_BW } {
	# Procedure called to update C_THRESHHOLD_CLKPRD_BW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_THRESHHOLD_CLKPRD_BW { PARAM_VALUE.C_THRESHHOLD_CLKPRD_BW } {
	# Procedure called to validate C_THRESHHOLD_CLKPRD_BW
	return true
}

proc update_PARAM_VALUE.C_TIMEOUT_DET_BLOCK_EN { PARAM_VALUE.C_TIMEOUT_DET_BLOCK_EN } {
	# Procedure called to update C_TIMEOUT_DET_BLOCK_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_TIMEOUT_DET_BLOCK_EN { PARAM_VALUE.C_TIMEOUT_DET_BLOCK_EN } {
	# Procedure called to validate C_TIMEOUT_DET_BLOCK_EN
	return true
}

proc update_PARAM_VALUE.C_TIMEOUT_TIME_CLKNUM_BW { PARAM_VALUE.C_TIMEOUT_TIME_CLKNUM_BW } {
	# Procedure called to update C_TIMEOUT_TIME_CLKNUM_BW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_TIMEOUT_TIME_CLKNUM_BW { PARAM_VALUE.C_TIMEOUT_TIME_CLKNUM_BW } {
	# Procedure called to validate C_TIMEOUT_TIME_CLKNUM_BW
	return true
}

proc update_PARAM_VALUE.C_TIMEOUT_TIME_US { PARAM_VALUE.C_TIMEOUT_TIME_US } {
	# Procedure called to update C_TIMEOUT_TIME_US when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_TIMEOUT_TIME_US { PARAM_VALUE.C_TIMEOUT_TIME_US } {
	# Procedure called to validate C_TIMEOUT_TIME_US
	return true
}

proc update_PARAM_VALUE.C_VS_NUM { PARAM_VALUE.C_VS_NUM } {
	# Procedure called to update C_VS_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VS_NUM { PARAM_VALUE.C_VS_NUM } {
	# Procedure called to validate C_VS_NUM
	return true
}

proc update_PARAM_VALUE.C_VS_POLARITY { PARAM_VALUE.C_VS_POLARITY } {
	# Procedure called to update C_VS_POLARITY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VS_POLARITY { PARAM_VALUE.C_VS_POLARITY } {
	# Procedure called to validate C_VS_POLARITY
	return true
}


proc update_MODELPARAM_VALUE.C_VS_NUM { MODELPARAM_VALUE.C_VS_NUM PARAM_VALUE.C_VS_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VS_NUM}] ${MODELPARAM_VALUE.C_VS_NUM}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH PARAM_VALUE.C_AXI_LITE_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_CLK_PRD_NS { MODELPARAM_VALUE.C_AXI_CLK_PRD_NS PARAM_VALUE.C_AXI_CLK_PRD_NS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_CLK_PRD_NS}] ${MODELPARAM_VALUE.C_AXI_CLK_PRD_NS}
}

proc update_MODELPARAM_VALUE.C_FILTER_EN_DEFAULT { MODELPARAM_VALUE.C_FILTER_EN_DEFAULT PARAM_VALUE.C_FILTER_EN_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_EN_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_EN_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_TIMES_0_DEFAULT { MODELPARAM_VALUE.C_FILTER_TIMES_0_DEFAULT PARAM_VALUE.C_FILTER_TIMES_0_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_TIMES_0_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_TIMES_0_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_TIMES_1_DEFAULT { MODELPARAM_VALUE.C_FILTER_TIMES_1_DEFAULT PARAM_VALUE.C_FILTER_TIMES_1_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_TIMES_1_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_TIMES_1_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_TIMES_2_DEFAULT { MODELPARAM_VALUE.C_FILTER_TIMES_2_DEFAULT PARAM_VALUE.C_FILTER_TIMES_2_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_TIMES_2_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_TIMES_2_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_TIMES_3_DEFAULT { MODELPARAM_VALUE.C_FILTER_TIMES_3_DEFAULT PARAM_VALUE.C_FILTER_TIMES_3_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_TIMES_3_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_TIMES_3_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_TIMES_4_DEFAULT { MODELPARAM_VALUE.C_FILTER_TIMES_4_DEFAULT PARAM_VALUE.C_FILTER_TIMES_4_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_TIMES_4_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_TIMES_4_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_TIMES_5_DEFAULT { MODELPARAM_VALUE.C_FILTER_TIMES_5_DEFAULT PARAM_VALUE.C_FILTER_TIMES_5_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_TIMES_5_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_TIMES_5_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_TIMES_6_DEFAULT { MODELPARAM_VALUE.C_FILTER_TIMES_6_DEFAULT PARAM_VALUE.C_FILTER_TIMES_6_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_TIMES_6_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_TIMES_6_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_TIMES_7_DEFAULT { MODELPARAM_VALUE.C_FILTER_TIMES_7_DEFAULT PARAM_VALUE.C_FILTER_TIMES_7_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_TIMES_7_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_TIMES_7_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_0_DEFAULT { MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_0_DEFAULT PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_0_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_0_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_0_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_1_DEFAULT { MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_1_DEFAULT PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_1_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_1_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_1_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_2_DEFAULT { MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_2_DEFAULT PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_2_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_2_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_2_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_3_DEFAULT { MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_3_DEFAULT PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_3_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_3_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_3_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_4_DEFAULT { MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_4_DEFAULT PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_4_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_4_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_4_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_5_DEFAULT { MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_5_DEFAULT PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_5_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_5_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_5_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_6_DEFAULT { MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_6_DEFAULT PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_6_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_6_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_6_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_7_DEFAULT { MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_7_DEFAULT PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_7_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_7_DEFAULT}] ${MODELPARAM_VALUE.C_FILTER_THRESHHOLD_CLKPRD_7_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_THRESHHOLD_CLKPRD_BW { MODELPARAM_VALUE.C_THRESHHOLD_CLKPRD_BW PARAM_VALUE.C_THRESHHOLD_CLKPRD_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_THRESHHOLD_CLKPRD_BW}] ${MODELPARAM_VALUE.C_THRESHHOLD_CLKPRD_BW}
}

proc update_MODELPARAM_VALUE.C_TIMEOUT_TIME_CLKNUM_BW { MODELPARAM_VALUE.C_TIMEOUT_TIME_CLKNUM_BW PARAM_VALUE.C_TIMEOUT_TIME_CLKNUM_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_TIMEOUT_TIME_CLKNUM_BW}] ${MODELPARAM_VALUE.C_TIMEOUT_TIME_CLKNUM_BW}
}

proc update_MODELPARAM_VALUE.C_TIMEOUT_TIME_US { MODELPARAM_VALUE.C_TIMEOUT_TIME_US PARAM_VALUE.C_TIMEOUT_TIME_US } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_TIMEOUT_TIME_US}] ${MODELPARAM_VALUE.C_TIMEOUT_TIME_US}
}

proc update_MODELPARAM_VALUE.C_FSYNC_CNT_BW { MODELPARAM_VALUE.C_FSYNC_CNT_BW PARAM_VALUE.C_FSYNC_CNT_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FSYNC_CNT_BW}] ${MODELPARAM_VALUE.C_FSYNC_CNT_BW}
}

proc update_MODELPARAM_VALUE.C_ILA_AXILITE_EN { MODELPARAM_VALUE.C_ILA_AXILITE_EN PARAM_VALUE.C_ILA_AXILITE_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ILA_AXILITE_EN}] ${MODELPARAM_VALUE.C_ILA_AXILITE_EN}
}

proc update_MODELPARAM_VALUE.C_CLKPRD_DET_BLOCK_EN { MODELPARAM_VALUE.C_CLKPRD_DET_BLOCK_EN PARAM_VALUE.C_CLKPRD_DET_BLOCK_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CLKPRD_DET_BLOCK_EN}] ${MODELPARAM_VALUE.C_CLKPRD_DET_BLOCK_EN}
}

proc update_MODELPARAM_VALUE.C_TIMEOUT_DET_BLOCK_EN { MODELPARAM_VALUE.C_TIMEOUT_DET_BLOCK_EN PARAM_VALUE.C_TIMEOUT_DET_BLOCK_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_TIMEOUT_DET_BLOCK_EN}] ${MODELPARAM_VALUE.C_TIMEOUT_DET_BLOCK_EN}
}

proc update_MODELPARAM_VALUE.C_VS_POLARITY { MODELPARAM_VALUE.C_VS_POLARITY PARAM_VALUE.C_VS_POLARITY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VS_POLARITY}] ${MODELPARAM_VALUE.C_VS_POLARITY}
}

