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

//控制阻塞的模块
/*
阻塞逻辑在id阶段判断，通过if中的指令信息与ex中的上一个指令信息做出判断
1.id阶段为非beq/jr/jarl指令且需要用到寄存器：
ex中需要会写相同的寄存器且需要memread,阻塞(一个周期)
2.id阶段为beq/jr/jarl指令：
ex阶段的指令不需memread且写回的寄存器相同：阻塞(一个周期)
ex阶段的指令需要memread且写回的寄存器相同，阻塞(两个周期)
mem阶段的指令需要memread且写回的寄存器相同，阻塞(一个周期)
由于要阻塞两个周期，我们需要对ex/mem也进行清空的设置，
以上都是在id阶段发生的阻塞
3.ex阶段乘法busy信号会导致在ex阶段的阻塞
ex阶段为mut类指令且busy被设置（busy&mutstart==0(操作为乘除类操作)），清空ex/mem,冻结id/ex,id/if,pc
如果阻塞操作发生了冲突（在一个周期id和ex阶段都检测到了阻塞）
优先处理ex阶段的阻塞（id/ex冻结而非清空)
4.syscall的阻塞，(当指令为syscall并且后面exe,mem,阶段存在写回v0/a0则阻塞逻辑与j类型一样)
为了保证在syscall时寄存器全部写入，应该取消旁路，阻塞到相应的寄存器回写完成再执行
阻塞阶段：id
条件：ex,和mem阶段存在需要回写ao,vo寄存器的指令(不需要限制回写数据是memwread还是alu获得的）

*/
module Block_unit(Op,Func,rs,rt,ex_Op,ex_Func,ex_memread,ex_wb,ex_regwrite,ex_mutstart,ex_busy,mem_memread,mem_wb,mem_regwrite,stoppc,stopif_id,reset_idex,reset_exmem,stop_idex,block_gr);//OP,FUNC确定指令类型,rs,rt为需要的寄存器地址,剩余的为ex,mem阶段需要的条件
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
    //id阶段判断指令类型
    wire i_jr  =(Op == 6'b000000 & Func == 6'b001000)?1:0;
    wire i_jalr= (Op == 6'b000000 & Func == 6'b001001)?1:0;
    wire i_mu_div = (Op == 6'b000000 & (Func == 6'b011000|Func==6'b011001|Func==6'b011010|Func==6'b011011))?1:0;//为MULT/MULTU/DIV/DIVU
    wire i_mf= (Op == 6'b000000 & (Func == 6'b010000| Func == 6'b010010))?1:0;//为MFHI/MFLO
    wire i_mt= (Op == 6'b000000 & (Func == 6'b010001| Func == 6'b010011))?1:0;//为MTHI/MTLO
    wire r_format=(Op==6'b000000&(!i_mu_div)&(!i_mf)&(!i_mt)&(!i_jr)&(!i_jalr))?1:0;//r型指令
    wire i_lui  = (Op == 6'b001111)?1:0;
    wire i_jal  = (Op == 6'b000011)?1:0;
    wire i_l=(Op==6'b100011|Op==6'b100000|Op==6'b100100|Op==6'b100001|Op==6'b100101);//lw/lb/lbu/lh/lhu
    wire i_s=(Op==6'b101011|Op==6'b101000|Op==6'b101001);//sw/sb/sh
    wire i_alui=(Op==6'b001000|Op==6'b001001|Op==6'b001100|Op==6'b001101|Op==6'b001110|Op==6'b001010|Op==6'b001011);//带有立即数的ALU指令ADDI / ADDIU / ANDI / ORI / XORI / SLTI / SLTIU
    wire i_branch=(Op==6'b000100|Op==6'b000101|Op==6'b000001|Op==6'b000110|Op==6'b000111)?1:0;//beq/bne/beqz/bgez/blez/bgtz
    wire i_shift=(Op==6'b000000&(Func==6'b000000|Func==6'b000010|Func==6'b000011))?1:0;//sll/srl/sra
    //ex阶段指令判断
    wire ex_mu_div = (ex_Op == 6'b000000 & (ex_Func == 6'b011000|ex_Func==6'b011001|ex_Func==6'b011010|ex_Func==6'b011011))?1:0;//为MULT/MULTU/DIV/DIVU
    wire ex_mf= (ex_Op == 6'b000000 & (ex_Func == 6'b010000| ex_Func == 6'b010010))?1:0;//为MFHI/MFLO
    wire ex_mt= (ex_Op == 6'b000000 & (ex_Func == 6'b010001| ex_Func == 6'b010011))?1:0;//为MTHI/MTLO
    //id阶段是否为syscall
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
