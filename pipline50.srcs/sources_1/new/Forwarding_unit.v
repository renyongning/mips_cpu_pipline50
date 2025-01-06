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

//��·���ƣ�1.����ex�׶�alu���룬2.����id�׶�jal,beq=�ж��������GR[31]�Ľ��
/*
forwardA 2λ
forwardB 2λ
jrָ�beq�ھ���pc��id�׶�Ҳ��������������Ǻ�A,Bһ����ͬ����1.pc������id�׶Σ�Ҫ���ͣ��ʹ����·��������·����ϢӦ����id�׶ε�
    //2.���ݵ�ʹ��λ����id�׶Σ�Ҫ����һ��mux
�����ģ�鲻��Ҫȥ���ǵ�ǰ�Ƿ���Ҫ���Ĵ��������⣬�������������ģ�����
��ex/mem�׶λ������jal��lui�Ľ������������aluout����·����һ����·ѡ����forwardAȷ��,forwardA��Ϊ��λ
*/
module Forwarding_unit(id_rs,id_rt,ex_rs,ex_rt,ex_regwrite,wb_regwrite,ex_rd,wb_rd,forwardA,forwardB,forwardPCA,forwardPCB,forwardsysA,forwardsysB);//���룺id,ex�׶���Ҫ��rs,rd,��һ��ָ��ex�׶ε�ָ���Ƿ�д�أ�д�ص�ַ����2��ָ��wb�׶ε�ָ���Ƿ�д�أ�д�ص�ַ
    input wire[4:0]id_rs,id_rt,ex_rs,ex_rt;//id�׶���Ҫ�õ���rs,rt,rd
    input wire ex_regwrite,wb_regwrite;
    input wire[4:0]ex_rd,wb_rd;
    output wire[1:0]forwardA,forwardB,forwardPCA,forwardPCB;//���������ex�׶�alu���룬����id��
    output wire[1:0]forwardsysA,forwardsysB;//����syscallͨ·��forward
    wire a_choose_wb;
    assign a_choose_wb=wb_regwrite&(!(ex_regwrite&(ex_rd!=5'b0)&(ex_rd==ex_rs)))&(wb_rd==ex_rs);//Aѡ��wb
    wire b_choose_wb;
    assign b_choose_wb=wb_regwrite&(!(ex_regwrite&(ex_rd!=5'b0)&(ex_rd==ex_rt)))&(wb_rd==ex_rt);//Bѡ��wb
    wire a_choose_ex;
    wire b_choose_ex;
    assign a_choose_ex=ex_regwrite&(ex_rd!=5'b0)&(ex_rd==ex_rs);//Aѡ��ex
    assign b_choose_ex=ex_regwrite&(ex_rd!=5'b0)&(ex_rd==ex_rt);//Bѡ��ex
    assign forwardA[1]=a_choose_ex;//Aѡ��
    assign forwardB[1]=b_choose_ex;//Bѡ��
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
