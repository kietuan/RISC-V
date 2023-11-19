`include "global.vh"
module MEMORY
(
    input wire [0:0] SYS_clk,
    input wire [0:0] SYS_reset,

    input wire [0:0]  MEM_write_enable,
    input wire [31:0] MEM_write_data,
    input wire [31:0] MEM_write_address,

    input wire [31:0]  MEM_read_address,
    output wire [31:0] MEM_read_data,

    input wire [31:0]  instruction_address,
    output wire [31:0] instruction
);
    reg [7:0] data [0 : 32'hFFFF_FFFF]

    assign MEM_read_data[31:0]   = {data[MEM_read_address+3],data[MEM_read_address+2], data[MEM_read_address+1], data[MEM_read_address]};
    assign instruction[31:0] = {data[instruction_address+3],data[instruction_address+2], data[instruction_address+1], data[instruction_address]};


    integer i;
    always @(posedge SYS_clk) 
    begin
        if (SYS_reset)
        begin
            //TODO Kieungan: initialize the memory in the start of
        end
        
        else if (MEM_write_enable)
        begin
            data[MEM_write_address+3] <= MEM_write_data[31:24];
            data[MEM_write_address+2] <= MEM_write_data[23:16];
            data[MEM_write_address+1] <= MEM_write_data[15:8];
            data[MEM_write_address+0] <= MEM_write_data[7:0];
        end
    end

endmodule