module controller (
    input write_initial_command_word_1_reset,
    input write_initial_command_word_2_4,
    input write_operation_control_word_1,
    input write_operation_control_word_2,
    input write_operation_control_word_3,
    input clk,

    output level_or_edge_triggered,

    inout [7:0] internal_data_bus
);
// ISR
    reg [7:0] interrupt_vector_address;

  
//registers
    reg level_or_edge_triggered_config;
    reg single_or_cascade_config;
    reg set_icw4_config;
    reg auto_eoi_config; 
    reg auto_rotate_mode;
    reg [7:0] cascade_device_config;


    assign level_or_edge_triggered = level_or_edge_triggered_config;
//State machine that write ICWs
    reg [1:0] next_command_state;
    reg [1:0] command_state;
    
    localparam CMD_READY = 2'b00;
    localparam WRITE_ICW2 = 2'b01;
    localparam WRITE_ICW3 = 2'b10;
    localparam WRITE_ICW4 = 2'b11;


    always begin
        if (write_initial_command_word_1_reset == 1'b1)
            next_command_state <= WRITE_ICW2;
        else if (write_initial_command_word_2_4 == 1'b1) begin
            case (command_state)
                WRITE_ICW2: begin
                   if (single_or_cascade_config == 1'b0)
                      next_command_state = WRITE_ICW3;
                  else if (set_icw4_config == 1'b1)
                      next_command_state = WRITE_ICW4;
                   else
                        next_command_state <= CMD_READY;
                end
                WRITE_ICW3: begin
                   if (set_icw4_config == 1'b1)
                       next_command_state = WRITE_ICW4;
                   else
                        next_command_state <= CMD_READY;
                end
                WRITE_ICW4: begin
                    next_command_state <= CMD_READY;
                end
                default: begin
                    next_command_state <= CMD_READY;
                end
            endcase
        end
        else
            next_command_state <= command_state;
    end

    always @(negedge clk) begin
            command_state <= next_command_state;
    end

 //   Writing registers/command signals
    wire    write_initial_command_word_2 = (command_state == WRITE_ICW2) & write_initial_command_word_2_4;
    wire    write_initial_command_word_3 = (command_state == WRITE_ICW3) & write_initial_command_word_2_4;
    wire    write_initial_command_word_4 = (command_state == WRITE_ICW4) & write_initial_command_word_2_4;
    wire    write_operation_control_word_1_registers = (command_state == CMD_READY) & write_operation_control_word_1;
    wire    write_operation_control_word_2_registers = (command_state == CMD_READY) & write_operation_control_word_2;
    wire    write_operation_control_word_3_registers = (command_state == CMD_READY) & write_operation_control_word_3;
    


    // LTIM
    always @(negedge clk, posedge write_initial_command_word_1_reset) begin
        if (write_initial_command_word_1_reset == 1'b1)
            level_or_edge_triggered_config <= internal_data_bus[3];
        else
            level_or_edge_triggered_config <= level_or_edge_triggered_config;
    end

    // SNGL
    always @(negedge clk, posedge write_initial_command_word_1_reset) begin
        if (write_initial_command_word_1_reset == 1'b1)
            single_or_cascade_config <= internal_data_bus[1];
        else
            single_or_cascade_config <= single_or_cascade_config;
    end

    // IC4
    always @(negedge clk, posedge write_initial_command_word_1_reset) begin
        if (write_initial_command_word_1_reset == 1'b1)
            set_icw4_config <= internal_data_bus[0];
        else
            set_icw4_config <= set_icw4_config;
    end

    //
    // Initialization command word 2
    // T7-T3 (8086, 8088)
    always @(negedge clk, posedge write_initial_command_word_1_reset) begin
        if (write_initial_command_word_1_reset == 1'b1)
            interrupt_vector_address[7:3] <= 5'b00000;
        else if (write_initial_command_word_2 == 1'b1)
            interrupt_vector_address[7:3] <= internal_data_bus[7:3];
        else
            interrupt_vector_address[7:3] <= interrupt_vector_address[7:3];
    end

    //
    // Initialization command word 3
    // S7-S0 (MASTER) or ID2-ID0 (SLAVE)
    always @(negedge clk, posedge write_initial_command_word_1_reset) begin
        if (write_initial_command_word_1_reset == 1'b1)
            cascade_device_config <= 8'b00000000;
        else if (write_initial_command_word_3 == 1'b1)
            cascade_device_config <= internal_data_bus;
        else
            cascade_device_config <= cascade_device_config;
    end


    // AEOI
    always @(negedge clk, posedge write_initial_command_word_1_reset) begin
        if (write_initial_command_word_1_reset == 1'b1)
            auto_eoi_config <= 1'b0;
        else if (write_initial_command_word_4 == 1'b1)
            auto_eoi_config <= internal_data_bus[1];
        else
            auto_eoi_config <= auto_eoi_config;
    end

    // // Operation control word 1
    // //
    // // IMR
    // always @(negedge clk, posedge write_initial_command_word_1_reset) begin
    //     if (write_initial_command_word_1_reset == 1'b1)
    //         interrupt_mask <= 8'b11111111;
    //     else if ((write_operation_control_word_1_registers == 1'b1)) //&& (special_mask_mode == 1'b0))
    //         interrupt_mask <= internal_data_bus;
    //     else
    //         interrupt_mask <= interrupt_mask;
    // end
endmodule

