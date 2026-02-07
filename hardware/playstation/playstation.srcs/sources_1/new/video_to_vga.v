
// vid_io - Video interface bus which includes data, syncs, and blanks. (slave directions)
// 
module vga_adapter(
 (* X_INTERFACE_INFO =
 "xilinx.com:interface:vid_io:1.0 VideoIn DATA" *)
 input [23:0] vin_d, // Parallel video data (required)
 (* X_INTERFACE_INFO =
 "xilinx.com:interface:vid_io:1.0 VideoIn ACTIVE_VIDEO" *)
 input vin_av, // Active video Flag (optional)
 (* X_INTERFACE_INFO =
 "xilinx.com:interface:vid_io:1.0 VideoIn HBLANK" *)
 input vin_hb, // Horizontal blanking signal (optional)
 (* X_INTERFACE_INFO =
 "xilinx.com:interface:vid_io:1.0 VideoIn VBLANK" *)
 input vin_vb, // Vertical blanking signal (optional)
 (* X_INTERFACE_INFO =
 "xilinx.com:interface:vid_io:1.0 VideoIn HSYNC" *)
 input vin_hs, // Horizontal sync signal (optional)
 (* X_INTERFACE_INFO =
 "xilinx.com:interface:vid_io:1.0 VideoIn VSYNC" *)
 input vin_vs, // Veritcal sync signal (optional)
 (* X_INTERFACE_INFO =
 "xilinx.com:interface:vid_io:1.0 VideoIn FIELD" *)
 input vin_fid, // Field ID (optional)
 
 output [3:0] VGA_R,VGA_G,VGA_B,
 output VGA_HS,VGA_VS
);
 
 assign VGA_R = vin_av ? vin_d[23:20] : 0;
 assign VGA_G = vin_av ? vin_d[15:12] : 0; 
 assign VGA_B = vin_av ? vin_d[ 7: 4] : 0; 
 assign VGA_HS = vin_hs;
 assign VGA_VS = vin_vs;
 
endmodule

			