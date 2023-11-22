`include "global.vh"
module VECTOR_REGISTER_FILE
(
    input SYS_reset, SYS_clk,
    //input next_value?

    output reg [(`VLEN - 1) : 0] vector_register [0 : 31],

    // control registers
    output reg [31 : 0]          vl, //hold the number of elements to be updated -> index the last element
    output reg [31 : 0]          vstart, //index the first element
    output reg [31 : 0]          vetype,
    output wire                  vill, // illigal if attempt to set invalid value to vetype
    output wire [2:0]            vsew,
    output wire [2:0]            vlmul,
    output reg [31:0]            element_width
);
    assign vill = vetype [31];
    assign vsew = vetype [5:3]; 
    assign vlmul= vetype [2:0];

    always (SYS_clk)
    begin
        if (SYS_reset)
        begin
          
        end

        else
        begin

        end
    end
    always @(vetype) 
    begin
        element_width = 32;
        
        if      (vsew == 3'b000) element_width = 32'd8;
        else if (vsew == 3'b001) element_width = 32'd16;
        else if (vsew == 3'b010) element_width = 32'd32;
        // else if (vsew == 3'b011) element_width = 32'd64; IS IT UPSUPPORTED because of ELEN = 32
    end
endmodule
