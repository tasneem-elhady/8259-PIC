
module PriorityResolver (
    // Inputs from control logic
    input   reg    [2:0]   priority_rotate,
    input   reg    [7:0]   interrupt_mask,
    input   reg    [7:0]   highest_level_in_service,

    // Inputs
    input   reg    [7:0]   interrupt_request_register,
    input   reg    [7:0]   in_service_register,

    // Outputs
    output  reg    [7:0]   interrupt
);
    
    common c();
    //
    // Masked flags
    //
    reg     [7:0]   masked_interrupt_request;
    reg    [7:0]   masked_in_service;
    
    always @* begin
     masked_in_service        = in_service_register& (~interrupt_mask) ;
     masked_interrupt_request = interrupt_request_register & (~interrupt_mask);
    end


    //
    // Resolve priority
    //

    reg     [7:0]   rotated_request;
    reg     [7:0]   rotated_in_service;
    reg     [7:0]   priority_mask;
    reg     [7:0]   rotated_interrupt;

    always @* begin
        rotated_request = c.rotate_right(masked_interrupt_request, priority_rotate);

      
    end

    always @* begin
        rotated_in_service = c.rotate_right(masked_in_service, priority_rotate);

        
    end

        always @* begin
        if      (rotated_in_service[0]) priority_mask = 8'b00000000;
        else if (rotated_in_service[1]) priority_mask = 8'b00000001;
        else if (rotated_in_service[2]) priority_mask = 8'b00000011;
        else if (rotated_in_service[3]) priority_mask = 8'b00000111;
        else if (rotated_in_service[4]) priority_mask = 8'b00001111;
        else if (rotated_in_service[5]) priority_mask = 8'b00011111;
        else if (rotated_in_service[6]) priority_mask = 8'b00111111;
        else if (rotated_in_service[7]) priority_mask = 8'b01111111;
        else                            priority_mask = 8'b11111111;
    end

    always @* begin
        rotated_interrupt = c.resolv_priority(rotated_request) & priority_mask;
        interrupt = c.rotate_left(rotated_interrupt, priority_rotate);
       end

endmodule


