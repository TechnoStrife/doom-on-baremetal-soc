`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 08:12:54 PM
// Design Name: 
// Module Name: gamepad_logic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SEGAGamePad_logic
    #(
        // Количество тактов clk для отсчета одной мкс
        DELAY_US_TICKS = 150
    )
    (
        input clk,
        input rst_n,
        
        // иниерфейс с GamePad
        input gp_up_z,
        input gp_down_y,
        input gp_left_x,
        input gp_right_mode,
        input gp_c_start,
        input gp_b_a,
        output logic gp_sel,
        // статусный регистр
        output logic [31:0] gp_status,
        // режим непрерываного опроса
        input polling,
        // управление сигналом sel в ручном режиме
        input select
    );
 
    // нумерация разрядов регистра статуса
    typedef enum {
        UP_BTN = 0,
        DOWN_BTN,
        LEFT_BTN,
        RIGTH_BTN,
        A_BTN, B_BTN, C_BTN,
        START_BTN, MODE_BTN,
        X_BTN, Y_BTN, Z_BTN
    } BUTTON_t;
 
 
    /*************************************************************************/
    // Реализация счетчиков и задержек. 
    // Время установки значений - 20мкс. Между опросами 10 мс
    localparam int C_WAIT_DELAY = 20; // 20 us
    localparam int C_POLLING_DELAY = 10000; // 10 ms
    
    // $bits - возвращает количество бит, необходимое для хранения аргумента.
    logic [$bits(DELAY_US_TICKS)-1 : 0] us_counter;
    logic [$bits(C_WAIT_DELAY)-1 : 0] dly_counter;
    logic [$bits(C_POLLING_DELAY)-1 : 0] polling_counter;
    // импульсы переполнения счетчиков. 
    // !!! должны быть длительностью в 1 такт!
    logic counter_us_pulse;
    logic dly_pulse;
    logic polling_pulse;
     
    // overflow flags
    assign counter_us_pulse = ((us_counter == DELAY_US_TICKS - 1) ? '1 : '0) ;
    assign dly_pulse = ((counter_us_pulse && dly_counter == C_WAIT_DELAY - 1) ? '1 : '0);
    assign polling_pulse = ((counter_us_pulse && polling_counter == C_POLLING_DELAY - 1) ? '1 : '0);
    
    // US counter
    always_ff @(posedge clk) begin : us_counter_alw
        if (!rst_n) us_counter <= '0;
        else if (counter_us_pulse) us_counter <= '0;
        else us_counter <= us_counter + 1;
    end : us_counter_alw
    
    // Input setup delay
    always_ff @(posedge clk) begin : dly_counter_alw
        if (!rst_n) dly_counter <= '0;
        else if (dly_pulse) dly_counter <= '0;
        else if (counter_us_pulse) dly_counter <= dly_counter + 1;
        else dly_counter <= dly_counter;
    end : dly_counter_alw
    
    // Delay between polls
    always_ff @(posedge clk) begin : polling_counter_alw
        if (!rst_n) polling_counter <= '0;
        else if (polling_pulse) polling_counter <= '0;
        else if (counter_us_pulse) polling_counter <= polling_counter + 1;
        else polling_counter <= polling_counter;
    end : polling_counter_alw
    
    // Автомат управления лоя опроса состояния GamePad.
    typedef enum {
        IDLE,
        WAIT_LOW, READ_LOW,
        WAIT_HIGH,READ_HIGH
    } gp_read_state_t;
    
    gp_read_state_t state, next_state;
    
    always_ff @(posedge clk)
        if(!rst_n) state <= IDLE;
        else state <= next_state;
    
    always_comb begin : nest_state_alw
        case(state)
            IDLE:
                if (polling_pulse) next_state <= WAIT_LOW;
                else next_state <= state;
            WAIT_LOW: 
                if (dly_pulse) next_state <= READ_LOW;
                else next_state <= state;
            READ_LOW: next_state <= WAIT_HIGH;
            WAIT_HIGH: 
                if (dly_pulse) next_state <= READ_HIGH;
                else next_state <= state;
            READ_HIGH: next_state <= IDLE;
            default : next_state <= IDLE;
        endcase
    end : nest_state_alw
    
    /*************************************************************************/
    // Захват занчаений в регистр. 
    // TODO: Модифицировать при необходимости
    always_ff @(posedge clk) begin
        if (!rst_n) gp_sel <= '0;
        else begin
            if (polling && state == WAIT_LOW) gp_sel <= '0;
            else if (polling && state == WAIT_HIGH) gp_sel <= '1;
            else if (~polling) gp_sel <= select;
        end
    end
    
    always_ff @(posedge clk) begin : read_btn_alw
        if (!rst_n) gp_status <= '0;
        else begin
            case(state)
                READ_LOW: begin
                    gp_status[UP_BTN] <= ~gp_up_z;
                    gp_status[DOWN_BTN] <= ~gp_down_y;
                    gp_status[A_BTN] <= ~gp_b_a;
                    gp_status[START_BTN]<= ~gp_c_start;
                end
                READ_HIGH: begin
                    gp_status[UP_BTN] <= ~gp_up_z;
                    gp_status[DOWN_BTN] <= ~gp_down_y;
                    gp_status[LEFT_BTN] <= ~gp_left_x;
                    gp_status[RIGTH_BTN]<= ~gp_right_mode;
                    gp_status[B_BTN] <= ~gp_b_a;
                    gp_status[C_BTN] <= ~gp_c_start;
                end
            endcase
            gp_status[21:16] <= {
                gp_c_start,
                gp_b_a,
                gp_right_mode,
                gp_left_x,
                gp_down_y,
                gp_up_z
            };
        end;
    end : read_btn_alw
endmodule
