# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {Base}]
  ipgui::add_param $IPINST -name "C_LB_ENABLE" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_BLANK_EN" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_CONTAIN_DLY_CTRL" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_PCLK_DET_BLOCK_EN" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_DEVICE_TYPE" -parent ${Page_0} -widget comboBox
  set C_IMPL_MECHANISM [ipgui::add_param $IPINST -name "C_IMPL_MECHANISM" -parent ${Page_0} -widget comboBox]
  set_property tooltip {default:DDR} ${C_IMPL_MECHANISM}
  ipgui::add_param $IPINST -name "AXICLK_PRD_NS" -parent ${Page_0}
  set USE_PLL [ipgui::add_param $IPINST -name "USE_PLL" -parent ${Page_0} -widget comboBox]
  set_property tooltip {default: 0} ${USE_PLL}
  ipgui::add_param $IPINST -name "C_AXI_LITE_ADDR_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_LITE_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "PORT_NUM" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "LANE_NUM" -parent ${Page_0} -widget comboBox
  set REF_FREQ [ipgui::add_param $IPINST -name "REF_FREQ" -parent ${Page_0} -widget comboBox]
  set_property tooltip {REF Freq (MHz)} ${REF_FREQ}
  ipgui::add_param $IPINST -name "CLKIN_PERIOD" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "SAMPL_CLOCK" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "INTER_CLOCK" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "PIXEL_CLOCK" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_PIXEL_ARR_MODE" -parent ${Page_0} -widget comboBox
  ipgui::add_static_text $IPINST -name "help" -parent ${Page_0} -text {note: video locked and misaligned  is all masked by actual port num}

  #Adding Page
  set MISALIGN [ipgui::add_page $IPINST -name "MISALIGN"]
  ipgui::add_param $IPINST -name "DETECT_MISALLIGN" -parent ${MISALIGN} -widget comboBox
  ipgui::add_param $IPINST -name "C_MISALIGN_RST_THRESHOLD_PCLK_NUM" -parent ${MISALIGN}
  ipgui::add_param $IPINST -name "C_1TO7_RST_ACLK_NUM" -parent ${MISALIGN}
  ipgui::add_param $IPINST -name "C_MISALIGN_PCLK_PROTECT" -parent ${MISALIGN}

  #Adding Page
  set default_para [ipgui::add_page $IPINST -name "default para"]
  ipgui::add_param $IPINST -name "LVDS_ENABLE_DEFAULT" -parent ${default_para} -widget comboBox
  ipgui::add_param $IPINST -name "LVDS_CLK_PN_SWAP_DEFAULT" -parent ${default_para} -widget comboBox
  ipgui::add_param $IPINST -name "LVDS_DATAOUT_PN_SWAP_DEFAULT" -parent ${default_para} -widget comboBox
  set LVDS_LOCKED_PORT_NUM_DEFAULT [ipgui::add_param $IPINST -name "LVDS_LOCKED_PORT_NUM_DEFAULT" -parent ${default_para} -widget comboBox]
  set_property tooltip {only server for locked signal} ${LVDS_LOCKED_PORT_NUM_DEFAULT}
  ipgui::add_param $IPINST -name "PIXEL_ARR_MODE_DEFAULT" -parent ${default_para} -widget comboBox

  #Adding Page
  set ILA [ipgui::add_page $IPINST -name "ILA"]
  ipgui::add_param $IPINST -name "ACLK_ILA_ENABLE" -parent ${ILA}
  ipgui::add_param $IPINST -name "PCLK_ILA_ENABLE" -parent ${ILA}
  ipgui::add_param $IPINST -name "DESKEW_ILA_ENABLE" -parent ${ILA}

  #Adding Page
  set reg_space [ipgui::add_page $IPINST -name "reg space"]
  ipgui::add_static_text $IPINST -name "reg_space2" -parent ${reg_space} -text {ADDR_ENABLE         0x0000

ADDR_CLK_PN_SWAP    0x0004

ADDR_DATAIN_PN_SWAP   0x0008

ADDR_DATAOUT_PN_SWAP   0x000c

ADDR_PORT_NUM 0x0010

ADDR_STATUS_DBG              0x0014  DETECT_MISALLIGN, rx_mmcm_lckdpsbs_m__aclk,  3b000,mmcm_locked__aclk,3b000,rx_pixel_clk_locked__aclk
ADDR_MIS_ALIGNED_ACCUS_DBG   0x0018
ADDR_MIS_ALIGNED_ROUNDS_DBG  0x001c
ADDR_MIS_ALIGNED_RETRYS_DBG  0x0020
ADDR_PCLK_MHZ_DBG            0x0024}

  #Adding Page
  set ulitity [ipgui::add_page $IPINST -name "ulitity"]
  ipgui::add_static_text $IPINST -name "utility 0" -parent ${ulitity} -text {perm clk is used for misalign block
port_num reg is only used for video locked output
port_num reg dont influence actual hard structure

MODULE_ENABLE_O ~ axi clk}


}

proc update_PARAM_VALUE.ACLK_ILA_ENABLE { PARAM_VALUE.ACLK_ILA_ENABLE } {
	# Procedure called to update ACLK_ILA_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ACLK_ILA_ENABLE { PARAM_VALUE.ACLK_ILA_ENABLE } {
	# Procedure called to validate ACLK_ILA_ENABLE
	return true
}

proc update_PARAM_VALUE.AXICLK_PRD_NS { PARAM_VALUE.AXICLK_PRD_NS } {
	# Procedure called to update AXICLK_PRD_NS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXICLK_PRD_NS { PARAM_VALUE.AXICLK_PRD_NS } {
	# Procedure called to validate AXICLK_PRD_NS
	return true
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

proc update_PARAM_VALUE.C_1TO7_RST_ACLK_NUM { PARAM_VALUE.C_1TO7_RST_ACLK_NUM } {
	# Procedure called to update C_1TO7_RST_ACLK_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_1TO7_RST_ACLK_NUM { PARAM_VALUE.C_1TO7_RST_ACLK_NUM } {
	# Procedure called to validate C_1TO7_RST_ACLK_NUM
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

proc update_PARAM_VALUE.C_BLANK_EN { PARAM_VALUE.C_BLANK_EN } {
	# Procedure called to update C_BLANK_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_BLANK_EN { PARAM_VALUE.C_BLANK_EN } {
	# Procedure called to validate C_BLANK_EN
	return true
}

proc update_PARAM_VALUE.C_CONTAIN_DLY_CTRL { PARAM_VALUE.C_CONTAIN_DLY_CTRL } {
	# Procedure called to update C_CONTAIN_DLY_CTRL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CONTAIN_DLY_CTRL { PARAM_VALUE.C_CONTAIN_DLY_CTRL } {
	# Procedure called to validate C_CONTAIN_DLY_CTRL
	return true
}

proc update_PARAM_VALUE.C_DEVICE_TYPE { PARAM_VALUE.C_DEVICE_TYPE } {
	# Procedure called to update C_DEVICE_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DEVICE_TYPE { PARAM_VALUE.C_DEVICE_TYPE } {
	# Procedure called to validate C_DEVICE_TYPE
	return true
}

proc update_PARAM_VALUE.C_IMPL_MECHANISM { PARAM_VALUE.C_IMPL_MECHANISM } {
	# Procedure called to update C_IMPL_MECHANISM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_IMPL_MECHANISM { PARAM_VALUE.C_IMPL_MECHANISM } {
	# Procedure called to validate C_IMPL_MECHANISM
	return true
}

proc update_PARAM_VALUE.C_LB_ENABLE { PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to update C_LB_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_LB_ENABLE { PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to validate C_LB_ENABLE
	return true
}

proc update_PARAM_VALUE.C_MISALIGN_PCLK_PROTECT { PARAM_VALUE.C_MISALIGN_PCLK_PROTECT } {
	# Procedure called to update C_MISALIGN_PCLK_PROTECT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MISALIGN_PCLK_PROTECT { PARAM_VALUE.C_MISALIGN_PCLK_PROTECT } {
	# Procedure called to validate C_MISALIGN_PCLK_PROTECT
	return true
}

proc update_PARAM_VALUE.C_MISALIGN_RST_THRESHOLD_PCLK_NUM { PARAM_VALUE.C_MISALIGN_RST_THRESHOLD_PCLK_NUM } {
	# Procedure called to update C_MISALIGN_RST_THRESHOLD_PCLK_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MISALIGN_RST_THRESHOLD_PCLK_NUM { PARAM_VALUE.C_MISALIGN_RST_THRESHOLD_PCLK_NUM } {
	# Procedure called to validate C_MISALIGN_RST_THRESHOLD_PCLK_NUM
	return true
}

proc update_PARAM_VALUE.C_PCLK_DET_BLOCK_EN { PARAM_VALUE.C_PCLK_DET_BLOCK_EN } {
	# Procedure called to update C_PCLK_DET_BLOCK_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PCLK_DET_BLOCK_EN { PARAM_VALUE.C_PCLK_DET_BLOCK_EN } {
	# Procedure called to validate C_PCLK_DET_BLOCK_EN
	return true
}

proc update_PARAM_VALUE.C_PIXEL_ARR_MODE { PARAM_VALUE.C_PIXEL_ARR_MODE } {
	# Procedure called to update C_PIXEL_ARR_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PIXEL_ARR_MODE { PARAM_VALUE.C_PIXEL_ARR_MODE } {
	# Procedure called to validate C_PIXEL_ARR_MODE
	return true
}

proc update_PARAM_VALUE.DCD_CORRECT { PARAM_VALUE.DCD_CORRECT } {
	# Procedure called to update DCD_CORRECT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DCD_CORRECT { PARAM_VALUE.DCD_CORRECT } {
	# Procedure called to validate DCD_CORRECT
	return true
}

proc update_PARAM_VALUE.DESKEW_ILA_ENABLE { PARAM_VALUE.DESKEW_ILA_ENABLE } {
	# Procedure called to update DESKEW_ILA_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DESKEW_ILA_ENABLE { PARAM_VALUE.DESKEW_ILA_ENABLE } {
	# Procedure called to validate DESKEW_ILA_ENABLE
	return true
}

proc update_PARAM_VALUE.DETECT_MISALLIGN { PARAM_VALUE.DETECT_MISALLIGN } {
	# Procedure called to update DETECT_MISALLIGN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DETECT_MISALLIGN { PARAM_VALUE.DETECT_MISALLIGN } {
	# Procedure called to validate DETECT_MISALLIGN
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

proc update_PARAM_VALUE.LVDS_CLK_PN_SWAP_DEFAULT { PARAM_VALUE.LVDS_CLK_PN_SWAP_DEFAULT } {
	# Procedure called to update LVDS_CLK_PN_SWAP_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LVDS_CLK_PN_SWAP_DEFAULT { PARAM_VALUE.LVDS_CLK_PN_SWAP_DEFAULT } {
	# Procedure called to validate LVDS_CLK_PN_SWAP_DEFAULT
	return true
}

proc update_PARAM_VALUE.LVDS_DATAIN_PN_SWAP_DEFAULT { PARAM_VALUE.LVDS_DATAIN_PN_SWAP_DEFAULT } {
	# Procedure called to update LVDS_DATAIN_PN_SWAP_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LVDS_DATAIN_PN_SWAP_DEFAULT { PARAM_VALUE.LVDS_DATAIN_PN_SWAP_DEFAULT } {
	# Procedure called to validate LVDS_DATAIN_PN_SWAP_DEFAULT
	return true
}

proc update_PARAM_VALUE.LVDS_DATAOUT_PN_SWAP_DEFAULT { PARAM_VALUE.LVDS_DATAOUT_PN_SWAP_DEFAULT } {
	# Procedure called to update LVDS_DATAOUT_PN_SWAP_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LVDS_DATAOUT_PN_SWAP_DEFAULT { PARAM_VALUE.LVDS_DATAOUT_PN_SWAP_DEFAULT } {
	# Procedure called to validate LVDS_DATAOUT_PN_SWAP_DEFAULT
	return true
}

proc update_PARAM_VALUE.LVDS_ENABLE_DEFAULT { PARAM_VALUE.LVDS_ENABLE_DEFAULT } {
	# Procedure called to update LVDS_ENABLE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LVDS_ENABLE_DEFAULT { PARAM_VALUE.LVDS_ENABLE_DEFAULT } {
	# Procedure called to validate LVDS_ENABLE_DEFAULT
	return true
}

proc update_PARAM_VALUE.LVDS_LOCKED_PORT_NUM_DEFAULT { PARAM_VALUE.LVDS_LOCKED_PORT_NUM_DEFAULT } {
	# Procedure called to update LVDS_LOCKED_PORT_NUM_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LVDS_LOCKED_PORT_NUM_DEFAULT { PARAM_VALUE.LVDS_LOCKED_PORT_NUM_DEFAULT } {
	# Procedure called to validate LVDS_LOCKED_PORT_NUM_DEFAULT
	return true
}

proc update_PARAM_VALUE.MMCM_MODE { PARAM_VALUE.MMCM_MODE } {
	# Procedure called to update MMCM_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MMCM_MODE { PARAM_VALUE.MMCM_MODE } {
	# Procedure called to validate MMCM_MODE
	return true
}

proc update_PARAM_VALUE.PCLK_ILA_ENABLE { PARAM_VALUE.PCLK_ILA_ENABLE } {
	# Procedure called to update PCLK_ILA_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PCLK_ILA_ENABLE { PARAM_VALUE.PCLK_ILA_ENABLE } {
	# Procedure called to validate PCLK_ILA_ENABLE
	return true
}

proc update_PARAM_VALUE.PIXEL_ARR_MODE_DEFAULT { PARAM_VALUE.PIXEL_ARR_MODE_DEFAULT } {
	# Procedure called to update PIXEL_ARR_MODE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PIXEL_ARR_MODE_DEFAULT { PARAM_VALUE.PIXEL_ARR_MODE_DEFAULT } {
	# Procedure called to validate PIXEL_ARR_MODE_DEFAULT
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

proc update_MODELPARAM_VALUE.PCLK_ILA_ENABLE { MODELPARAM_VALUE.PCLK_ILA_ENABLE PARAM_VALUE.PCLK_ILA_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PCLK_ILA_ENABLE}] ${MODELPARAM_VALUE.PCLK_ILA_ENABLE}
}

proc update_MODELPARAM_VALUE.DETECT_MISALLIGN { MODELPARAM_VALUE.DETECT_MISALLIGN PARAM_VALUE.DETECT_MISALLIGN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DETECT_MISALLIGN}] ${MODELPARAM_VALUE.DETECT_MISALLIGN}
}

proc update_MODELPARAM_VALUE.LVDS_ENABLE_DEFAULT { MODELPARAM_VALUE.LVDS_ENABLE_DEFAULT PARAM_VALUE.LVDS_ENABLE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LVDS_ENABLE_DEFAULT}] ${MODELPARAM_VALUE.LVDS_ENABLE_DEFAULT}
}

proc update_MODELPARAM_VALUE.LVDS_CLK_PN_SWAP_DEFAULT { MODELPARAM_VALUE.LVDS_CLK_PN_SWAP_DEFAULT PARAM_VALUE.LVDS_CLK_PN_SWAP_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LVDS_CLK_PN_SWAP_DEFAULT}] ${MODELPARAM_VALUE.LVDS_CLK_PN_SWAP_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH PARAM_VALUE.C_AXI_LITE_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.LVDS_DATAIN_PN_SWAP_DEFAULT { MODELPARAM_VALUE.LVDS_DATAIN_PN_SWAP_DEFAULT PARAM_VALUE.LVDS_DATAIN_PN_SWAP_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LVDS_DATAIN_PN_SWAP_DEFAULT}] ${MODELPARAM_VALUE.LVDS_DATAIN_PN_SWAP_DEFAULT}
}

proc update_MODELPARAM_VALUE.LVDS_DATAOUT_PN_SWAP_DEFAULT { MODELPARAM_VALUE.LVDS_DATAOUT_PN_SWAP_DEFAULT PARAM_VALUE.LVDS_DATAOUT_PN_SWAP_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LVDS_DATAOUT_PN_SWAP_DEFAULT}] ${MODELPARAM_VALUE.LVDS_DATAOUT_PN_SWAP_DEFAULT}
}

proc update_MODELPARAM_VALUE.LVDS_LOCKED_PORT_NUM_DEFAULT { MODELPARAM_VALUE.LVDS_LOCKED_PORT_NUM_DEFAULT PARAM_VALUE.LVDS_LOCKED_PORT_NUM_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LVDS_LOCKED_PORT_NUM_DEFAULT}] ${MODELPARAM_VALUE.LVDS_LOCKED_PORT_NUM_DEFAULT}
}

proc update_MODELPARAM_VALUE.ACLK_ILA_ENABLE { MODELPARAM_VALUE.ACLK_ILA_ENABLE PARAM_VALUE.ACLK_ILA_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ACLK_ILA_ENABLE}] ${MODELPARAM_VALUE.ACLK_ILA_ENABLE}
}

proc update_MODELPARAM_VALUE.C_MISALIGN_RST_THRESHOLD_PCLK_NUM { MODELPARAM_VALUE.C_MISALIGN_RST_THRESHOLD_PCLK_NUM PARAM_VALUE.C_MISALIGN_RST_THRESHOLD_PCLK_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MISALIGN_RST_THRESHOLD_PCLK_NUM}] ${MODELPARAM_VALUE.C_MISALIGN_RST_THRESHOLD_PCLK_NUM}
}

proc update_MODELPARAM_VALUE.C_1TO7_RST_ACLK_NUM { MODELPARAM_VALUE.C_1TO7_RST_ACLK_NUM PARAM_VALUE.C_1TO7_RST_ACLK_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_1TO7_RST_ACLK_NUM}] ${MODELPARAM_VALUE.C_1TO7_RST_ACLK_NUM}
}

proc update_MODELPARAM_VALUE.DESKEW_ILA_ENABLE { MODELPARAM_VALUE.DESKEW_ILA_ENABLE PARAM_VALUE.DESKEW_ILA_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DESKEW_ILA_ENABLE}] ${MODELPARAM_VALUE.DESKEW_ILA_ENABLE}
}

proc update_MODELPARAM_VALUE.C_MISALIGN_PCLK_PROTECT { MODELPARAM_VALUE.C_MISALIGN_PCLK_PROTECT PARAM_VALUE.C_MISALIGN_PCLK_PROTECT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MISALIGN_PCLK_PROTECT}] ${MODELPARAM_VALUE.C_MISALIGN_PCLK_PROTECT}
}

proc update_MODELPARAM_VALUE.C_LB_ENABLE { MODELPARAM_VALUE.C_LB_ENABLE PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_LB_ENABLE}] ${MODELPARAM_VALUE.C_LB_ENABLE}
}

proc update_MODELPARAM_VALUE.AXICLK_PRD_NS { MODELPARAM_VALUE.AXICLK_PRD_NS PARAM_VALUE.AXICLK_PRD_NS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXICLK_PRD_NS}] ${MODELPARAM_VALUE.AXICLK_PRD_NS}
}

proc update_MODELPARAM_VALUE.C_BLANK_EN { MODELPARAM_VALUE.C_BLANK_EN PARAM_VALUE.C_BLANK_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_BLANK_EN}] ${MODELPARAM_VALUE.C_BLANK_EN}
}

proc update_MODELPARAM_VALUE.C_CONTAIN_DLY_CTRL { MODELPARAM_VALUE.C_CONTAIN_DLY_CTRL PARAM_VALUE.C_CONTAIN_DLY_CTRL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CONTAIN_DLY_CTRL}] ${MODELPARAM_VALUE.C_CONTAIN_DLY_CTRL}
}

proc update_MODELPARAM_VALUE.C_PCLK_DET_BLOCK_EN { MODELPARAM_VALUE.C_PCLK_DET_BLOCK_EN PARAM_VALUE.C_PCLK_DET_BLOCK_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PCLK_DET_BLOCK_EN}] ${MODELPARAM_VALUE.C_PCLK_DET_BLOCK_EN}
}

proc update_MODELPARAM_VALUE.C_DEVICE_TYPE { MODELPARAM_VALUE.C_DEVICE_TYPE PARAM_VALUE.C_DEVICE_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DEVICE_TYPE}] ${MODELPARAM_VALUE.C_DEVICE_TYPE}
}

proc update_MODELPARAM_VALUE.C_IMPL_MECHANISM { MODELPARAM_VALUE.C_IMPL_MECHANISM PARAM_VALUE.C_IMPL_MECHANISM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_IMPL_MECHANISM}] ${MODELPARAM_VALUE.C_IMPL_MECHANISM}
}

proc update_MODELPARAM_VALUE.PIXEL_ARR_MODE_DEFAULT { MODELPARAM_VALUE.PIXEL_ARR_MODE_DEFAULT PARAM_VALUE.PIXEL_ARR_MODE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PIXEL_ARR_MODE_DEFAULT}] ${MODELPARAM_VALUE.PIXEL_ARR_MODE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_PIXEL_ARR_MODE { MODELPARAM_VALUE.C_PIXEL_ARR_MODE PARAM_VALUE.C_PIXEL_ARR_MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PIXEL_ARR_MODE}] ${MODELPARAM_VALUE.C_PIXEL_ARR_MODE}
}

