`include "int_req.v"

module int_req_tb;

	reg clock;
	reg write_initial_command_word_1_reset;
	
	initial clock = 1'b1;
	always #(10) clock = ~clock;
	
	initial begin
		write_initial_command_word_1_reset = 1'b1;
		#(200) write_initial_command_word_1_reset = 1'b0;
	end

	reg [31:0] tb_cycle_counter;

	always @(negedge clock)
		if (write_initial_command_word_1_reset)
			tb_cycle_counter <= 32'h00000000;
		else
			tb_cycle_counter <= tb_cycle_counter + 32'h00000001;
	
	always @(*) begin
		if (tb_cycle_counter == 20000) begin
			$display("## SIMULATION TIMEOUT ## at %d", tb_cycle_counter);
			$finish;
		end
	end

	reg level_toriggered_config;
	reg freeze;
	reg [7:0] clear_interrupt_request;
	reg [7:0] interrupt_request_pin;
	wire [7:0] interrupt_request_register;
	
	int_req u_int_req();
	
	task TASK_INIT;
		begin
			#(0)
				;
			level_toriggered_config = 1'b0;
			freeze = 1'b0;
			interrupt_request_pin = 8'b00000000;
			clear_interrupt_request = 8'b00000000;
			#(240)
				;
		end
	endtask

	task TASK_LEVEL_TRIGGER_INTERRUPT;
		input [7:0] data;
		begin
			#(0)
				;
			level_toriggered_config = 1'b1;
			#(20)
				;
			interrupt_request_pin = data;
			#(20)
				;
			clear_interrupt_request = data;
			#(20)
				;
			clear_interrupt_request = 8'b00000000;
			#(20)
				;
		end
	endtask

	task TASK_EDGE_TRIGGER_INTERRUPT;
		input [7:0] data;
		begin
			#(0)
				;
			level_toriggered_config = 1'b0;
			#(20)
				;
			interrupt_request_pin = 8'b00000000;
			#(20)
				;
			interrupt_request_pin = data;
			#(20)
				;
			clear_interrupt_request = data;
			#(20)
				;
			clear_interrupt_request = 8'b00000000;
			#(20)
				;
		end
	endtask

	task TASK_CLEAR_INTERRUPT_REQUEST;
		input [7:0] data;
		begin
			#(0)
				;
			clear_interrupt_request = data;
			#(20)
				;
		end
	endtask

	task TASK_INTERRUPT_TEST;
		begin
			#(0)
				;
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
			#(20)
				;
		end
	endtask

	initial begin
		TASK_INIT;
		TASK_INTERRUPT_TEST;
		freeze = 1'b1;
		TASK_INTERRUPT_TEST;
		#(20)
			;
		$finish;
	end


	initial
    begin
		$dumpfile("int_req_tb.vcd");
		$dumpvars(0,int_req_tb);
    end

endmodule
