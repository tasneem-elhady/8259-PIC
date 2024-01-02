`define TB_CYCLE        20
`define TB_FINISH_COUNT 20000

module Interrupt_Request_tb();

    //
    // Generate wave file to check
    //
`ifdef IVERILOG
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end
`endif

    //
    // Generate clock
    //
    reg   clock;
    initial clock = 1'b1;
    always #(20 / 2) clock = ~clock;

    //
    // Generate reset
    //
    reg write_initial_command_word_1_reset;
    initial begin
        write_initial_command_word_1_reset = 1'b1;
            # (20 * 10)
        write_initial_command_word_1_reset = 1'b0;
    end

    //
    // Module under test
    //
    //
    reg            level_triggered_config;
    reg            freeze;
    reg    [7:0]   clear_interrupt_request;
    reg    [7:0]   interrupt_request_pin;
    wire   [7:0]   interrupt_request_register;

     Interrupt_Request IRR_tb(
        //  clock,                       
        .write_initial_command_word_1_reset     (write_initial_command_word_1_reset),                             
        // Inputs from control logic                                
        .level_triggered_config        (level_triggered_config),                            
        .freeze                                (freeze),           
        .clear_interrupt_request               (clear_interrupt_request),          
        // pic input pins                                      
        .interrupt_request_pin                 (interrupt_request_pin),           
        // Outputs                               
        .interrupt_request_register            (interrupt_request_register)                                                                  
    );

    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        level_triggered_config = 1'b0;
        freeze                  = 1'b0;
        interrupt_request_pin   = 8'b00000000;
        clear_interrupt_request = 8'b00000000;
        #(20);
    end
    endtask

    //
    // Task : Level trigger interrupt
    //
    task TASK_LEVEL_TRIGGER_INTERRUPT(input [7:0] data);
    begin
        #(20 * 0);
        level_triggered_config = 1'b1;
        #(20 * 1);
        interrupt_request_pin   = data;
        #(20 * 1);
        clear_interrupt_request = data;
        #(20 * 1);
        clear_interrupt_request = 8'b00000000;
        #(20 * 1);
    end
    endtask

    //
    // Task : Edge trigger interrupt
    //
    task TASK_EDGE_TRIGGER_INTERRUPT(input [7:0] data);
    begin
        #(20 * 0);
        level_triggered_config = 1'b0;
        #(20 * 1);
        interrupt_request_pin   = 8'b00000000;
        #(20 * 1);
        interrupt_request_pin   = data;
        #(20 * 1);
        clear_interrupt_request = data;
        #(20 * 1);
        clear_interrupt_request = 8'b00000000;
        #(20 * 1);
    end
    endtask

    //
    // Task : Clear interrupt request
    //
    task TASK_CLEAR_INTERRUPT_REQUEST(input [7:0] data);
    begin
        #(20 * 0);
        clear_interrupt_request = data;
        #(20 * 1);
    end
    endtask

    //
    // Task : Interrupt test
    //
    task TASK_INTERRUPT_TEST();
    begin
        #(20 * 0);
        TASK_LEVEL_TRIGGER_INTERRUPT(8'b00000001);
        TASK_LEVEL_TRIGGER_INTERRUPT(8'b00000010);
        TASK_LEVEL_TRIGGER_INTERRUPT(8'b00000100);
        TASK_LEVEL_TRIGGER_INTERRUPT(8'b00001000);
        TASK_LEVEL_TRIGGER_INTERRUPT(8'b00010000);
        TASK_LEVEL_TRIGGER_INTERRUPT(8'b00100000);
        TASK_LEVEL_TRIGGER_INTERRUPT(8'b01000000);
        TASK_LEVEL_TRIGGER_INTERRUPT(8'b10000000);
        TASK_LEVEL_TRIGGER_INTERRUPT(8'b00000000);

        TASK_CLEAR_INTERRUPT_REQUEST(8'b11111111);
        TASK_CLEAR_INTERRUPT_REQUEST(8'b00000000);

        TASK_EDGE_TRIGGER_INTERRUPT(8'b10000000);
        TASK_EDGE_TRIGGER_INTERRUPT(8'b01000000);
        TASK_EDGE_TRIGGER_INTERRUPT(8'b00100000);
        TASK_EDGE_TRIGGER_INTERRUPT(8'b00010000);
        TASK_EDGE_TRIGGER_INTERRUPT(8'b00001000);
        TASK_EDGE_TRIGGER_INTERRUPT(8'b00000100);
        TASK_EDGE_TRIGGER_INTERRUPT(8'b00000010);
        TASK_EDGE_TRIGGER_INTERRUPT(8'b00000001);

        TASK_CLEAR_INTERRUPT_REQUEST(8'b11111111);
        TASK_CLEAR_INTERRUPT_REQUEST(8'b00000000);

        #(20 * 1);
    end
    endtask


    //
    // Test pattern
    //
    initial begin
        TASK_INIT();

        TASK_INTERRUPT_TEST();

        freeze = 1'b1;

        TASK_INTERRUPT_TEST();

        #(20 * 1);
        // End of simulation
`ifdef IVERILOG
        $finish;
`elsif  MODELSIM
        $stop;
`else
        $finish;
`endif
    end
endmodule


