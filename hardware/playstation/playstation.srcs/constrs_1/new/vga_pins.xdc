# -----------------------------------------------------------------------
# VGA Output - Bank 33
# -----------------------------------------------------------------------
set_property PACKAGE_PIN Y21 [get_ports {VGA_B[0]}]; # "VGA-B1"
set_property PACKAGE_PIN Y20 [get_ports {VGA_B[1]}]; # "VGA-B2"
set_property PACKAGE_PIN AB20 [get_ports {VGA_B[2]}]; # "VGA-B3"
set_property PACKAGE_PIN AB19 [get_ports {VGA_B[3]}]; # "VGA-B4"
set_property PACKAGE_PIN AB22 [get_ports {VGA_G[0]}]; # "VGA-G1"
set_property PACKAGE_PIN AA22 [get_ports {VGA_G[1]}]; # "VGA-G2"
set_property PACKAGE_PIN AB21 [get_ports {VGA_G[2]}]; # "VGA-G3"
set_property PACKAGE_PIN AA21 [get_ports {VGA_G[3]}]; # "VGA-G4"
set_property PACKAGE_PIN AA19 [get_ports {VGA_HS}]; # "VGA-HS"
set_property PACKAGE_PIN V20 [get_ports {VGA_R[0]}]; # "VGA-R1"
set_property PACKAGE_PIN U20 [get_ports {VGA_R[1]}]; # "VGA-R2"
set_property PACKAGE_PIN V19 [get_ports {VGA_R[2]}]; # "VGA-R3"
set_property PACKAGE_PIN V18 [get_ports {VGA_R[3]}]; # "VGA-R4"
set_property PACKAGE_PIN Y19 [get_ports {VGA_VS}]; # "VGA-VS"
# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];