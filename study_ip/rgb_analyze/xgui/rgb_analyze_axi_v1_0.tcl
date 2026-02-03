# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {Base}]
  set C_FIXED_MAX_PARA [ipgui::add_param $IPINST -name "C_FIXED_MAX_PARA" -parent ${Page_0} -widget comboBox]
  set_property tooltip {port num and bpc will be fixed to max para ignoing user config} ${C_FIXED_MAX_PARA}
  ipgui::add_param $IPINST -name "C_LB_ENABLE" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_S_AXI_ADDR_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_S_AXI_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_MAX_PORT_NUM" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_MAX_BPC" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_INPUT_REG_NUM" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_CLK_PERIOD_NS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_CRC_BLOCK_EN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_CRC_FIFO_DEPTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_PURE_CHECK_BLOCK_EN" -parent ${Page_0}
  set C_PURE_CHECK_MODE [ipgui::add_param $IPINST -name "C_PURE_CHECK_MODE" -parent ${Page_0} -widget comboBox]
  set_property tooltip {0:flag mode 1:cnt mode} ${C_PURE_CHECK_MODE}

  #Adding Page
  set Default_Para [ipgui::add_page $IPINST -name "Default Para"]
  ipgui::add_param $IPINST -name "C_VS_REVERSE_EN_DEFAULT" -parent ${Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_HS_REVERSE_EN_DEFAULT" -parent ${Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_DE_REVERSE_EN_DEFAULT" -parent ${Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_PURE_CHECK_EXCLUDE_PT_NUM_DEFAULT" -parent ${Default_Para}
  ipgui::add_param $IPINST -name "PORT_NUM_DEFAULT" -parent ${Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "BPC_DEFAULT" -parent ${Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "RED_HIGH_DEFAULT" -parent ${Default_Para}
  ipgui::add_param $IPINST -name "RED_LOW_DEFAULT" -parent ${Default_Para}
  ipgui::add_param $IPINST -name "GREEN_HIGH_DEFAULT" -parent ${Default_Para}
  ipgui::add_param $IPINST -name "GREEN_LOW_DEFAULT" -parent ${Default_Para}
  ipgui::add_param $IPINST -name "BLUE_HIGH_DEFAULT" -parent ${Default_Para}
  ipgui::add_param $IPINST -name "BLUE_LOW_DEFAULT" -parent ${Default_Para}

  #Adding Page
  set Debug [ipgui::add_page $IPINST -name "Debug"]
  ipgui::add_param $IPINST -name "C_DEBUG_ENABLE_ACLK" -parent ${Debug}
  ipgui::add_param $IPINST -name "C_DEBUG_ENABLE_PCLK" -parent ${Debug}
  ipgui::add_param $IPINST -name "C_ILA_RGB_PARA_PARSE_ACLK" -parent ${Debug}
  set C_ILA_HSVSDERGB_PCLK [ipgui::add_param $IPINST -name "C_ILA_HSVSDERGB_PCLK" -parent ${Debug}]
  set_property tooltip {hsvsdergb and cnt_h cnt_v for locate pixel of sepcital site} ${C_ILA_HSVSDERGB_PCLK}

  #Adding Page
  set Reg_Space [ipgui::add_page $IPINST -name "Reg Space"]
  ipgui::add_static_text $IPINST -name "reg space" -parent ${Reg_Space} -text {//read from ram
ADDR_LOCKED        0x0000 
ADDR_HSYNC          0x0004 //note:return total value according to actual port num
ADDR_HBP            0x0008  
 ADDR_HACTIVE        0x000c   
ADDR_HFP            0x0010   
ADDR_VSYNC          0x0014   
ADDR_VBP            0x0018  
 ADDR_VACTIVE        0x001c  
ADDR_VFP            0x0020  
ADDR_FPS_C1            0x0024
ADDR_FPS_C1_M1     0x0028
ADDR_FPS_C1_M2      0x002c
ADDR_FPS_C1_M3      0x0030
ADDR_FPS_C1_M4      0x0034
ADDR_FPS_C1_M5      0x0038
ADDR_FPS_C1_M6      0x003c
ADDR_FPS_C1_M7      0x0040
ADDR_FPS_C1_M8      0x0044
ADDR_FPS_C1_M9      0x0048
ADDR_FPS_C1_M10      0x004c
ADDR_FPS_C2             0x0050
ADDR_FPS_C2_M1      0x0054
ADDR_FPS_C2_M2      0x0058
ADDR_FPS_C2_M3      0x005c
ADDR_FPS_C2_M4      0x0060
ADDR_FPS_C2_M5      0x0064
ADDR_FPS_C2_M6      0x0068
ADDR_FPS_C2_M7      0x006c
ADDR_FPS_C2_M8      0x0070
ADDR_FPS_C2_M9      0x0074
ADDR_FPS_C2_M10      0x0078
ADDR_PURE_EXCLUDE_PT_NUM     0x1020

//read from fifo
 ADDR_CRC_NUM        0x2000 
 ADDR_CRC_OFFSET    0x2004


//write only
ADDR_PORT_NUM       0x1000
ADDR_BPC            0x1004
ADDR_RED_HIGH       0x1008
ADDR_RED_LOW        0x100c
ADDR_GREEN_HIGH     0x1010
ADDR_GREEN_LOW      0x1014
ADDR_BLUE_HIGH      0x1018
ADDR_BLUE_LOW       0x101c}

  #Adding Page
  set Ulitity [ipgui::add_page $IPINST -name "Ulitity" -display_name {Utility}]
  ipgui::add_static_text $IPINST -name "use help" -parent ${Ulitity} -text {1 when normal TPG input, 7 parsed results are right;

2 when phiyo TPG input,only hactive and vactive(may need add 1)are right

3 paresed results have taken into account of actual port num }


}

proc update_PARAM_VALUE.BLUE_HIGH_DEFAULT { PARAM_VALUE.BLUE_HIGH_DEFAULT } {
	# Procedure called to update BLUE_HIGH_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BLUE_HIGH_DEFAULT { PARAM_VALUE.BLUE_HIGH_DEFAULT } {
	# Procedure called to validate BLUE_HIGH_DEFAULT
	return true
}

proc update_PARAM_VALUE.BLUE_LOW_DEFAULT { PARAM_VALUE.BLUE_LOW_DEFAULT } {
	# Procedure called to update BLUE_LOW_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BLUE_LOW_DEFAULT { PARAM_VALUE.BLUE_LOW_DEFAULT } {
	# Procedure called to validate BLUE_LOW_DEFAULT
	return true
}

proc update_PARAM_VALUE.BPC_DEFAULT { PARAM_VALUE.BPC_DEFAULT } {
	# Procedure called to update BPC_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BPC_DEFAULT { PARAM_VALUE.BPC_DEFAULT } {
	# Procedure called to validate BPC_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_AXI_CLK_PERIOD_NS { PARAM_VALUE.C_AXI_CLK_PERIOD_NS } {
	# Procedure called to update C_AXI_CLK_PERIOD_NS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_CLK_PERIOD_NS { PARAM_VALUE.C_AXI_CLK_PERIOD_NS } {
	# Procedure called to validate C_AXI_CLK_PERIOD_NS
	return true
}

proc update_PARAM_VALUE.C_CRC_BLOCK_EN { PARAM_VALUE.C_CRC_BLOCK_EN } {
	# Procedure called to update C_CRC_BLOCK_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CRC_BLOCK_EN { PARAM_VALUE.C_CRC_BLOCK_EN } {
	# Procedure called to validate C_CRC_BLOCK_EN
	return true
}

proc update_PARAM_VALUE.C_CRC_EXCLUVE_H_DEFAULT { PARAM_VALUE.C_CRC_EXCLUVE_H_DEFAULT } {
	# Procedure called to update C_CRC_EXCLUVE_H_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CRC_EXCLUVE_H_DEFAULT { PARAM_VALUE.C_CRC_EXCLUVE_H_DEFAULT } {
	# Procedure called to validate C_CRC_EXCLUVE_H_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_CRC_EXCLUVE_V_DEFAULT { PARAM_VALUE.C_CRC_EXCLUVE_V_DEFAULT } {
	# Procedure called to update C_CRC_EXCLUVE_V_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CRC_EXCLUVE_V_DEFAULT { PARAM_VALUE.C_CRC_EXCLUVE_V_DEFAULT } {
	# Procedure called to validate C_CRC_EXCLUVE_V_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_CRC_EXCLUVE_X_DEFAULT { PARAM_VALUE.C_CRC_EXCLUVE_X_DEFAULT } {
	# Procedure called to update C_CRC_EXCLUVE_X_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CRC_EXCLUVE_X_DEFAULT { PARAM_VALUE.C_CRC_EXCLUVE_X_DEFAULT } {
	# Procedure called to validate C_CRC_EXCLUVE_X_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_CRC_EXCLUVE_Y_DEFAULT { PARAM_VALUE.C_CRC_EXCLUVE_Y_DEFAULT } {
	# Procedure called to update C_CRC_EXCLUVE_Y_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CRC_EXCLUVE_Y_DEFAULT { PARAM_VALUE.C_CRC_EXCLUVE_Y_DEFAULT } {
	# Procedure called to validate C_CRC_EXCLUVE_Y_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_CRC_FIFO_DEPTH { PARAM_VALUE.C_CRC_FIFO_DEPTH } {
	# Procedure called to update C_CRC_FIFO_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CRC_FIFO_DEPTH { PARAM_VALUE.C_CRC_FIFO_DEPTH } {
	# Procedure called to validate C_CRC_FIFO_DEPTH
	return true
}

proc update_PARAM_VALUE.C_DEBUG_ENABLE_ACLK { PARAM_VALUE.C_DEBUG_ENABLE_ACLK } {
	# Procedure called to update C_DEBUG_ENABLE_ACLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DEBUG_ENABLE_ACLK { PARAM_VALUE.C_DEBUG_ENABLE_ACLK } {
	# Procedure called to validate C_DEBUG_ENABLE_ACLK
	return true
}

proc update_PARAM_VALUE.C_DEBUG_ENABLE_PCLK { PARAM_VALUE.C_DEBUG_ENABLE_PCLK } {
	# Procedure called to update C_DEBUG_ENABLE_PCLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DEBUG_ENABLE_PCLK { PARAM_VALUE.C_DEBUG_ENABLE_PCLK } {
	# Procedure called to validate C_DEBUG_ENABLE_PCLK
	return true
}

proc update_PARAM_VALUE.C_DE_REVERSE_EN_DEFAULT { PARAM_VALUE.C_DE_REVERSE_EN_DEFAULT } {
	# Procedure called to update C_DE_REVERSE_EN_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DE_REVERSE_EN_DEFAULT { PARAM_VALUE.C_DE_REVERSE_EN_DEFAULT } {
	# Procedure called to validate C_DE_REVERSE_EN_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FIXED_MAX_PARA { PARAM_VALUE.C_FIXED_MAX_PARA } {
	# Procedure called to update C_FIXED_MAX_PARA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FIXED_MAX_PARA { PARAM_VALUE.C_FIXED_MAX_PARA } {
	# Procedure called to validate C_FIXED_MAX_PARA
	return true
}

proc update_PARAM_VALUE.C_HS_REVERSE_EN_DEFAULT { PARAM_VALUE.C_HS_REVERSE_EN_DEFAULT } {
	# Procedure called to update C_HS_REVERSE_EN_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_HS_REVERSE_EN_DEFAULT { PARAM_VALUE.C_HS_REVERSE_EN_DEFAULT } {
	# Procedure called to validate C_HS_REVERSE_EN_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_ILA_HSVSDERGB_PCLK { PARAM_VALUE.C_ILA_HSVSDERGB_PCLK } {
	# Procedure called to update C_ILA_HSVSDERGB_PCLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ILA_HSVSDERGB_PCLK { PARAM_VALUE.C_ILA_HSVSDERGB_PCLK } {
	# Procedure called to validate C_ILA_HSVSDERGB_PCLK
	return true
}

proc update_PARAM_VALUE.C_ILA_RGB_PARA_PARSE_ACLK { PARAM_VALUE.C_ILA_RGB_PARA_PARSE_ACLK } {
	# Procedure called to update C_ILA_RGB_PARA_PARSE_ACLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ILA_RGB_PARA_PARSE_ACLK { PARAM_VALUE.C_ILA_RGB_PARA_PARSE_ACLK } {
	# Procedure called to validate C_ILA_RGB_PARA_PARSE_ACLK
	return true
}

proc update_PARAM_VALUE.C_INPUT_REG_NUM { PARAM_VALUE.C_INPUT_REG_NUM } {
	# Procedure called to update C_INPUT_REG_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_INPUT_REG_NUM { PARAM_VALUE.C_INPUT_REG_NUM } {
	# Procedure called to validate C_INPUT_REG_NUM
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

proc update_PARAM_VALUE.C_MAX_PORT_NUM { PARAM_VALUE.C_MAX_PORT_NUM } {
	# Procedure called to update C_MAX_PORT_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MAX_PORT_NUM { PARAM_VALUE.C_MAX_PORT_NUM } {
	# Procedure called to validate C_MAX_PORT_NUM
	return true
}

proc update_PARAM_VALUE.C_PURE_CHECK_BLOCK_EN { PARAM_VALUE.C_PURE_CHECK_BLOCK_EN } {
	# Procedure called to update C_PURE_CHECK_BLOCK_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PURE_CHECK_BLOCK_EN { PARAM_VALUE.C_PURE_CHECK_BLOCK_EN } {
	# Procedure called to validate C_PURE_CHECK_BLOCK_EN
	return true
}

proc update_PARAM_VALUE.C_PURE_CHECK_EXCLUDE_PT_NUM_DEFAULT { PARAM_VALUE.C_PURE_CHECK_EXCLUDE_PT_NUM_DEFAULT } {
	# Procedure called to update C_PURE_CHECK_EXCLUDE_PT_NUM_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PURE_CHECK_EXCLUDE_PT_NUM_DEFAULT { PARAM_VALUE.C_PURE_CHECK_EXCLUDE_PT_NUM_DEFAULT } {
	# Procedure called to validate C_PURE_CHECK_EXCLUDE_PT_NUM_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_PURE_CHECK_MODE { PARAM_VALUE.C_PURE_CHECK_MODE } {
	# Procedure called to update C_PURE_CHECK_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PURE_CHECK_MODE { PARAM_VALUE.C_PURE_CHECK_MODE } {
	# Procedure called to validate C_PURE_CHECK_MODE
	return true
}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_VS_REVERSE_EN_DEFAULT { PARAM_VALUE.C_VS_REVERSE_EN_DEFAULT } {
	# Procedure called to update C_VS_REVERSE_EN_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VS_REVERSE_EN_DEFAULT { PARAM_VALUE.C_VS_REVERSE_EN_DEFAULT } {
	# Procedure called to validate C_VS_REVERSE_EN_DEFAULT
	return true
}

proc update_PARAM_VALUE.GREEN_HIGH_DEFAULT { PARAM_VALUE.GREEN_HIGH_DEFAULT } {
	# Procedure called to update GREEN_HIGH_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.GREEN_HIGH_DEFAULT { PARAM_VALUE.GREEN_HIGH_DEFAULT } {
	# Procedure called to validate GREEN_HIGH_DEFAULT
	return true
}

proc update_PARAM_VALUE.GREEN_LOW_DEFAULT { PARAM_VALUE.GREEN_LOW_DEFAULT } {
	# Procedure called to update GREEN_LOW_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.GREEN_LOW_DEFAULT { PARAM_VALUE.GREEN_LOW_DEFAULT } {
	# Procedure called to validate GREEN_LOW_DEFAULT
	return true
}

proc update_PARAM_VALUE.PORT_NUM_DEFAULT { PARAM_VALUE.PORT_NUM_DEFAULT } {
	# Procedure called to update PORT_NUM_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PORT_NUM_DEFAULT { PARAM_VALUE.PORT_NUM_DEFAULT } {
	# Procedure called to validate PORT_NUM_DEFAULT
	return true
}

proc update_PARAM_VALUE.RED_HIGH_DEFAULT { PARAM_VALUE.RED_HIGH_DEFAULT } {
	# Procedure called to update RED_HIGH_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RED_HIGH_DEFAULT { PARAM_VALUE.RED_HIGH_DEFAULT } {
	# Procedure called to validate RED_HIGH_DEFAULT
	return true
}

proc update_PARAM_VALUE.RED_LOW_DEFAULT { PARAM_VALUE.RED_LOW_DEFAULT } {
	# Procedure called to update RED_LOW_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RED_LOW_DEFAULT { PARAM_VALUE.RED_LOW_DEFAULT } {
	# Procedure called to validate RED_LOW_DEFAULT
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_CLK_PERIOD_NS { MODELPARAM_VALUE.C_AXI_CLK_PERIOD_NS PARAM_VALUE.C_AXI_CLK_PERIOD_NS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_CLK_PERIOD_NS}] ${MODELPARAM_VALUE.C_AXI_CLK_PERIOD_NS}
}

proc update_MODELPARAM_VALUE.C_DEBUG_ENABLE_PCLK { MODELPARAM_VALUE.C_DEBUG_ENABLE_PCLK PARAM_VALUE.C_DEBUG_ENABLE_PCLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DEBUG_ENABLE_PCLK}] ${MODELPARAM_VALUE.C_DEBUG_ENABLE_PCLK}
}

proc update_MODELPARAM_VALUE.C_DEBUG_ENABLE_ACLK { MODELPARAM_VALUE.C_DEBUG_ENABLE_ACLK PARAM_VALUE.C_DEBUG_ENABLE_ACLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DEBUG_ENABLE_ACLK}] ${MODELPARAM_VALUE.C_DEBUG_ENABLE_ACLK}
}

proc update_MODELPARAM_VALUE.C_MAX_PORT_NUM { MODELPARAM_VALUE.C_MAX_PORT_NUM PARAM_VALUE.C_MAX_PORT_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MAX_PORT_NUM}] ${MODELPARAM_VALUE.C_MAX_PORT_NUM}
}

proc update_MODELPARAM_VALUE.C_CRC_BLOCK_EN { MODELPARAM_VALUE.C_CRC_BLOCK_EN PARAM_VALUE.C_CRC_BLOCK_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CRC_BLOCK_EN}] ${MODELPARAM_VALUE.C_CRC_BLOCK_EN}
}

proc update_MODELPARAM_VALUE.C_MAX_BPC { MODELPARAM_VALUE.C_MAX_BPC PARAM_VALUE.C_MAX_BPC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MAX_BPC}] ${MODELPARAM_VALUE.C_MAX_BPC}
}

proc update_MODELPARAM_VALUE.PORT_NUM_DEFAULT { MODELPARAM_VALUE.PORT_NUM_DEFAULT PARAM_VALUE.PORT_NUM_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PORT_NUM_DEFAULT}] ${MODELPARAM_VALUE.PORT_NUM_DEFAULT}
}

proc update_MODELPARAM_VALUE.BPC_DEFAULT { MODELPARAM_VALUE.BPC_DEFAULT PARAM_VALUE.BPC_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BPC_DEFAULT}] ${MODELPARAM_VALUE.BPC_DEFAULT}
}

proc update_MODELPARAM_VALUE.RED_HIGH_DEFAULT { MODELPARAM_VALUE.RED_HIGH_DEFAULT PARAM_VALUE.RED_HIGH_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RED_HIGH_DEFAULT}] ${MODELPARAM_VALUE.RED_HIGH_DEFAULT}
}

proc update_MODELPARAM_VALUE.RED_LOW_DEFAULT { MODELPARAM_VALUE.RED_LOW_DEFAULT PARAM_VALUE.RED_LOW_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RED_LOW_DEFAULT}] ${MODELPARAM_VALUE.RED_LOW_DEFAULT}
}

proc update_MODELPARAM_VALUE.GREEN_HIGH_DEFAULT { MODELPARAM_VALUE.GREEN_HIGH_DEFAULT PARAM_VALUE.GREEN_HIGH_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.GREEN_HIGH_DEFAULT}] ${MODELPARAM_VALUE.GREEN_HIGH_DEFAULT}
}

proc update_MODELPARAM_VALUE.GREEN_LOW_DEFAULT { MODELPARAM_VALUE.GREEN_LOW_DEFAULT PARAM_VALUE.GREEN_LOW_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.GREEN_LOW_DEFAULT}] ${MODELPARAM_VALUE.GREEN_LOW_DEFAULT}
}

proc update_MODELPARAM_VALUE.BLUE_HIGH_DEFAULT { MODELPARAM_VALUE.BLUE_HIGH_DEFAULT PARAM_VALUE.BLUE_HIGH_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BLUE_HIGH_DEFAULT}] ${MODELPARAM_VALUE.BLUE_HIGH_DEFAULT}
}

proc update_MODELPARAM_VALUE.BLUE_LOW_DEFAULT { MODELPARAM_VALUE.BLUE_LOW_DEFAULT PARAM_VALUE.BLUE_LOW_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BLUE_LOW_DEFAULT}] ${MODELPARAM_VALUE.BLUE_LOW_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_PURE_CHECK_MODE { MODELPARAM_VALUE.C_PURE_CHECK_MODE PARAM_VALUE.C_PURE_CHECK_MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PURE_CHECK_MODE}] ${MODELPARAM_VALUE.C_PURE_CHECK_MODE}
}

proc update_MODELPARAM_VALUE.C_PURE_CHECK_EXCLUDE_PT_NUM_DEFAULT { MODELPARAM_VALUE.C_PURE_CHECK_EXCLUDE_PT_NUM_DEFAULT PARAM_VALUE.C_PURE_CHECK_EXCLUDE_PT_NUM_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PURE_CHECK_EXCLUDE_PT_NUM_DEFAULT}] ${MODELPARAM_VALUE.C_PURE_CHECK_EXCLUDE_PT_NUM_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_INPUT_REG_NUM { MODELPARAM_VALUE.C_INPUT_REG_NUM PARAM_VALUE.C_INPUT_REG_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_INPUT_REG_NUM}] ${MODELPARAM_VALUE.C_INPUT_REG_NUM}
}

proc update_MODELPARAM_VALUE.C_VS_REVERSE_EN_DEFAULT { MODELPARAM_VALUE.C_VS_REVERSE_EN_DEFAULT PARAM_VALUE.C_VS_REVERSE_EN_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VS_REVERSE_EN_DEFAULT}] ${MODELPARAM_VALUE.C_VS_REVERSE_EN_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_HS_REVERSE_EN_DEFAULT { MODELPARAM_VALUE.C_HS_REVERSE_EN_DEFAULT PARAM_VALUE.C_HS_REVERSE_EN_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_HS_REVERSE_EN_DEFAULT}] ${MODELPARAM_VALUE.C_HS_REVERSE_EN_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_DE_REVERSE_EN_DEFAULT { MODELPARAM_VALUE.C_DE_REVERSE_EN_DEFAULT PARAM_VALUE.C_DE_REVERSE_EN_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DE_REVERSE_EN_DEFAULT}] ${MODELPARAM_VALUE.C_DE_REVERSE_EN_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_ILA_RGB_PARA_PARSE_ACLK { MODELPARAM_VALUE.C_ILA_RGB_PARA_PARSE_ACLK PARAM_VALUE.C_ILA_RGB_PARA_PARSE_ACLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ILA_RGB_PARA_PARSE_ACLK}] ${MODELPARAM_VALUE.C_ILA_RGB_PARA_PARSE_ACLK}
}

proc update_MODELPARAM_VALUE.C_ILA_HSVSDERGB_PCLK { MODELPARAM_VALUE.C_ILA_HSVSDERGB_PCLK PARAM_VALUE.C_ILA_HSVSDERGB_PCLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ILA_HSVSDERGB_PCLK}] ${MODELPARAM_VALUE.C_ILA_HSVSDERGB_PCLK}
}

proc update_MODELPARAM_VALUE.C_CRC_EXCLUVE_X_DEFAULT { MODELPARAM_VALUE.C_CRC_EXCLUVE_X_DEFAULT PARAM_VALUE.C_CRC_EXCLUVE_X_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CRC_EXCLUVE_X_DEFAULT}] ${MODELPARAM_VALUE.C_CRC_EXCLUVE_X_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_CRC_EXCLUVE_Y_DEFAULT { MODELPARAM_VALUE.C_CRC_EXCLUVE_Y_DEFAULT PARAM_VALUE.C_CRC_EXCLUVE_Y_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CRC_EXCLUVE_Y_DEFAULT}] ${MODELPARAM_VALUE.C_CRC_EXCLUVE_Y_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_CRC_EXCLUVE_H_DEFAULT { MODELPARAM_VALUE.C_CRC_EXCLUVE_H_DEFAULT PARAM_VALUE.C_CRC_EXCLUVE_H_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CRC_EXCLUVE_H_DEFAULT}] ${MODELPARAM_VALUE.C_CRC_EXCLUVE_H_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_CRC_EXCLUVE_V_DEFAULT { MODELPARAM_VALUE.C_CRC_EXCLUVE_V_DEFAULT PARAM_VALUE.C_CRC_EXCLUVE_V_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CRC_EXCLUVE_V_DEFAULT}] ${MODELPARAM_VALUE.C_CRC_EXCLUVE_V_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_LB_ENABLE { MODELPARAM_VALUE.C_LB_ENABLE PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_LB_ENABLE}] ${MODELPARAM_VALUE.C_LB_ENABLE}
}

proc update_MODELPARAM_VALUE.C_CRC_FIFO_DEPTH { MODELPARAM_VALUE.C_CRC_FIFO_DEPTH PARAM_VALUE.C_CRC_FIFO_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CRC_FIFO_DEPTH}] ${MODELPARAM_VALUE.C_CRC_FIFO_DEPTH}
}

proc update_MODELPARAM_VALUE.C_PURE_CHECK_BLOCK_EN { MODELPARAM_VALUE.C_PURE_CHECK_BLOCK_EN PARAM_VALUE.C_PURE_CHECK_BLOCK_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PURE_CHECK_BLOCK_EN}] ${MODELPARAM_VALUE.C_PURE_CHECK_BLOCK_EN}
}

proc update_MODELPARAM_VALUE.C_FIXED_MAX_PARA { MODELPARAM_VALUE.C_FIXED_MAX_PARA PARAM_VALUE.C_FIXED_MAX_PARA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FIXED_MAX_PARA}] ${MODELPARAM_VALUE.C_FIXED_MAX_PARA}
}

