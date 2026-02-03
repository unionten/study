# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {Base}]
  ipgui::add_param $IPINST -name "C_LB_ENABLE" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_RD_LINE_BY_LINE_EN" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_LITE_ADDR_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_LITE_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI4_ADDR_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI4_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_FRAME_BYTE_NUM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FRAME_BUF_NUM" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_DMA_BURST_LEN" -parent ${Page_0} -widget comboBox
  set C_RD_NORM_DATA_SOURCE [ipgui::add_param $IPINST -name "C_RD_NORM_DATA_SOURCE" -parent ${Page_0} -widget comboBox]
  set_property tooltip {0: ddr data 1: cycle ...} ${C_RD_NORM_DATA_SOURCE}
  ipgui::add_param $IPINST -name "C_RD_NORM_DATA_UNIT_BYTE_NUM" -parent ${Page_0} -widget comboBox

  #Adding Page
  set Default_Para [ipgui::add_page $IPINST -name "Default Para"]
  ipgui::add_param $IPINST -name "C_ENABLE_DEFAULT" -parent ${Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_DDR_BASE_ADDR" -parent ${Default_Para}
  ipgui::add_param $IPINST -name "C_STRIP_NUM_DEFAULT" -parent ${Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_STRIP_ID_DEFAULT" -parent ${Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_HACTIVE_DEFAULT" -parent ${Default_Para}
  ipgui::add_param $IPINST -name "C_VACTIVE_DEFAULT" -parent ${Default_Para}
  ipgui::add_param $IPINST -name "C_MEM_BYTES_DEFAULT" -parent ${Default_Para} -widget comboBox

  #Adding Page
  set ILA [ipgui::add_page $IPINST -name "ILA"]
  ipgui::add_param $IPINST -name "C_AXI_LITE_ILA_ENABLE" -parent ${ILA} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI4_ILA_ENABLE" -parent ${ILA} -widget comboBox

  #Adding Page
  set Sim [ipgui::add_page $IPINST -name "Sim"]
  ipgui::add_param $IPINST -name "C_RD_SIM_ENABLE" -parent ${Sim} -widget comboBox
  set C_RD_SIM_PATTERN_TYPE [ipgui::add_param $IPINST -name "C_RD_SIM_PATTERN_TYPE" -parent ${Sim} -widget comboBox]
  set_property tooltip {0£ºall 0  1:cycle 2  ...} ${C_RD_SIM_PATTERN_TYPE}
  ipgui::add_param $IPINST -name "C_RD_SIM_PATTERN_UNIT_BYTE_NUM" -parent ${Sim} -widget comboBox
  ipgui::add_param $IPINST -name "C_SIM_INTERVAL_NUM" -parent ${Sim}


}

proc update_PARAM_VALUE.C_AXI4_ADDR_WIDTH { PARAM_VALUE.C_AXI4_ADDR_WIDTH } {
	# Procedure called to update C_AXI4_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI4_ADDR_WIDTH { PARAM_VALUE.C_AXI4_ADDR_WIDTH } {
	# Procedure called to validate C_AXI4_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI4_DATA_WIDTH { PARAM_VALUE.C_AXI4_DATA_WIDTH } {
	# Procedure called to update C_AXI4_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI4_DATA_WIDTH { PARAM_VALUE.C_AXI4_DATA_WIDTH } {
	# Procedure called to validate C_AXI4_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI4_ILA_ENABLE { PARAM_VALUE.C_AXI4_ILA_ENABLE } {
	# Procedure called to update C_AXI4_ILA_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI4_ILA_ENABLE { PARAM_VALUE.C_AXI4_ILA_ENABLE } {
	# Procedure called to validate C_AXI4_ILA_ENABLE
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

proc update_PARAM_VALUE.C_AXI_LITE_ILA_ENABLE { PARAM_VALUE.C_AXI_LITE_ILA_ENABLE } {
	# Procedure called to update C_AXI_LITE_ILA_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_LITE_ILA_ENABLE { PARAM_VALUE.C_AXI_LITE_ILA_ENABLE } {
	# Procedure called to validate C_AXI_LITE_ILA_ENABLE
	return true
}

proc update_PARAM_VALUE.C_DDR_BASE_ADDR { PARAM_VALUE.C_DDR_BASE_ADDR } {
	# Procedure called to update C_DDR_BASE_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DDR_BASE_ADDR { PARAM_VALUE.C_DDR_BASE_ADDR } {
	# Procedure called to validate C_DDR_BASE_ADDR
	return true
}

proc update_PARAM_VALUE.C_DMA_BURST_LEN { PARAM_VALUE.C_DMA_BURST_LEN } {
	# Procedure called to update C_DMA_BURST_LEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DMA_BURST_LEN { PARAM_VALUE.C_DMA_BURST_LEN } {
	# Procedure called to validate C_DMA_BURST_LEN
	return true
}

proc update_PARAM_VALUE.C_ENABLE_DEFAULT { PARAM_VALUE.C_ENABLE_DEFAULT } {
	# Procedure called to update C_ENABLE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ENABLE_DEFAULT { PARAM_VALUE.C_ENABLE_DEFAULT } {
	# Procedure called to validate C_ENABLE_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FRAME_BUF_NUM { PARAM_VALUE.C_FRAME_BUF_NUM } {
	# Procedure called to update C_FRAME_BUF_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FRAME_BUF_NUM { PARAM_VALUE.C_FRAME_BUF_NUM } {
	# Procedure called to validate C_FRAME_BUF_NUM
	return true
}

proc update_PARAM_VALUE.C_FRAME_BYTE_NUM { PARAM_VALUE.C_FRAME_BYTE_NUM } {
	# Procedure called to update C_FRAME_BYTE_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FRAME_BYTE_NUM { PARAM_VALUE.C_FRAME_BYTE_NUM } {
	# Procedure called to validate C_FRAME_BYTE_NUM
	return true
}

proc update_PARAM_VALUE.C_FRAME_OFFSET_ADDR { PARAM_VALUE.C_FRAME_OFFSET_ADDR } {
	# Procedure called to update C_FRAME_OFFSET_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FRAME_OFFSET_ADDR { PARAM_VALUE.C_FRAME_OFFSET_ADDR } {
	# Procedure called to validate C_FRAME_OFFSET_ADDR
	return true
}

proc update_PARAM_VALUE.C_HACTIVE_DEFAULT { PARAM_VALUE.C_HACTIVE_DEFAULT } {
	# Procedure called to update C_HACTIVE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_HACTIVE_DEFAULT { PARAM_VALUE.C_HACTIVE_DEFAULT } {
	# Procedure called to validate C_HACTIVE_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_LB_ENABLE { PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to update C_LB_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_LB_ENABLE { PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to validate C_LB_ENABLE
	return true
}

proc update_PARAM_VALUE.C_MEM_BYTES_DEFAULT { PARAM_VALUE.C_MEM_BYTES_DEFAULT } {
	# Procedure called to update C_MEM_BYTES_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MEM_BYTES_DEFAULT { PARAM_VALUE.C_MEM_BYTES_DEFAULT } {
	# Procedure called to validate C_MEM_BYTES_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_RD_LINE_BY_LINE_EN { PARAM_VALUE.C_RD_LINE_BY_LINE_EN } {
	# Procedure called to update C_RD_LINE_BY_LINE_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_RD_LINE_BY_LINE_EN { PARAM_VALUE.C_RD_LINE_BY_LINE_EN } {
	# Procedure called to validate C_RD_LINE_BY_LINE_EN
	return true
}

proc update_PARAM_VALUE.C_RD_NORM_DATA_SOURCE { PARAM_VALUE.C_RD_NORM_DATA_SOURCE } {
	# Procedure called to update C_RD_NORM_DATA_SOURCE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_RD_NORM_DATA_SOURCE { PARAM_VALUE.C_RD_NORM_DATA_SOURCE } {
	# Procedure called to validate C_RD_NORM_DATA_SOURCE
	return true
}

proc update_PARAM_VALUE.C_RD_NORM_DATA_UNIT_BYTE_NUM { PARAM_VALUE.C_RD_NORM_DATA_UNIT_BYTE_NUM } {
	# Procedure called to update C_RD_NORM_DATA_UNIT_BYTE_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_RD_NORM_DATA_UNIT_BYTE_NUM { PARAM_VALUE.C_RD_NORM_DATA_UNIT_BYTE_NUM } {
	# Procedure called to validate C_RD_NORM_DATA_UNIT_BYTE_NUM
	return true
}

proc update_PARAM_VALUE.C_RD_SIM_ENABLE { PARAM_VALUE.C_RD_SIM_ENABLE } {
	# Procedure called to update C_RD_SIM_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_RD_SIM_ENABLE { PARAM_VALUE.C_RD_SIM_ENABLE } {
	# Procedure called to validate C_RD_SIM_ENABLE
	return true
}

proc update_PARAM_VALUE.C_RD_SIM_PATTERN_TYPE { PARAM_VALUE.C_RD_SIM_PATTERN_TYPE } {
	# Procedure called to update C_RD_SIM_PATTERN_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_RD_SIM_PATTERN_TYPE { PARAM_VALUE.C_RD_SIM_PATTERN_TYPE } {
	# Procedure called to validate C_RD_SIM_PATTERN_TYPE
	return true
}

proc update_PARAM_VALUE.C_RD_SIM_PATTERN_UNIT_BYTE_NUM { PARAM_VALUE.C_RD_SIM_PATTERN_UNIT_BYTE_NUM } {
	# Procedure called to update C_RD_SIM_PATTERN_UNIT_BYTE_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_RD_SIM_PATTERN_UNIT_BYTE_NUM { PARAM_VALUE.C_RD_SIM_PATTERN_UNIT_BYTE_NUM } {
	# Procedure called to validate C_RD_SIM_PATTERN_UNIT_BYTE_NUM
	return true
}

proc update_PARAM_VALUE.C_SIM_INTERVAL_NUM { PARAM_VALUE.C_SIM_INTERVAL_NUM } {
	# Procedure called to update C_SIM_INTERVAL_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SIM_INTERVAL_NUM { PARAM_VALUE.C_SIM_INTERVAL_NUM } {
	# Procedure called to validate C_SIM_INTERVAL_NUM
	return true
}

proc update_PARAM_VALUE.C_STRIP_ID_DEFAULT { PARAM_VALUE.C_STRIP_ID_DEFAULT } {
	# Procedure called to update C_STRIP_ID_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_STRIP_ID_DEFAULT { PARAM_VALUE.C_STRIP_ID_DEFAULT } {
	# Procedure called to validate C_STRIP_ID_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_STRIP_NUM_DEFAULT { PARAM_VALUE.C_STRIP_NUM_DEFAULT } {
	# Procedure called to update C_STRIP_NUM_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_STRIP_NUM_DEFAULT { PARAM_VALUE.C_STRIP_NUM_DEFAULT } {
	# Procedure called to validate C_STRIP_NUM_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_VACTIVE_DEFAULT { PARAM_VALUE.C_VACTIVE_DEFAULT } {
	# Procedure called to update C_VACTIVE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VACTIVE_DEFAULT { PARAM_VALUE.C_VACTIVE_DEFAULT } {
	# Procedure called to validate C_VACTIVE_DEFAULT
	return true
}


proc update_MODELPARAM_VALUE.C_DMA_BURST_LEN { MODELPARAM_VALUE.C_DMA_BURST_LEN PARAM_VALUE.C_DMA_BURST_LEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DMA_BURST_LEN}] ${MODELPARAM_VALUE.C_DMA_BURST_LEN}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH PARAM_VALUE.C_AXI_LITE_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI4_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI4_ADDR_WIDTH PARAM_VALUE.C_AXI4_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI4_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI4_DATA_WIDTH { MODELPARAM_VALUE.C_AXI4_DATA_WIDTH PARAM_VALUE.C_AXI4_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI4_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_ILA_ENABLE { MODELPARAM_VALUE.C_AXI_LITE_ILA_ENABLE PARAM_VALUE.C_AXI_LITE_ILA_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_ILA_ENABLE}] ${MODELPARAM_VALUE.C_AXI_LITE_ILA_ENABLE}
}

proc update_MODELPARAM_VALUE.C_AXI4_ILA_ENABLE { MODELPARAM_VALUE.C_AXI4_ILA_ENABLE PARAM_VALUE.C_AXI4_ILA_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_ILA_ENABLE}] ${MODELPARAM_VALUE.C_AXI4_ILA_ENABLE}
}

proc update_MODELPARAM_VALUE.C_DDR_BASE_ADDR { MODELPARAM_VALUE.C_DDR_BASE_ADDR PARAM_VALUE.C_DDR_BASE_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DDR_BASE_ADDR}] ${MODELPARAM_VALUE.C_DDR_BASE_ADDR}
}

proc update_MODELPARAM_VALUE.C_FRAME_OFFSET_ADDR { MODELPARAM_VALUE.C_FRAME_OFFSET_ADDR PARAM_VALUE.C_FRAME_OFFSET_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FRAME_OFFSET_ADDR}] ${MODELPARAM_VALUE.C_FRAME_OFFSET_ADDR}
}

proc update_MODELPARAM_VALUE.C_FRAME_BUF_NUM { MODELPARAM_VALUE.C_FRAME_BUF_NUM PARAM_VALUE.C_FRAME_BUF_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FRAME_BUF_NUM}] ${MODELPARAM_VALUE.C_FRAME_BUF_NUM}
}

proc update_MODELPARAM_VALUE.C_FRAME_BYTE_NUM { MODELPARAM_VALUE.C_FRAME_BYTE_NUM PARAM_VALUE.C_FRAME_BYTE_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FRAME_BYTE_NUM}] ${MODELPARAM_VALUE.C_FRAME_BYTE_NUM}
}

proc update_MODELPARAM_VALUE.C_ENABLE_DEFAULT { MODELPARAM_VALUE.C_ENABLE_DEFAULT PARAM_VALUE.C_ENABLE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ENABLE_DEFAULT}] ${MODELPARAM_VALUE.C_ENABLE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_MEM_BYTES_DEFAULT { MODELPARAM_VALUE.C_MEM_BYTES_DEFAULT PARAM_VALUE.C_MEM_BYTES_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MEM_BYTES_DEFAULT}] ${MODELPARAM_VALUE.C_MEM_BYTES_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_HACTIVE_DEFAULT { MODELPARAM_VALUE.C_HACTIVE_DEFAULT PARAM_VALUE.C_HACTIVE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_HACTIVE_DEFAULT}] ${MODELPARAM_VALUE.C_HACTIVE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_VACTIVE_DEFAULT { MODELPARAM_VALUE.C_VACTIVE_DEFAULT PARAM_VALUE.C_VACTIVE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VACTIVE_DEFAULT}] ${MODELPARAM_VALUE.C_VACTIVE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_STRIP_NUM_DEFAULT { MODELPARAM_VALUE.C_STRIP_NUM_DEFAULT PARAM_VALUE.C_STRIP_NUM_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_STRIP_NUM_DEFAULT}] ${MODELPARAM_VALUE.C_STRIP_NUM_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_STRIP_ID_DEFAULT { MODELPARAM_VALUE.C_STRIP_ID_DEFAULT PARAM_VALUE.C_STRIP_ID_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_STRIP_ID_DEFAULT}] ${MODELPARAM_VALUE.C_STRIP_ID_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_RD_SIM_ENABLE { MODELPARAM_VALUE.C_RD_SIM_ENABLE PARAM_VALUE.C_RD_SIM_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_RD_SIM_ENABLE}] ${MODELPARAM_VALUE.C_RD_SIM_ENABLE}
}

proc update_MODELPARAM_VALUE.C_RD_NORM_DATA_SOURCE { MODELPARAM_VALUE.C_RD_NORM_DATA_SOURCE PARAM_VALUE.C_RD_NORM_DATA_SOURCE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_RD_NORM_DATA_SOURCE}] ${MODELPARAM_VALUE.C_RD_NORM_DATA_SOURCE}
}

proc update_MODELPARAM_VALUE.C_RD_NORM_DATA_UNIT_BYTE_NUM { MODELPARAM_VALUE.C_RD_NORM_DATA_UNIT_BYTE_NUM PARAM_VALUE.C_RD_NORM_DATA_UNIT_BYTE_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_RD_NORM_DATA_UNIT_BYTE_NUM}] ${MODELPARAM_VALUE.C_RD_NORM_DATA_UNIT_BYTE_NUM}
}

proc update_MODELPARAM_VALUE.C_LB_ENABLE { MODELPARAM_VALUE.C_LB_ENABLE PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_LB_ENABLE}] ${MODELPARAM_VALUE.C_LB_ENABLE}
}

proc update_MODELPARAM_VALUE.C_RD_SIM_PATTERN_TYPE { MODELPARAM_VALUE.C_RD_SIM_PATTERN_TYPE PARAM_VALUE.C_RD_SIM_PATTERN_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_RD_SIM_PATTERN_TYPE}] ${MODELPARAM_VALUE.C_RD_SIM_PATTERN_TYPE}
}

proc update_MODELPARAM_VALUE.C_RD_SIM_PATTERN_UNIT_BYTE_NUM { MODELPARAM_VALUE.C_RD_SIM_PATTERN_UNIT_BYTE_NUM PARAM_VALUE.C_RD_SIM_PATTERN_UNIT_BYTE_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_RD_SIM_PATTERN_UNIT_BYTE_NUM}] ${MODELPARAM_VALUE.C_RD_SIM_PATTERN_UNIT_BYTE_NUM}
}

proc update_MODELPARAM_VALUE.C_SIM_INTERVAL_NUM { MODELPARAM_VALUE.C_SIM_INTERVAL_NUM PARAM_VALUE.C_SIM_INTERVAL_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SIM_INTERVAL_NUM}] ${MODELPARAM_VALUE.C_SIM_INTERVAL_NUM}
}

proc update_MODELPARAM_VALUE.C_RD_LINE_BY_LINE_EN { MODELPARAM_VALUE.C_RD_LINE_BY_LINE_EN PARAM_VALUE.C_RD_LINE_BY_LINE_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_RD_LINE_BY_LINE_EN}] ${MODELPARAM_VALUE.C_RD_LINE_BY_LINE_EN}
}

