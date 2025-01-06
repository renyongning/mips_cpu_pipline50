`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/16 15:18:05
// Design Name: 
// Module Name: controlunit
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
//�����źţ�sa:ALU A��ѡ�񾭹��޷�����չ��sa��Ϊ���룬����SLL,SRL,SRA
//mulstart:�˷����Ŀ�ʼ�źţ�mulop[2:0]:�˷����Ĳ����ź�,�����йس˷��Ĳ���
module controlunit(reset,clock,instruction,Op,Func,regdst,regwrite,alusrc,aluop,memread,memwrite,memtoreg,lui,jal,branch,jr,jump,pc_write,alusrca,mutstart,syscall);
    input wire[31:0]instruction;
    input wire[5:0]Op;
    input wire[5:0]Func;
    input wire reset;
    input wire clock;
    output wire regdst;
    output wire regwrite;
    output wire alusrc;
    output wire[1:0] aluop;
    output wire memread;
    output wire memwrite;
    output wire memtoreg;
    output wire branch;
    output wire jr;
    output wire lui;
    output wire jal;
    output wire pc_write;//���ڳ�ʼ��ʱ�Ŀ���
    output wire jump;
    output wire alusrca;
    output wire mutstart;
    output wire syscall;
    reg pc_writereg;
    always @(negedge reset) begin
        pc_writereg=0;
    end//reset�½�����pcдʹ��Ϊ�㣬����һ������pc����ı�??
    always @(posedge clock) begin
        pc_writereg=1;
        //if((Op==6'b000000&Func==6'b001100)) begin
        //    $finish;
        //end
    end
    assign pc_write=pc_writereg;
    assign syscall=(Op==6'b000000&Func==6'b001100)?1:0;//syscall
    wire nop=(instruction==0)?1:0;//��ͬ��sll0������sll���źŴ���
    wire i_jr  = (Op == 6'b000000 & Func == 6'b001000)?1:0;
    wire i_jalr= (Op == 6'b000000 & Func == 6'b001001)?1:0;
    wire i_mu_div = (Op == 6'b000000 & (Func == 6'b011000|Func==6'b011001|Func==6'b011010|Func==6'b011011))?1:0;//ΪMULT/MULTU/DIV/DIVU
    wire i_mf= (Op == 6'b000000 & (Func == 6'b010000| Func == 6'b010010))?1:0;//ΪMFHI/MFLO
    wire i_mt= (Op == 6'b000000 & (Func == 6'b010001| Func == 6'b010011))?1:0;//ΪMTHI/MTLO
    wire r_format=(Op==6'b000000&(!i_mu_div)&(!i_mf)&(!i_mt)&(!i_jr)&(!i_jalr)&(!syscall))?1:0;//r��ָ��
    wire i_lui  = (Op == 6'b001111)?1:0;
    wire i_jal  = (Op == 6'b000011)?1:0;
    wire i_l=(Op==6'b100011|Op==6'b100000|Op==6'b100100|Op==6'b100001|Op==6'b100101);//lw/lb/lbu/lh/lhu
    wire i_s=(Op==6'b101011|Op==6'b101000|Op==6'b101001);//sw/sb/sh
    wire i_alui=(Op==6'b001000|Op==6'b001001|Op==6'b001100|Op==6'b001101|Op==6'b001110|Op==6'b001010|Op==6'b001011);//������������ALUָ��ADDI / ADDIU / ANDI / ORI / XORI / SLTI / SLTIU
    wire i_branch=(Op==6'b000100|Op==6'b000101|Op==6'b000001|Op==6'b000110|Op==6'b000111)?1:0;//beq/bne/beqz/bgez/blez/bgtz
    wire i_shift=(Op==6'b000000&(Func==6'b000000|Func==6'b000010|Func==6'b000011))?1:0;//sll/srl/sra

    assign regdst=(r_format|i_mf|i_shift|i_jalr);
    assign alusrc=(i_l|i_s|i_alui);
    assign memtoreg=i_l;
    assign regwrite=(r_format|i_l|i_lui|i_jal|i_alui|i_jalr|i_mf|i_shift);
    assign memread=i_l;
    assign memwrite=i_s;
    assign branch=i_branch;
    assign aluop[0]=(i_alui|i_branch);
    assign aluop[1]=(i_shift|i_alui|r_format);
    assign lui=i_lui;
    assign jal=(i_jal|i_jalr);
    assign jr=(i_jr|i_jalr);
    assign jump=(Op==6'b000010)?1:0;
    assign alusrca=i_shift;
    assign mutstart=(i_mu_div|i_mt|i_mf);
endmodule
