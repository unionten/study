# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {Base}]
  set C_FIXED_MAX_PARA [ipgui::add_param $IPINST -name "C_FIXED_MAX_PARA" -parent ${Page_0} -widget comboBox]
  set_property tooltip {when en, bpc mem byte andport num will be fixed to max para, ignoring default paras} ${C_FIXED_MAX_PARA}
  ipgui::add_param $IPINST -name "C_LB_ENABLE" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_RD_LINE_BY_LINE_EN" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_LITE_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI_LITE_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI4_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI4_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_MAX_PORT_NUM" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_MAX_BPC" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_MAX_MEM_BYTES" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_DDR_BASE_ADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FRAME_OFFSET_ADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FRAME_BYTE_NUM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FRAME_BUF_NUM" -parent ${Page_0}
  set C_CSC_RGB2YUV_ENABLE [ipgui::add_param $IPINST -name "C_CSC_RGB2YUV_ENABLE" -parent ${Page_0}]
  set_property tooltip {CSC RGB2YUV Enable(all YUV)} ${C_CSC_RGB2YUV_ENABLE}
  ipgui::add_param $IPINST -name "C_CSC_FIFO_ENABLE" -parent ${Page_0}

  #Adding Page
  set Simulation] [ipgui::add_page $IPINST -name "Simulation]" -display_name {DDR}]
  set_property tooltip {Simulation} ${Simulation]}
  ipgui::add_param $IPINST -name "C_DDR_BURST_LEN" -parent ${Simulation]} -widget comboBox
  ipgui::add_param $IPINST -name "C_DDR_WR_SIM_ENABLE" -parent ${Simulation]}

  #Adding Page
  set Default_Para [ipgui::add_page $IPINST -name "Default Para"]
  ipgui::add_param $IPINST -name "C_ENABLE_DEFAULT" -parent ${Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_PORT_NUM_DEFAULT" -parent ${Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_COLOR_DEPTH_DEFAULT" -parent ${Default_Para} -widget comboBox
  set C_COLOR_SPACE_DEFAULT [ipgui::add_param $IPINST -name "C_COLOR_SPACE_DEFAULT" -parent ${Default_Para} -widget comboBox]
  set_property tooltip {0:rgb 1:yuv888 2:yuv422 3:yuv420} ${C_COLOR_SPACE_DEFAULT}
  ipgui::add_param $IPINST -name "C_MEM_BYTES_DEFAULT" -parent ${Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_STRIP_NUM_DEFAULT" -parent ${Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_STRIP_ID_DEFAULT" -parent ${Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_HACTIVE_DEFAULT" -parent ${Default_Para}
  ipgui::add_param $IPINST -name "C_VACTIVE_DEFAULT" -parent ${Default_Para}

  #Adding Page
  set Debug [ipgui::add_page $IPINST -name "Debug"]
  ipgui::add_param $IPINST -name "C_PCLK_ILA_ENABLE" -parent ${Debug}
  ipgui::add_param $IPINST -name "C_AXI_LITE_ILA_ENABLE" -parent ${Debug}
  ipgui::add_param $IPINST -name "C_AXI4_ILA_ENABLE" -parent ${Debug}

  #Adding Page
  set Use_Help [ipgui::add_page $IPINST -name "Use Help" -display_name {Reg Space}]
  set_property tooltip {Reg Space} ${Use_Help}
  ipgui::add_static_text $IPINST -name "reg space" -parent ${Use_Help} -text {old reg space}

  #Adding Page
  set Hse_Help [ipgui::add_page $IPINST -name "Hse Help"]
  ipgui::add_static_text $IPINST -name "use help" -parent ${Hse_Help} -text {1 ddr master will not response immediately if its op has not been done
2 now only support 8 color depth 
3 vs and not_locked will exit current burst , current trig ,and current top state
  then everything will return to idle and wait for next VS}


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

proc update_PARAM_VALUE.C_COLOR_DEPTH_DEFAULT { PARAM_VALUE.C_COLOR_DEPTH_DEFAULT } {
	# Procedure called to update C_COLOR_DEPTH_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_COLOR_DEPTH_DEFAULT { PARAM_VALUE.C_COLOR_DEPTH_DEFAULT } {
	# Procedure called to validate C_COLOR_DEPTH_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_COLOR_SPACE_DEFAULT { PARAM_VALUE.C_COLOR_SPACE_DEFAULT } {
	# Procedure called to update C_COLOR_SPACE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_COLOR_SPACE_DEFAULT { PARAM_VALUE.C_COLOR_SPACE_DEFAULT } {
	# Procedure called to validate C_COLOR_SPACE_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_CSC_FIFO_ENABLE { PARAM_VALUE.C_CSC_FIFO_ENABLE } {
	# Procedure called to update C_CSC_FIFO_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CSC_FIFO_ENABLE { PARAM_VALUE.C_CSC_FIFO_ENABLE } {
	# Procedure called to validate C_CSC_FIFO_ENABLE
	return true
}

proc update_PARAM_VALUE.C_CSC_RGB2YUV_ENABLE { PARAM_VALUE.C_CSC_RGB2YUV_ENABLE } {
	# Procedure called to update C_CSC_RGB2YUV_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CSC_RGB2YUV_ENABLE { PARAM_VALUE.C_CSC_RGB2YUV_ENABLE } {
	# Procedure called to validate C_CSC_RGB2YUV_ENABLE
	return true
}

proc update_PARAM_VALUE.C_DDR_BASE_ADDR { PARAM_VALUE.C_DDR_BASE_ADDR } {
	# Procedure called to update C_DDR_BASE_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DDR_BASE_ADDR { PARAM_VALUE.C_DDR_BASE_ADDR } {
	# Procedure called to validate C_DDR_BASE_ADDR
	return true
}

proc update_PARAM_VALUE.C_DDR_BURST_LEN { PARAM_VALUE.C_DDR_BURST_LEN } {
	# Procedure called to update C_DDR_BURST_LEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DDR_BURST_LEN { PARAM_VALUE.C_DDR_BURST_LEN } {
	# Procedure called to validate C_DDR_BURST_LEN
	return true
}

proc update_PARAM_VALUE.C_DDR_WR_SIM_ENABLE { PARAM_VALUE.C_DDR_WR_SIM_ENABLE } {
	# Procedure called to update C_DDR_WR_SIM_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DDR_WR_SIM_ENABLE { PARAM_VALUE.C_DDR_WR_SIM_ENABLE } {
	# Procedure called to validate C_DDR_WR_SIM_ENABLE
	return true
}

proc update_PARAM_VALUE.C_ENABLE_DEFAULT { PARAM_VALUE.C_ENABLE_DEFAULT } {
	# Procedure called to update C_ENABLE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ENABLE_DEFAULT { PARAM_VALUE.C_ENABLE_DEFAULT } {
	# Procedure called to validate C_ENABLE_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FIXED_MAX_PARA { PARAM_VALUE.C_FIXED_MAX_PARA } {
	# Procedure called to update C_FIXED_MAX_PARA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FIXED_MAX_PARA { PARAM_VALUE.C_FIXED_MAX_PARA } {
	# Procedure called to validate C_FIXED_MAX_PARA
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

proc update_PARAM_VALUE.C_MAX_BPC { PARAM_VALUE.C_MAX_BPC } {
	# Procedure called to update C_MAX_BPC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MAX_BPC { PARAM_VALUE.C_MAX_BPC } {
	# Procedure called to validate C_MAX_BPC
	return true
}

proc update_PARAM_VALUE.C_MAX_MEM_BYTES { PARAM_VALUE.C_MAX_MEM_BYTES } {
	# Procedure called to update C_MAX_MEM_BYTES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MAX_MEM_BYTES { PARAM_VALUE.C_MAX_MEM_BYTES } {
	# Procedure called to validate C_MAX_MEM_BYTES
	return true
}

proc update_PARAM_VALUE.C_MAX_PORT_NUM { PARAM_VALUE.C_MAX_PORT_NUM } {
	# Procedure called to update C_MAX_PORT_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MAX_PORT_NUM { PARAM_VALUE.C_MAX_PORT_NUM } {
	# Procedure called to validate C_MAX_PORT_NUM
	return true
}

proc update_PARAM_VALUE.C_MEM_BYTES_DEFAULT { PARAM_VALUE.C_MEM_BYTES_DEFAULT } {
	# Procedure called to update C_MEM_BYTES_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MEM_BYTES_DEFAULT { PARAM_VALUE.C_MEM_BYTES_DEFAULT } {
	# Procedure called to validate C_MEM_BYTES_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_PCLK_ILA_ENABLE { PARAM_VALUE.C_PCLK_ILA_ENABLE } {
	# Procedure called to update C_PCLK_ILA_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PCLK_ILA_ENABLE { PARAM_VALUE.C_PCLK_ILA_ENABLE } {
	# Procedure called to validate C_PCLK_ILA_ENABLE
	return true
}

proc update_PARAM_VALUE.C_PORT_NUM_DEFAULT { PARAM_VALUE.C_PORT_NUM_DEFAULT } {
	# Procedure called to update C_PORT_NUM_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PORT_NUM_DEFAULT { PARAM_VALUE.C_PORT_NUM_DEFAULT } {
	# Procedure called to validate C_PORT_NUM_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_RD_LINE_BY_LINE_EN { PARAM_VALUE.C_RD_LINE_BY_LINE_EN } {
	# Procedure called to update C_RD_LINE_BY_LINE_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_RD_LINE_BY_LINE_EN { PARAM_VALUE.C_RD_LINE_BY_LINE_EN } {
	# Procedure called to validate C_RD_LINE_BY_LINE_EN
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


proc update_MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH PARAM_VALUE.C_AXI_LITE_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI4_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI4_ADDR_WIDTH PARAM_VALUE.C_AXI4_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI4_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI4_DATA_WIDTH { MODELPARAM_VALUE.C_AXI4_DATA_WIDTH PARAM_VALUE.C_AXI4_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI4_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_MAX_PORT_NUM { MODELPARAM_VALUE.C_MAX_PORT_NUM PARAM_VALUE.C_MAX_PORT_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MAX_PORT_NUM}] ${MODELPARAM_VALUE.C_MAX_PORT_NUM}
}

proc update_MODELPARAM_VALUE.C_MAX_BPC { MODELPARAM_VALUE.C_MAX_BPC PARAM_VALUE.C_MAX_BPC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MAX_BPC}] ${MODELPARAM_VALUE.C_MAX_BPC}
}

proc update_MODELPARAM_VALUE.C_DDR_BASE_ADDR { MODELPARAM_VALUE.C_DDR_BASE_ADDR PARAM_VALUE.C_DDR_BASE_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DDR_BASE_ADDR}] ${MODELPARAM_VALUE.C_DDR_BASE_ADDR}
}

proc update_MODELPARAM_VALUE.C_FRAME_OFFSET_ADDR { MODELPARAM_VALUE.C_FRAME_OFFSET_ADDR PARAM_VALUE.C_FRAME_OFFSET_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FRAME_OFFSET_ADDR}] ${MODELPARAM_VALUE.C_FRAME_OFFSET_ADDR}
}

proc update_MODELPARAM_VALUE.C_FRAME_BYTE_NUM { MODELPARAM_VALUE.C_FRAME_BYTE_NUM PARAM_VALUE.C_FRAME_BYTE_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FRAME_BYTE_NUM}] ${MODELPARAM_VALUE.C_FRAME_BYTE_NUM}
}

proc update_MODELPARAM_VALUE.C_FRAME_BUF_NUM { MODELPARAM_VALUE.C_FRAME_BUF_NUM PARAM_VALUE.C_FRAME_BUF_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FRAME_BUF_NUM}] ${MODELPARAM_VALUE.C_FRAME_BUF_NUM}
}

proc update_MODELPARAM_VALUE.C_MAX_MEM_BYTES { MODELPARAM_VALUE.C_MAX_MEM_BYTES PARAM_VALUE.C_MAX_MEM_BYTES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MAX_MEM_BYTES}] ${MODELPARAM_VALUE.C_MAX_MEM_BYTES}
}

proc update_MODELPARAM_VALUE.C_CSC_RGB2YUV_ENABLE { MODELPARAM_VALUE.C_CSC_RGB2YUV_ENABLE PARAM_VALUE.C_CSC_RGB2YUV_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CSC_RGB2YUV_ENABLE}] ${MODELPARAM_VALUE.C_CSC_RGB2YUV_ENABLE}
}

proc update_MODELPARAM_VALUE.C_CSC_FIFO_ENABLE { MODELPARAM_VALUE.C_CSC_FIFO_ENABLE PARAM_VALUE.C_CSC_FIFO_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CSC_FIFO_ENABLE}] ${MODELPARAM_VALUE.C_CSC_FIFO_ENABLE}
}

proc update_MODELPARAM_VALUE.C_DDR_WR_SIM_ENABLE { MODELPARAM_VALUE.C_DDR_WR_SIM_ENABLE PARAM_VALUE.C_DDR_WR_SIM_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DDR_WR_SIM_ENABLE}] ${MODELPARAM_VALUE.C_DDR_WR_SIM_ENABLE}
}

proc update_MODELPARAM_VALUE.C_PCLK_ILA_ENABLE { MODELPARAM_VALUE.C_PCLK_ILA_ENABLE PARAM_VALUE.C_PCLK_ILA_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PCLK_ILA_ENABLE}] ${MODELPARAM_VALUE.C_PCLK_ILA_ENABLE}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_ILA_ENABLE { MODELPARAM_VALUE.C_AXI_LITE_ILA_ENABLE PARAM_VALUE.C_AXI_LITE_ILA_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_ILA_ENABLE}] ${MODELPARAM_VALUE.C_AXI_LITE_ILA_ENABLE}
}

proc update_MODELPARAM_VALUE.C_AXI4_ILA_ENABLE { MODELPARAM_VALUE.C_AXI4_ILA_ENABLE PARAM_VALUE.C_AXI4_ILA_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_ILA_ENABLE}] ${MODELPARAM_VALUE.C_AXI4_ILA_ENABLE}
}

proc update_MODELPARAM_VALUE.C_ENABLE_DEFAULT { MODELPARAM_VALUE.C_ENABLE_DEFAULT PARAM_VALUE.C_ENABLE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ENABLE_DEFAULT}] ${MODELPARAM_VALUE.C_ENABLE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_PORT_NUM_DEFAULT { MODELPARAM_VALUE.C_PORT_NUM_DEFAULT PARAM_VALUE.C_PORT_NUM_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PORT_NUM_DEFAULT}] ${MODELPARAM_VALUE.C_PORT_NUM_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_COLOR_DEPTH_DEFAULT { MODELPARAM_VALUE.C_COLOR_DEPTH_DEFAULT PARAM_VALUE.C_COLOR_DEPTH_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_COLOR_DEPTH_DEFAULT}] ${MODELPARAM_VALUE.C_COLOR_DEPTH_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_COLOR_SPACE_DEFAULT { MODELPARAM_VALUE.C_COLOR_SPACE_DEFAULT PARAM_VALUE.C_COLOR_SPACE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_COLOR_SPACE_DEFAULT}] ${MODELPARAM_VALUE.C_COLOR_SPACE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_MEM_BYTES_DEFAULT { MODELPARAM_VALUE.C_MEM_BYTES_DEFAULT PARAM_VALUE.C_MEM_BYTES_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MEM_BYTES_DEFAULT}] ${MODELPARAM_VALUE.C_MEM_BYTES_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_STRIP_NUM_DEFAULT { MODELPARAM_VALUE.C_STRIP_NUM_DEFAULT PARAM_VALUE.C_STRIP_NUM_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_STRIP_NUM_DEFAULT}] ${MODELPARAM_VALUE.C_STRIP_NUM_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_STRIP_ID_DEFAULT { MODELPARAM_VALUE.C_STRIP_ID_DEFAULT PARAM_VALUE.C_STRIP_ID_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_STRIP_ID_DEFAULT}] ${MODELPARAM_VALUE.C_STRIP_ID_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_HACTIVE_DEFAULT { MODELPARAM_VALUE.C_HACTIVE_DEFAULT PARAM_VALUE.C_HACTIVE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_HACTIVE_DEFAULT}] ${MODELPARAM_VALUE.C_HACTIVE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_VACTIVE_DEFAULT { MODELPARAM_VALUE.C_VACTIVE_DEFAULT PARAM_VALUE.C_VACTIVE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VACTIVE_DEFAULT}] ${MODELPARAM_VALUE.C_VACTIVE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_DDR_BURST_LEN { MODELPARAM_VALUE.C_DDR_BURST_LEN PARAM_VALUE.C_DDR_BURST_LEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DDR_BURST_LEN}] ${MODELPARAM_VALUE.C_DDR_BURST_LEN}
}

proc update_MODELPARAM_VALUE.C_LB_ENABLE { MODELPARAM_VALUE.C_LB_ENABLE PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_LB_ENABLE}] ${MODELPARAM_VALUE.C_LB_ENABLE}
}

proc update_MODELPARAM_VALUE.C_RD_LINE_BY_LINE_EN { MODELPARAM_VALUE.C_RD_LINE_BY_LINE_EN PARAM_VALUE.C_RD_LINE_BY_LINE_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_RD_LINE_BY_LINE_EN}] ${MODELPARAM_VALUE.C_RD_LINE_BY_LINE_EN}
}

proc update_MODELPARAM_VALUE.C_FIXED_MAX_PARA { MODELPARAM_VALUE.C_FIXED_MAX_PARA PARAM_VALUE.C_FIXED_MAX_PARA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FIXED_MAX_PARA}] ${MODELPARAM_VALUE.C_FIXED_MAX_PARA}
}

