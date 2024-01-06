`include "include.v"
module INS_MEMORY
(
    input wire [0:0] SYS_clk,
    input wire [0:0] SYS_reset,
    input            SYS_start_button,
    input  wire [31:0]  PC,

    input      PC_data_valid,
    input[7:0] PC_data,  

    output reg          execution_enable,
    output wire [31:0]  instruction
);
    reg [7:0] data [(`INS_START_ADDRESS) : (`INS_START_ADDRESS) + 1000];

    reg [31:0] PC_to_mem_address;

    assign instruction[31:0] = {data[PC], data[PC+1], data[PC+2], data[PC+3]};

    integer i, file;
    always @(posedge SYS_clk) 
    begin
        if (SYS_reset)
        begin
            for(i=`INS_START_ADDRESS; i<`INS_START_ADDRESS + 1000 ;i=i+1)
            begin
                data[i] <= 0;
            end

            execution_enable <= 0;
            PC_to_mem_address<= `INS_START_ADDRESS;

            `ifdef TESTING
            $readmemh("C:/Users/tuankiet/Desktop/RISC-V/test/input_text.txt", data);
            `endif
        end

        else if (SYS_start_button)
            execution_enable <= 1;

        else if (execution_enable == 0)
        begin
            if (PC_data_valid)
            begin
                data[PC_to_mem_address] <= PC_data;
                PC_to_mem_address       <= PC_to_mem_address + 1;
            end     


        end
    end

endmodule