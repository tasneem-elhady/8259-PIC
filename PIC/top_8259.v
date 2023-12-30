module top_8259(
    // Bus
    // input   logic           clock,
    // input   logic           reset,
    input              chip_select_n,
    input              read_enable_n,
    input              write_enable_n,
    input              A0,
    // input      [7:0]   data_bus_in,
    // output     [7:0]   data_bus_out,

    output   reg          data_bus_io,

// interface with the cpu
    inout         [7:0]   data_bus,

    // I/O
    // input      [2:0]   cascade_in,
    // output     [2:0]   cascade_out,

    output               cascade_io,

    inout         [2:0]   cascade_inout,

    input              slave_program_n,
    output             buffer_enable,
    output             slave_program_or_enable_buffer,

    input              interrupt_acknowledge_n,
    output             interrupt_to_cpu,
    

    input      [7:0]   interrupt_request
);


    //
    // Data Bus Buffer & Read/Write Control Logic (1)
    //
    wire [7:0]   internal_data_bus;
    wire write_initial_command_word_1_reset;
    wire write_initial_command_word_2_4;
    wire write_operation_control_word_1;
    wire write_operation_control_word_2;
    wire write_operation_control_word_3;
    wire read;

    Bus_Control_Logic bcl (
        // input
        // Bus
        // .clock                              (clock),
        // .reset                              (reset),
        .cs_n                                (chip_select_n),
        .rd_n                                (read_enable_n),
        .wr_n                                (write_enable_n),
        .data_bus_in                         (data_bus_in),                    
        .A0                                  (A0),
        
        //output***
        // Control signals
        .internal_data_bus                  (internal_data_bus),
        .write_initial_command_word_1_reset (write_initial_command_word_1_reset),
        .write_initial_command_word_2_4     (write_initial_command_word_2_4),
        .write_operation_control_word_1     (write_operation_control_word_1),
        .write_operation_control_word_2     (write_operation_control_word_2),
        .write_operation_control_word_3     (write_operation_control_word_3),
        .rd                                 (read)
    );


    Interrupt_Request IRR(
        // inputs
        //  clock,                       
        .write_initial_command_word_1_reset     (write_initial_command_word_1_reset),                             
        // Inputs from control logic                                
        .level_or_edge_triggered_config        (level_or_edge_triggered_config),                            
        .freeze                                (freeze),           
        .clear_interrupt_request               (clear_interrupt_request),          
        // pic input pins                                      
        .interrupt_request_pin                 (interrupt_request_pin),           
        // Outputs                               
        .interrupt_request_register            (interrupt_request_register)                                                                  
    );


    wire            out_control_logic_data;
    wire    [7:0]   control_logic_data;
    wire            level_or_edge_toriggered_config;
    //wire            special_fully_nest_config;
    wire            enable_read_register;
    wire            read_register_isr_or_irr;
    wire    [7:0]   interrupt;
    wire    [7:0]   highest_level_in_service;
    wire    [7:0]   interrupt_mask;
    wire    [7:0]   interrupt_special_mask;
    wire    [7:0]   end_of_interrupt;
    wire    [2:0]   priority_rotate;
    //wire            freeze
    wire            latch_in_service;
    //wire    [7:0]   clear_interrupt_request;

    controller u_Control_Logic (
        // Bus
        // .clock                              (clock),
        // .reset                              (reset),
        .write_initial_command_word_1_reset       (write_initial_command_word_1),
        .write_initial_command_word_2_4     (write_initial_command_word_2_4),
        .write_operation_control_word_1     (write_operation_control_word_1),
        .write_operation_control_word_2     (write_operation_control_word_2),
        .write_operation_control_word_3     (write_operation_control_word_3),
        // Signals from interrupt detectiong logics
        .highest_level_in_service           (highest_level_in_service),
        .interrupt                          (interrupt),
        
        .interrupt_acknowledge_n            (interrupt_acknowledge_n),
        
//inputs from cascading block
         .cascade_slave                      (cascade_slave),
         .cascade_slave_enable               (cascade_slave_enable),
         .cascade_output_ack_2_3             (cascade_output_ack_2_3),

        // External input/output
        // .cascade_in                         (cascade_in),
        // .cascade_out                        (cascade_out),
        // .cascade_io                         (cascade_io),

        // .slave_program_n                    (slave_program_n),
        // .slave_program_or_enable_buffer     (slave_program_or_enable_buffer),

        // .read                               (read),
        
        // .special_fully_nest_config          (special_fully_nest_config),
// outputs
    // Registers to interrupt detecting logics
        .level_or_edge_toriggered_config    (level_or_edge_toriggered_config),
        .end_of_interrupt                   (end_of_interrupt),
        .priority_rotate                    (priority_rotate),
// Registers to Read logics
        .enable_read_register               (enable_read_register),
        .read_register_isr_or_irr           (read_register_isr_or_irr),
// Interrupt control signals
        // .interrupt_special_mask             (interrupt_special_mask),
        .interrupt_mask                     (interrupt_mask),
        .interrupt_to_cpu                   (interrupt_to_cpu),
        .freeze                             (freeze),
        .clear_interrupt_request            (clear_interrupt_request),
        .latch_in_service                   (latch_in_service),
        .out_control_logic_data             (out_control_logic_data),
        .control_logic_data                 (control_logic_data),
        .data_bus_io                        (data_bus_io),

// inout
// Internal bus
        
        .internal_data_bus                  (internal_data_bus)
    );

    cascading_block cb(
        // input     clock, 
        .write_initial_command_word_1_reset              (write_initial_command_word_1_reset),
        .slave_program_n                                 (slave_program_n),
        .internal_data_bus                               (internal_data_bus),
        .write_initial_command_word_3                    (write_initial_command_word_3),
        .write_initial_command_word_4                    (write_initial_command_word_4),
        .acknowledge_interrupt                           (acknowledge_interrupt),
        .control_state                                   (control_state),
        .single_or_cascade_config                        (single_or_cascade_config),
        .slave_program_or_enable_buffer                  (slave_program_or_enable_buffer),


        .cascade_output_ack_2_3                          (cascade_output_ack_2_3),
        .cascade_slave                                   (cascade_slave),
        .cascade_slave_enable                            (cascade_slave_enable),
        .cascade_inout                                   (cascade_inout),
        .cascade_io                                      (cascade_io)
    );

    reg   [7:0]   in_service_register;

    in_service_8259 isr(
    .write_initial_command_word_1_reset                  (write_initial_command_word_1_reset),

    // Inputs
    // from controller
    .priority_rotate                                     (priority_rotate),
    // .interrupt_special_mask                              (interrupt_special_mask),
    
    .interrupt                                           (interrupt),
    // from controller
    .latch_in_service                                    (latch_in_service),
    .end_of_interrupt                                    (end_of_interrupt),

    // Outputs
    .in_service_register                                 (in_service_register),
    .highest_level_in_service                            (highest_level_in_service)
    );

     pr_8259 pr(
    //Inputs 
    // from controller
	.priority_rotate                                      (priority_rotate),
	.interrupt_mask                                       (interrupt_mask),
	// interrupt_special_mask                            (interrupt_special_mask),
	// special_fully_nest_config                         (special_fully_nest_config),
	// from in service register
    .highest_level_in_service                             (highest_level_in_service),
	.in_service_register                                  (in_service_register),
	// from irr
    .interrupt_request_register                           (interrupt_request_register),
	//output
    .interrupt                                            (interrupt)
    );
    
    reg [7:0] data_bus_reg;

always @(*) begin
    // from controller
        if (out_control_logic_data == 1'b1) begin
            data_bus_io  = 1'b0;
            data_bus_reg = control_logic_data;
        end
        // else if (read == 1'b0) begin
        //     data_bus_io  = 1'b1;
        //     data_bus_reg = 8'b00000000;
        // end
        else if (A0 == 1'b1) begin
            data_bus_io  = 1'b0;
            data_bus_reg = interrupt_mask;
        end
        else if ((enable_read_register == 1'b1) && (read_register_isr_or_irr == 1'b0)) begin
            data_bus_io  = 1'b0;
            data_bus_reg = interrupt_request_register;
        end
        else if ((enable_read_register == 1'b1) && (read_register_isr_or_irr == 1'b1)) begin
            data_bus_io  = 1'b0;
            data_bus_reg = in_service_register;
        end
        else begin
            data_bus_io  = 1'b1;
        end
    end
    assign data_bus = !data_bus_io ? data_bus_reg : 8'bzzzzzzzz ;

endmodule
