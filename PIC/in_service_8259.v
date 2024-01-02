module int_req (
	clock,
	write_initial_command_word_1_reset,
	level_or_edge_toriggered_config,
	freeze,
	clear_interrupt_request,
	interrupt_request_pin,
	interrupt_request_register );

	input wire clock;
	input wire write_initial_command_word_1_reset;

	input wire level_or_edge_toriggered_config;
	input wire freeze;
	input wire [7:0] clear_interrupt_request;
	input wire [7:0] interrupt_request_pin;

	output reg [7:0] interrupt_request_register;

	reg [7:0] low_input_latch;
	wire [7:0] interrupt_request_edge;

	genvar _gv_ir_bit_no_1;

	generate
		for (_gv_ir_bit_no_1 = 0; _gv_ir_bit_no_1 <= 7; _gv_ir_bit_no_1 = _gv_ir_bit_no_1 + 1) begin : Request_Latch
			localparam ir_bit_no = _gv_ir_bit_no_1;
			always @(negedge clock)
				if (write_initial_command_word_1_reset)
					low_input_latch[ir_bit_no] <= 1'b0;
				else if (clear_interrupt_request[ir_bit_no])
					low_input_latch[ir_bit_no] <= 1'b0;
				else if (~interrupt_request_pin[ir_bit_no])
					low_input_latch[ir_bit_no] <= 1'b1;
				else
					low_input_latch[ir_bit_no] <= low_input_latch[ir_bit_no];

			assign interrupt_request_edge[ir_bit_no] = (low_input_latch[ir_bit_no] == 1'b1) & (interrupt_request_pin[ir_bit_no] == 1'b1);

			always @(negedge clock)
				if (write_initial_command_word_1_reset)
					interrupt_request_register[ir_bit_no] <= 1'b0;
				else if (clear_interrupt_request[ir_bit_no])
					interrupt_request_register[ir_bit_no] <= 1'b0;
				else if (freeze)
					interrupt_request_register[ir_bit_no] <= interrupt_request_register[ir_bit_no];
				else if (level_or_edge_toriggered_config)
					interrupt_request_register[ir_bit_no] <= interrupt_request_pin[ir_bit_no];
				else
					interrupt_request_register[ir_bit_no] <= interrupt_request_edge[ir_bit_no];
		end
	endgenerate
endmodule
