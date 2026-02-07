
`timescale 1 ns / 1 ps

	module SEGAGamePad2 #
	(
		// Users to add parameters here
        parameter integer DELAY_US_TICKS = 150,
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXILite
		parameter integer C_S00_AXILite_DATA_WIDTH	= 32,
		parameter integer C_S00_AXILite_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
        output wire interrupt,
        input  wire gp_left_x,
        input  wire gp_right_mode,
        input  wire gp_b_a,
        input  wire gp_down_y,
        input  wire gp_c_start,
        input  wire gp_up_z,
        output wire gp_sel,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXILite
		input wire  s00_axilite_aclk,
		input wire  s00_axilite_aresetn,
		input wire [C_S00_AXILite_ADDR_WIDTH-1 : 0] s00_axilite_awaddr,
		input wire [2 : 0] s00_axilite_awprot,
		input wire  s00_axilite_awvalid,
		output wire  s00_axilite_awready,
		input wire [C_S00_AXILite_DATA_WIDTH-1 : 0] s00_axilite_wdata,
		input wire [(C_S00_AXILite_DATA_WIDTH/8)-1 : 0] s00_axilite_wstrb,
		input wire  s00_axilite_wvalid,
		output wire  s00_axilite_wready,
		output wire [1 : 0] s00_axilite_bresp,
		output wire  s00_axilite_bvalid,
		input wire  s00_axilite_bready,
		input wire [C_S00_AXILite_ADDR_WIDTH-1 : 0] s00_axilite_araddr,
		input wire [2 : 0] s00_axilite_arprot,
		input wire  s00_axilite_arvalid,
		output wire  s00_axilite_arready,
		output wire [C_S00_AXILite_DATA_WIDTH-1 : 0] s00_axilite_rdata,
		output wire [1 : 0] s00_axilite_rresp,
		output wire  s00_axilite_rvalid,
		input wire  s00_axilite_rready
	);
    wire [31:0]gp_status;
// Instantiation of Axi Bus Interface S00_AXILite
	SEGAGamePad2_slave_lite_v1_0_S00_AXILite # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXILite_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXILite_ADDR_WIDTH)
	) SEGAGamePad2_slave_lite_v1_0_S00_AXILite_inst (
		.S_AXI_ACLK(s00_axilite_aclk),
		.S_AXI_ARESETN(s00_axilite_aresetn),
		.S_AXI_AWADDR(s00_axilite_awaddr),
		.S_AXI_AWPROT(s00_axilite_awprot),
		.S_AXI_AWVALID(s00_axilite_awvalid),
		.S_AXI_AWREADY(s00_axilite_awready),
		.S_AXI_WDATA(s00_axilite_wdata),
		.S_AXI_WSTRB(s00_axilite_wstrb),
		.S_AXI_WVALID(s00_axilite_wvalid),
		.S_AXI_WREADY(s00_axilite_wready),
		.S_AXI_BRESP(s00_axilite_bresp),
		.S_AXI_BVALID(s00_axilite_bvalid),
		.S_AXI_BREADY(s00_axilite_bready),
		.S_AXI_ARADDR(s00_axilite_araddr),
		.S_AXI_ARPROT(s00_axilite_arprot),
		.S_AXI_ARVALID(s00_axilite_arvalid),
		.S_AXI_ARREADY(s00_axilite_arready),
		.S_AXI_RDATA(s00_axilite_rdata),
		.S_AXI_RRESP(s00_axilite_rresp),
		.S_AXI_RVALID(s00_axilite_rvalid),
		.S_AXI_RREADY(s00_axilite_rready),
		
        .gp_status(gp_status),
        .polling(polling),
        .select(select),
        .interrupt(interrupt)
	);

	// Add user logic here
	SEGAGamePad_logic #(
        .DELAY_US_TICKS     (DELAY_US_TICKS)
    ) SEGAGamePad_logic_inst (
        .clk        (s00_axilite_aclk),
        .rst_n      (s00_axilite_aresetn),
        //.interrupt  (interrupt),
        // режим непрерываного опроса
        .polling      (polling),
        // управление сигналом sel в ручном режиме
        .select(select),
        // иниерфейс с GamePad
        .gp_up_z(gp_up_z),
        .gp_down_y(gp_down_y),
        .gp_left_x(gp_left_x),
        .gp_right_mode(gp_right_mode),
        .gp_c_start(gp_c_start),
        .gp_b_a(gp_b_a),
        .gp_sel(gp_sel),
        // статусный регистр
        .gp_status(gp_status)
    );
	// User logic ends

	endmodule
