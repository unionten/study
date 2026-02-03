# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {Base}]
  ipgui::add_param $IPINST -name "C_AXI_PRD_NS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_BAUD_RATE" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_LITE_ADDR_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_LITE_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_ILA_ENABLE" -parent ${Page_0}

  #Adding Page
  set defalt_para [ipgui::add_page $IPINST -name "defalt para"]
  ipgui::add_param $IPINST -name "C_FPD_RATE_DEFAULT" -parent ${defalt_para}
  ipgui::add_param $IPINST -name "C_HSYNC_DEFAULT" -parent ${defalt_para}
  ipgui::add_param $IPINST -name "C_HBP_DEFAULT" -parent ${defalt_para}
  ipgui::add_param $IPINST -name "C_HACTIVE_DEFAULT" -parent ${defalt_para}
  ipgui::add_param $IPINST -name "C_HFP_DEFAULT" -parent ${defalt_para}
  ipgui::add_param $IPINST -name "C_VSYNC_DEFAULT" -parent ${defalt_para}
  ipgui::add_param $IPINST -name "C_VBP_DEFAULT" -parent ${defalt_para}
  ipgui::add_param $IPINST -name "C_VACTIVE_DEFAULT" -parent ${defalt_para}
  ipgui::add_param $IPINST -name "C_VFP_DEFAULT" -parent ${defalt_para}
  ipgui::add_param $IPINST -name "C_FPS_DEFAULT" -parent ${defalt_para}
  ipgui::add_param $IPINST -name "C_SERADDR_DEFAULT" -parent ${defalt_para}
  ipgui::add_param $IPINST -name "C_DESERADDR_DEFAULT" -parent ${defalt_para}
  ipgui::add_param $IPINST -name "C_CONF_DEFAULT" -parent ${defalt_para}
  ipgui::add_param $IPINST -name "C_PATTERN_SRC_DEFAULT" -parent ${defalt_para}
  ipgui::add_param $IPINST -name "C_PATTERN_ID_DEFAULT" -parent ${defalt_para}
  ipgui::add_param $IPINST -name "C_SD_PHY_ADDR_DEFAULT" -parent ${defalt_para}

  #Adding Page
  set reg_table [ipgui::add_page $IPINST -name "reg table"]
  ipgui::add_static_text $IPINST -name "reg table0" -parent ${reg_table} -text {ADDR_FPD_RATE          0x0000

ADDR_HSYNC             0x0004

ADDR_HBP               0x0008

ADDR_HACTIVE           0x000c

ADDR_HFP               0x0010

ADDR_VSYNC             0x0014

ADDR_VBP               0x0018

ADDR_VACTIVE           0x001c

ADDR_VFP               0x0020

ADDR_FPS               0x0024

ADDR_SERADDR           0x0028

ADDR_DESERADDR         0x002c

ADDR_CONF              0x0030

ADDR_PATTERN_SRC       0x0034

ADDR_PATTERN_ID        0x0038}


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

proc update_PARAM_VALUE.C_AXI_PRD_NS { PARAM_VALUE.C_AXI_PRD_NS } {
	# Procedure called to update C_AXI_PRD_NS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_PRD_NS { PARAM_VALUE.C_AXI_PRD_NS } {
	# Procedure called to validate C_AXI_PRD_NS
	return true
}

proc update_PARAM_VALUE.C_BAUD_RATE { PARAM_VALUE.C_BAUD_RATE } {
	# Procedure called to update C_BAUD_RATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_BAUD_RATE { PARAM_VALUE.C_BAUD_RATE } {
	# Procedure called to validate C_BAUD_RATE
	return true
}

proc update_PARAM_VALUE.C_CONF_DEFAULT { PARAM_VALUE.C_CONF_DEFAULT } {
	# Procedure called to update C_CONF_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CONF_DEFAULT { PARAM_VALUE.C_CONF_DEFAULT } {
	# Procedure called to validate C_CONF_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_DESERADDR_DEFAULT { PARAM_VALUE.C_DESERADDR_DEFAULT } {
	# Procedure called to update C_DESERADDR_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DESERADDR_DEFAULT { PARAM_VALUE.C_DESERADDR_DEFAULT } {
	# Procedure called to validate C_DESERADDR_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FPD_RATE_DEFAULT { PARAM_VALUE.C_FPD_RATE_DEFAULT } {
	# Procedure called to update C_FPD_RATE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FPD_RATE_DEFAULT { PARAM_VALUE.C_FPD_RATE_DEFAULT } {
	# Procedure called to validate C_FPD_RATE_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FPD_TX_MODE_DEFAULT { PARAM_VALUE.C_FPD_TX_MODE_DEFAULT } {
	# Procedure called to update C_FPD_TX_MODE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FPD_TX_MODE_DEFAULT { PARAM_VALUE.C_FPD_TX_MODE_DEFAULT } {
	# Procedure called to validate C_FPD_TX_MODE_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FPS_DEFAULT { PARAM_VALUE.C_FPS_DEFAULT } {
	# Procedure called to update C_FPS_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FPS_DEFAULT { PARAM_VALUE.C_FPS_DEFAULT } {
	# Procedure called to validate C_FPS_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_HACTIVE_DEFAULT { PARAM_VALUE.C_HACTIVE_DEFAULT } {
	# Procedure called to update C_HACTIVE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_HACTIVE_DEFAULT { PARAM_VALUE.C_HACTIVE_DEFAULT } {
	# Procedure called to validate C_HACTIVE_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_HBP_DEFAULT { PARAM_VALUE.C_HBP_DEFAULT } {
	# Procedure called to update C_HBP_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_HBP_DEFAULT { PARAM_VALUE.C_HBP_DEFAULT } {
	# Procedure called to validate C_HBP_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_HFP_DEFAULT { PARAM_VALUE.C_HFP_DEFAULT } {
	# Procedure called to update C_HFP_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_HFP_DEFAULT { PARAM_VALUE.C_HFP_DEFAULT } {
	# Procedure called to validate C_HFP_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_HSYNC_DEFAULT { PARAM_VALUE.C_HSYNC_DEFAULT } {
	# Procedure called to update C_HSYNC_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_HSYNC_DEFAULT { PARAM_VALUE.C_HSYNC_DEFAULT } {
	# Procedure called to validate C_HSYNC_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_ILA_ENABLE { PARAM_VALUE.C_ILA_ENABLE } {
	# Procedure called to update C_ILA_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ILA_ENABLE { PARAM_VALUE.C_ILA_ENABLE } {
	# Procedure called to validate C_ILA_ENABLE
	return true
}

proc update_PARAM_VALUE.C_PATTERN_ID_DEFAULT { PARAM_VALUE.C_PATTERN_ID_DEFAULT } {
	# Procedure called to update C_PATTERN_ID_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PATTERN_ID_DEFAULT { PARAM_VALUE.C_PATTERN_ID_DEFAULT } {
	# Procedure called to validate C_PATTERN_ID_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_PATTERN_SRC_DEFAULT { PARAM_VALUE.C_PATTERN_SRC_DEFAULT } {
	# Procedure called to update C_PATTERN_SRC_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PATTERN_SRC_DEFAULT { PARAM_VALUE.C_PATTERN_SRC_DEFAULT } {
	# Procedure called to validate C_PATTERN_SRC_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_SD_PHY_ADDR_DEFAULT { PARAM_VALUE.C_SD_PHY_ADDR_DEFAULT } {
	# Procedure called to update C_SD_PHY_ADDR_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SD_PHY_ADDR_DEFAULT { PARAM_VALUE.C_SD_PHY_ADDR_DEFAULT } {
	# Procedure called to validate C_SD_PHY_ADDR_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_SERADDR_DEFAULT { PARAM_VALUE.C_SERADDR_DEFAULT } {
	# Procedure called to update C_SERADDR_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SERADDR_DEFAULT { PARAM_VALUE.C_SERADDR_DEFAULT } {
	# Procedure called to validate C_SERADDR_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_STP_COAX_DEFAULT { PARAM_VALUE.C_STP_COAX_DEFAULT } {
	# Procedure called to update C_STP_COAX_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_STP_COAX_DEFAULT { PARAM_VALUE.C_STP_COAX_DEFAULT } {
	# Procedure called to validate C_STP_COAX_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_VACTIVE_DEFAULT { PARAM_VALUE.C_VACTIVE_DEFAULT } {
	# Procedure called to update C_VACTIVE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VACTIVE_DEFAULT { PARAM_VALUE.C_VACTIVE_DEFAULT } {
	# Procedure called to validate C_VACTIVE_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_VBP_DEFAULT { PARAM_VALUE.C_VBP_DEFAULT } {
	# Procedure called to update C_VBP_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VBP_DEFAULT { PARAM_VALUE.C_VBP_DEFAULT } {
	# Procedure called to validate C_VBP_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_VFP_DEFAULT { PARAM_VALUE.C_VFP_DEFAULT } {
	# Procedure called to update C_VFP_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VFP_DEFAULT { PARAM_VALUE.C_VFP_DEFAULT } {
	# Procedure called to validate C_VFP_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_VSYNC_DEFAULT { PARAM_VALUE.C_VSYNC_DEFAULT } {
	# Procedure called to update C_VSYNC_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VSYNC_DEFAULT { PARAM_VALUE.C_VSYNC_DEFAULT } {
	# Procedure called to validate C_VSYNC_DEFAULT
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

proc update_MODELPARAM_VALUE.C_AXI_PRD_NS { MODELPARAM_VALUE.C_AXI_PRD_NS PARAM_VALUE.C_AXI_PRD_NS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_PRD_NS}] ${MODELPARAM_VALUE.C_AXI_PRD_NS}
}

proc update_MODELPARAM_VALUE.C_BAUD_RATE { MODELPARAM_VALUE.C_BAUD_RATE PARAM_VALUE.C_BAUD_RATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_BAUD_RATE}] ${MODELPARAM_VALUE.C_BAUD_RATE}
}

proc update_MODELPARAM_VALUE.C_ILA_ENABLE { MODELPARAM_VALUE.C_ILA_ENABLE PARAM_VALUE.C_ILA_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ILA_ENABLE}] ${MODELPARAM_VALUE.C_ILA_ENABLE}
}

proc update_MODELPARAM_VALUE.C_FPD_RATE_DEFAULT { MODELPARAM_VALUE.C_FPD_RATE_DEFAULT PARAM_VALUE.C_FPD_RATE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FPD_RATE_DEFAULT}] ${MODELPARAM_VALUE.C_FPD_RATE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_HSYNC_DEFAULT { MODELPARAM_VALUE.C_HSYNC_DEFAULT PARAM_VALUE.C_HSYNC_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_HSYNC_DEFAULT}] ${MODELPARAM_VALUE.C_HSYNC_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_HBP_DEFAULT { MODELPARAM_VALUE.C_HBP_DEFAULT PARAM_VALUE.C_HBP_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_HBP_DEFAULT}] ${MODELPARAM_VALUE.C_HBP_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_HACTIVE_DEFAULT { MODELPARAM_VALUE.C_HACTIVE_DEFAULT PARAM_VALUE.C_HACTIVE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_HACTIVE_DEFAULT}] ${MODELPARAM_VALUE.C_HACTIVE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_HFP_DEFAULT { MODELPARAM_VALUE.C_HFP_DEFAULT PARAM_VALUE.C_HFP_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_HFP_DEFAULT}] ${MODELPARAM_VALUE.C_HFP_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_VSYNC_DEFAULT { MODELPARAM_VALUE.C_VSYNC_DEFAULT PARAM_VALUE.C_VSYNC_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VSYNC_DEFAULT}] ${MODELPARAM_VALUE.C_VSYNC_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_VBP_DEFAULT { MODELPARAM_VALUE.C_VBP_DEFAULT PARAM_VALUE.C_VBP_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VBP_DEFAULT}] ${MODELPARAM_VALUE.C_VBP_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_VACTIVE_DEFAULT { MODELPARAM_VALUE.C_VACTIVE_DEFAULT PARAM_VALUE.C_VACTIVE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VACTIVE_DEFAULT}] ${MODELPARAM_VALUE.C_VACTIVE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_VFP_DEFAULT { MODELPARAM_VALUE.C_VFP_DEFAULT PARAM_VALUE.C_VFP_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VFP_DEFAULT}] ${MODELPARAM_VALUE.C_VFP_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FPS_DEFAULT { MODELPARAM_VALUE.C_FPS_DEFAULT PARAM_VALUE.C_FPS_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FPS_DEFAULT}] ${MODELPARAM_VALUE.C_FPS_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_SERADDR_DEFAULT { MODELPARAM_VALUE.C_SERADDR_DEFAULT PARAM_VALUE.C_SERADDR_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SERADDR_DEFAULT}] ${MODELPARAM_VALUE.C_SERADDR_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_DESERADDR_DEFAULT { MODELPARAM_VALUE.C_DESERADDR_DEFAULT PARAM_VALUE.C_DESERADDR_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DESERADDR_DEFAULT}] ${MODELPARAM_VALUE.C_DESERADDR_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_CONF_DEFAULT { MODELPARAM_VALUE.C_CONF_DEFAULT PARAM_VALUE.C_CONF_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CONF_DEFAULT}] ${MODELPARAM_VALUE.C_CONF_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_PATTERN_SRC_DEFAULT { MODELPARAM_VALUE.C_PATTERN_SRC_DEFAULT PARAM_VALUE.C_PATTERN_SRC_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PATTERN_SRC_DEFAULT}] ${MODELPARAM_VALUE.C_PATTERN_SRC_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_PATTERN_ID_DEFAULT { MODELPARAM_VALUE.C_PATTERN_ID_DEFAULT PARAM_VALUE.C_PATTERN_ID_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PATTERN_ID_DEFAULT}] ${MODELPARAM_VALUE.C_PATTERN_ID_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_SD_PHY_ADDR_DEFAULT { MODELPARAM_VALUE.C_SD_PHY_ADDR_DEFAULT PARAM_VALUE.C_SD_PHY_ADDR_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SD_PHY_ADDR_DEFAULT}] ${MODELPARAM_VALUE.C_SD_PHY_ADDR_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_STP_COAX_DEFAULT { MODELPARAM_VALUE.C_STP_COAX_DEFAULT PARAM_VALUE.C_STP_COAX_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_STP_COAX_DEFAULT}] ${MODELPARAM_VALUE.C_STP_COAX_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_FPD_TX_MODE_DEFAULT { MODELPARAM_VALUE.C_FPD_TX_MODE_DEFAULT PARAM_VALUE.C_FPD_TX_MODE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FPD_TX_MODE_DEFAULT}] ${MODELPARAM_VALUE.C_FPD_TX_MODE_DEFAULT}
}

