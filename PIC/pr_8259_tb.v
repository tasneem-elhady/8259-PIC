`include "pr_8259.v"

module pr_8259_tb ;

	reg clock;
	initial clock = 1'b1;
	always #(10) clock = ~clock;
	reg reset;
	initial begin
		reset = 1'b1;
		#(200) reset = 1'b0;
	end
	reg [31:0] tb_cycle_counter;
	always @(negedge clock or posedge reset)
		if (reset)
			tb_cycle_counter <= 32'h00000000;
		else
			tb_cycle_counter <= tb_cycle_counter + 32'h00000001;
	always @(*) begin
		if (tb_cycle_counter == 20000) begin
			$display("## SIMULATION TIMEOUT ## at %d", tb_cycle_counter);
			$finish;
		end
	end
	reg [2:0] priority_rotate;
	reg [7:0] interrupt_mask;
	reg [7:0] interrupt_special_mask;
	reg special_fully_nest_config;
	reg [7:0] highest_level_in_service;
	reg [7:0] interrupt_request_register;
	reg [7:0] in_service_register;
	wire [7:0] interrupt;

	pr_8259 u_pr_8259();
	
	task TASK_INIT;
		begin
			#(0)
				;
			priority_rotate = 3'b111;
			interrupt_mask = 8'b11111111;
			interrupt_special_mask = 8'b00000000;
			special_fully_nest_config = 1'b0;
			highest_level_in_service = 8'b00000000;
			interrupt_request_register = 8'b00000000;
			in_service_register = 8'b00000000;
			#(240)
				;
		end
	endtask
	task TASK_SCAN_INTERRUPT_REQUEST;
		begin
			#(0)
				;
			interrupt_request_register = 8'b10000000;
			#(20)
				;
			interrupt_request_register = 8'b11000000;
			#(20)
				;
			interrupt_request_register = 8'b11100000;
			#(20)
				;
			interrupt_request_register = 8'b11110000;
			#(20)
				;
			interrupt_request_register = 8'b11111000;
			#(20)
				;
			interrupt_request_register = 8'b11111100;
			#(20)
				;
			interrupt_request_register = 8'b11111110;
			#(20)
				;
			interrupt_request_register = 8'b11111111;
			#(20)
				;
			interrupt_request_register = 8'b00000000;
			#(20)
				;
		end
	endtask
	task TASK_INTERRUPT_MASK_TEST;
		begin
			$display("## TEST ALL MASK ## at %d", tb_cycle_counter);
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST ALL NON-MASK ## at %d", tb_cycle_counter);
			interrupt_mask = 8'b00000000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST MASK BIT0 ## at %d", tb_cycle_counter);
			interrupt_mask = 8'b00000001;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST MASK BIT1 ## at %d", tb_cycle_counter);
			interrupt_mask = 8'b00000010;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST MASK BIT2 ## at %d", tb_cycle_counter);
			interrupt_mask = 8'b00000100;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST MASK BIT3 ## at %d", tb_cycle_counter);
			interrupt_mask = 8'b00001000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST MASK BIT4 ## at %d", tb_cycle_counter);
			interrupt_mask = 8'b00010000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST MASK BIT5 ## at %d", tb_cycle_counter);
			interrupt_mask = 8'b00100000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST MASK BIT6 ## at %d", tb_cycle_counter);
			interrupt_mask = 8'b01000000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST MASK BIT7 ## at %d", tb_cycle_counter);
			interrupt_mask = 8'b10000000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			#(20)
				;
		end
	endtask
	task TASK_IN_SERVICE_INTERRUPT_TEST;
		begin
			interrupt_mask = 8'b00000000;
			#(20)
				;
			$display("## TEST IN-SERVICE BIT0 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00000001;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST IN-SERVICE BIT1 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00000010;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST IN-SERVICE BIT2 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00000100;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST IN-SERVICE BIT3 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00001000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST IN-SERVICE BIT4 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00010000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST IN-SERVICE BIT5 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00100000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST IN-SERVICE BIT6 ## at %d", tb_cycle_counter);
			in_service_register = 8'b01000000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST IN-SERVICE BIT7 ## at %d", tb_cycle_counter);
			in_service_register = 8'b10000000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			in_service_register = 8'b00000000;
			#(20)
				;
		end
	endtask
	task TASK_SPECIAL_MASK_MODE_TEST;
		begin
			interrupt_mask = 8'b00000000;
			#(20)
				;
			$display("## TEST SPECIAL MASK BIT0 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00000011;
			interrupt_special_mask = 8'b00000001;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST SPECIAL MASK BIT1 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00000110;
			interrupt_special_mask = 8'b00000010;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST SPECIAL MASK BIT2 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00001100;
			interrupt_special_mask = 8'b00000100;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST SPECIAL MASK BIT3 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00011000;
			interrupt_special_mask = 8'b00001000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST SPECIAL MASK BIT4 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00110000;
			interrupt_special_mask = 8'b00010000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST SPECIAL MASK BIT5 ## at %d", tb_cycle_counter);
			in_service_register = 8'b01100000;
			interrupt_special_mask = 8'b00100000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST SPECIAL MASK BIT6 ## at %d", tb_cycle_counter);
			in_service_register = 8'b11000000;
			interrupt_special_mask = 8'b01000000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST SPECIAL MASK BIT7 ## at %d", tb_cycle_counter);
			in_service_register = 8'b10000000;
			interrupt_special_mask = 8'b10000000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			in_service_register = 8'b00000000;
			interrupt_special_mask = 8'b00000000;
			#(20)
				;
		end
	endtask
	task TASK_SPECIAL_FULLY_NEST_MODE_TEST;
		begin
			special_fully_nest_config = 1'b1;
			#(20)
				;
			$display("## TEST FULLY NEST BIT0 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00000001;
			highest_level_in_service = 8'b00000001;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST FULLY NEST BIT1 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00000010;
			highest_level_in_service = 8'b00000010;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST FULLY NEST BIT2 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00000100;
			highest_level_in_service = 8'b00000100;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST FULLY NEST BIT3 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00001000;
			highest_level_in_service = 8'b00001000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST FULLY NEST BIT4 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00010000;
			highest_level_in_service = 8'b00010000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST FULLY NEST BIT5 ## at %d", tb_cycle_counter);
			in_service_register = 8'b00100000;
			highest_level_in_service = 8'b00100000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST FULLY NEST BIT6 ## at %d", tb_cycle_counter);
			in_service_register = 8'b01000000;
			highest_level_in_service = 8'b01000000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			$display("## TEST FULLY NEST BIT7 ## at %d", tb_cycle_counter);
			in_service_register = 8'b10000000;
			highest_level_in_service = 8'b10000000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			in_service_register = 8'b00000000;
			highest_level_in_service = 8'b00000000;
			special_fully_nest_config = 1'b0;
			#(20)
				;
		end
	endtask
	task TASK_ROTATION_TEST;
		begin
			$display("## TEST ROTATE 0 ## at %d", tb_cycle_counter);
			priority_rotate = 3'b000;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			interrupt_request_register = 8'b00000001;
			#(20)
				;
			interrupt_request_register = 8'b00000000;
			$display("## TEST ROTATE 1 ## at %d", tb_cycle_counter);
			priority_rotate = 3'b001;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			interrupt_request_register = 8'b00000010;
			#(20)
				;
			interrupt_request_register = 8'b00000011;
			#(20)
				;
			interrupt_request_register = 8'b00000000;
			$display("## TEST ROTATE 2 ## at %d", tb_cycle_counter);
			priority_rotate = 3'b010;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			interrupt_request_register = 8'b00000100;
			#(20)
				;
			interrupt_request_register = 8'b00000110;
			#(20)
				;
			interrupt_request_register = 8'b00000111;
			#(20)
				;
			interrupt_request_register = 8'b00000000;
			$display("## TEST ROTATE 3 ## at %d", tb_cycle_counter);
			priority_rotate = 3'b011;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			interrupt_request_register = 8'b00001000;
			#(20)
				;
			interrupt_request_register = 8'b00001100;
			#(20)
				;
			interrupt_request_register = 8'b00001110;
			#(20)
				;
			interrupt_request_register = 8'b00001111;
			#(20)
				;
			interrupt_request_register = 8'b00000000;
			$display("## TEST ROTATE 4 ## at %d", tb_cycle_counter);
			priority_rotate = 3'b100;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			interrupt_request_register = 8'b00010000;
			#(20)
				;
			interrupt_request_register = 8'b00011000;
			#(20)
				;
			interrupt_request_register = 8'b00011100;
			#(20)
				;
			interrupt_request_register = 8'b00011110;
			#(20)
				;
			interrupt_request_register = 8'b00011111;
			#(20)
				;
			interrupt_request_register = 8'b00000000;
			$display("## TEST ROTATE 5 ## at %d", tb_cycle_counter);
			priority_rotate = 3'b101;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			interrupt_request_register = 8'b00100000;
			#(20)
				;
			interrupt_request_register = 8'b00110000;
			#(20)
				;
			interrupt_request_register = 8'b00111000;
			#(20)
				;
			interrupt_request_register = 8'b00111100;
			#(20)
				;
			interrupt_request_register = 8'b00111110;
			#(20)
				;
			interrupt_request_register = 8'b00111111;
			#(20)
				;
			interrupt_request_register = 8'b00000000;
			$display("## TEST ROTATE 6 ## at %d", tb_cycle_counter);
			priority_rotate = 3'b110;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			interrupt_request_register = 8'b01000000;
			#(20)
				;
			interrupt_request_register = 8'b01100000;
			#(20)
				;
			interrupt_request_register = 8'b01110000;
			#(20)
				;
			interrupt_request_register = 8'b01111000;
			#(20)
				;
			interrupt_request_register = 8'b01111100;
			#(20)
				;
			interrupt_request_register = 8'b01111110;
			#(20)
				;
			interrupt_request_register = 8'b01111111;
			#(20)
				;
			interrupt_request_register = 8'b00000000;
			$display("## TEST ROTATE 7 ## at %d", tb_cycle_counter);
			priority_rotate = 3'b111;
			#(20)
				;
			TASK_SCAN_INTERRUPT_REQUEST;
			interrupt_request_register = 8'b00000000;
			#(20)
				;
		end
	endtask
	initial begin
		TASK_INIT;
		$display("## TEST INTERRUPT NASK ## at %d", tb_cycle_counter);
		TASK_INTERRUPT_MASK_TEST;
		$display("## TEST IN-SERVICE INTERRUPT ## at %d", tb_cycle_counter);
		TASK_IN_SERVICE_INTERRUPT_TEST;
		$display("## TEST SPECIAL MASK MODE ## at %d", tb_cycle_counter);
		TASK_SPECIAL_MASK_MODE_TEST;
		$display("## TEST SPECIAL FULLY NEST MODE ## at %d", tb_cycle_counter);
		TASK_SPECIAL_FULLY_NEST_MODE_TEST;
		$display("## TEST ROTATION ## at %d", tb_cycle_counter);
		TASK_ROTATION_TEST;
		#(20)
			;
		$finish;
	end
	
	initial
    begin
		$dumpfile("pr_8259_tb.vcd");
		$dumpvars(0,pr_8259_tb);
    end


endmodule

