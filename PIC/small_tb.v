
`define TB_CYCLE        20
`define TB_FINISH_COUNT 20000

module tb_8259();


    //
    // Generate clock
    //
    reg   clock;
    initial clock = 1'b1;
    always #(10) clock = ~clock;

    //
    // Generate reset
    //
    // reg write_initial_command_word_1_reset;
    // initial begin
    //     write_initial_command_word_1_reset = 1'b1;
    //         # (20* 10)
    //     write_initial_command_word_1_reset = 1'b0;
    // end


    //
    // Module under test
    //
    reg           chip_select_n;
    reg           read_enable_n;
    reg           write_enable_n;
    reg           A0;
    
    wire   [7:0]  data_bus;
    reg           cascade_io;
    wire   [2:0]  cascade_inout;
    reg           slave_program_n;
    reg           buffer_enable;
    reg           slave_program_or_enable_buffer;
    reg           interrupt_acknowledge_n;
    reg           interrupt_to_cpu;
    reg   [7:0]   interrupt_request_pin;

    top_8259 top (.*);
    
    reg           data_bus_in;
reg   [2:0]   cascade_inout_reg;
reg   [7:0]   data_bus_reg;
// assign data_bus = data_bus_reg;
// assign cascade_inout = cascade_inout_reg;


// initial
// begin
//         chip_select_n           = 1'b0;
//         read_enable_n           = 1'b1;
//         write_enable_n          = 1'b0;
//         A0                      = 1'b0;
//         data_bus_reg            = 8'b00010000;
//         cascade_inout_reg       = 3'b000;
//         slave_program_n         = 1'b1;
//         interrupt_acknowledge_n = 1'b1;
//         interrupt_request_pin   = 8'b00000000;
//         data_bus_in             = 1'b1;
//         #20
// end
//tristate buffer ?
 assign data_bus = data_bus_in ? data_bus_reg :8'bzzzzzzzz;


    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        chip_select_n   = 1'b0;
      write_enable_n  = 1'b0;
      read_enable_n   = 1'b1;
      A0              = 1'b0;
      data_bus_reg        = 8'b00010000;
      data_bus_in     = 1'b1;
            // # (20 * 2)
    //     chip_select_n   = 1'b1;
        
    //     write_enable_n  = 1'b1;
    //     A0         = 1'b0;
    //     data_bus_reg     = 8'b00000000;
    //     #(20 *2);
        #(20* 0);
        
        chip_select_n           = 1'b1;
        read_enable_n           = 1'b1;
        write_enable_n          = 1'b1;
        A0                      = 1'b0;
        data_bus_reg            = 8'b00000000;
        cascade_inout_reg       = 3'b000;
        slave_program_n         = 1'b0;
        interrupt_acknowledge_n = 1'b1;
        interrupt_request_pin   = 8'b00000000;
        data_bus_in = 1'b1;
        #(20* 2);
    end
    endtask

 //
    // Task : Send Interrupt request
    //
    task TASK_INTERRUPT_REQUEST(input [7:0] request);
    begin
        #(`TB_CYCLE * 0);
        interrupt_request_pin = request;
        #(`TB_CYCLE * 1);
        interrupt_request_pin = 8'b00000000;
    end
    endtask
    //
    // Task : Write data
    //
    task TASK_WRITE_DATA(input addr, input [7:0] data);
    begin
        #(20* 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        A0              = addr;
        data_bus_in     = 1'b1;
        data_bus_reg    = data;
        #(20* 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        A0              = 1'b0;
        data_bus_reg        = 8'b00000000;
        #(20* 1);
    end
    endtask

    //
    // Task : Read data
    //
    task TASK_READ_DATA(input addr);
    begin
        #(20* 0);
        data_bus_in = 1'b0;
        chip_select_n   = 1'b0;
        read_enable_n   = 1'b0;
        A0              = addr;
        #(20* 1);
        chip_select_n   = 1'b1;
        read_enable_n   = 1'b1;
        #(20* 1);
    end
    endtask

    //
    // Task : Send non specific EOI
    //
    task TASK_SEND_NON_SPECIFIC_EOI();
    begin
        TASK_WRITE_DATA(1'b0, 8'b00100000);
    end
    endtask

    //
    // Task : Send ack (8086)
    //
    task TASK_SEND_ACK_TO_8086();
    begin
        #(20* 0);
        interrupt_acknowledge_n = 1'b1;
        #(20* 1);
        interrupt_acknowledge_n = 1'b0;
        #(20* 1);
        interrupt_acknowledge_n = 1'b1;
        #(20* 1);
        interrupt_acknowledge_n = 1'b0;
        #(20* 1);
        interrupt_acknowledge_n = 1'b1;
    end
    endtask

   //
    // Task : Send specific EOI
    //
    task TASK_SEND_SPECIFIC_EOI(input [2:0] int_no);
    begin
        TASK_WRITE_DATA(1'b0, {8'b01100, int_no});
    end
    endtask

    //
    // TASK : 8086 interrupt test
    //
    task TASK_8086_NORMAL_INTERRUPT_TEST();
    begin
        #(20* 0);
        // $display("***** T7-T3=0b'00000 ***** at %d", 20_counter);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b000);

        TASK_INTERRUPT_REQUEST(8'b00000010);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b001);

        TASK_INTERRUPT_REQUEST(8'b00000100);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b010);

        TASK_INTERRUPT_REQUEST(8'b00001000);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b011);

    //     TASK_INTERRUPT_REQUEST(8'b00010000);
    //     TASK_SEND_ACK_TO_8086();
    //     TASK_SEND_SPECIFIC_EOI(3'b100);

    //     TASK_INTERRUPT_REQUEST(8'b00100000);
    //     TASK_SEND_ACK_TO_8086();
    //     TASK_SEND_SPECIFIC_EOI(3'b101);

    //     TASK_INTERRUPT_REQUEST(8'b01000000);
    //     TASK_SEND_ACK_TO_8086();
    //     TASK_SEND_SPECIFIC_EOI(3'b110);

    //     TASK_INTERRUPT_REQUEST(8'b10000000);
    //     TASK_SEND_ACK_TO_8086();
    //     TASK_SEND_SPECIFIC_EOI(3'b111);

    //     // $display("***** T7-T3=0b'00001 ***** at %d", 20_counter)
    //     // ICW1
    //     TASK_WRITE_DATA(1'b0, 8'b00011111);
    //     // ICW2
    //     TASK_WRITE_DATA(1'b1, 8'b00001000);
    //     // ICW4
    //     TASK_WRITE_DATA(1'b1, 8'b00001101);
    //     // OCW1
    //     TASK_WRITE_DATA(1'b1, 8'b00000000);
    //     // OCW3
    //     TASK_WRITE_DATA(1'b0, 8'b00001000);

    //     // Interrupt
    //     TASK_INTERRUPT_REQUEST(8'b00000001);
    //     TASK_SEND_ACK_TO_8086();
    //     TASK_SEND_SPECIFIC_EOI(3'b000);

    //     // $display("***** T7-T3=0b'00010 ***** at %d", 20_counter);
    //     // ICW1
    //     TASK_WRITE_DATA(1'b0, 8'b00011111);
    //     // ICW2
    //     TASK_WRITE_DATA(1'b1, 8'b00010000);
    //     // ICW4
    //     TASK_WRITE_DATA(1'b1, 8'b00001101);
    //     // OCW1
    //     TASK_WRITE_DATA(1'b1, 8'b00000000);
    //     // OCW3
    //     TASK_WRITE_DATA(1'b0, 8'b00001000);

    //     // Interrupt
    //     TASK_INTERRUPT_REQUEST(8'b00000001);
    //     TASK_SEND_ACK_TO_8086();
    //     TASK_SEND_SPECIFIC_EOI(3'b000);

    //     // $display("***** T7-T3=0b'00100 ***** at %d", 20_counter);
    //     // ICW1
    //     TASK_WRITE_DATA(1'b0, 8'b00011111);
    //     // ICW2
    //     TASK_WRITE_DATA(1'b1, 8'b00100000);
    //     // ICW4
    //     TASK_WRITE_DATA(1'b1, 8'b00001101);
    //     // OCW1
    //     TASK_WRITE_DATA(1'b1, 8'b00000000);
    //     // OCW3
    //     TASK_WRITE_DATA(1'b0, 8'b00001000);

    //     // Interrupt
    //     TASK_INTERRUPT_REQUEST(8'b00000001);
    //     TASK_SEND_ACK_TO_8086();
    //     TASK_SEND_SPECIFIC_EOI(3'b000);

    //     // $display("***** T7-T3=0b'01000 ***** at %d", 20_counter);
    //     // ICW1
    //     TASK_WRITE_DATA(1'b0, 8'b00011111);
    //     // ICW2
    //     TASK_WRITE_DATA(1'b1, 8'b01000000);
    //     // ICW4
    //     TASK_WRITE_DATA(1'b1, 8'b00001101);
    //     // OCW1
    //     TASK_WRITE_DATA(1'b1, 8'b00000000);
    //     // OCW3
    //     TASK_WRITE_DATA(1'b0, 8'b00001000);

    //     // Interrupt
    //     TASK_INTERRUPT_REQUEST(8'b00000001);
    //     TASK_SEND_ACK_TO_8086();
    //     TASK_SEND_SPECIFIC_EOI(3'b000);

    // //    $display("***** T7-T3=0b'10000 ***** at %d", 20_counter);
    //     // ICW1
    //     TASK_WRITE_DATA(1'b0, 8'b00011111);
    //     // ICW2
    //     TASK_WRITE_DATA(1'b1, 8'b10000000);
    //     // ICW4
    //     TASK_WRITE_DATA(1'b1, 8'b00001101);
    //     // OCW1
    //     TASK_WRITE_DATA(1'b1, 8'b00000000);
    //     // OCW3
    //     TASK_WRITE_DATA(1'b0, 8'b00001000);

    //     // Interrupt
    //     TASK_INTERRUPT_REQUEST(8'b00000001);
    //     TASK_SEND_ACK_TO_8086();
    //     TASK_SEND_SPECIFIC_EOI(3'b000);
    //     #(20* 12);
    end
    endtask


    //
    // Test pattern
    //
    initial begin
        TASK_INIT();

        // $display("******************************** ");
        // $display("***** TEST 8086 INTERRUPT  ***** at %d", 20_counter);
        // $display("******************************** ");
         TASK_8086_NORMAL_INTERRUPT_TEST();
        // ICW1
        // TASK_WRITE_DATA(1'b0, 8'b00011111);

        #(20* 1);
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
