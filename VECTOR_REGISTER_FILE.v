`include "global.vh"
module VECTOR_REGISTER_FILE
(
    input SYS_reset, SYS_clk,
    input [`VLEN * 32 - 1 : 0] new_v_regs ,
    input [31:0] new_vl,
    input        new_vill,
    input [2:0]  new_vsew,
    input [2:0]  new_vlmul,
    input [`VLEN - 1 : 0] new_masks,

    output reg [`VLEN * 32 - 1 : 0] v_regs, //cannot, we can't assign to all, mux index by address
    output reg [`VLEN - 1 : 0]  masks,
    // control registers
    output reg [31 : 0]          vl, //hold the number of elements to be updated -> index the last element
    output reg [31 : 0]          vstart, //index the first element
    output reg                   vill, // illigal if attempt to set invalid value to vetype
    output reg [2:0]             vsew,
    output reg [2:0]             vlmul,
    output reg [31:0]            element_width
);
    integer i;
    always @(posedge SYS_clk)
    begin
        if (SYS_reset)
        begin
            vill    <= 1;
            vsew    <= 0;
            vlmul   <= 0;
            vl      <= 0;
            v_regs <= 0;
            for (i = 0; i < `VLEN ; i = i + 1)
                masks[i] <= 1;
        end

        else
        begin
            v_regs <= new_v_regs ;
            vl     <= new_vl;
            vill   <= new_vill;
            vsew   <= new_vsew;
            vlmul  <= new_vlmul;
            masks <= new_masks;
        end
    end

    always @(vsew) 
    begin
        element_width = 32;
        
        if      (vsew == 3'b000) element_width = 32'd8;
        else if (vsew == 3'b001) element_width = 32'd16;
        else if (vsew == 3'b010) element_width = 32'd32;
        // else if (vsew == 3'b011) element_width = 32'd64; IS IT UPSUPPORTED because of ELEN = 32
    end
endmodule
