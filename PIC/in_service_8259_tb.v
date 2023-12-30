`include "in_service_8259.v"

module in_service_8259_tb;

	reg _sv2v_0;
	reg clock;
	reg reset;

	// clock
	initial clock = 1'b1;
	always #(10) clock = ~clock;

	// reset
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
	reg [7:0] interrupt;
	reg start_in_service;
	reg [7:0] end_of_interrupt;
	wire [7:0] in_service_register;
	wire [7:0] highest_level_in_service;

	in_service_8259 u_in_service_8259();

		task TASK_INIT;
		begin
			#(0)
				;
			priority_rotate = 3'b111;
			interrupt = 8'b00000000;
			start_in_service = 1'b0;
			end_of_interrupt = 8'b00000000;
			#(240)
				;
		end
	endtask
	task TASK_INTERRUPT;
		input [7:0] in;
		begin
			#(0)
				;
			interrupt = in;
			start_in_service = 1'b0;
			#(20)
				;
			start_in_service = 1'b1;
			#(20)
				;
			interrupt = 8'b00000000;
			start_in_service = 1'b0;
			#(20)
				;
		end
	endtask
	task TASK_END_OF_INTERRUPT;
		input [7:0] in;
		begin
			#(0)
				;
			end_of_interrupt = in;
			#(20)
				;
			end_of_interrupt = 8'b00000000;
			#(20)
				;
		end
	endtask
	task TASK_SCAN_INTERRUPT;
		begin
			#(0)
				;
			TASK_INTERRUPT(8'b10000000);
			TASK_INTERRUPT(8'b01000000);
			TASK_INTERRUPT(8'b00100000);
			TASK_INTERRUPT(8'b00010000);
			TASK_INTERRUPT(8'b00001000);
			TASK_INTERRUPT(8'b00000100);
			TASK_INTERRUPT(8'b00000010);
			TASK_INTERRUPT(8'b00000001);
			#(20)
				;
		end
	endtask
	task TASK_SCAN_END_OF_INTERRUPT;
		begin
			#(0)
				;
			TASK_END_OF_INTERRUPT(8'b00000001);
			TASK_END_OF_INTERRUPT(8'b00000010);
			TASK_END_OF_INTERRUPT(8'b00000100);
			TASK_END_OF_INTERRUPT(8'b00001000);
			TASK_END_OF_INTERRUPT(8'b00010000);
			TASK_END_OF_INTERRUPT(8'b00100000);
			TASK_END_OF_INTERRUPT(8'b01000000);
			TASK_END_OF_INTERRUPT(8'b10000000);
			#(20)
				;
		end
	endtask
	initial begin
		TASK_INIT;
		$display("## TEST ROTATE 7 ## at %d", tb_cycle_counter);
		priority_rotate = 3'b111;
		#(20)
			;
		TASK_SCAN_INTERRUPT;
		TASK_SCAN_END_OF_INTERRUPT;
		$display("## TEST ROTATE 6 ## at %d", tb_cycle_counter);
		priority_rotate = 3'b110;
		#(20)
			;
		TASK_SCAN_INTERRUPT;
		TASK_SCAN_END_OF_INTERRUPT;
		$display("## TEST ROTATE 5 ## at %d", tb_cycle_counter);
		priority_rotate = 3'b101;
		#(20)
			;
		TASK_SCAN_INTERRUPT;
		TASK_SCAN_END_OF_INTERRUPT;
		$display("## TEST ROTATE 4 ## at %d", tb_cycle_counter);
		priority_rotate = 3'b100;
		#(20)
			;
		TASK_SCAN_INTERRUPT;
		TASK_SCAN_END_OF_INTERRUPT;
		$display("## TEST ROTATE 3 ## at %d", tb_cycle_counter);
		priority_rotate = 3'b011;
		#(20)
			;
		TASK_SCAN_INTERRUPT;
		TASK_SCAN_END_OF_INTERRUPT;
		$display("## TEST ROTATE 2 ## at %d", tb_cycle_counter);
		priority_rotate = 3'b010;
		#(20)
			;
		TASK_SCAN_INTERRUPT;
		TASK_SCAN_END_OF_INTERRUPT;
		$display("## TEST ROTATE 1 ## at %d", tb_cycle_counter);
		priority_rotate = 3'b001;
		#(20)
			;
		TASK_SCAN_INTERRUPT;
		TASK_SCAN_END_OF_INTERRUPT;
		$display("## TEST ROTATE 0 ## at %d", tb_cycle_counter);
		priority_rotate = 3'b000;
		#(20)
			;
		TASK_SCAN_INTERRUPT;
		TASK_SCAN_END_OF_INTERRUPT;
		#(20)
			;
		$finish;
	end
	
	initial
    begin
		$dumpfile("tb.vcd");
		$dumpvars(0,in_service_8259_tb);
    end


endmodule
