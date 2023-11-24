`include "global.vh"
module MEMORY
(
    input wire [0:0] SYS_clk,
    input wire [0:0] SYS_reset,

    input wire [1:0]  MEM_write_length,
    input wire [1:0]  MEM_read_length,
    input wire        MEM_read_signed,
    input wire [31:0] MEM_write_data,
    input wire [31:0] MEM_write_address,

    input wire [31:0]  MEM_read_address,
    input wire [31:0]  PC,

    output reg [31:0] MEM_read_data,
    output wire [31:0] instruction
);
    reg [7:0] data [0 : 32'hFFFF_FFFF]

    assign instruction[31:0] = {data[PC+3],data[PC+2], data[PC+1], data[PC]};

    always @(*) 
    begin
        MEM_read_data[31:0]   = {data[MEM_read_address+3],data[MEM_read_address+2], data[MEM_read_address+1], data[MEM_read_address]};
        
        if (MEM_read_length == 2'b01)
        begin
            if (MEM_read_signed)
                MEM_read_data = { {24{data[MEM_read_address][7]}}  , data[MEM_read_address]};
            else 
                MEM_read_data = { {24{0}}  , data[MEM_read_address]};
        end

        else if (MEM_read_length == 2'b10)
        begin
            if (MEM_read_signed)
                MEM_read_data = { {16{data[MEM_read_address + 1][7]}}  , data[MEM_read_address+1], data[MEM_read_address]};
            else 
                MEM_read_data = { {16{0}}  ,                             data[MEM_read_address+1], data[MEM_read_address]};
        end
    end

    integer i;
    always @(posedge SYS_clk) 
    begin
        if (SYS_reset)
        begin
            //TODO Kieungan: initialize the memory in the start of
        end

        else if (MEM_write_length == 2'b01) //store 1 byte
        begin
            data[MEM_write_address+0] <= MEM_write_data[7:0];
        end

        else if (MEM_write_length == 2'b10) //store half-word
        begin
            data[MEM_write_address+1] <= MEM_write_data[15:8];
            data[MEM_write_address+0] <= MEM_write_data[7:0];
        end

        else if (MEM_write_length == 2'b11) //store word
        begin
            data[MEM_write_address+3] <= MEM_write_data[31:24];
            data[MEM_write_address+2] <= MEM_write_data[23:16];
            data[MEM_write_address+1] <= MEM_write_data[15:8];
            data[MEM_write_address+0] <= MEM_write_data[7:0];
        end
    end

endmodule