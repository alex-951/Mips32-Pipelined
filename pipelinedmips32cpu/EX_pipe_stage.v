`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    // Write your code here
    wire[31:0] zero, mux1_to_alu, mux2_to_mux3, mux3_to_alu;
    wire [3:0] alu_control;
    wire dub;
    assign zero= 32'b0;
    assign alu_in2_out = mux2_to_mux3;
    
    ALU #() da_alu
    (   .a(mux1_to_alu),
        .b(mux3_to_alu),
        .alu_control(alu_control ),
        .zero(dub),
        .alu_result (alu_result));
        
    ALUControl #()da_alu_control
    (   .ALUOp (id_ex_alu_op ),
        .Function (id_ex_instr [5:0] ),
        .ALU_Control (alu_control));
    
     mux4 #(.mux_width(32)) mux1
    (   .a(reg1 ),
        .b(mem_wb_write_back_result  ),
        .c(ex_mem_alu_result ),
        .d(zero),
        .sel(Forward_A ),
        .y(mux1_to_alu));
     
      mux4 #(.mux_width(32)) mux2
    (   .a(reg2 ),
        .b(mem_wb_write_back_result ),
        .c(ex_mem_alu_result ),
        .d(zero),
        .sel(Forward_B ),
        .y(mux2_to_mux3));
      mux2 #(.mux_width()) mux3
    (   .a(mux2_to_mux3 ),
        .b(id_ex_imm_value ),
        .sel(id_ex_alu_src ),
        .y(mux3_to_alu));
        
        
    
   
endmodule
