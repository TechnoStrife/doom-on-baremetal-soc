set_property PACKAGE_PIN W7 [get_ports {GamePad_gp_down_y}];     # "JD1_N"
set_property PACKAGE_PIN V7 [get_ports {GamePad_gp_up_z}];       # "JD1_P"
set_property PACKAGE_PIN V4 [get_ports {GamePad_gp_right_mode}]; # "JD2_N"
set_property PACKAGE_PIN V5 [get_ports {GamePad_gp_left_x}];     # "JD2_P"
set_property PACKAGE_PIN W5 [get_ports {GamePad_gp_sel}];        # "JD3_N"
set_property PACKAGE_PIN W6 [get_ports {GamePad_gp_b_a}];        # "JD3_P"
set_property PACKAGE_PIN U6 [get_ports {GamePad_gp_c_start}];    # "JD4_P"
#set_property PACKAGE_PIN U5 [get_ports {JD4_N}];                # "JD4_N"

set_property PULLTYPE PULLUP [get_ports GamePad_gp_b_a];
set_property PULLTYPE PULLUP [get_ports GamePad_gp_c_start];
set_property PULLTYPE PULLUP [get_ports GamePad_gp_down_y];
set_property PULLTYPE PULLUP [get_ports GamePad_gp_up_z];
set_property PULLTYPE PULLUP [get_ports GamePad_gp_right_mode];
set_property PULLTYPE PULLUP [get_ports GamePad_gp_left_x];

# Note that the bank voltage for IO Bank 13 is fixed to 3.3V on ZedBoard.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];