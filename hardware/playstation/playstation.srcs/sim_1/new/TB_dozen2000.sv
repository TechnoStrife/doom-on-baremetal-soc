module TB_dozen2000
    #(
        DELAY_US_TICKS = 1000/15
    )
    ( );
    // Сигналы тактирования и сброса:
    logic ps_clk = 0;
    logic ps_rst_n = 1;
    // Скопированное объявление сигналов:
    wire [14:0]DDR_addr;
    wire [2:0]DDR_ba;
    wire DDR_cas_n;
    wire DDR_ck_n;
    wire DDR_ck_p;
    wire DDR_cke;
    wire DDR_cs_n;
    wire [3:0]DDR_dm;
    wire [31:0]DDR_dq;
    wire [3:0]DDR_dqs_n;
    wire [3:0]DDR_dqs_p;
    wire DDR_odt;
    wire DDR_ras_n;
    wire DDR_reset_n;
    wire DDR_we_n;
    wire FIXED_IO_ddr_vrn;
    wire FIXED_IO_ddr_vrp;
    wire [53:0]FIXED_IO_mio;
    wire FIXED_IO_ps_clk;
    wire FIXED_IO_ps_porb;
    wire FIXED_IO_ps_srstb;
    wire [3:0]VGA_R;
    wire [3:0]VGA_G;
    wire [3:0]VGA_B;
    wire VGA_HS;
    wire VGA_VS;
    
    
    wire GamePad_gp_sel;
    reg GamePad_gp_b_a;
    reg GamePad_gp_c_start;
    reg GamePad_gp_down_y;
    reg GamePad_gp_up_z;
    reg GamePad_gp_right_mode;
    reg GamePad_gp_left_x;
    reg delay_active = 0;
    
    // Генератор тактирования
    always #15 ps_clk <= ~ps_clk;
    // Подключение входов стактирования и сброса:
    assign FIXED_IO_ps_clk = ps_clk;
    assign FIXED_IO_ps_porb = ps_rst_n;
    assign FIXED_IO_ps_srstb = ps_rst_n;
    
    
    always_ff @(GamePad_gp_sel) begin
        if (GamePad_gp_sel) begin
            GamePad_gp_up_z <= 0;
            GamePad_gp_down_y <= 1;
            GamePad_gp_left_x <= 0;
            GamePad_gp_right_mode <= 1;
            GamePad_gp_c_start <= 1;
            GamePad_gp_b_a <= 1;
        end
        else begin
            GamePad_gp_up_z <= 1;
            GamePad_gp_down_y <= 1;
            GamePad_gp_left_x <= 1;
            GamePad_gp_right_mode <= 1;
            GamePad_gp_c_start <= 1;
            GamePad_gp_b_a <= 0;
        end
    end

    
    // подключение тестируемого модуля:
    ps_system_wrapper DUT (.*);
    // описание теста:
    logic [1:0] resp; // вспомогательный сигнал
    logic [31:0] data;
    initial begin : test
    // ждем 100нс и подаем сброс
    #100;
    ps_rst_n <= 0;
    #100;
    //снимаем сброс и ждем еще 100нс
    @(posedge ps_clk) ps_rst_n <= 1;
    #100;
    @(posedge ps_clk);
    // выполняем сброс со стороны процессора
    
    DUT.ps_system_i.processing_system7_0.inst.fpga_soft_reset(1);
    
    DUT.ps_system_i.processing_system7_0.inst.fpga_soft_reset(0);
    
    DUT.ps_system_i.processing_system7_0.inst.write_data(32'h43C0_0004, 4, 32'h0000_0003, resp);
    #1us;
    DUT.ps_system_i.processing_system7_0.inst.read_data(32'h43C0_0008, 4, data, resp);
    $display("gp_status %x", data);
    // инициализируем память по адресу 32'h0100_0000
    for(integer i=0;i<640*480*3/4;i++)
        DUT.ps_system_i.processing_system7_0.inst.write_mem(32'h00 + i,32'h0100_0000 + i*4,4);
    
    // ждем 100 нс и запускаем DMA
    #100us;
    @(posedge ps_clk);
    DUT.ps_system_i.processing_system7_0.inst.write_data(32'h4300_0000, 4, 32'h0000_0001, resp);
    DUT.ps_system_i.processing_system7_0.inst.write_data(32'h4300_005C, 4, 32'h0100_0000, resp);
    DUT.ps_system_i.processing_system7_0.inst.write_data(32'h4300_0054, 4, 640*3, resp); 
    DUT.ps_system_i.processing_system7_0.inst.write_data(32'h4300_0050, 4, 480, resp);
    
    #10ms;
    DUT.ps_system_i.processing_system7_0.inst.read_data(32'h43C0_0008, 4, data, resp);
    $display("gp_status %x", data);
    end;
endmodule
