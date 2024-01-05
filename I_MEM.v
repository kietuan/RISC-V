`include "include.v"
module INS_MEMORY
(
    input wire [0:0] SYS_clk,
    input wire [0:0] SYS_reset,
    input  wire [31:0]  PC,

    input      PC_to_mem_enable,
    input[7:0] PC_to_mem_data,  
    input[31:0]PC_to_mem_address,

    output wire [31:0]  instruction
);
    reg [7:0] data [(`INS_START_ADDRESS) : (`INS_START_ADDRESS) + 1000];
    assign instruction[31:0] = {data[PC], data[PC+1], data[PC+2], data[PC+3]};

    integer i, file;
    always @(posedge SYS_clk) 
    begin
        if (SYS_reset)
        begin
            for(i=`INS_START_ADDRESS; i<`INS_START_ADDRESS + 1000 ;i=i+1)
            begin
                data[i] = 0;
            end
            
            `ifdef TESTING
            $readmemh("C:/Users/tuankiet/Desktop/RISC-V/test/input_text.txt", data);
            `endif
        end

        else
        begin
            if (PC_to_mem_enable)
            begin
                data[PC_to_mem_address] <= PC_to_mem_data;
            end     
        end
    end

endmodule