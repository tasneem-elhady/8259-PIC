module controller (
    input         write_initial_command_word_1_reset,
    input         write_initial_command_word_2_4,
    input         write_operation_control_word_1,
    input         write_operation_control_word_2,
    input         write_operation_control_word_3,
    // input clk,
    input [7:0]   highest_level_in_service,
    input [7:0]   interrupt,
    input         interrupt_acknowledge_n,
    input         cascade_slave,
    input         cascade_slave_enable,
    input         cascade_output_ack_2,

    output wire   write_initial_command_word_3,
    output reg level_or_edge_triggered_config,
    output reg[7:0] end_of_interrupt,
    output reg[2:0] priority_rotate,
    output reg      enable_read_register,
    output reg      read_register_isr_or_irr,
    output reg [7:0]interrupt_mask,
    output reg      interrupt_to_cpu,
    output reg      freeze,
    output reg[7:0] clear_interrupt_request,
    output reg      latch_in_service,
    output reg          out_control_logic_data,
    output reg  [7:0]   control_logic_data,
    output reg  [7:0] acknowledge_interrupt,
    output reg  [1:0] control_state,
    output reg  single_or_cascade_config,
    // output reg           data_bus_io,


    input [7:0] internal_data_bus
);

common c();
// ISR
    reg [7:0] interrupt_vector_address;

  
//registers
    // reg single_or_cascade_config;
    reg set_icw4_config;
    reg auto_eoi_config; 
    reg auto_rotate_mode;
    // reg [7:0] cascade_device_config;
    // reg [7:0] acknowledge_interrupt;

//State machine that write ICWs
    reg [1:0] next_command_state;
    reg [1:0] command_state;
    
    localparam CMD_READY = 2'b00;
    localparam WRITE_ICW2 = 2'b01;
    localparam WRITE_ICW3 = 2'b10;
    localparam WRITE_ICW4 = 2'b11;



    always @(*) begin
        if (write_initial_command_word_1_reset == 1'b1)
            next_command_state = WRITE_ICW2;
        else if (write_initial_command_word_2_4 == 1'b1) begin
            case (command_state)
                WRITE_ICW2: begin
                //    if (single_or_cascade_config == 1'b0)
                //       next_command_state = WRITE_ICW3;
                //   else 
                  if (set_icw4_config == 1'b1)
                      next_command_state = WRITE_ICW4;
                   else
                        next_command_state = CMD_READY;
                end
                WRITE_ICW3: begin
                   if (set_icw4_config == 1'b1)
                       next_command_state = WRITE_ICW4;
                   else
                        next_command_state = CMD_READY;
                end
                WRITE_ICW4: begin
                    next_command_state = CMD_READY;
                end
                default: begin
                    command_state = CMD_READY;
                end
            endcase
        end
        else
            next_command_state = next_command_state;
    end

    always@(posedge write_initial_command_word_2_4) /@(negedge clk)*/   begin
            command_state = next_command_state;
    end

 //   Writing registers/command signals
    wire    write_initial_command_word_2 = (command_state == WRITE_ICW2) & write_initial_command_word_2_4;
    assign  write_initial_command_word_3 = (command_state == WRITE_ICW3) & write_initial_command_word_2_4;
    wire    write_initial_command_word_4 = (command_state == WRITE_ICW4) & write_initial_command_word_2_4;
    wire    write_operation_control_word_1_registers = (command_state == CMD_READY) & write_operation_control_word_1;
    wire    write_operation_control_word_2_registers = (next_command_state == CMD_READY||(command_state == CMD_READY)) & write_operation_control_word_2;
    wire    write_operation_control_word_3_registers = (next_command_state == CMD_READY||(command_state == CMD_READY)) & write_operation_control_word_3;
    

    // LTIM
    always@(*) /*@(negedge clk, posedge write_initial_command_word_1_reset)*/ begin
        if (write_initial_command_word_1_reset == 1'b1)
            level_or_edge_triggered_config <= internal_data_bus[3];
        else
            level_or_edge_triggered_config <= level_or_edge_triggered_config;
    end

    // SNGL
    always@(*) /*@(negedge clk, posedge write_initial_command_word_1_reset)*/ begin
        if (write_initial_command_word_1_reset == 1'b1)
            single_or_cascade_config <= internal_data_bus[1];
        else
            single_or_cascade_config <= single_or_cascade_config;
    end

    // IC4
    always@(*) /*@(negedge clk, posedge write_initial_command_word_1_reset)*/ begin
        if (write_initial_command_word_1_reset == 1'b1)
            set_icw4_config <= internal_data_bus[0];
        else
            set_icw4_config <= set_icw4_config;
    end

    //
    // Initialization command word 2
    // T7-T3 (8086, 8088)
    always@(*) /*@(negedge clk, posedge write_initial_command_word_1_reset)*/ begin
        if (write_initial_command_word_1_reset == 1'b1)
            interrupt_vector_address[7:3] <= 5'b00000;
        else if (write_initial_command_word_2 == 1'b1)
            interrupt_vector_address[7:3] <= internal_data_bus[7:3];
        else
            interrupt_vector_address[7:3] <= interrupt_vector_address[7:3];
    end

    // //
    // // Initialization command word 3
    // // S7-S0 (MASTER) or ID2-ID0 (SLAVE)
    // always@(*) /*@(negedge clk, posedge write_initial_command_word_1_reset)*/ begin
    //     if (write_initial_command_word_1_reset == 1'b1)
    //         cascade_device_config <= 8'b00000000;
    //     else if (write_initial_command_word_3 == 1'b1)
    //         cascade_device_config <= internal_data_bus;
    //     else
    //         cascade_device_config <= cascade_device_config;
    // end


    // AEOI
    always@(*) /*@(negedge clk, posedge write_initial_command_word_1_reset)*/ begin
        if (write_initial_command_word_1_reset == 1'b1)
            auto_eoi_config <= 1'b0;
        else if (write_initial_command_word_4 == 1'b1)
            auto_eoi_config <= internal_data_bus[1];
        else
            auto_eoi_config <= auto_eoi_config;
    end

     // State
    // reg [1:0] control_state;
    reg [1:0] next_control_state;

    localparam CTL_READY = 2'b00;
    localparam ACK1 = 2'b01;
    localparam ACK2 = 2'b10;

    // Detect ACK edge
        reg    prev_interrupt_acknowledge_n;

        always@(*)/*@(negedge clk,posedge write_initial_command_word_1_reset)*/ begin
        if (write_initial_command_word_1_reset)
            prev_interrupt_acknowledge_n <= 1'b1;
        else
            prev_interrupt_acknowledge_n <= interrupt_acknowledge_n;
    end

    wire    nedge_interrupt_acknowledge =  prev_interrupt_acknowledge_n & ~interrupt_acknowledge_n;
    wire    pedge_interrupt_acknowledge = ~prev_interrupt_acknowledge_n &  interrupt_acknowledge_n;

    // State machine
    always@(/interrupt_acknowledge_n or write_operation_control_word_2_registers/*) begin
        case (control_state)
            CTL_READY: begin
                //*****
                if (write_operation_control_word_2_registers == 1'b1)
                    next_control_state = CTL_READY;
                else if (nedge_interrupt_acknowledge == 1'b0)
                    next_control_state = CTL_READY;
                else
                    next_control_state = ACK1;
            end
            ACK1: begin
                if (pedge_interrupt_acknowledge == 1'b0)
                    next_control_state = ACK1;
                else
                    next_control_state = ACK2;
            end
            ACK2: begin
                if (pedge_interrupt_acknowledge == 1'b0)
                    next_control_state = ACK2;
                else
                    next_control_state = CTL_READY;
            end
            default: begin
                next_control_state = CTL_READY;
            end
        endcase
    end
    always@(/interrupt_acknowledge_n or write_initial_command_word_1_reset/*)/*@(negedge clk,posedge write_initial_command_word_1_reset)*/ begin
        if (write_initial_command_word_1_reset == 1'b1)
            control_state <= CTL_READY;
        else
            control_state <= next_control_state;
    end

    // Latch in service register signal*************
    always@(*) begin
        if (write_initial_command_word_1_reset == 1'b1)
            latch_in_service = 1'b0;
        else if ((control_state == CTL_READY))
            latch_in_service = 1'b1;
        else if (cascade_slave == 1'b0)
            latch_in_service = (control_state == CTL_READY) & (next_control_state != CTL_READY);
        else
            latch_in_service = (control_state == ACK2) & (cascade_slave_enable == 1'b1) & (nedge_interrupt_acknowledge == 1'b1);
    end

     // End of acknowledge sequence
    //  control state is ack2 and next is ctl ready
    wire    end_of_acknowledge_sequence =   (control_state != CTL_READY) & (next_control_state == CTL_READY);
    // Operation control word 1
    //

    // IMR
    always@(*) /*@(negedge clk, posedge write_initial_command_word_1_reset)*/ begin
        if (write_initial_command_word_1_reset == 1'b1)
            interrupt_mask <= 8'b11111111;
        else if ((write_operation_control_word_1_registers == 1'b1)) //&& (special_mask_mode == 1'b0))
            interrupt_mask <= internal_data_bus;
        else
            interrupt_mask <= interrupt_mask;
    end
    
// Operation control word 2
    //
    // End of interrupt
    always@(*) begin/***@ **/
        if (write_initial_command_word_1_reset  == 1'b1)
            end_of_interrupt = 8'b11111111;
        else if ((auto_eoi_config == 1'b1) && (end_of_acknowledge_sequence == 1'b1))
            end_of_interrupt = acknowledge_interrupt;
        else if (write_operation_control_word_2 == 1'b1) begin
            case (internal_data_bus[6:5])//*******
                2'b01:   end_of_interrupt = highest_level_in_service;
                2'b11:   end_of_interrupt = c.num2bit(internal_data_bus[2:0]);/****num*/
                default: end_of_interrupt = 8'b00000000;
            endcase
        end
        else
            end_of_interrupt = 8'b00000000;
    end

    // Auto rotate mode
    always@(*)/*@(negedge clk, posedge write_initial_command_word_1_reset)*/ begin
        if (write_initial_command_word_1_reset == 1'b1)
            auto_rotate_mode <= 1'b0;
        else if (write_operation_control_word_2 == 1'b1) begin
            case (internal_data_bus[7:5])
                3'b000:  auto_rotate_mode <= 1'b0;//clear
                3'b100:  auto_rotate_mode <= 1'b1;//set
                default: auto_rotate_mode <= auto_rotate_mode;
            endcase
        end
        else
            auto_rotate_mode <= auto_rotate_mode;
    end

     // Rotate
    always@(*) /*@(negedge clk, posedge write_initial_command_word_1_reset)*/ begin
        if (write_initial_command_word_1_reset == 1'b1)
            priority_rotate <= 3'b111;
        else if ((auto_rotate_mode == 1'b1) && (end_of_acknowledge_sequence == 1'b1))
            priority_rotate <= c.bit2num(acknowledge_interrupt);//3b
        else if (write_operation_control_word_2 == 1'b1) begin
            case (internal_data_bus[7:5])
                3'b101:  priority_rotate <= c.bit2num(highest_level_in_service);
                3'b11?:  priority_rotate <= internal_data_bus[2:0];/******/
                default: priority_rotate <= priority_rotate;
            endcase
        end
        else
            priority_rotate <= priority_rotate;
    end

    // Operation control word 3
    // RR/RIS
    always@(*) /*@(negedge clk, posedge write_initial_command_word_1_reset)*/ begin
        if (write_initial_command_word_1_reset == 1'b1) begin
            enable_read_register     <= 1'b1;
            read_register_isr_or_irr <= 1'b0;//IRR
        end
        else if (write_operation_control_word_3_registers == 1'b1) begin
            enable_read_register     <= internal_data_bus[1];//RR
            read_register_isr_or_irr <= internal_data_bus[0];//RIS
        end
        else begin
            enable_read_register     <= enable_read_register;
            read_register_isr_or_irr <= read_register_isr_or_irr;
        end
    end

    // Interrupt control signals
    // INT
    always@(*) /*@(negedge clk, posedge write_initial_command_word_1_reset)*/ begin
        if (write_initial_command_word_1_reset == 1'b1)
            interrupt_to_cpu <= 1'b0;
        else if (interrupt != 8'b00000000)
            interrupt_to_cpu <= 1'b1;
        else if (end_of_acknowledge_sequence == 1'b1)
            interrupt_to_cpu <= 1'b0;
        else
            interrupt_to_cpu <= interrupt_to_cpu;
    end

    // freeze
    always@(*) /*@(negedge clk, posedge write_initial_command_word_1_reset)*/ begin
        if (next_control_state == CTL_READY)
            freeze <= 1'b0;
        else
            freeze <= 1'b1;
    end

    // clear_interrupt_request
    always@(*) begin
        if (write_initial_command_word_1_reset == 1'b1)
            clear_interrupt_request = 8'b11111111;
        else if (latch_in_service == 1'b0)//****
            clear_interrupt_request = 8'b00000000;
        else
            clear_interrupt_request = interrupt;
    end

    // interrupt buffer
    always@(*) /*@(negedge clk, posedge write_initial_command_word_1_reset)*/ begin
        if (write_initial_command_word_1_reset == 1'b1)
            acknowledge_interrupt <= 8'b00000000;
        else if (end_of_acknowledge_sequence)
            acknowledge_interrupt <= 8'b00000000;
        else if (latch_in_service == 1'b1)
            acknowledge_interrupt <= interrupt;
        else
            acknowledge_interrupt <= acknowledge_interrupt;
    end
    
     // interrupt buffer
    reg  [7:0]   interrupt_when_ack1;

    always@(*) /*@(negedge clk, posedge write_initial_command_word_1_reset)*/ begin
        if (write_initial_command_word_1_reset == 1'b1)
            interrupt_when_ack1 <= 8'b00000000;
        else if (control_state == ACK1)/******/
            interrupt_when_ack1 <= interrupt;
        else
            interrupt_when_ack1 <= interrupt_when_ack1;
    end
    
    // control_logic_data
    always@(*) begin
        if (interrupt_acknowledge_n == 1'b0) begin
            // Acknowledge
            case (control_state)
                CTL_READY: begin
                    // if (cascade_slave == 1'b0) begin
                            // out_control_logic_data = 1'b0;
                            // control_logic_data     = 8'b00000000;
                    // end
                    // else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'b00000000;
                    // end
                end
                ACK1: begin
                    // if (cascade_slave == 1'b0) begin
                            // out_control_logic_data = 1'b0;
                            // control_logic_data     = 8'b00000000;
                    // end
                    // else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'b00000000;
                    // end
                end
                ACK2: begin
                    if (cascade_output_ack_2 == 1'b1) begin
                        out_control_logic_data = 1'b1;
                        if (cascade_slave == 1'b1)
                            control_logic_data[2:0] = c.bit2num(interrupt_when_ack1);
                        else
                            control_logic_data[2:0] = c.bit2num(acknowledge_interrupt);

                         control_logic_data = {interrupt_vector_address[7:3], control_logic_data[2:0]};
                    end
                    else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'b00000000;
                    end
                end
                default: begin
                    out_control_logic_data = 1'b0;
                    control_logic_data     = 8'b00000000;
                end
            endcase
        end
        else begin
            out_control_logic_data = 1'b0;
            control_logic_data     = 8'b00000000;
        end
    end
endmodule
