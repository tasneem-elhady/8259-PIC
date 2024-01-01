module Bus_Control_tb();


//     //
//     // Generate wave file to check
//     //
// `ifdef IVERILOG
//     initial begin
//         $dumpfile("tb.vcd");
//         $dumpvars(0, tb);
//     end
// `endif


    //
    // Module under test
    //
    //
    reg           chip_select_n;
    reg           read_enable_n;
    reg           write_enable_n;
    reg           [7:0]   data_bus;
    reg           A0;
    wire           [7:0]   internal_data_bus;
    wire           write_initial_command_word_1_reset;
    wire           write_initial_command_word_2_4;
    wire           write_operation_control_word_1;
    wire           write_operation_control_word_2;
    wire           write_operation_control_word_3;
    wire           read;

    wire           [7:0]   data_bus_in;
    assign data_bus_in = data_bus;
    Bus_Control_Logic bcl_tb (
         chip_select_n,
         read_enable_n,
         write_enable_n,
         data_bus_in,
         A0,
         internal_data_bus,
         write_initial_command_word_1_reset,
         write_initial_command_word_2_4,
         write_operation_control_word_1,
         write_operation_control_word_2,
         write_operation_control_word_3,
         read
    );
    //
    // Generate clock
    //
    reg clock;
    initial clock = 1'b1;
    always #(20 / 2) clock = ~clock;

    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
      chip_select_n   = 1'b0;
      write_enable_n  = 1'b0;
      read_enable_n   = 1'b1;
      A0              = 1'b0;
      data_bus        = 8'b00010000;
            # (20 * 1)
        chip_select_n   = 1'b1;
        
        write_enable_n  = 1'b1;
        A0         = 1'b0;
        data_bus     = 8'b00000000;
        #(20 *1);
    end
    endtask

    //
    // Task : Write data
    //
    task TASK_WRITE_DATA(input [1:0] addr, input [7:0] data);
    begin
        #(20 * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        A0         = addr;
        data_bus     = data;
        #(20 * 1);
        write_enable_n  = 1'b1;
        chip_select_n   = 1'b1;
        #(20 * 1);
    end
    endtask


    //
    // Test pattern
    //
    initial begin
        TASK_INIT();

        TASK_WRITE_DATA(1'b0, 8'b00010000);
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        TASK_WRITE_DATA(1'b0, 8'b00000000);
        TASK_WRITE_DATA(1'b0, 8'b00001000);
        #(20 * 1);
        read_enable_n   = 1'b0;
        chip_select_n   = 1'b0;
        #(20 * 1);
        read_enable_n   = 1'b1;
        chip_select_n   = 1'b1;
        #(20 * 1);
        read_enable_n   = 1'b0;
        chip_select_n   = 1'b0;
        #(20 * 1);
        read_enable_n   = 1'b1;
        #(20 * 1);
        chip_select_n   = 1'b1;
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
