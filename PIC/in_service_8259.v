module in_service_8259 (
    input clock,
    input reset,

    // Inputs
    input [2:0] priority_rotate,
    input [7:0] interrupt_special_mask,
    input [7:0] interrupt,
    input latch_in_service,
    input [7:0] end_of_interrupt,

    // Outputs
    output reg [7:0] in_service_register,
    output reg [7:0] highest_level_in_service
);

// functions
function [7:0] rotate_right (input [7:0] source, input [2:0] rotate);
    case (rotate)
        3'b000:  rotate_right = {source[0],   source[7:1]};
        3'b001:  rotate_right = {source[1:0], source[7:2]};
        3'b010:  rotate_right = {source[2:0], source[7:3]};
        3'b011:  rotate_right = {source[3:0], source[7:4]};
        3'b100:  rotate_right = {source[4:0], source[7:5]};
        3'b101:  rotate_right = {source[5:0], source[7:6]};
        3'b110:  rotate_right = {source[6:0], source[7]};
        3'b111:  rotate_right = source;
        default: rotate_right = source;  
    endcase
endfunction


function [7:0] rotate_left (input [7:0] source, input [2:0] rotate);
    case (rotate)
        3'b000:  rotate_left = {source[6:0], source[7]};
        3'b001:  rotate_left = {source[5:0], source[7:6]};
        3'b010:  rotate_left = {source[4:0], source[7:5]};
        3'b011:  rotate_left = {source[3:0], source[7:4]};
        3'b100:  rotate_left = {source[2:0], source[7:3]};
        3'b101:  rotate_left = {source[1:0], source[7:2]};
        3'b110:  rotate_left = {source[0],   source[7:1]};
        3'b111:  rotate_left = source;
        default: rotate_left = source;  
    endcase
endfunction

function [7:0] resolv_priority (input [7:0] request);
    begin
        if (request[0] == 1'b1) begin
            resolv_priority = 8'b00000001;
        end else if (request[1] == 1'b1) begin
            resolv_priority = 8'b00000010;
        end else if (request[2] == 1'b1) begin
            resolv_priority = 8'b00000100;
        end else if (request[3] == 1'b1) begin
            resolv_priority = 8'b00001000;
        end else if (request[4] == 1'b1) begin
            resolv_priority = 8'b00010000;
        end else if (request[5] == 1'b1) begin
            resolv_priority = 8'b00100000;
        end else if (request[6] == 1'b1) begin
            resolv_priority = 8'b01000000;
        end else if (request[7] == 1'b1) begin
            resolv_priority = 8'b10000000;
        end else begin
            resolv_priority = 8'b00000000;
        end
    end
endfunction

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////

    // In service register
    reg [7:0] next_in_service_register;

always @* begin
    next_in_service_register = (in_service_register & ~end_of_interrupt) |
                        (latch_in_service ? interrupt : 8'b00000000);
end


    always @(negedge clock or posedge reset) begin
        if (reset) begin
            in_service_register <= 8'b00000000;
        end else begin
            in_service_register <= next_in_service_register;
        end
    end

    // Get Highest level in service
    reg [7:0] next_highest_level_in_service;


    always @(*) begin
        next_highest_level_in_service = next_in_service_register & ~interrupt_special_mask;
        next_highest_level_in_service = rotate_right(next_highest_level_in_service, priority_rotate);
        next_highest_level_in_service = resolv_priority(next_highest_level_in_service);
        next_highest_level_in_service = rotate_left(next_highest_level_in_service, priority_rotate);
    end



    always @(negedge clock or posedge reset) begin
        if (reset) begin
            highest_level_in_service <= 8'b00000000;
        end else begin
            highest_level_in_service <= next_highest_level_in_service;
        end
    end

endmodule


