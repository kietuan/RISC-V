module INS_MEMORY
(
    input wire [0:0] SYS_clk,
    input wire [0:0] SYS_reset,
    input  wire [31:0]  PC,

    output wire [31:0]  instruction
);
    reg [31:0] data [0 : 1000];
    assign instruction[31:0] = data[PC >> 2];

    integer i, file;
    always @(posedge SYS_clk) 
    begin
        if (SYS_reset)
        begin
            for(i=0; i<1000 ;i=i+1)
            begin
                data[i] = 0;
            end

            $readmemh("C:/Users/tuankiet/Desktop/RISC-V/input_text.txt", data);

        end
    end

endmodule;