module tb_controller();
    //
    // Generate clock
    //
    reg   clock;
    initial clock = 1'b1;
    always #(10) clock = ~clock;

    //
    // Generate reset
    //
    reg write_initial_command_word_1_reset;
    initial begin
        write_initial_command_word_1_reset = 1'b1;
            # (20* 10)
        write_initial_command_word_1_reset = 1'b0;
    end


    //
    // Module under test
    //
    //reg           write_initial_command_word_1_reset;
    reg           write_initial_command_word_2_4;
    reg           write_operation_control_word_1;
    reg           write_operation_control_word_2;
    reg           write_operation_control_word_3;
    // input clk,
    reg   [7:0]   highest_level_in_service;
    reg   [7:0]   interrupt;
    reg           interrupt_acknowledge_n;
    reg           cascade_slave;
    reg           cascade_slave_enable;
    reg           cascade_output_ack_2_3;

     reg level_or_edge_triggered_config;
     wire  [7:0] end_of_interrupt;
     wire  [2:0] priority_rotate;
     wire      enable_read_register;
     wire      read_register_isr_or_irr;
     wire [7:0]interrupt_mask;
     wire      interrupt_to_cpu;
     wire      freeze;
     wire [7:0] clear_interrupt_request;
     wire       latch_in_service;
     wire            out_control_logic_data;
     wire [7:0]   control_logic_data;
     



    reg [7:0] internal_data_bus;

    controller c_tb (.*);
 
    task INIT();
    begin
               write_initial_command_word_1_reset = 1;
               write_initial_command_word_2_4 = 0;
               write_operation_control_word_1 = 0;
               write_operation_control_word_2 = 0;
               write_operation_control_word_3 = 0;
    // input clk,
               highest_level_in_service = 0;
               interrupt = 0;
               interrupt_acknowledge_n = 0;
               cascade_slave = 0;
               cascade_slave_enable = 0;
               cascade_output_ack_2_3 = 0;
               internal_data_bus = 8'b00000000;
               #(20 * 1);
    end
    endtask

    task TASK_WRITE_ICW1(input [7:0] data);
    begin
        #(20 * 0);
        write_initial_command_word_1_reset = 1;
        internal_data_bus = data;
        #(20 * 1);
        write_initial_command_word_1_reset = 0;
        #(20 * 1);
    end
    endtask
    task TASK_WRITE_ICW2(input [7:0] data);
    begin
        #(20 * 0);
        write_initial_command_word_2_4 = 1;
        internal_data_bus = data;
        #(20 * 1);
        write_initial_command_word_2_4 = 0;
        #(20 * 1);
    end
    endtask
    task TASK_WRITE_ICW3(input [7:0] data);
    begin
        #(20 * 0);
        write_initial_command_word_2_4 = 1;
        internal_data_bus = data;
        #(20 * 1);
        write_initial_command_word_2_4 = 0;
        #(20 * 1);
    end
    endtask
    task TASK_WRITE_ICW4(input [7:0] data);
    begin
        #(20 * 0);
        write_initial_command_word_2_4 = 1;
        internal_data_bus = data;
        #(20 * 1);
        write_initial_command_word_2_4 = 0;
        #(20 * 1);
    end
    endtask
    task TASK_WRITE_OCW1(input [7:0] data);
    begin
        #(20 * 0);
        write_initial_command_word_2_4 = 1;
        write_operation_control_word_1 = 1;
        internal_data_bus = data;
        #(20 * 1);
        write_initial_command_word_2_4 = 0;
        write_operation_control_word_1 = 1;
        #(20 * 1);
    end
    endtask
    
    initial begin
        INIT();
        TASK_WRITE_ICW1( 8'b00011001);
        TASK_WRITE_ICW2( 8'b11111111);
        TASK_WRITE_ICW3( 8'b01010101);
        TASK_WRITE_ICW4( 8'b00000000);
        TASK_WRITE_OCW1 (8'b00000111);
        // interrupt = 8'b00000001;
    end
endmodule