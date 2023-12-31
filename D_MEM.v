`include "include.v"

module DATA_MEMORY
(
    input wire [0:0] SYS_clk,
    input wire [0:0] SYS_reset,

    input wire [1:0]  MEM_read_length,
    input wire        MEM_read_signed,

    input wire [1:0]  MEM_write_length,
    input wire [31:0] MEM_write_data,
    input wire [31:0] MEM_write_address,

    input wire [31:0]  MEM_read_address,

    output reg [31:0] MEM_read_data
);
    reg [7:0] data [`DATA_START_ADDRESS :`DATA_END_ADDRESS];
    always @(*) 
    begin
        MEM_read_data[31:0]   = {data[MEM_read_address+0],data[MEM_read_address+1], data[MEM_read_address+2], data[MEM_read_address+3]};
        
        if (MEM_read_length == 2'b01) //read 1 byte
        begin
            if (MEM_read_signed)
                MEM_read_data = { {24{data[MEM_read_address][7]}}  , data[MEM_read_address]};
            else 
                MEM_read_data = { {24{1'b0}}  , data[MEM_read_address]};
        end

        else if (MEM_read_length == 2'b10) //read half word
        begin
            if (MEM_read_signed)
                MEM_read_data = { {16{data[MEM_read_address + 0][7]}}  , data[MEM_read_address+0], data[MEM_read_address+1]};
            else 
                MEM_read_data = { {16{1'b0}}  ,                          data[MEM_read_address+0], data[MEM_read_address+1]};
        end
    end

    integer i, file;
    always @(posedge SYS_clk) 
    begin
        if (SYS_reset)
        begin
            //TODO Kieungan: initialize the memory in the start of
            for (i = `DATA_START_ADDRESS ; i <=`DATA_END_ADDRESS; i = i + 1)
                data [i] = 0;
            
            `ifdef TESTING
            $readmemh("C:/Users/tuankiet/Desktop/RISC-v/test/input_data.txt", data);
            `endif
        end

        else if (MEM_write_length == 2'b01) //store 1 byte
        begin
            data[MEM_write_address+0] <= MEM_write_data[7:0];
        end

        else if (MEM_write_length == 2'b10) //store half-word
        begin
            data[MEM_write_address  ] <= MEM_write_data[15:8];
            data[MEM_write_address+1] <= MEM_write_data[7:0];
        end

        else if (MEM_write_length == 2'b11) //store word
        begin
            data[MEM_write_address  ] <= MEM_write_data[31:24];
            data[MEM_write_address+1] <= MEM_write_data[23:16];
            data[MEM_write_address+2] <= MEM_write_data[15:8];
            data[MEM_write_address+3] <= MEM_write_data[7:0];
        end

        `ifdef TESTING
        file = $fopen("C:/Users/tuankiet/Desktop/RISC-V/test/output_data.txt", "w");
        for (i = `DATA_START_ADDRESS ; i <= `DATA_END_ADDRESS; i = i + 1) 
        begin
            $fwrite(file, "%h\n", data[i]);
        end
        $fclose(file);
        `endif
    end

endmodule