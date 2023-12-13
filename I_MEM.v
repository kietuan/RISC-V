`include "include.v"
module INS_MEMORY
(
    input wire [0:0] SYS_clk,
    input wire [0:0] SYS_reset,
    input  wire [31:0]  PC,

    output wire [31:0]  instruction
);
    reg [31:0] data [(`INS_START_ADDRESS >> 2) : (`INS_START_ADDRESS >> 2) + 1000];
    assign instruction[31:0] = data[PC >> 2];

    integer i, file;
    always @(posedge SYS_clk) 
    begin
        if (SYS_reset)
        begin
            for(i=(`INS_START_ADDRESS >> 2); i<(`INS_START_ADDRESS >> 2) + 1000 ;i=i+1)
            begin
                data[i] = 0;
            end
            
            `ifdef TESTING
            $readmemh("C:/Users/tuankiet/Desktop/RISC-V/test/input_text.txt", data);
            `endif
        end
    end

endmodule