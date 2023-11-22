`include "global.vh"

module RSICV_CPU
(
    input wire  [0:0] SYS_clk,
    input wire  [0:0] SYS_reset,

    //TODO: Kieungan, what is RAM being implemented?
);

    reg  [31:0] PC;
    wire [0:0]  invalid_instruction;

    wire [31:0] instruction;
    wire [31:0] new_PC; //need to choose

    wire [0:0]  MEM_write_enable;
    wire [31:0] MEM_write_data;
    wire [31:0] MEM_write_address;
    wire [31:0] MEM_read_address;
    wire [31:0] MEM_read_data;
    wire [31:0] instruction_address;

    wire [4:0] rs1, rs2, REG_write_address;
    wire [0:0] REG_write_enable;
    wire [31:0]REG_write_value, REG_rs1_data, REG_rs1_data;

    
    wire [`VLEN * 32 - 1 : 0] v_regs, new_v_regs ;
    wire [31:0] vl, new_vl ;
    wire [31:0] vstart, new_vstart;
    wire        vill, new_vill;
    wire [2:0]  vsew, new_vsew;
    wire [2:0]  vlmul, new_vlmul;
    wire [`VLEN - 1 : 0]      masks, new_masks;
    wire [31:0]               element_width;


    always @(posedge SYS_clk)
    begin
        if (SYS_reset)
        begin
            PC <= `START_INS_ADDRESS;
        end
        else 
            PC <= new_PC;
    end

    MAIN_MEMORY main_memory //the block hold the insrtuciton and data. It can be read every time and written at the clock. once
    (
        .SYS_clk            (SYS_clk),
        .SYS_reset          (SYS_reset),
        .instruction_address(PC),
        //INPUT
        .MEM_write_enable  (MEM_write_enable),
        .MEM_write_data    (MEM_write_data),
        .MEM_write_address (MEM_write_address),
        .MEM_read_address  (MEM_read_address),
        
        //OUTPUT
        .MEM_read_data      (MEM_read_data),
        .instruction        (instruction) //got the instruction
    );



    REGISTER_FILE register_file
    (
        .SYS_clk            (SYS_clk),
        .SYS_reset          (SYS_reset),
        .rs1                (rs1),
        .rs2                (rs2), 
        .REG_write_address  (REG_write_address), //written value may rd or else
        .REG_write_enable   (REG_write_enable), 
        .REG_write_value    (REG_write_value), 


        .REG_rs1_data       (REG_rs1_data), 
        .REG_rs2_data       (REG_rs2_data)
    );

    
    VECTOR_REGISTER_FILE VECTOR_REGISTER_FILE
    (
        .SYS_reset      (SYS_reset), 
        .SYS_clk        (SYS_clk),
        //INPUT, i.e. next value
        .new_v_regs     (new_v_regs) ,
        .new_vl         (new_vl),
        .new_vstart     (new_vstart),
        .new_vill       (new_vill),
        .new_vsew       (new_vsew),
        .new_vlmul      (new_vlmul),
        .new_masks      (new_masks),

        //OUTPUT
        .v_regs         (v_regs), //cannot, we can't assign to all, mux index by address
        .vl             (vl), //hold the number of elements to be updated -> index the last element
        .vstart         (vstart), //index the first element
        .vill           (vill), // illigal if attempt to set invalid value to vetype
        .vsew           (vsew),
        .vlmul          (vlmul),
        .element_width  (element_width),
        .masks          (masks)
    );

    DATA_PATH DATA_PATH
    (
        //INPUT
        .instruction        (instruction),
        .REG_rs1_data       (REG_rs1_data),
        .REG_rs2_data       (REG_rs2_data),
        .MEM_read_data      (MEM_read_data),
        .PC                 (PC),
        .v_regs(v_regs),
        .vl(vl),
        .vstart(vstart),
        .vill(vill),
        .vsew(vsew),
        .vlmul(vlmul),
        .element_width(element_width),
        .masks(masks),

        //OUTPUT
        .new_PC             (new_PC),
        .REG_write_value    (REG_write_value),
        .REG_write_enable   (REG_write_enable),
        .REG_write_address  (REG_write_address),

        .MEM_write_enable   (MEM_write_enable),
        .MEM_write_data     (MEM_write_data),
        .MEM_write_address  (MEM_write_address),

        .MEM_read_address   (MEM_read_address),
        .invalid_instruction(invalid_instruction),

        .rs1                (rs1),
        .rs2                (rs2),

        .new_v_regs(new_v_regs),
        .new_vl(new_vl),
        .new_vstart(new_vstart),
        .new_vill(new_vill),
        .new_vsew(new_vsew),
        .new_vlmul(new_vlmul),
        .new_masks(new_masks)
    );    
endmodule;


module DATA_PATH
(
    input [31:0] instruction,
    input [31:0] REG_rs1_data,
    input [31:0] REG_rs2_data,
    input [31:0] MEM_read_data,
    input [31:0] PC,

    //vector update
    input [`VLEN * 32 - 1 : 0] v_regs, 
    input [31 : 0]             vl, //hold the number of elements to be updated -> index the last element
    input [31 : 0]             vstart, //index the first element
    input                      vill, // illigal if attempt to set invalid value to vetype
    input [2:0]                vsew,
    input [2:0]                vlmul,
    input [31:0]               element_width,
    input [`VLEN - 1 : 0]      masks,

    output reg [31:0] new_PC,
    output reg [31:0] REG_write_value,
    output reg [0:0]  REG_write_enable,
    output reg [4:0]  REG_write_address,
    
    output reg [0:0]  MEM_write_enable,
    output reg [31:0] MEM_write_data,
    output reg [31:0] MEM_write_address,

    output reg [31:0] MEM_read_address,
    output reg [0:0]  invalid_instruction,
    output wire [4:0] rs1,
    output wire [4:0] rs2,

    //vector update
    output wire [`VLEN * 32 - 1 : 0] new_v_regs ,
    output reg [31:0] new_vl,
    output reg [31:0] new_vstart,
    output reg        new_vill,
    output reg [2:0]  new_vsew,
    output reg [2:0]  new_vlmul,
    output reg [`VLEN - 1 : 0] new_masks
);

    wire [6:0] opcode   = instruction [6:0];
    wire [4:0] rd       = instruction [11:7];
    assign     rs1      = instruction [19:15];
    assign     rs2      = instruction [24:20];
    wire [4:0] shamt    = instruction [24:20];
    wire [2:0] funct3   = instruction [14:12];
    wire [6:0] funct7   = instruction [31:25]; //R-type only
    wire [11:0]S_immed  ={instruction[31:25], instruction[11:7]}; //S-type only, for STORE
    wire [11:0]I_immed  = instruction[31:20];//I-type only, for LOAD and immediate ADD SUB....
    wire [12:1]B_immed  ={instruction[31], instruction[7], instruction[30:25], instruction[11:8]}; //B-type only, for conditional BRANCH
    wire [20:1]J_immed  ={instruction[31], instruction[19:12], instruction[20], instruction[30:21]};//J-type only, for JUMP-AND-LINK
    wire[31:12]U_immed  = instruction[31:12]; //U_type only, for LUI, wide immediate instruction....
    //vector update
    //vector load
    wire [2:0] width    = instruction[14:12];
    wire       vm       = instruction [25];
    wire [1:0] mop      = instruction [27:26];
    wire       mew      = instruction[28];
    wire [2:0] nf       = instruction [31:29] ;
    wire [4:0] vd       = instruction [11:7];
    wire [4:0] vs3      = instruction [11:7];
    // vector arthimetic
    wire [5:0] funct6   = instruction [31:26];
    wire [4:0] vs2      = instruction [24:20];
    wire [4:0] vs1      = instruction [19:15];
    //vector configuration instructions
    wire [10:0]zimm11   = instruction [30:20];
    wire [4:0] uimm     = instruction [19:15];

    reg branch_taken;

    reg [31:0] vlmax;

    reg   [(`VLEN - 1) : 0]    new_vector_register [0 : 31];
    wire  [(`VLEN - 1) : 0]    vector_register     [0 : 31];

    genvar i;
    generate
        for (i = 0; i <= 31; i = i + 1)
        begin: vector_assign
            assign vector_register[i]               = v_regs [(i * `VLEN) +: `VLEN];
            assign new_v_regs[(i * `VLEN) +: `VLEN] = new_vector_register[i];
        end
    endgenerate

    integer k;
    always @(instruction, REG_rs1_data, REG_rs2_data, MEM_read_data, PC, v_regs, vl, vstart, vill, vsew, vsew, vlmul, element_width) // all the input
    begin
        //set the default, also prevent latch
        new_PC              = PC + 4;
        REG_write_value     = 0;
        REG_write_enable    = 0;
        REG_write_address   = 0;
        MEM_write_enable    = 0;
        MEM_write_data      = 0;
        MEM_write_address   = 0;
        MEM_read_address    = 0;

        branch_taken        = 0;
        invalid_instruction = 0;

        for (k = 0; k <= 31; k = k+1)
            new_vector_register[k] = vector_register[k];
        
        
        new_vl              = vl;
        new_vstart          = vstart;
        new_vill            = vill;
        new_vsew            = vsew;
        new_vlmul           = vlmul;
        new_masks           = masks;

        vlmax = `VLEN / element_width; 
        

        case (opcode)
            7'b0110011: 
            begin //base-R, 10 instructions
                REG_write_enable = 1;
                REG_write_address= rd;

                //The funct7 and funct3 fields select the type of operation.
                case ({funct7, funct3})
                    10'b0000000_000: REG_write_value = REG_rs1_data + REG_rs2_data; //add
                    10'b0100000_000: REG_write_value = REG_rs1_data - REG_rs2_data;//sub
                    10'b0000000_001: REG_write_value = REG_rs1_data << REG_rs2_data;// ALU_operation = `ALU_SHIFT_LEFT;//sll
                    10'b0000000_010: REG_write_value = $signed(REG_rs1_data) < $signed(REG_rs2_data);  //ALU_operation = `ALU_LESS_SIGNED;//slt
                    10'b0000000_011: REG_write_value = $unsigned(REG_rs1_data) < $unsigned(REG_rs2_data);//sltu
                    10'b0000000_100: REG_write_value = REG_rs1_data ^ REG_rs2_data;//xor
                    10'b0000000_101: REG_write_value = REG_rs1_data >> REG_rs2_data;//srl
                    10'b0100000_101: REG_write_value = REG_rs1_data >>> REG_rs2_data;//sra
                    10'b0000000_110: REG_write_value = REG_rs1_data | REG_rs2_data;//or
                    10'b0000000_111: REG_write_value = REG_rs1_data & REG_rs2_data;//and
                    10'b0000001_000: REG_write_value = ($signed(REG_rs1_data) * $signed(REG_rs2_data)) [31:0];//mul, treat them as signed and put the LOWER in result
                    10'b0000001_001: REG_write_value = ($signed(REG_rs1_data) * $signed(REG_rs2_data)) [63:32];//mulh
                    10'b0000001_010: REG_write_value = ($signed(REG_rs1_data) * $unsigned(REG_rs2_data)) [63:32];//mulhsu
                    10'b0000001_011: REG_write_value = ($unsigned(REG_rs1_data) * $unsigned(REG_rs2_data)) [63:32];//mulhu
                    10'b0000001_100: REG_write_value = ($signed(REG_rs1_data) / $signed(REG_rs2_data));//div
                    10'b0000001_101: REG_write_value = ($unsigned(REG_rs1_data) / $unsigned(REG_rs2_data));//divu
                    10'b0000001_110: REG_write_value = ($signed(REG_rs1_data) % $signed(REG_rs2_data));//rem
                    10'b0000001_111: REG_write_value = ($unsigned(REG_rs1_data) % $unsigned(REG_rs2_data));//remu
                    default         : invalid_instruction = 1;
                endcase
            end

            7'b0010011: //I- arthimetic and shift
            begin
                REG_write_enable = 1;
                REG_write_address= rd;

                case (funct3)
                    3'b000: REG_write_value = $signed(REG_rs1_data) + $signed(I_immed);
                    3'b010: REG_write_value = $signed(REG_rs1_data) < $signed(I_immed);
                    3'b011: REG_write_value = $unsigned(REG_rs1_data) < $unsigned(I_immed);
                    3'b100: REG_write_value = $unsigned(REG_rs1_data) ^ $unsigned(I_immed);
                    3'b110: REG_write_value = $unsigned(REG_rs1_data) | $unsigned(I_immed);
                    3'b111: REG_write_value = $unsigned(REG_rs1_data) & $unsigned(I_immed);
                    3'b001: REG_write_value = REG_rs1_data << shamt;
                    3'b101: if (funct7 == 7'd0) 
                                REG_write_value = REG_rs1_data >> shamt;
                            else
                                REG_write_value = REG_rs1_data >>> shamt;
                    default: invalid_instruction = 1;
                endcase
            end

            7'b0000011: //I - load only
            begin
                REG_write_enable = 1;
                REG_write_address= rd;
                MEM_read_address = REG_rs1_data + $signed(I_immed); // go to change the mem read value...
                REG_write_data = MEM_read_data;
            end

            7'b1100111: //I- jalr only
            begin
                REG_write_enable = 1;
                REG_write_address= rd;
                REG_write_value  = PC + 4;
                new_PC           = (REG_rs1_data + $signed(I_immed)) << 1 ;
            end

            7'b1101111: // J jal only
            begin
                REG_write_enable = 1;
                REG_write_address= rd;
                REG_write_value  = PC + 4;
                new_PC           = PC + $signed(J_immed << 1);
            end

            7'b1100011: //B-type
            begin
                case(funct3)
                    3'b000: branch_taken = REG_rs1_data == REG_rs2_data; //BEQ
                    3'b001: branch_taken = REG_rs1_data != REG_rs2_data;//BNE
                    3'b100: branch_taken = $signed(REG_rs1_data) < $signed(REG_rs2_data);//BLT
                    3'b101: branch_taken = $signed(REG_rs1_data) >= $signed(REG_rs2_data);//bge
                    3'b110: branch_taken = REG_rs1_data < REG_rs2_data;//bltu
                    3'b111: branch_taken = REG_rs1_data >= REG_rs2_data;//bgeu
                    default: invalid_instruction = 1;
                endcase

                if (branch_taken) new_PC = PC + $signed(B_immed << 1);
            end

            7'b0000111: //vector load
            begin
              
            end

            7'b0100111: //vector store
            begin
            
            end

            7'b1010111: //vector arthimetic
            begin
                case (funct3)
                    3'b010: //OPMVV vector and vector multiply

                    3'b011: //OPIVI vector and IMM

                    3'b100: //OPIVX vector and scalar I base

                    3'b110: //OPMVX vector and scalar

                    3'b000: //OPIVV  vector and vector I base

                    default: invalid_instruction = 1;
                endcase
            end
            7'b1010111: //vector configuration
            begin   //tự hiện thực, đặt vtype = zimm
                if (instruction[2:0] == 3'b111)
                begin
                    if (instruction[31] == 0)   //vsetvli
                    begin
                        new_vlmul = zimm11[2:0];
                        new_vsew = zimm11 [5:3];
                        if  (new_vsew > 3'b010)
                            new_vsew = 3'b010;

                        if      (new_vlmul == 3'b000)
                            vlmax = `VLEN / (2 ** (new_vsew + 3)); 
                        else if (new_vlmul == 3'b001)
                            vlmax = 2 * `VLEN / (2 ** (new_vsew + 3)); 
                        else if (new_vlmul == 3'b010)
                            vlmax = 4 * `VLEN / (2 ** (new_vsew + 3)); 
                        else if (new_vlmul == 3'b011)
                            vlmax = 8 * `VLEN / (2 ** (new_vsew + 3)); 
                        else if (new_vlmul == 3'b101)
                            vlmax = `VLEN / 8 / (2 ** (new_vsew + 3)); 
                        else if (new_vlmul == 3'b110)
                            vlmax = `VLEN / 4 / (2 ** (new_vsew + 3)); 
                        else if (new_vlmul == 3'b111)
                            vlmax = `VLEN / 2 / (2 ** (new_vsew + 3)); 
                            
                        REG_write_enable = 1;
                        REG_write_address= rd;
                        if (REG_rs1_data <= vlmax)
                            new_vl = REG_rs1_data;
                        else
                            new_vl = vlmax;
                        
                        REG_write_value = new_vl;

                        new_vill = 0;
                    end
                    
                    else if (instruction [30] == 1)//vsetivli
                    begin
                        new_vlmul = zimm11[2:0];
                        new_vsew = zimm11 [5:3];
                        if  (new_vsew > 3'b010)
                            new_vsew = 3'b010;

                        if      (new_vlmul == 3'b000)
                            vlmax = `VLEN / (2 ** (new_vsew + 3)); 
                        else if (new_vlmul == 3'b001)
                            vlmax = 2 * `VLEN / (2 ** (new_vsew + 3)); 
                        else if (new_vlmul == 3'b010)
                            vlmax = 4 * `VLEN / (2 ** (new_vsew + 3)); 
                        else if (new_vlmul == 3'b011)
                            vlmax = 8 * `VLEN / (2 ** (new_vsew + 3)); 
                        else if (new_vlmul == 3'b101)
                            vlmax = `VLEN / 8 / (2 ** (new_vsew + 3)); 
                        else if (new_vlmul == 3'b110)
                            vlmax = `VLEN / 4 / (2 ** (new_vsew + 3)); 
                        else if (new_vlmul == 3'b111)
                            vlmax = `VLEN / 2 / (2 ** (new_vsew + 3)); 

                        REG_write_enable = 1;
                        REG_write_address= rd;
                        if (uimm <= vlmax)
                            new_vl = uimm;
                        else
                            new_vl = vlmax;

                        REG_write_value = new_vl;

                        new_vill = 0;

                        
                    end
                    
                    // else if (instruction[30:25] == 0) //vsetvl
                    // begin
                      
                    // end

                    else invalid_instruction = 1;
                end
                else invalid_instruction = 1;
            end

            default: invalid_instruction = 1;
        endcase

        if (invalid_instruction == 1)
        begin
            REG_write_enable    = 0;
            MEM_write_enable    = 0;
            branch_taken        = 0;
            new_PC              = PC + 4;
        end
    end
endmodule