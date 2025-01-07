`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/20 22:19:38
// Design Name: 
// Module Name: alucontrol
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//R型指令：ADD/ADDU/SUB/SUBU/AND/OR/XOR/NOR/SLT/SLTU +SLL/SRL/SRA+SLLV/SRLV/SRAV aluop为10OP就是Func
//带有立即数的ALU指令ADDI / ADDIU / ANDI / ORI / XORI / SLTI/sltiu aluop确定为11，通过INSOP确定OP
//条件跳转指令beq/bne/beqz/ aluop确定为01,通过INSOP确定OP(这个指令是传入pcalu的)
//l/s指令确定aluop为00，操作符为100000
module alucontrol(INS_OP,rt,Func,aluop,OP);//利用instruction的op和func部分以及aluop确定最终传入ALU的操作
    input wire[5:0] INS_OP;
    input wire[5:0] Func;
    input wire[4:0] rt;
    input wire[1:0] aluop;
    output wire[5:0] OP;
    //判断指令类型
    wire i_R=(aluop==2'b10)?1:0;
    wire i_lsj=(aluop==2'b00)?1:0;
    wire i_branch=(aluop==2'b01)?1:0;
    wire i_alui=(aluop==2'b11)?1:0;
    //判断具体的指令
    wire beq=(INS_OP==6'b000100)?1:0;
    wire bne=(INS_OP==6'b000101)?1:0;
    wire bgez=(INS_OP==6'b000001&rt==5'b00001)?1:0;
    wire blez=(INS_OP==6'b000110)?1:0;
    wire bgtz=(INS_OP==6'b000111)?1:0;
    wire bltz=(INS_OP==6'b000001&rt==5'b00000)?1:0;
    wire[5:0] pcaluop;
    assign pcaluop=(beq==1)?6'b000000:(bne==1)?6'b000001:(bgez==1)?6'b000010:(blez==1)?6'b000011:(bgtz==1)?6'b000100:(bltz==1)?6'b000101:6'b111111;

    wire add_i=(INS_OP==6'b001000)?1:0;
    wire addiu=(INS_OP==6'b001001)?1:0;
    wire andi=(INS_OP==6'b001100)?1:0;
    wire ori=(INS_OP==6'b001101)?1:0;
    wire xori=(INS_OP==6'b001110)?1:0;
    wire slti=(INS_OP==6'b001010)?1:0;
    wire sltiu=(INS_OP==6'b001011)?1:0;
    wire[5:0] aluiop;
    assign aluiop=(add_i==1)?6'b100000:(addiu==1)?6'b100001:(andi==1)?6'b100100:(ori==1)?6'b100101:(xori==1)?6'b100110:(slti==1)?6'b101010:(sltiu==1)?6'b101011:6'b111111;
    assign OP=(i_R==1)?Func:(i_lsj==1)?6'b100000:(i_branch==1)?pcaluop:aluiop;
endmodule
