always@(*) /*@(negedge clk, posedge write_initial_command_word_1_reset)*/ begin
        if (write_initial_command_word_1_reset == 1'b1)
            interrupt_when_ack1 <= 8'b00000000;
        else if (control_state == ACK1)/******/
            interrupt_when_ack1 <= interrupt;
        else
            interrupt_when_ack1 <= interrupt_when_ack1;
    end
    
    // control_logic_data
    always@(*) begin
        if (interrupt_acknowledge_n == 1'b0) begin
            // Acknowledge
            case (control_state)
                CTL_READY: begin
                    // if (cascade_slave == 1'b0) begin
                            // out_control_logic_data = 1'b0;
                            // control_logic_data     = 8'b00000000;
                    // end
                    // else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'b00000000;
                    // end
                end
                ACK1: begin
                    // if (cascade_slave == 1'b0) begin
                            // out_control_logic_data = 1'b0;
                            // control_logic_data     = 8'b00000000;
                    // end
                    // else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'b00000000;
                    // end
                end
                ACK2: begin
                    if (cascade_output_ack_2 == 1'b1) begin
                        out_control_logic_data = 1'b1;
                        if (cascade_slave == 1'b1)
                            control_logic_data[2:0] = c.bit2num(interrupt_when_ack1);
                        else
                            control_logic_data[2:0] = c.bit2num(acknowledge_interrupt);

                         control_logic_data = {interrupt_vector_address[7:3], control_logic_data[2:0]};
                    end
                    else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'b00000000;
                    end
                end
                default: begin
                    out_control_logic_data = 1'b0;
                    control_logic_data     = 8'b00000000;
                end
            endcase
        end
        else begin
            out_control_logic_data = 1'b0;
            control_logic_data     = 8'b00000000;
        end
    end
endmodule
