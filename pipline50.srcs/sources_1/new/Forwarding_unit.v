`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/09 22:48:21
// Design Name: 
// Module Name: Forwarding_unit
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

//旁路控制：1.控制ex阶段alu输入，2.控制id阶段jal,beq=判断输入或者GR[31]的结果
/*
forwardA 2位
forwardB 2位
jr指令，beq在决定pc的id阶段也会产生依赖，但是和A,B一样不同在于1.pc操作在id阶段，要结合停顿使用旁路，决定旁路的信息应该是id阶段的
    //2.数据的使用位置在id阶段，要新增一个mux
在这个模块不需要去考虑当前是否需要读寄存器的问题，这个问题由阻塞模块控制
在ex/mem阶段还会产生jal和lui的结果，这个结果和aluout在旁路经过一个三路选择结合forwardA确定,forwardA仍为两位
*/
module Forwarding_unit(id_rs,id_rt,ex_rs,ex_rt,ex_regwrite,wb_regwrite,ex_rd,wb_rd,forwardA,forwardB,forwardPCA,forwardPCB,forwardsysA,forwardsysB);//输入：id,ex阶段需要的rs,rd,上一条指令ex阶段的指令是否写回，写回地址，上2条指令wb阶段的指令是否写回，写回地址
    input wire[4:0]id_rs,id_rt,ex_rs,ex_rt;//id阶段需要用到的rs,rt,rd
    input wire ex_regwrite,wb_regwrite;
    input wire[4:0]ex_rd,wb_rd;
    output wire[1:0]forwardA,forwardB,forwardPCA,forwardPCB;//输出：控制ex阶段alu输入，控制id阶
    output wire[1:0]forwardsysA,forwardsysB;//用于syscall通路的forward
    wire a_choose_wb;
    assign a_choose_wb=wb_regwrite&(!(ex_regwrite&(ex_rd!=5'b0)&(ex_rd==ex_rs)))&(wb_rd==ex_rs);//A选择wb
    wire b_choose_wb;
    assign b_choose_wb=wb_regwrite&(!(ex_regwrite&(ex_rd!=5'b0)&(ex_rd==ex_rt)))&(wb_rd==ex_rt);//B选择wb
    wire a_choose_ex;
    wire b_choose_ex;
    assign a_choose_ex=ex_regwrite&(ex_rd!=5'b0)&(ex_rd==ex_rs);//A选择ex
    assign b_choose_ex=ex_regwrite&(ex_rd!=5'b0)&(ex_rd==ex_rt);//B选择ex
    assign forwardA[1]=a_choose_ex;//A选择
    assign forwardB[1]=b_choose_ex;//B选择
    assign forwardA[0]=a_choose_wb;
    assign forwardB[0]=b_choose_wb;
    wire pca_choose_wb;
    wire pcb_choose_wb;
    assign pca_choose_wb=wb_regwrite&(ex_rd!=5'b0)&(!(ex_regwrite&(ex_rd!=5'b0)&(ex_rd==id_rs)))&(wb_rd==id_rs);
    assign pcb_choose_wb=wb_regwrite&(ex_rd!=5'b0)&(!(ex_regwrite&(ex_rd!=5'b0)&(ex_rd==id_rt)))&(wb_rd==id_rt);
    wire pca_choose_ex;
    wire pcb_choose_ex;
    assign pca_choose_ex=ex_regwrite&(ex_rd!=5'b0)&(ex_rd==id_rs);
    assign pcb_choose_ex=ex_regwrite&(ex_rd!=5'b0)&(ex_rd==id_rt);
    wire sysa_choose_wb;
    wire sysb_choose_wb;
    assign sysa_choose_wb=wb_regwrite&(ex_rd!=5'b0)&(!(ex_regwrite&(ex_rd!=5'b0)&(ex_rd==5'b000010)))&(wb_rd==5'b000010);
    assign sysb_choose_wb=wb_regwrite&(ex_rd!=5'b0)&(!(ex_regwrite&(ex_rd!=5'b0)&(ex_rd==5'b000100)))&(wb_rd==5'b000100);
    wire sysa_choose_ex;
    wire sysb_choose_ex;
    assign sysa_choose_ex=ex_regwrite&(ex_rd!=5'b0)&(ex_rd==5'b000010);
    assign sysb_choose_ex=ex_regwrite&(ex_rd!=5'b0)&(ex_rd==5'b000100);
    assign forwardPCA[1]=pca_choose_ex;
    assign forwardPCB[1]=pcb_choose_ex;
    assign forwardPCA[0]=pca_choose_wb;
    assign forwardPCB[0]=pcb_choose_wb;
    assign forwardsysA[1]=sysa_choose_ex;
    assign forwardsysB[1]=sysb_choose_ex;
    assign forwardsysA[0]=sysa_choose_wb;
    assign forwardsysB[0]=sysb_choose_wb;
endmodule
