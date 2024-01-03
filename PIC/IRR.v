// Code your design here
module Interrupt_Request (
       
        input  wire  write_initial_command_word_1_reset,
        // Inputs from control logic
        input  level_triggered_config,
        input  freeze,
        input  [7:0] clear_interrupt_request,

        // pic input pins
        input   [7:0] interrupt_request_pin,

        // Outputs
        output reg  [7:0] interrupt_request_register
        );

        reg  [7:0] low_input_latch;
        wire [7:0] interrupt_request_edge;

        //
        // Edge Sense
        //
        integer ir_bit_no;


        always@(*)  begin
        for (ir_bit_no = 0; ir_bit_no < 8; ir_bit_no = ir_bit_no + 1) begin
        if (write_initial_command_word_1_reset) begin
        low_input_latch = 8'b0;
        end
        else if (clear_interrupt_request[ir_bit_no]) begin
        low_input_latch[ir_bit_no] = 1'b0;
        end
        else if (~interrupt_request_pin[ir_bit_no]) begin
        low_input_latch[ir_bit_no] = 1'b1;
        end
        else begin
        low_input_latch[ir_bit_no] = low_input_latch[ir_bit_no];
        end
        end
        end

        assign interrupt_request_edge = low_input_latch & interrupt_request_pin;

        //
        // IRR
        //
        always@(*) /*@(posedge clock or posedge write_initial_command_word_1_reset)*/ begin
        for (ir_bit_no = 0; ir_bit_no < 8; ir_bit_no = ir_bit_no + 1) begin
        if (write_initial_command_word_1_reset) begin
        interrupt_request_register = 8'b0;
        end
        else if (clear_interrupt_request[ir_bit_no]) begin
        interrupt_request_register[ir_bit_no] = 1'b0;
        end
        else if (freeze) begin
        interrupt_request_register[ir_bit_no] = interrupt_request_register[ir_bit_no];
        end
        else if (level_triggered_config) begin
        interrupt_request_register[ir_bit_no] = interrupt_request_pin[ir_bit_no];
        end
        else begin
        interrupt_request_register[ir_bit_no] = interrupt_request_edge[ir_bit_no];
        end
        end
        end
        endmodule

