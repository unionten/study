# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Base [ipgui::add_page $IPINST -name "Base"]
  ipgui::add_param $IPINST -name "DDR_Video_Format" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_FIXED_MAX_PARA" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_LB_ENABLE" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_LITE_ADDR_WIDTH" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_LITE_DATA_WIDTH" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_RAW_DATA_WIDTH" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_MAX_PORT_NUM" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_DDR_PIXEL_MAX_BYTE_NUM" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_MAX_BPC" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_OUT_FORMAT" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_RGB2YUV_BLOCK_EN" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_YUV2RGB_BLOCK_EN" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_420FIFO_BLOCK_EN" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_OSD_BLOCK_EN" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_INNER_PATTERN_BLOCK_EN" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_FIFO_DEPTH" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_FIFO_WREADY_THRESH" -parent ${Base} -widget comboBox
  ipgui::add_param $IPINST -name "C_TPG_SRC" -parent ${Base} -widget comboBox
  ipgui::add_static_text $IPINST -name "Note" -parent ${Base} -text {timing para dont care port num}

  #Adding Page
  set Base_Default_Para [ipgui::add_page $IPINST -name "Base Default Para"]
  ipgui::add_param $IPINST -name "C_ENABLE_DEFAULT" -parent ${Base_Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_PORT_NUM_DEFAULT" -parent ${Base_Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_MEM_BYTES_DEFAULT" -parent ${Base_Default_Para}
  ipgui::add_param $IPINST -name "C_COLOR_DEPTH_DEFAULT" -parent ${Base_Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_COLOR_SPACE_DEFAULT" -parent ${Base_Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_DP_COLOR_SPACE_DEFAULT" -parent ${Base_Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_DP_COLOR_DEPTH_DEFAULT" -parent ${Base_Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_PIX_CLK_FREQ_DEFAULT" -parent ${Base_Default_Para}
  ipgui::add_param $IPINST -name "C_HACTIVE_DEFAULT" -parent ${Base_Default_Para}
  ipgui::add_param $IPINST -name "C_HFP_DEFAULT" -parent ${Base_Default_Para}
  ipgui::add_param $IPINST -name "C_HBP_DEFAULT" -parent ${Base_Default_Para}
  ipgui::add_param $IPINST -name "C_HSYNC_DEFAULT" -parent ${Base_Default_Para}
  ipgui::add_param $IPINST -name "C_VACTIVE_DEFAULT" -parent ${Base_Default_Para}
  ipgui::add_param $IPINST -name "C_VSYNC_DEFAULT" -parent ${Base_Default_Para}
  ipgui::add_param $IPINST -name "C_VBP_DEFAULT" -parent ${Base_Default_Para}
  ipgui::add_param $IPINST -name "C_VFP_DEFAULT" -parent ${Base_Default_Para}
  ipgui::add_param $IPINST -name "C_LU_HACTIVE_DEFAULT" -parent ${Base_Default_Para}
  ipgui::add_param $IPINST -name "C_LU_VACTIVE_DEFAULT" -parent ${Base_Default_Para}
  ipgui::add_param $IPINST -name "C_OUTPUT_SRC_DEFAULT" -parent ${Base_Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_INNER_PATTERN_ID_DEFAULT" -parent ${Base_Default_Para} -widget comboBox

  #Adding Page
  set OSD_Default_Para [ipgui::add_page $IPINST -name "OSD Default Para"]
  ipgui::add_param $IPINST -name "C_OSD_ENABLE_DEFAULT" -parent ${OSD_Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_OSD_SETTING_DEFAULT" -parent ${OSD_Default_Para} -widget comboBox
  ipgui::add_param $IPINST -name "C_OSD_X_DEFAULT" -parent ${OSD_Default_Para}
  ipgui::add_param $IPINST -name "C_OSD_Y_DEFAULT" -parent ${OSD_Default_Para}
  ipgui::add_param $IPINST -name "C_OSD_HPIXEL_DEFAULT" -parent ${OSD_Default_Para}
  ipgui::add_param $IPINST -name "C_OSD_VPIXEL_DEFAULT" -parent ${OSD_Default_Para}

  #Adding Page
  set Debug [ipgui::add_page $IPINST -name "Debug"]
  ipgui::add_param $IPINST -name "C_VID_OSD_ILA_EN" -parent ${Debug}
  ipgui::add_param $IPINST -name "C_PARA_NATIVE_ILA_EN_AXICLK" -parent ${Debug}
  ipgui::add_param $IPINST -name "C_AXI_ILA_EN" -parent ${Debug}
  ipgui::add_param $IPINST -name "C_RAW_ILA_EN" -parent ${Debug}
  ipgui::add_param $IPINST -name "C_VID_ILA_EN" -parent ${Debug}

  #Adding Page
  set Use_Help [ipgui::add_page $IPINST -name "Use Help"]
  ipgui::add_static_text $IPINST -name "use help" -parent ${Use_Help} -text {1 ENABLE_O ~ AXI_CLK

2 inner TPG drive all the logic to run

3 VID_RSTN will reset inner tpg

4 vs will reset fifo

5 note, osd base addr is 0x40000, so axi-lite addr width must >=20}


}

proc update_PARAM_VALUE.C_420FIFO_BLOCK_EN { PARAM_VALUE.C_420FIFO_BLOCK_EN } {
	# Procedure called to update C_420FIFO_BLOCK_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_420FIFO_BLOCK_EN { PARAM_VALUE.C_420FIFO_BLOCK_EN } {
	# Procedure called to validate C_420FIFO_BLOCK_EN
	return true
}

proc update_PARAM_VALUE.C_AXI_ILA_EN { PARAM_VALUE.C_AXI_ILA_EN } {
	# Procedure called to update C_AXI_ILA_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_ILA_EN { PARAM_VALUE.C_AXI_ILA_EN } {
	# Procedure called to validate C_AXI_ILA_EN
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

proc update_PARAM_VALUE.C_DDR_PIXEL_MAX_BYTE_NUM { PARAM_VALUE.C_DDR_PIXEL_MAX_BYTE_NUM } {
	# Procedure called to update C_DDR_PIXEL_MAX_BYTE_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DDR_PIXEL_MAX_BYTE_NUM { PARAM_VALUE.C_DDR_PIXEL_MAX_BYTE_NUM } {
	# Procedure called to validate C_DDR_PIXEL_MAX_BYTE_NUM
	return true
}

proc update_PARAM_VALUE.C_DP_COLOR_DEPTH_DEFAULT { PARAM_VALUE.C_DP_COLOR_DEPTH_DEFAULT } {
	# Procedure called to update C_DP_COLOR_DEPTH_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DP_COLOR_DEPTH_DEFAULT { PARAM_VALUE.C_DP_COLOR_DEPTH_DEFAULT } {
	# Procedure called to validate C_DP_COLOR_DEPTH_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_DP_COLOR_SPACE_DEFAULT { PARAM_VALUE.C_DP_COLOR_SPACE_DEFAULT } {
	# Procedure called to update C_DP_COLOR_SPACE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DP_COLOR_SPACE_DEFAULT { PARAM_VALUE.C_DP_COLOR_SPACE_DEFAULT } {
	# Procedure called to validate C_DP_COLOR_SPACE_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_ENABLE_DEFAULT { PARAM_VALUE.C_ENABLE_DEFAULT } {
	# Procedure called to update C_ENABLE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ENABLE_DEFAULT { PARAM_VALUE.C_ENABLE_DEFAULT } {
	# Procedure called to validate C_ENABLE_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_FIFO_DEPTH { PARAM_VALUE.C_FIFO_DEPTH } {
	# Procedure called to update C_FIFO_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FIFO_DEPTH { PARAM_VALUE.C_FIFO_DEPTH } {
	# Procedure called to validate C_FIFO_DEPTH
	return true
}

proc update_PARAM_VALUE.C_FIFO_WREADY_THRESH { PARAM_VALUE.C_FIFO_WREADY_THRESH } {
	# Procedure called to update C_FIFO_WREADY_THRESH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FIFO_WREADY_THRESH { PARAM_VALUE.C_FIFO_WREADY_THRESH } {
	# Procedure called to validate C_FIFO_WREADY_THRESH
	return true
}

proc update_PARAM_VALUE.C_FIXED_MAX_PARA { PARAM_VALUE.C_FIXED_MAX_PARA } {
	# Procedure called to update C_FIXED_MAX_PARA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FIXED_MAX_PARA { PARAM_VALUE.C_FIXED_MAX_PARA } {
	# Procedure called to validate C_FIXED_MAX_PARA
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

proc update_PARAM_VALUE.C_INNER_PATTERN_BLOCK_EN { PARAM_VALUE.C_INNER_PATTERN_BLOCK_EN } {
	# Procedure called to update C_INNER_PATTERN_BLOCK_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_INNER_PATTERN_BLOCK_EN { PARAM_VALUE.C_INNER_PATTERN_BLOCK_EN } {
	# Procedure called to validate C_INNER_PATTERN_BLOCK_EN
	return true
}

proc update_PARAM_VALUE.C_INNER_PATTERN_ID_DEFAULT { PARAM_VALUE.C_INNER_PATTERN_ID_DEFAULT } {
	# Procedure called to update C_INNER_PATTERN_ID_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_INNER_PATTERN_ID_DEFAULT { PARAM_VALUE.C_INNER_PATTERN_ID_DEFAULT } {
	# Procedure called to validate C_INNER_PATTERN_ID_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_LB_ENABLE { PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to update C_LB_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_LB_ENABLE { PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to validate C_LB_ENABLE
	return true
}

proc update_PARAM_VALUE.C_LU_HACTIVE_DEFAULT { PARAM_VALUE.C_LU_HACTIVE_DEFAULT } {
	# Procedure called to update C_LU_HACTIVE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_LU_HACTIVE_DEFAULT { PARAM_VALUE.C_LU_HACTIVE_DEFAULT } {
	# Procedure called to validate C_LU_HACTIVE_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_LU_VACTIVE_DEFAULT { PARAM_VALUE.C_LU_VACTIVE_DEFAULT } {
	# Procedure called to update C_LU_VACTIVE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_LU_VACTIVE_DEFAULT { PARAM_VALUE.C_LU_VACTIVE_DEFAULT } {
	# Procedure called to validate C_LU_VACTIVE_DEFAULT
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

proc update_PARAM_VALUE.C_MEM_BYTES_DEFAULT { PARAM_VALUE.C_MEM_BYTES_DEFAULT } {
	# Procedure called to update C_MEM_BYTES_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MEM_BYTES_DEFAULT { PARAM_VALUE.C_MEM_BYTES_DEFAULT } {
	# Procedure called to validate C_MEM_BYTES_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_OSD_BLOCK_EN { PARAM_VALUE.C_OSD_BLOCK_EN } {
	# Procedure called to update C_OSD_BLOCK_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_OSD_BLOCK_EN { PARAM_VALUE.C_OSD_BLOCK_EN } {
	# Procedure called to validate C_OSD_BLOCK_EN
	return true
}

proc update_PARAM_VALUE.C_OSD_ENABLE_DEFAULT { PARAM_VALUE.C_OSD_ENABLE_DEFAULT } {
	# Procedure called to update C_OSD_ENABLE_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_OSD_ENABLE_DEFAULT { PARAM_VALUE.C_OSD_ENABLE_DEFAULT } {
	# Procedure called to validate C_OSD_ENABLE_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_OSD_HPIXEL_DEFAULT { PARAM_VALUE.C_OSD_HPIXEL_DEFAULT } {
	# Procedure called to update C_OSD_HPIXEL_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_OSD_HPIXEL_DEFAULT { PARAM_VALUE.C_OSD_HPIXEL_DEFAULT } {
	# Procedure called to validate C_OSD_HPIXEL_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_OSD_SETTING_DEFAULT { PARAM_VALUE.C_OSD_SETTING_DEFAULT } {
	# Procedure called to update C_OSD_SETTING_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_OSD_SETTING_DEFAULT { PARAM_VALUE.C_OSD_SETTING_DEFAULT } {
	# Procedure called to validate C_OSD_SETTING_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_OSD_VPIXEL_DEFAULT { PARAM_VALUE.C_OSD_VPIXEL_DEFAULT } {
	# Procedure called to update C_OSD_VPIXEL_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_OSD_VPIXEL_DEFAULT { PARAM_VALUE.C_OSD_VPIXEL_DEFAULT } {
	# Procedure called to validate C_OSD_VPIXEL_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_OSD_X_DEFAULT { PARAM_VALUE.C_OSD_X_DEFAULT } {
	# Procedure called to update C_OSD_X_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_OSD_X_DEFAULT { PARAM_VALUE.C_OSD_X_DEFAULT } {
	# Procedure called to validate C_OSD_X_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_OSD_Y_DEFAULT { PARAM_VALUE.C_OSD_Y_DEFAULT } {
	# Procedure called to update C_OSD_Y_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_OSD_Y_DEFAULT { PARAM_VALUE.C_OSD_Y_DEFAULT } {
	# Procedure called to validate C_OSD_Y_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_OUTPUT_SRC_DEFAULT { PARAM_VALUE.C_OUTPUT_SRC_DEFAULT } {
	# Procedure called to update C_OUTPUT_SRC_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_OUTPUT_SRC_DEFAULT { PARAM_VALUE.C_OUTPUT_SRC_DEFAULT } {
	# Procedure called to validate C_OUTPUT_SRC_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_OUT_FORMAT { PARAM_VALUE.C_OUT_FORMAT } {
	# Procedure called to update C_OUT_FORMAT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_OUT_FORMAT { PARAM_VALUE.C_OUT_FORMAT } {
	# Procedure called to validate C_OUT_FORMAT
	return true
}

proc update_PARAM_VALUE.C_PARA_NATIVE_ILA_EN_AXICLK { PARAM_VALUE.C_PARA_NATIVE_ILA_EN_AXICLK } {
	# Procedure called to update C_PARA_NATIVE_ILA_EN_AXICLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PARA_NATIVE_ILA_EN_AXICLK { PARAM_VALUE.C_PARA_NATIVE_ILA_EN_AXICLK } {
	# Procedure called to validate C_PARA_NATIVE_ILA_EN_AXICLK
	return true
}

proc update_PARAM_VALUE.C_PIX_CLK_FREQ_DEFAULT { PARAM_VALUE.C_PIX_CLK_FREQ_DEFAULT } {
	# Procedure called to update C_PIX_CLK_FREQ_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PIX_CLK_FREQ_DEFAULT { PARAM_VALUE.C_PIX_CLK_FREQ_DEFAULT } {
	# Procedure called to validate C_PIX_CLK_FREQ_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_PORT_NUM_DEFAULT { PARAM_VALUE.C_PORT_NUM_DEFAULT } {
	# Procedure called to update C_PORT_NUM_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PORT_NUM_DEFAULT { PARAM_VALUE.C_PORT_NUM_DEFAULT } {
	# Procedure called to validate C_PORT_NUM_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_RAW_DATA_WIDTH { PARAM_VALUE.C_RAW_DATA_WIDTH } {
	# Procedure called to update C_RAW_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_RAW_DATA_WIDTH { PARAM_VALUE.C_RAW_DATA_WIDTH } {
	# Procedure called to validate C_RAW_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_RAW_ILA_EN { PARAM_VALUE.C_RAW_ILA_EN } {
	# Procedure called to update C_RAW_ILA_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_RAW_ILA_EN { PARAM_VALUE.C_RAW_ILA_EN } {
	# Procedure called to validate C_RAW_ILA_EN
	return true
}

proc update_PARAM_VALUE.C_RGB2YUV_BLOCK_EN { PARAM_VALUE.C_RGB2YUV_BLOCK_EN } {
	# Procedure called to update C_RGB2YUV_BLOCK_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_RGB2YUV_BLOCK_EN { PARAM_VALUE.C_RGB2YUV_BLOCK_EN } {
	# Procedure called to validate C_RGB2YUV_BLOCK_EN
	return true
}

proc update_PARAM_VALUE.C_RGB_DEFAULT { PARAM_VALUE.C_RGB_DEFAULT } {
	# Procedure called to update C_RGB_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_RGB_DEFAULT { PARAM_VALUE.C_RGB_DEFAULT } {
	# Procedure called to validate C_RGB_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_TPG_SRC { PARAM_VALUE.C_TPG_SRC } {
	# Procedure called to update C_TPG_SRC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_TPG_SRC { PARAM_VALUE.C_TPG_SRC } {
	# Procedure called to validate C_TPG_SRC
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

proc update_PARAM_VALUE.C_VID_ILA_EN { PARAM_VALUE.C_VID_ILA_EN } {
	# Procedure called to update C_VID_ILA_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VID_ILA_EN { PARAM_VALUE.C_VID_ILA_EN } {
	# Procedure called to validate C_VID_ILA_EN
	return true
}

proc update_PARAM_VALUE.C_VID_OSD_ILA_EN { PARAM_VALUE.C_VID_OSD_ILA_EN } {
	# Procedure called to update C_VID_OSD_ILA_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VID_OSD_ILA_EN { PARAM_VALUE.C_VID_OSD_ILA_EN } {
	# Procedure called to validate C_VID_OSD_ILA_EN
	return true
}

proc update_PARAM_VALUE.C_VSYNC_DEFAULT { PARAM_VALUE.C_VSYNC_DEFAULT } {
	# Procedure called to update C_VSYNC_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_VSYNC_DEFAULT { PARAM_VALUE.C_VSYNC_DEFAULT } {
	# Procedure called to validate C_VSYNC_DEFAULT
	return true
}

proc update_PARAM_VALUE.C_YUV2RGB_BLOCK_EN { PARAM_VALUE.C_YUV2RGB_BLOCK_EN } {
	# Procedure called to update C_YUV2RGB_BLOCK_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_YUV2RGB_BLOCK_EN { PARAM_VALUE.C_YUV2RGB_BLOCK_EN } {
	# Procedure called to validate C_YUV2RGB_BLOCK_EN
	return true
}

proc update_PARAM_VALUE.DDR_Video_Format { PARAM_VALUE.DDR_Video_Format } {
	# Procedure called to update DDR_Video_Format when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DDR_Video_Format { PARAM_VALUE.DDR_Video_Format } {
	# Procedure called to validate DDR_Video_Format
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

proc update_MODELPARAM_VALUE.C_RAW_DATA_WIDTH { MODELPARAM_VALUE.C_RAW_DATA_WIDTH PARAM_VALUE.C_RAW_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_RAW_DATA_WIDTH}] ${MODELPARAM_VALUE.C_RAW_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_MAX_PORT_NUM { MODELPARAM_VALUE.C_MAX_PORT_NUM PARAM_VALUE.C_MAX_PORT_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MAX_PORT_NUM}] ${MODELPARAM_VALUE.C_MAX_PORT_NUM}
}

proc update_MODELPARAM_VALUE.C_MAX_BPC { MODELPARAM_VALUE.C_MAX_BPC PARAM_VALUE.C_MAX_BPC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MAX_BPC}] ${MODELPARAM_VALUE.C_MAX_BPC}
}

proc update_MODELPARAM_VALUE.C_DDR_PIXEL_MAX_BYTE_NUM { MODELPARAM_VALUE.C_DDR_PIXEL_MAX_BYTE_NUM PARAM_VALUE.C_DDR_PIXEL_MAX_BYTE_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DDR_PIXEL_MAX_BYTE_NUM}] ${MODELPARAM_VALUE.C_DDR_PIXEL_MAX_BYTE_NUM}
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

proc update_MODELPARAM_VALUE.C_HACTIVE_DEFAULT { MODELPARAM_VALUE.C_HACTIVE_DEFAULT PARAM_VALUE.C_HACTIVE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_HACTIVE_DEFAULT}] ${MODELPARAM_VALUE.C_HACTIVE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_VACTIVE_DEFAULT { MODELPARAM_VALUE.C_VACTIVE_DEFAULT PARAM_VALUE.C_VACTIVE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VACTIVE_DEFAULT}] ${MODELPARAM_VALUE.C_VACTIVE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_HSYNC_DEFAULT { MODELPARAM_VALUE.C_HSYNC_DEFAULT PARAM_VALUE.C_HSYNC_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_HSYNC_DEFAULT}] ${MODELPARAM_VALUE.C_HSYNC_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_HBP_DEFAULT { MODELPARAM_VALUE.C_HBP_DEFAULT PARAM_VALUE.C_HBP_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_HBP_DEFAULT}] ${MODELPARAM_VALUE.C_HBP_DEFAULT}
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

proc update_MODELPARAM_VALUE.C_VFP_DEFAULT { MODELPARAM_VALUE.C_VFP_DEFAULT PARAM_VALUE.C_VFP_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VFP_DEFAULT}] ${MODELPARAM_VALUE.C_VFP_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_OSD_HPIXEL_DEFAULT { MODELPARAM_VALUE.C_OSD_HPIXEL_DEFAULT PARAM_VALUE.C_OSD_HPIXEL_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_OSD_HPIXEL_DEFAULT}] ${MODELPARAM_VALUE.C_OSD_HPIXEL_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_OSD_VPIXEL_DEFAULT { MODELPARAM_VALUE.C_OSD_VPIXEL_DEFAULT PARAM_VALUE.C_OSD_VPIXEL_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_OSD_VPIXEL_DEFAULT}] ${MODELPARAM_VALUE.C_OSD_VPIXEL_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_YUV2RGB_BLOCK_EN { MODELPARAM_VALUE.C_YUV2RGB_BLOCK_EN PARAM_VALUE.C_YUV2RGB_BLOCK_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_YUV2RGB_BLOCK_EN}] ${MODELPARAM_VALUE.C_YUV2RGB_BLOCK_EN}
}

proc update_MODELPARAM_VALUE.C_RGB2YUV_BLOCK_EN { MODELPARAM_VALUE.C_RGB2YUV_BLOCK_EN PARAM_VALUE.C_RGB2YUV_BLOCK_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_RGB2YUV_BLOCK_EN}] ${MODELPARAM_VALUE.C_RGB2YUV_BLOCK_EN}
}

proc update_MODELPARAM_VALUE.C_420FIFO_BLOCK_EN { MODELPARAM_VALUE.C_420FIFO_BLOCK_EN PARAM_VALUE.C_420FIFO_BLOCK_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_420FIFO_BLOCK_EN}] ${MODELPARAM_VALUE.C_420FIFO_BLOCK_EN}
}

proc update_MODELPARAM_VALUE.C_VID_ILA_EN { MODELPARAM_VALUE.C_VID_ILA_EN PARAM_VALUE.C_VID_ILA_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VID_ILA_EN}] ${MODELPARAM_VALUE.C_VID_ILA_EN}
}

proc update_MODELPARAM_VALUE.C_AXI_ILA_EN { MODELPARAM_VALUE.C_AXI_ILA_EN PARAM_VALUE.C_AXI_ILA_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_ILA_EN}] ${MODELPARAM_VALUE.C_AXI_ILA_EN}
}

proc update_MODELPARAM_VALUE.C_OUT_FORMAT { MODELPARAM_VALUE.C_OUT_FORMAT PARAM_VALUE.C_OUT_FORMAT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_OUT_FORMAT}] ${MODELPARAM_VALUE.C_OUT_FORMAT}
}

proc update_MODELPARAM_VALUE.C_RAW_ILA_EN { MODELPARAM_VALUE.C_RAW_ILA_EN PARAM_VALUE.C_RAW_ILA_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_RAW_ILA_EN}] ${MODELPARAM_VALUE.C_RAW_ILA_EN}
}

proc update_MODELPARAM_VALUE.C_OSD_BLOCK_EN { MODELPARAM_VALUE.C_OSD_BLOCK_EN PARAM_VALUE.C_OSD_BLOCK_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_OSD_BLOCK_EN}] ${MODELPARAM_VALUE.C_OSD_BLOCK_EN}
}

proc update_MODELPARAM_VALUE.C_OSD_X_DEFAULT { MODELPARAM_VALUE.C_OSD_X_DEFAULT PARAM_VALUE.C_OSD_X_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_OSD_X_DEFAULT}] ${MODELPARAM_VALUE.C_OSD_X_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_OSD_Y_DEFAULT { MODELPARAM_VALUE.C_OSD_Y_DEFAULT PARAM_VALUE.C_OSD_Y_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_OSD_Y_DEFAULT}] ${MODELPARAM_VALUE.C_OSD_Y_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_OSD_ENABLE_DEFAULT { MODELPARAM_VALUE.C_OSD_ENABLE_DEFAULT PARAM_VALUE.C_OSD_ENABLE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_OSD_ENABLE_DEFAULT}] ${MODELPARAM_VALUE.C_OSD_ENABLE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_OSD_SETTING_DEFAULT { MODELPARAM_VALUE.C_OSD_SETTING_DEFAULT PARAM_VALUE.C_OSD_SETTING_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_OSD_SETTING_DEFAULT}] ${MODELPARAM_VALUE.C_OSD_SETTING_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_TPG_SRC { MODELPARAM_VALUE.C_TPG_SRC PARAM_VALUE.C_TPG_SRC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_TPG_SRC}] ${MODELPARAM_VALUE.C_TPG_SRC}
}

proc update_MODELPARAM_VALUE.C_FIFO_DEPTH { MODELPARAM_VALUE.C_FIFO_DEPTH PARAM_VALUE.C_FIFO_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_DEPTH}] ${MODELPARAM_VALUE.C_FIFO_DEPTH}
}

proc update_MODELPARAM_VALUE.C_FIFO_WREADY_THRESH { MODELPARAM_VALUE.C_FIFO_WREADY_THRESH PARAM_VALUE.C_FIFO_WREADY_THRESH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_WREADY_THRESH}] ${MODELPARAM_VALUE.C_FIFO_WREADY_THRESH}
}

proc update_MODELPARAM_VALUE.C_LB_ENABLE { MODELPARAM_VALUE.C_LB_ENABLE PARAM_VALUE.C_LB_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_LB_ENABLE}] ${MODELPARAM_VALUE.C_LB_ENABLE}
}

proc update_MODELPARAM_VALUE.C_VID_OSD_ILA_EN { MODELPARAM_VALUE.C_VID_OSD_ILA_EN PARAM_VALUE.C_VID_OSD_ILA_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_VID_OSD_ILA_EN}] ${MODELPARAM_VALUE.C_VID_OSD_ILA_EN}
}

proc update_MODELPARAM_VALUE.C_PIX_CLK_FREQ_DEFAULT { MODELPARAM_VALUE.C_PIX_CLK_FREQ_DEFAULT PARAM_VALUE.C_PIX_CLK_FREQ_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PIX_CLK_FREQ_DEFAULT}] ${MODELPARAM_VALUE.C_PIX_CLK_FREQ_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_PARA_NATIVE_ILA_EN_AXICLK { MODELPARAM_VALUE.C_PARA_NATIVE_ILA_EN_AXICLK PARAM_VALUE.C_PARA_NATIVE_ILA_EN_AXICLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PARA_NATIVE_ILA_EN_AXICLK}] ${MODELPARAM_VALUE.C_PARA_NATIVE_ILA_EN_AXICLK}
}

proc update_MODELPARAM_VALUE.C_FIXED_MAX_PARA { MODELPARAM_VALUE.C_FIXED_MAX_PARA PARAM_VALUE.C_FIXED_MAX_PARA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FIXED_MAX_PARA}] ${MODELPARAM_VALUE.C_FIXED_MAX_PARA}
}

proc update_MODELPARAM_VALUE.C_LU_HACTIVE_DEFAULT { MODELPARAM_VALUE.C_LU_HACTIVE_DEFAULT PARAM_VALUE.C_LU_HACTIVE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_LU_HACTIVE_DEFAULT}] ${MODELPARAM_VALUE.C_LU_HACTIVE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_LU_VACTIVE_DEFAULT { MODELPARAM_VALUE.C_LU_VACTIVE_DEFAULT PARAM_VALUE.C_LU_VACTIVE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_LU_VACTIVE_DEFAULT}] ${MODELPARAM_VALUE.C_LU_VACTIVE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_DP_COLOR_DEPTH_DEFAULT { MODELPARAM_VALUE.C_DP_COLOR_DEPTH_DEFAULT PARAM_VALUE.C_DP_COLOR_DEPTH_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DP_COLOR_DEPTH_DEFAULT}] ${MODELPARAM_VALUE.C_DP_COLOR_DEPTH_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_DP_COLOR_SPACE_DEFAULT { MODELPARAM_VALUE.C_DP_COLOR_SPACE_DEFAULT PARAM_VALUE.C_DP_COLOR_SPACE_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DP_COLOR_SPACE_DEFAULT}] ${MODELPARAM_VALUE.C_DP_COLOR_SPACE_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_INNER_PATTERN_BLOCK_EN { MODELPARAM_VALUE.C_INNER_PATTERN_BLOCK_EN PARAM_VALUE.C_INNER_PATTERN_BLOCK_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_INNER_PATTERN_BLOCK_EN}] ${MODELPARAM_VALUE.C_INNER_PATTERN_BLOCK_EN}
}

proc update_MODELPARAM_VALUE.C_OUTPUT_SRC_DEFAULT { MODELPARAM_VALUE.C_OUTPUT_SRC_DEFAULT PARAM_VALUE.C_OUTPUT_SRC_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_OUTPUT_SRC_DEFAULT}] ${MODELPARAM_VALUE.C_OUTPUT_SRC_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_INNER_PATTERN_ID_DEFAULT { MODELPARAM_VALUE.C_INNER_PATTERN_ID_DEFAULT PARAM_VALUE.C_INNER_PATTERN_ID_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_INNER_PATTERN_ID_DEFAULT}] ${MODELPARAM_VALUE.C_INNER_PATTERN_ID_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_RGB_DEFAULT { MODELPARAM_VALUE.C_RGB_DEFAULT PARAM_VALUE.C_RGB_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_RGB_DEFAULT}] ${MODELPARAM_VALUE.C_RGB_DEFAULT}
}

proc update_MODELPARAM_VALUE.DDR_Video_Format { MODELPARAM_VALUE.DDR_Video_Format PARAM_VALUE.DDR_Video_Format } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DDR_Video_Format}] ${MODELPARAM_VALUE.DDR_Video_Format}
}

