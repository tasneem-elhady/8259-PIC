module cascading_block(
    // input     clock, 
    input     write_initial_command_word_1_reset,
    input     slave_program_n,
    input     [7:0]   internal_data_bus,
    input     write_initial_command_word_3,
    input     [7:0]acknowledge_interrupt,
    input     [1:0]control_state,
    input     single_or_cascade_config,

    output    reg        cascade_output_ack_2,
    output    reg        cascade_slave,
   
    output    reg     cascade_slave_enable,
   
    inout     [2:0]   cascade_inout
    // output            cascade_io
);
common c();
   reg       [2:0]   cascade_inoutreg;
//    reg       cascade_slave_reg;
   reg               buffered_mode_config; 
   
   reg       [7:0]   cascade_device_config;

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
    always@(*)begin
        if (single_or_cascade_config == 1'b1)
            cascade_slave = 1'b0;
        else 
            cascade_slave = ~slave_program_n;
    end

    // Cascade port I/O

    //
    // Cascade signals (slave)
    //
    always@(*)begin
        if (cascade_slave == 1'b0)
            cascade_slave_enable = 1'b0;
        else if (cascade_device_config[2:0] != cascade_inout)
            cascade_slave_enable = 1'b0;
        else
            cascade_slave_enable = 1'b1;
    end

    //
    // Cascade signals (master)
    //
    wire  interrupt_from_slave_device = (acknowledge_interrupt & cascade_device_config) != 8'b00000000;
    
    // output ACK2 
    always@(*) begin

        if (single_or_cascade_config == 1'b1)
            cascade_output_ack_2 = 1'b1;

        else if (cascade_slave_enable == 1'b1)
            cascade_output_ack_2  = 1'b1;

        else if ((cascade_slave == 1'b0) && (interrupt_from_slave_device == 1'b0))//***
            cascade_output_ack_2  = 1'b1;
        else
            cascade_output_ack_2 = 1'b0;

    end
    reg cascade_outreg ;
    localparam ACK1 = 2'b01;
    localparam ACK2 = 2'b10;



    
    // Output slave id
    always@(*) begin
        if (cascade_slave == 1'b1)//m
            cascade_outreg <= 1'b0;
       else if ((control_state != ACK1) && (control_state != ACK2))
            cascade_outreg <= 1'b0;
        else if (interrupt_from_slave_device == 1'b0)
            cascade_outreg <= 1'b0;
        else begin 
            cascade_outreg = 1'b1;
            cascade_inoutreg <= c.bit2num(acknowledge_interrupt);
        end
    end

assign cascade_inout = cascade_outreg ? cascade_inoutreg : 8'bzzzzzzzz;

endmodule
