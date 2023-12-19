//
// Bus_Control_Logic
// Data Bus Buffer & Read/Write Control Logic
//
//
module Bus_Control_Logic (
    input  clk,
    
    input  cs_n,
    input  rd_n,
    input  wr_n,
    //input  addr,
    inout  [7:0] data,

    input  A0,
    // Internal Bus
    output [7:0] internal_data_bus,
    output write_initial_command_word_1_reset,
    output write_initial_command_word_2_4,
    output write_operation_control_word_1,
    output write_operation_control_word_2,
    output write_operation_control_word_3,
    output rd
);

    // Internal Signals
    wire wr_flag;
    reg  prev_write_enable_n;
    
    reg [7:0] databuffer;
    assign internal_data_bus = databuffer;
    assign wr_flag = ~cs_n & ~wr_n;

    // Write Control
    always @(posedge clk)begin  
        if (wr_flag) begin
            databuffer <= data;
        end
    end

    
    // Generate write request flags
    assign write_initial_command_word_1_reset = wr_flag & ~A0 & internal_data_bus[4];
    assign write_initial_command_word_2_4 = wr_flag & A0;
    assign write_operation_control_word_1 = wr_flag & A0;
    assign write_operation_control_word_2 = wr_flag & ~A0 & ~internal_data_bus[4] & ~internal_data_bus[3];
    assign write_operation_control_word_3 = wr_flag & ~A0 & ~internal_data_bus[4] & internal_data_bus[3];

    // Read Control
    assign rd = ~rd_n & ~cs_n;

endmodule


