module main(
    input     clock, 
    input     write_initial_command_word_1_reset,
    input     slave_program_n,
    input     [7:0]   internal_data_bus,
    input     write_initial_command_word_3,
    input     write_initial_command_word_4,
    input     acknowledge_interrupt,
    input     control_state,
    input     single_or_cascade_config,
    input     slave_program_or_enable_buffer,


    output    cascade_output_ack_2_3,
    output    cascade_slave,

    inout     [2:0]   cascade_inout
);
   reg       [2:0]   cascade_inoutreg;
   reg       cascade_slave_reg;
   reg       buffered_mode_config ; 
   
   reg       [7:0]   cascade_device_config;
   reg       cascade_slave_enable;
   reg       cascade_output_ack_2_3reg;

assign cascade_slave = cascade_slave_reg;
assign cascade_output_ack_2_3 = cascade_output_ack_2_3reg;


       // S7-S0 (MASTER) or ID2-ID0 (SLAVE)
    always@(*) begin
        
        if (write_initial_command_word_1_reset == 1'b1)
            cascade_device_config <= 8'b00000000;
        else if (write_initial_command_word_3 == 1'b1)
            cascade_device_config <= internal_data_bus;
        else
            cascade_device_config <= cascade_device_config;
    end

    //
    // Cascade signals
    //
    // Select master/slave
    always@*begin
        if (single_or_cascade_config == 1'b1)
            cascade_slave_reg = 1'b0;
        else 
            cascade_slave_reg = ~slave_program_n;
    end

    // Cascade port I/O
  //  assign cascade_io = cascade_slave;

    //
    // Cascade signals (slave)
    //
    always@*begin
        if (cascade_slave_reg == 1'b0)
            cascade_slave_enable = 1'b0;
        else if (cascade_device_config[2:0] != cascade_inout)
            cascade_slave_enable = 1'b0;
        else
            cascade_slave_enable = 1'b1;
    end
    //
    // Cascade signals (master)
    //
    wire    interrupt_from_slave_device = (acknowledge_interrupt & cascade_device_config) != 8'b00000000;
    // output ACK2 and ACK3
    always@* begin

        if (single_or_cascade_config == 1'b1)
            cascade_output_ack_2_3reg = 1'b1;

        else if (cascade_slave_enable == 1'b1)
            cascade_output_ack_2_3reg  = 1'b1;

        else if ((cascade_slave_reg == 1'b0) && (interrupt_from_slave_device == 1'b0))//**********
            cascade_output_ack_2_3reg  = 1'b1;
        else
            cascade_output_ack_2_3reg = 1'b0;

    end

//     // Output slave id
//     always@* begin
//         if (cascade_slave_reg == 1'b1)//m
//             cascade_inoutreg <= 3'b000;
//     //    else if ((control_state != ACK1) && (control_state != ACK2))
//     //      cascade_out <= 3'b000;
//         else if (interrupt_from_slave_device == 1'b0)
//             cascade_inoutreg <= 3'b000;
//       //nnelse
//  //           cascade_inoutreg <= bit2num(acknowledge_interrupt);
//     end

assign cascade_inout = cascade_inoutreg;

endmodule
