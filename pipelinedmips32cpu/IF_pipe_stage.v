`timescale 1ns / 1ps


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    
// write your code here
wire [9:0] mux1_to_mux2, mux2_to_pc, pc_to_mem, pc_plus4_b4;
wire [31:0] instr_b4;
reg [9:0] pc;


assign instr = instr_b4;
assign pc_plus4 = pc_plus4_b4;
assign pc_to_mem = pc;
assign pc_plus4_b4 = pc + 10'b0000000100;



 always @(posedge clk or posedge reset)  
    begin   
        if(reset)   
           pc = 10'b0000000000;  
        else
        if(en)  
           pc = mux2_to_pc;  
    end  

mux2 #(.mux_width(10)) mux1
(   .a(pc_plus4_b4),
    .b(branch_address),
    .sel(branch_taken),
    .y(mux1_to_mux2));
    
mux2 #(.mux_width(10)) mux2
(   .a(mux1_to_mux2),
    .b(jump_address),
    .sel(jump),
    .y(mux2_to_pc));

instruction_mem #() the_intstruction_mem
(   .read_addr(pc_to_mem),
    .data(instr_b4));
endmodule
