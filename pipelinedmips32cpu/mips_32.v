`timescale 1ns / 1ps


module mips_32(
    input clk, reset,  
    output[31:0] result
    );
    
// define all the wires here. You need to define more wires than the ones you did in Lab2
wire branch_taken, jump, mem_to_reg, id_ex_mem_to_reg, mem_read, mem_write, alu_src, reg_write, control_hazard, data_hazard,
mem_wb_reg_write, id_ex_alu_src, id_ex_reg_write, id_ex_mem_write, id_ex_mem_read, flush;
wire [9:0] jump_address, branch_address, pc_plus4, if_id_pc_plus4;
wire[31:0] instr, id_ex_instr, if_id_instr, mem_wb_write_back_data, reg1, reg2, imm_value, id_ex_reg1,
id_ex_reg2, id_ex_imm_value;
wire[4:0] mem_wb_write_reg_addr, destination_reg, id_ex_destination_reg;
wire[1:0] alu_op, id_ex_alu_op;



wire [1:0] forward_a, forward_b;
wire[31:0] alu_result, alu_in2_out, ex_mem_alu_result, mem_wb_write_back_result;

wire mem_wb_mem_to_reg;
wire [31:0] mem_wb_alu_result, mem_wb_mem_read_data;

wire [31:0] ex_mem_instr, ex_mem_alu_result, ex_mem_alu_in2_out, mem_read_data ;
	wire[4:0] ex_mem_destination_reg;
	wire ex_mem_mem_to_reg, ex_mem_mem_read, ex_mem_mem_write, ex_mem_reg_write;

assign result = mem_wb_write_back_result;
///////////////////////////// Instruction Fetch    
    // Complete your code here

IF_pipe_stage#() da_if
(   .branch_taken(branch_taken),
    .branch_address(branch_address),
    .clk(clk),
    .reset(reset),
    .jump(jump),
    .jump_address (jump_address),
    .en(data_hazard),
    .pc_plus4(pc_plus4),
    .instr(instr) );

///////////////////////////// IF/ID registers
    // Complete your code here

pipe_reg_en #(.WIDTH(10)) pipe1
(   .clk(clk),
    .reset(reset),
    .flush(flush),
    .en(data_hazard ),
    .d(pc_plus4 ),
    .q(if_id_pc_plus4 ));

pipe_reg_en #(.WIDTH(32)) pipe2
(   .clk(clk),
    .reset(reset),
    .flush(flush),
    .en(data_hazard ),
    .d(instr ),
    .q(if_id_instr));

///////////////////////////// Instruction Decode 
	// Complete your code here
	
	ID_pipe_stage #() DA_id
	(  .clk(clk),
	   .reset(reset),
	   .instr(if_id_instr ),
	   .pc_plus4(if_id_pc_plus4 ),
	   .mem_wb_reg_write (mem_wb_reg_write),
	   .mem_wb_write_reg_addr (mem_wb_write_reg_addr),
	   .mem_wb_write_back_data (mem_wb_write_back_result),
	   .jump(jump),
	   .Control_Hazard (flush),
	   .Data_Hazard (data_hazard),
	   .mem_to_reg (mem_to_reg),
	   .alu_op (alu_op),
	   .mem_read (mem_read),
	   .mem_write (mem_write),
	   .alu_src (alu_src),
	   .reg_write (reg_write),
	   .jump_address (jump_address),
	   .branch_address (branch_address),
	   .branch_taken (branch_taken),
	   .reg1(reg1),
	   .reg2 (reg2),
	   .imm_value (imm_value),
	   .destination_reg (destination_reg)   );
	
	
///////////////////////////// ID/EX registers 
	// Complete your code here
	
	pipe_reg #(.WIDTH(32)) d_pipe1
	(  .clk(clk),
	   .reset(reset),
	   .d(if_id_instr),
	   .q(id_ex_instr));
	pipe_reg #(.WIDTH(32)) d_pipe2
	(  .clk(clk),
	   .reset(reset),
	   .d(reg1 ),
	   .q(id_ex_reg1 ));
	pipe_reg #(.WIDTH(32)) d_pipe3
	(  .clk(clk),
	   .reset(reset),
	   .d(reg2 ),
	   .q(id_ex_reg2 ));
	pipe_reg #(.WIDTH(32)) d_pipe4
	(  .clk(clk),
	   .reset(reset),
	   .d(imm_value ),
	   .q(id_ex_imm_value));
	pipe_reg #(.WIDTH(5)) d_pipe5
	(  .clk(clk),
	   .reset(reset),
	   .d(destination_reg ),
	   .q(id_ex_destination_reg ));
	pipe_reg #(.WIDTH(1)) d_pipe6
	(  .clk(clk),
	   .reset(reset),
	   .d(mem_to_reg ),
	   .q(id_ex_mem_to_reg ));
	pipe_reg #(.WIDTH(2)) d_pipe7
	(  .clk(clk),
	   .reset(reset),
	   .d(alu_op ),
	   .q(id_ex_alu_op ));
	pipe_reg #(.WIDTH(1)) d_pipe8
	(  .clk(clk),
	   .reset(reset),
	   .d(mem_read ),
	   .q(id_ex_mem_read ));
	pipe_reg #(.WIDTH(1)) d_pipe9
	(  .clk(clk),
	   .reset(reset),
	   .d(mem_write ),
	   .q(id_ex_mem_write ));
	pipe_reg #(.WIDTH(1)) d_pipe10
	(  .clk(clk),
	   .reset(reset),
	   .d(alu_src ),
	   .q(id_ex_alu_src ));
	pipe_reg #(.WIDTH(1)) d_pipe11
	(  .clk(clk),
	   .reset(reset),
	   .d(reg_write ),
	   .q(id_ex_reg_write ));
	   
	
///////////////////////////// Hazard_detection unit
	// Complete your code here    
    Hazard_detection #() da_detection
    (   .id_ex_mem_read(id_ex_mem_read),
        .id_ex_destination_reg (id_ex_destination_reg ),
        .if_id_rs(if_id_instr [25:21]),
        .if_id_rt(if_id_instr [20:16]),
        .branch_taken(branch_taken ),
        .jump (jump),
        .Data_Hazard (data_hazard ),
        .IF_Flush(flush));
             
           
           
           
///////////////////////////// Execution    
	// Complete your code here
	
	//ex wire 
	
	EX_pipe_stage #()el_ex
	(  .id_ex_imm_value(id_ex_imm_value),
	   .reg1 (id_ex_reg1),
	   .reg2 (id_ex_reg2),
	   .id_ex_instr (id_ex_instr),
	   .id_ex_alu_op (id_ex_alu_op),
	   .id_ex_alu_src (id_ex_alu_src),
	   .alu_result (alu_result),
	   .alu_in2_out (alu_in2_out),
	   .Forward_A (forward_a),
	   .Forward_B (forward_b),
	   .ex_mem_alu_result (ex_mem_alu_result),
	   .mem_wb_write_back_result (mem_wb_write_back_result));
	
	
	
///////////////////////////// Forwarding unit
	// Complete your code here 
	EX_Forwarding_unit #() yes
	(  .ex_mem_reg_write (ex_mem_reg_write ),
	   .ex_mem_write_reg_addr(ex_mem_destination_reg ),
	   .id_ex_instr_rs (id_ex_instr[25:21]  ),
	   .id_ex_instr_rt (id_ex_instr[20:16] ),
	   .mem_wb_reg_write (mem_wb_reg_write) ,
	   .mem_wb_write_reg_addr (mem_wb_write_reg_addr ),
	   .Forward_A (forward_a ),
	   .Forward_B (forward_b ));
	
     
///////////////////////////// EX/MEM registers
	// Complete your code here 
	pipe_reg #(.WIDTH(32)) thirdset1
	(  .clk(clk),
	   .reset(reset),
	   .d(id_ex_instr ),
	   .q(ex_mem_instr ));
	pipe_reg #(.WIDTH(5)) thirdset2
	(  .clk(clk),
	   .reset(reset ),
	   .d(id_ex_destination_reg ),
	   .q(ex_mem_destination_reg ));
	pipe_reg #(.WIDTH(32)) thirdset3
	(  .clk(clk ),
	   .reset(reset ),
	   .d(alu_result ),
	   .q(ex_mem_alu_result ));
	pipe_reg #(.WIDTH(32)) thirdset4
	(  .clk(clk),
	   .reset(reset),
	   .d(alu_in2_out ),
	   .q(ex_mem_alu_in2_out ));
	pipe_reg #(.WIDTH(1)) thirdset5
	(  .clk(clk),
	   .reset(reset),
	   .d(id_ex_mem_to_reg  ),
	   .q(ex_mem_mem_to_reg ));
	pipe_reg #(.WIDTH(1)) thirdset6
	(  .clk(clk ),
	   .reset(reset),
	   .d(id_ex_mem_read ),
	   .q(ex_mem_mem_read ));
	pipe_reg #(.WIDTH(1)) thirdset7
	(  .clk(clk ),
	   .reset(reset ),
	   .d(id_ex_mem_write ),
	   .q(ex_mem_mem_write ));
	pipe_reg #(.WIDTH(1)) thirdset8
	(  .clk(clk ),
	   .reset(reset ),
	   .d(id_ex_reg_write ),
	   .q(ex_mem_reg_write ));
	
	
///////////////////////////// MEM/WB registers  
	// Complete your code here
	
	data_mem#() data_mem
	(  .clk(clk),
	   .mem_access_addr (ex_mem_alu_result  ),
	   .mem_write_data(ex_mem_alu_in2_out ),
	   .mem_write_en(ex_mem_mem_write ),
	   .mem_read_en (ex_mem_mem_read ),
	   .mem_read_data (mem_read_data));
	   
	pipe_reg #(.WIDTH(32)) woah
	(  .clk(clk),
	   .reset(reset),
	   .d(ex_mem_alu_result ),
	   .q(mem_wb_alu_result ));   
	pipe_reg #(.WIDTH(32)) woah2
	(  .clk(clk),
	   .reset(reset),
	   .d(mem_read_data ),
	   .q(mem_wb_mem_read_data));   
	pipe_reg #(.WIDTH(1)) woah3
	(  .clk(clk),
	   .reset(reset),
	   .d(ex_mem_mem_to_reg ),
	   .q(mem_wb_mem_to_reg));   
	pipe_reg #(.WIDTH(1)) woah4
	(  .clk(clk),
	   .reset(reset),
	   .d(ex_mem_reg_write ),
	   .q(mem_wb_reg_write ));   
	pipe_reg #(.WIDTH(5)) woah5
	(  .clk(clk),
	   .reset(reset),
	   .d(ex_mem_destination_reg ),
	   .q(mem_wb_write_reg_addr ));   
	
	mux2 #(.mux_width(32)) final_damn_mux
	(  .a(mem_wb_alu_result),
	   .b(mem_wb_mem_read_data),
	   .sel(mem_wb_mem_to_reg),
	   .y(mem_wb_write_back_result));
	

///////////////////////////// writeback    
    
endmodule
