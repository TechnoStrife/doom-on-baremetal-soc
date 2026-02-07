

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "SEGAGamePad2" "NUM_INSTANCES" "DEVICE_ID"  "C_S00_AXILite_BASEADDR" "C_S00_AXILite_HIGHADDR"
}
