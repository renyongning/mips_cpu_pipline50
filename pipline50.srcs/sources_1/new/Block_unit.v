`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/10 10:19:22
// Design Name: 
// Module Name: Block_unit
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

//����������ģ��
/*
�����߼���id�׶��жϣ�ͨ��if�е�ָ����Ϣ��ex�е���һ��ָ����Ϣ�����ж�
1.id�׶�Ϊ��beq/jr/jarlָ������Ҫ�õ��Ĵ�����
ex����Ҫ��д��ͬ�ļĴ�������Ҫmemread,����(һ������)
2.id�׶�Ϊbeq/jr/jarlָ�
ex�׶ε�ָ���memread��д�صļĴ�����ͬ������(һ������)
ex�׶ε�ָ����Ҫmemread��д�صļĴ�����ͬ������(��������)
mem�׶ε�ָ����Ҫmemread��д�صļĴ�����ͬ������(һ������)
����Ҫ�����������ڣ�������Ҫ��ex/memҲ������յ����ã�
���϶�����id�׶η���������
3.ex�׶γ˷�busy�źŻᵼ����ex�׶ε�����
ex�׶�Ϊmut��ָ����busy�����ã�busy&mutstart==0(����Ϊ�˳������)�������ex/mem,����id/ex,id/if,pc
����������������˳�ͻ����һ������id��ex�׶ζ���⵽��������
���ȴ���ex�׶ε�������id/ex����������)
4.syscall��������(��ָ��Ϊsyscall���Һ���exe,mem,�׶δ���д��v0/a0�������߼���j����һ��)
Ϊ�˱�֤��syscallʱ�Ĵ���ȫ��д�룬Ӧ��ȡ����·����������Ӧ�ļĴ�����д�����ִ��
�����׶Σ�id
������ex,��mem�׶δ�����Ҫ��дao,vo�Ĵ�����ָ��(����Ҫ���ƻ�д������memwread����alu��õģ�

*/
module Block_unit(Op,Func,rs,rt,ex_Op,ex_Func,ex_memread,ex_wb,ex_regwrite,ex_mutstart,ex_busy,mem_memread,mem_wb,mem_regwrite,stoppc,stopif_id,reset_idex,reset_exmem,stop_idex,block_gr);//OP,FUNCȷ��ָ������,rs,rtΪ��Ҫ�ļĴ�����ַ,ʣ���Ϊex,mem�׶���Ҫ������
    input wire[5:0]Op;
    input wire[5:0]Func;
    input wire[5:0] ex_Op;
    input wire[5:0] ex_Func;
    input wire[4:0]rs;
    input wire[4:0]rt;
    input wire ex_memread;
    input wire[4:0] ex_wb;
    input wire ex_regwrite;
    input wire ex_mutstart;
    input wire ex_busy;
    input wire mem_memread;
    input wire[4:0] mem_wb;
    input wire mem_regwrite;
    output wire stoppc;
    output wire stopif_id;
    output wire reset_idex;
    output wire reset_exmem;
    output wire stop_idex;
    output wire block_gr;
    //id�׶��ж�ָ������
    wire i_jr  =(Op == 6'b000000 & Func == 6'b001000)?1:0;
    wire i_jalr= (Op == 6'b000000 & Func == 6'b001001)?1:0;
    wire i_mu_div = (Op == 6'b000000 & (Func == 6'b011000|Func==6'b011001|Func==6'b011010|Func==6'b011011))?1:0;//ΪMULT/MULTU/DIV/DIVU
    wire i_mf= (Op == 6'b000000 & (Func == 6'b010000| Func == 6'b010010))?1:0;//ΪMFHI/MFLO
    wire i_mt= (Op == 6'b000000 & (Func == 6'b010001| Func == 6'b010011))?1:0;//ΪMTHI/MTLO
    wire r_format=(Op==6'b000000&(!i_mu_div)&(!i_mf)&(!i_mt)&(!i_jr)&(!i_jalr))?1:0;//r��ָ��
    wire i_lui  = (Op == 6'b001111)?1:0;
    wire i_jal  = (Op == 6'b000011)?1:0;
    wire i_l=(Op==6'b100011|Op==6'b100000|Op==6'b100100|Op==6'b100001|Op==6'b100101);//lw/lb/lbu/lh/lhu
    wire i_s=(Op==6'b101011|Op==6'b101000|Op==6'b101001);//sw/sb/sh
    wire i_alui=(Op==6'b001000|Op==6'b001001|Op==6'b001100|Op==6'b001101|Op==6'b001110|Op==6'b001010|Op==6'b001011);//������������ALUָ��ADDI / ADDIU / ANDI / ORI / XORI / SLTI / SLTIU
    wire i_branch=(Op==6'b000100|Op==6'b000101|Op==6'b000001|Op==6'b000110|Op==6'b000111)?1:0;//beq/bne/beqz/bgez/blez/bgtz
    wire i_shift=(Op==6'b000000&(Func==6'b000000|Func==6'b000010|Func==6'b000011))?1:0;//sll/srl/sra
    //ex�׶�ָ���ж�
    wire ex_mu_div = (ex_Op == 6'b000000 & (ex_Func == 6'b011000|ex_Func==6'b011001|ex_Func==6'b011010|ex_Func==6'b011011))?1:0;//ΪMULT/MULTU/DIV/DIVU
    wire ex_mf= (ex_Op == 6'b000000 & (ex_Func == 6'b010000| ex_Func == 6'b010010))?1:0;//ΪMFHI/MFLO
    wire ex_mt= (ex_Op == 6'b000000 & (ex_Func == 6'b010001| ex_Func == 6'b010011))?1:0;//ΪMTHI/MTLO
    //id�׶��Ƿ�Ϊsyscall
    wire syscall=(Op==6'b000000&Func==6'b001100)?1:0;
    
    wire case_1=i_mu_div|i_mt|r_format|i_s|i_alui|i_shift;
    wire case_2=i_jr|i_jalr|i_branch;
    wire case_3=ex_mu_div|ex_mt|ex_mf;
    wire block_in_id=(case_1&ex_memread&ex_regwrite&((ex_wb==rt)|(ex_wb==rs)))|(case_2&((ex_regwrite&((ex_wb==rt)|(ex_wb==rs)))|(mem_regwrite&mem_memread&((mem_wb==rt)|(mem_wb==rs)))));
    wire block_in_ex=(case_3&ex_busy&ex_mutstart);
    //wire block_in_gr=(syscall&((ex_regwrite&((ex_wb==5'b00010)|(ex_wb==5'b000100)))|(mem_regwrite&mem_memread&((mem_wb==5'b000010)|(mem_wb==5'b000100)))));
    wire block_in_gr=(syscall&((ex_regwrite&((ex_wb==5'b00010)|(ex_wb==5'b000100)))|(mem_regwrite&((mem_wb==5'b000010)|(mem_wb==5'b000100)))));
    assign stoppc=block_in_ex|block_in_id|block_in_gr;
    assign stopif_id=block_in_ex|block_in_id|block_in_gr;
    assign reset_idex=(block_in_id&(!block_in_ex))|block_in_gr;
    assign stop_idex=block_in_ex;
    assign reset_exmem=block_in_ex;
    assign block_gr=block_in_gr;
endmodule
