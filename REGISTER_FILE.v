module REGISTER_FILE(
    input       SYS_clk,
    input       SYS_reset,

    input [4:0] rs1,
    input [4:0] rs2, 
    input [4:0] REG_write_address, 
    input [0:0] REG_write_enable, 
    input [31:0]REG_write_value, 


    output wire [31:0] REG_rs1_data, 
    output wire [31:0] REG_rs2_data
);
    // input [31:0] testt_reg_add,
    // output [31:0] testt_reg

    reg [31:0] register [0:31];
    integer i;

    assign REG_rs1_data = register[rs1];
    assign REG_rs2_data = register[rs2];

    always @(posedge clk)
    begin 
        if (SYS_reset)
        begin
            for(i = 0; i<32 ; i=i+1)
                register[i] <= 32'b0;
        end
        else if(REG_write_enable && REG_write_address != 0)
        begin
            register[REG_write_address] <= REG_write_value;
        end

        register[0] <= 0;
    end

    // assign testt_reg = register[testt_reg_add];
endmodule
