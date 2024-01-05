`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    
    // write your code here 
    // Remember that we test if the branch is taken or not in the decode stage.
    wire reg_dst,bee, mem_to_reg_b4, mem_read_b4,branch, mem_write_b4, alu_src_b4, reg_write_b4, sel;
    wire [1:0] alu_op_b4;
    wire [31:0] se, reg1_b4, reg2_b4;
    wire zero;
    
    assign zero = 2'b0;
    assign sel = Control_Hazard | (~Data_Hazard);
    assign jump_address = instr[25:0] << 2; 
    assign branch_address = pc_plus4 + (se<<2);
    assign reg1 = reg1_b4;
    assign reg2 = reg2_b4;
    assign bee =((reg1 ^ reg2 )==32'd0) ? 1'b1: 1'b0;
    assign branch_taken = bee & branch; 
    assign imm_value = se;
    
    mux2 #(.mux_width(5)) mux7
    (   .a(instr [20:16]),
        .b(instr [15:11]),
        .sel(reg_dst ),
        .y(destination_reg ));
    register_file #() da_register_files
    (   .clk (clk),
        .reset(reset),
        .reg_write_en(mem_wb_reg_write),
        .reg_write_dest(mem_wb_write_reg_addr),
        .reg_write_data (mem_wb_write_back_data),
        .reg_read_addr_1(instr [25:21]),
        .reg_read_addr_2(instr [20:16]),
        .reg_read_data_1(reg1_b4),
        .reg_read_data_2 (reg2_b4));
        
    sign_extend #() see
    (   .sign_ex_in(instr[15:0]),
        .sign_ex_out (se));
        
    mux2 #(.mux_width(1)) mux1
    (   .a(mem_to_reg_b4 ),
        .b(zero),
        .sel(sel),
        .y(mem_to_reg ));
    
    mux2 #(.mux_width(1)) mux2
    (   .a(mem_read_b4 ),
        .b(zero),
        .sel(sel),
        .y(mem_read ));
    
    mux2 #(.mux_width(1)) mux3
    (   .a(mem_write_b4 ),
        .b(zero ),
        .sel(sel ),
        .y(mem_write ));
    mux2 #(.mux_width(1)) mux4
    (   .a(alu_src_b4 ),
        .b(zero ),
        .sel(sel ),
        .y(alu_src ));
    mux2 #(.mux_width(1)) mux5
    (   .a(reg_write_b4 ),
        .b(zero  ),
        .sel(sel ),
        .y(reg_write ));
    mux2 #(.mux_width(2)) mux6
    (   .a(alu_op_b4 ),
        .b(zero),
        .sel(sel),
        .y(alu_op ));
         
    control #() da_control
    (   .reset(reset),
        .opcode(instr[31:26]),
        .reg_dst(reg_dst),
        .mem_to_reg(mem_to_reg_b4),
        .alu_op(alu_op_b4),
        .mem_read(mem_read_b4),
        .mem_write(mem_write_b4),
        .alu_src(alu_src_b4),
        .reg_write(reg_write_b4),
        .branch(branch),
        .jump(jump));
       
endmodule
