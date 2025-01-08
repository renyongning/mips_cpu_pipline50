`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/20 22:35:00
// Design Name: 
// Module Name: Toplevel
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

`include "controlunit.v"
`include "ALU.v"
`include "DM.v"
`include "GR.v"
`include "PC.v"
`include "alucontrol.v"
`include "instructionmen.v"
`include "IF_ID.v"
`include "ID_EX.v"
`include "EX_MEM.v"
`include "MEM_WB.v"
`include "Block_unit.v"
`include "Forwarding_unit.v"
`include "E:\learn\cpuhomework\Pipeline50\lab_5\lab_5.srcs\sources_1\imports\Pipeline 50\MultiplicationDivisionUnit.sv"
module TopLevel(clock,reset,pcout,k);
    input wire clock;
    input wire reset;
    input wire[31:0]k;
    output wire[31:0] pcout;
    wire[31:0] mux2pc;//mux��pc��ͨ·
    wire[31:0] pc;//pc��ֵ
    wire[31:0] instruction;//ָ������
    wire[25:0] instoshift;//ָ���������ͨ·
    wire[31:26] ins2cu_op;//ָ����Ƶ�Ԫ��op
    wire[5:0] ins2cu_func;//ָ����Ƶ�Ԫ��func
    wire[25:21] rs;//rs��ַ
    wire[20:16] rt;//rt��ַ
    wire[4:0] writereg;//����GR��д���ַ
    wire[15:11] rd;
    wire[15:0] imm16;
    wire[31:0] addout;//add��Ԫ���
    wire[31:0] naddout;//nadd���
    wire[31:0] shiftout;//<<2��Ԫ���
    wire[31:0] signextendout;//��չ��Ԫ���
    wire[31:0] shiftout2;//�ڶ�������2��Ԫ���
    wire[31:0] shiftout3;//<<16��Ԫ���
    wire[31:0] mux1out;//pcģ���һ��mux���
    wire[31:0]mux2out;//pcģ��ڶ���mux�����
    wire[31:0] A;//ALU A
    wire[31:0] B;//ALU B
    wire[5:0] aluoperation;//�����alu�Ĳ����ź�
    wire[31:0] readdata2;//rg�ڶ������
    wire zero;//ALU ZERO���
    wire[31:0] aluresult;//alu���
    wire[31:0]readdata;//dm���
    wire[31:0] writedata;//rgд������
    wire[31:0]sa;//sa
    //���Ƶ�Ԫ�ź�
    wire regdst,regwrite,alusrc,pcsrc,memread,memwrite,memtoreg,lui,jal,branch,jr,jump,alusrca,mutstart,syscall;
    wire block_gr;
    wire[1:0] aluop;
    mdu_operation_t mutop;
    wire[2:0] dmop;//�������Ĳ����ź�
    //��ˮ�߼Ĵ��������ź�
    wire pc_write;//pc�Ƿ���дʹ��
    wire if_id_enable;//if_id�Ƿ��д
    wire id_ex_clean;//�Ƿ����id_ex
    wire id_ex_enable;//�Ƿ񶳽�id_ex
    wire ex_mem_clean;
    wire isslot;//id�׶�ִ�е�ָ���Ƿ�Ϊ�ӳٲ�ָ��
    //��ˮ�߽ṹ����
    //��д���ݶ���
    wire four_regwrite_out,four_memtoreg_out,four_lui_out,four_jal_out;
    wire[31:0]four_alu_out,four_pc_out,four_data_out,four_shiftleft_out;
    wire[4:0]four_wb_out;
    wire[31:0] realwritedata;//д��洢������ʵ����
    //IFID���룺PC+4��instruction,clock,enable,�����PC+4��instruction
    wire[31:0] one_IR_out;
    wire[31:0] one_PC_out;
    wire one_slot_out;
    instructionmen i_instrucmem(.readaddress(pc),.readresult(instruction));//ָ��洢��
    IF_ID i_if_id(.PC_in(addout),.IR_in(instruction),.isslot_in(isslot),.is_slot_out(one_slot_out),.clock(clock),.enable(!if_id_enable),.PC_out(one_PC_out),.IR_out(one_IR_out),.reset(reset));//�����pcΪpc+4
    
    //ID_EX ���룺���������,IFID���pc,id�׶����㲿�����
    //id�׶���Ҫ�ж��Ƿ�Ϊ�ӳٲ�ָ��,������ӳٲ�ָ����ָ��Ϊ��ת������Ҫ�������׶εĽ����
    wire iscleenslot;
    assign iscleenslot=(one_slot_out&(jump|jr|jal|branch));
    wire two_regwrite_out,two_alusrc_out,two_memread_out,two_memwrite_out,two_memtoreg_out,two_lui_out,two_jal_out,two_branch_out,two_jr_out,two_jump_out,two_alusrca_out,two_mutstart_out;//��Ϊ��һ���׶ε�����
    wire[31:0] two_a_out,two_b_out,two_extend_out;//��Ϊ��һ���׶ε�����
    wire[31:0] two_pc_out;
    wire[5:0] two_aluop_out,two_op_out,two_func_out;
    wire[31:0] two_shiftleft_out;
    wire[4:0] two_wb_out;
    wire[4:0] two_rs_out,two_rt_out,two_rd_out;
    wire[31:0] two_sa_out;
    wire[2:0] two_dmop_out;
    mdu_operation_t two_mutop_out;
    assign rs[25:21]=one_IR_out[25:21];
    assign rt[20:16]=one_IR_out[20:16];
    assign rd[15:11]=one_IR_out[15:11];
    assign imm16[15:0]=one_IR_out[15:0];
    assign ins2cu_op[31:26]=one_IR_out[31:26];
    assign ins2cu_func[5:0]=one_IR_out[5:0];
    assign sa[4:0]=one_IR_out[10:6];
    assign sa[31:5]=27'b000000000000000000000000000;
    mux3_2 mux1(.in1(5'b11111),.in2(rd),.in3(rt),.sign1(jal&(!regdst)),.sign2(regdst),.out(writereg));//��������gr��д���ַ�����regdst��jal�źų�ͻ������ѡ��regdst,��ֻ��regdstΪ��ʱjal�ſ�����Ч
    wire[5:0] readaddress1,readaddress2;
    mux2_1 grmux1(.in1(5'b000010),.in2(rs),.sign(syscall),.out(readaddress1));//��rs/rd��syscall��ȡ�ļĴ�����ѡȡ
    mux2_1 grmux2(.in1(5'b000100),.in2(rt),.sign(syscall),.out(readaddress2));
    GR i_gr(.clock(clock),.reset(reset),.rd1(readaddress1),.rd2(readaddress2),.wd1(four_wb_out),.iswriteable(four_regwrite_out),.writedata(writedata),.readresult1(A),.readresult2(readdata2),.pc(four_pc_out-4),.k(k));//�Ĵ�����(�й�д�Ĳ���Ҫ����mem.wb�Ĵ���)
    signextended extendmod(.instruction(one_IR_out),.imm16(imm16),.out(signextendout));//��չλ��ģ��
    alucontrol i_alucontrol(.INS_OP(ins2cu_op),.rt(rt),.Func(ins2cu_func),.aluop(aluop),.OP(aluoperation));//alu������
    dmcontrol i_dmcontrol(.Op(ins2cu_op),.dmop(dmop));//dm����������
    mutcontrol i_mutcontrol(.Op(ins2cu_op),.Func(ins2cu_func),.mutop(mutop));//�˳�������������
    shiftleft16_16 shiftleft1(.in(imm16),.out(shiftout3));//����16λģ��
    controlunit i_control(.reset(reset),.clock(clock),.instruction(one_IR_out),.Op(ins2cu_op),.Func(ins2cu_func),.regdst(regdst),.regwrite(regwrite),.alusrc(alusrc),.aluop(aluop),.memread(memread),.memwrite(memwrite),.memtoreg(memtoreg),.lui(lui),.jal(jal),.branch(branch),.jr(jr),.jump(jump),.pc_write(pc_write),.alusrca(alusrca),.mutstart(mutstart),.syscall(syscall));//���Ƶ�Ԫ
    ID_EX i_id_ex(.regwrite(regwrite),.alusrc(alusrc),.memread(memread),.memwrite(memwrite),.memtoreg(memtoreg),.lui(lui),.jal(jal),.branch(branch),.jr(jr),.jump(jump),.alusrca(alusrca),.mutstart(mutstart),//�����ź�
.regwrite_out(two_regwrite_out),.alusrc_out(two_alusrc_out),.memread_out(two_memread_out),.memwrite_out(two_memwrite_out),.memtoreg_out(two_memtoreg_out),.lui_out(two_lui_out),.jal_out(two_jal_out),.branch_out(two_branch_out),.jr_out(two_jr_out),.jump_out(two_jump_out),.alusrca_out(two_alusrca_out),.mutstart_out(two_mutstart_out),//����ź�
.sa_in(sa),.sa_out(two_sa_out),.pc_in(one_PC_out),.pc_out(two_pc_out),.a_in(A),.a_out(two_a_out),.b_in(readdata2),.b_out(two_b_out),.extend_in(signextendout),.extend_out(two_extend_out),.op_in(aluoperation),.op_out(two_aluop_out),.Op_in(ins2cu_op),.Op_out(two_op_out),.Func_in(ins2cu_func),.Func_out(two_func_out),.shiftleft_in(shiftout3),.shiftleft_out(two_shiftleft_out),.wb_in(writereg),.wb_out(two_wb_out),.mutop_in(mutop),.mutop_out(two_mutop_out),.dmop_in(dmop),.dmop_out(two_dmop_out),
.rs_in(rs),.rs_out(two_rs_out),.rt_in(rt),.rt_out(two_rt_out),.rd_in(rd),.rd_out(two_rd_out),.clock(clock),.reset(id_ex_clean|reset|iscleenslot),.block(id_ex_enable));

    //EX_MEM ���룺ID_EX�������+alu���
    wire three_regwrite_out,three_memtoreg_out,three_memread_out,three_memwrite_out,three_lui_out,three_jal_out;
    wire[31:0]three_pc_out,three_b_out,three_shiftleft_out;
    wire[4:0]three_wb_out;
    wire[31:0]three_alu_out;
    wire[2:0]three_dmop_out;
    wire[31:0] ALUA_IN,ALUB_IN;//����ALU����ʵֵA,����B��ѡ��������ʵֵB
    wire[31:0] temp_A;//�洢������·������A���м���
    wire busy;//�˷����Ƿ�busy
    wire[31:0] mutout;//�˷������
    wire[31:0] mut_alu_result;//ex�׶ε��������
    mux2_1 mux4(.in1(two_sa_out),.in2(temp_A),.sign(two_alusrca_out),.out(ALUA_IN));//alu a��ѡ�������ھ�����·������ļĴ��������sa֮��ѡ��
    mux2_1 mux2(.in1(two_extend_out),.in2(B),.sign(two_alusrc_out),.out(ALUB_IN));//����alu����B��ѡ����,ALUBΪ�������룬BΪ������·������Ķ��Ĵ������
    alu i_alu(.A(ALUA_IN),.B(ALUB_IN),.C(aluresult),.Op(two_aluop_out),.zero(zero));//aluģ��
    MultiplicationDivisionUnit i_mut(.reset(reset),.clock(clock),.operand1(temp_A),.operand2(B),.operation(two_mutop_out),.start(two_mutstart_out),.busy(busy),.dataRead(mutout));//�˳���ģ�� A��Ϊrs�Ĵ�����ֵ��B��Ϊrt��ֵ
    mux2_1 mux5(.in1(mutout),.in2(aluresult),.sign(two_mutstart_out),.out(mut_alu_result));//ѡ���������
    EX_MEM i_ex_mem(.regwrite(two_regwrite_out),.memread(two_memread_out),.memwrite(two_memwrite_out),.memtoreg(two_memtoreg_out),.lui(two_lui_out),.jal(two_jal_out),
.regwrite_out(three_regwrite_out),.memread_out(three_memread_out),.memwrite_out(three_memwrite_out),.memtoreg_out(three_memtoreg_out),.lui_out(three_lui_out),.jal_out(three_jal_out),
.dmop_in(two_dmop_out),.dmop_out(three_dmop_out),.pc_in(two_pc_out),.pc_out(three_pc_out),.b_in(realwritedata),.b_out(three_b_out),.shiftleft_in(two_shiftleft_out),.shiftleft_out(three_shiftleft_out),.wb_in(two_wb_out),.wb_out(three_wb_out),.clock(clock),.reset(0|reset|ex_mem_clean),.alu_in(mut_alu_result),.alu_out(three_alu_out));//EX/MEM�Ĵ���

    //mem_wb ���룺EX_MEM�������+dm���
    
    DM i_dm(.reset(reset),.clock(clock),.dmop(three_dmop_out),.address(three_alu_out),.writeEnabled(three_memwrite_out),.writeInput(three_b_out),.readResult(readdata),.pc(three_pc_out-4));//���ݴ洢��ģ��
    MEM_WB i_mem_wb(.regwrite(three_regwrite_out),.memtoreg(three_memtoreg_out),.lui(three_lui_out),.jal(three_jal_out),
.regwrite_out(four_regwrite_out),.memtoreg_out(four_memtoreg_out),.lui_out(four_lui_out),.jal_out(four_jal_out),
.pc_in(three_pc_out),.pc_out(four_pc_out),.alu_in(three_alu_out),.alu_out(four_alu_out),.data_in(readdata),.data_out(four_data_out),.shiftleft_in(three_shiftleft_out),.shiftleft_out(four_shiftleft_out),.wb_in(three_wb_out),.wb_out(four_wb_out),.clock(clock),.reset(0|reset));

    //��д�׶�
    mux4_3 mux3(.in1(four_shiftleft_out),.in2(four_pc_out+4),.in3(four_data_out),.in4(four_alu_out),.sign1(four_lui_out),.sign2(four_jal_out),.sign3(four_memtoreg_out),.out(writedata));//д�ؼĴ������ݵ�ѡ����jalӦ�ô�pc+8
    
    //��·ת������
    wire[1:0] forwardA,forwardB,forwardPCA,forwardPCB,forwardsysA,forwardsysB;
    Forwarding_unit i_forward_unit(.id_rs(rs),.id_rt(rt),.ex_rs(two_rs_out),.ex_rt(two_rt_out),.ex_regwrite(three_regwrite_out),.wb_regwrite(four_regwrite_out),.ex_rd(three_wb_out),.wb_rd(four_wb_out),.forwardA(forwardA),.forwardB(forwardB),.forwardPCA(forwardPCA),.forwardPCB(forwardPCB),.forwardsysA(forwardsysA),.forwardsysB(forwardsysB));//��·ת��������
    
   
    wire[31:0] PCA;
    wire[31:0] PCB;//����beq��jal�������ʵ����
    wire[31:0]lastex_res;
    wire[31:0]sysA,sysB;
    //ALUA��������in1Ϊ��һ��ex�׶εĽ������Ҫ�ȴ�aluout,pc+8,<<16�н���ѡ�񣩣�in2Ϊ��һ��mem�׶εĽ����in3Ϊ��ָ��id�׶ε�a
    mux3_2 lastex_reault(.in1(three_shiftleft_out),.in2(three_pc_out+4),.in3(three_alu_out),.sign1(three_lui_out),.sign2(three_jal_out),.out(lastex_res));//ѡ����һ��ex�׶ε���ȷ����
    mux3_2 forwarding_muxa(.in1(lastex_res),.in2(writedata),.in3(two_a_out),.sign1(forwardA[1]),.sign2(forwardA[0]),.out(temp_A));
    mux3_2 forwarding_muxb(.in1(lastex_res),.in2(writedata),.in3(two_b_out),.sign1(forwardB[1]),.sign2(forwardB[0]),.out(B));
    mux3_2 forwarding_muxwritedata(.in1(lastex_res),.in2(writedata),.in3(two_b_out),.sign1(forwardB[1]),.sign2(forwardB[0]),.out(realwritedata));//ѡ��д�洢��������
    mux3_2 forwarding_pca(.in1(lastex_res),.in2(writedata),.in3(A),.sign1(forwardPCA[1]),.sign2(forwardPCA[0]),.out(PCA));
    mux3_2 forwarding_pcb(.in1(lastex_res),.in2(writedata),.in3(readdata2),.sign1(forwardPCB[1]),.sign2(forwardPCB[0]),.out(PCB));
    
    mux3_2 forwarding_sysa(.in1(lastex_res),.in2(writedata),.in3(A),.sign1(forwardsysA[1]),.sign2(forwardsysA[0]),.out(sysA));//Ϊsyscall��������ͨ·
    mux3_2 forwarding_sysb(.in1(lastex_res),.in2(writedata),.in3(readdata2),.sign1(forwardsysB[1]),.sign2(forwardsysB[0]),.out(sysB));
    //�������Ʋ���
    wire pcstop;
    Block_unit i_block_unit(.Op(ins2cu_op),.Func(ins2cu_func),.rs(rs),.rt(rt),.ex_Op(two_op_out),.ex_Func(two_func_out),.ex_memread(two_memread_out),.ex_wb(two_wb_out),.ex_regwrite(two_regwrite_out),.ex_mutstart(two_mutstart_out),.ex_busy(busy),.mem_memread(three_memread_out),.mem_wb(three_wb_out),.mem_regwrite(three_regwrite_out),.stoppc(pcstop),.stopif_id(if_id_enable),.reset_idex(id_ex_clean),.reset_exmem(ex_mem_clean),.stop_idex(id_ex_enable),.block_gr(block_gr));
    
    //pc�������ֵ�ģ��ʵ����
    //ȡָ�������
    PC i_pc(.reset(reset),.clock(clock),.pcinput(mux2pc),.pc_write(pc_write),.pcValue(pc),.pcstop(pcstop));//pc����
    Add i_add(.pc(pc),.out(addout));//addģ��
    //�����������
    assign instoshift[25:0]=one_IR_out[25:0];
    assign shiftout[31:28]=one_PC_out[31:28];//���Ϊ��������תֵ
    shiftleft2_26 shiftleft2(.address(instoshift),.out(shiftout));//26λ������2
   
    shiftleft2_32 shiftleft3(.address(signextendout),.out(shiftout2));//32λ������2
    nadd i_nadd(.in1(one_PC_out),.in2(shiftout2),.out(naddout));//naddģ��
    
    wire[31:0] jr_result;
    wire equel;
    Equel_unit i_equel_unit(.a(PCA),.b(PCB),.op(ins2cu_op),.rt(rt),.out(equel),.add(jr_result));//beg jrģ��

    mux2_2 muxpc_1(.in1(addout),.in2(naddout),.sign1(branch&(!iscleenslot)),.sign2(equel),.out(mux1out));//pc��һ��mux����pc+4���ϸ�ָ���beq�����ѡ��
    mux2_2_2 muxpc_2(.in1(shiftout),.in2(mux1out),.sign1(jal&(!iscleenslot)),.sign2(jump&(!iscleenslot)),.out(mux2out));//pc�ڶ���mux,��mux1�������һ��ָ���j�����ѡ��,
    mux2_1 muxpc_3(.in1(PCA),.in2(mux2out),.sign(jr&(!iscleenslot)),.out(mux2pc));//pc������mux��Ҫ��id�׶ζ�ȡ��rs�Ĵ���ֵ������·�������ֵ��mux2out��ѡ��
    //��ȷ��pcֵ����Ҫ�ж�һ���Ƿ�����ת������������ʱȡָ�׶ε�ָ��Ϊ�ӳٲ�ָ�����ӳٲ�ָ��ҲΪ��תָ����Ҫ��գ���������ʱ��if_id��ȡ��ֵ��Ϊ0��
    assign isslot=(!one_slot_out)&(branch|jump|jal|jr)&(mux2pc!=addout);//����׶�Ϊ��תָ����ʵ����תpc!=ȡָ�׶�ʹ�õ�pc
    //debug
    assign pcout=pc;
    //syscall����
    syscall_unit sys(.vo(A),.ao(readdata2),.syscall(syscall),.sysblock(block_gr),.clock(clock),.reset(reset));

endmodule
module Add(pc,out);//pc������
    input wire[31:0] pc;
    output wire[31:0] out;
    assign out[31:0]=pc+4;
endmodule
module shiftleft2_26(address,out);//26λ����
    input wire[25:0] address;
    output wire [31:0] out;
    assign out[27:2]=address[25:0];
    assign out[1:0]=2'b00;
endmodule
module shiftleft2_32(address,out);//32Ϊ����
    input wire[31:0]address;
    output wire[31:0]out;
    assign out[31:2]=address[29:0];
    assign out[1:0]=2'b00;
endmodule
module signextended(instruction,imm16,out);//�з�����չ
    input wire[15:0]imm16;
    input wire[31:0]instruction;
    output wire[31:0]out;
    wire i_unsigned;
    wire[5:0]Op=instruction[31:26];
    assign i_unsigned=(Op==6'b001100|Op==6'b001101|Op==6'b001110);
    assign out[15:0]=imm16[15:0];
    assign out[31:16]=i_unsigned?0:{16{imm16[15]}};
endmodule
module mux2_1(in1,in2,sign,out);//2ѡ1mux,1���źſ���
    input wire[31:0] in1;
    input wire[31:0] in2;
    input wire sign;
    output wire[31:0] out;
    assign out=sign?in1:in2;
endmodule
module mux2_2(in1,in2,sign1,sign2,out);//2ѡ1mux,2���źſ���,����beq
    input wire[31:0] in1;
    input wire[31:0] in2;
    input wire sign1;
    input wire sign2;
    output wire[31:0] out;
    assign out=(sign1&sign2)?in2:in1;
endmodule
module mux2_2_2(in1,in2,sign1,sign2,out);//2ѡ1mux,2���źſ��ƣ�����j/jal
    input wire[31:0] in1;
    input wire[31:0] in2;
    input wire sign1;
    input wire sign2;
    output wire[31:0] out;
    assign out=(sign1|sign2)?in1:in2;
endmodule
module mux3_2(in1,in2,in3,sign1,sign2,out);//3ѡmux,2���źſ���
    input wire[31:0]in1;
    input wire[31:0]in2;
    input wire[31:0]in3;
    input wire sign1;
    input wire sign2;
    output wire[31:0] out;
    assign out=sign1?in1:sign2?in2:in3;
endmodule
module mux4_3(in1,in2,in3,in4,sign1,sign2,sign3,out);//4ѡmux,3���źſ���
    input wire[31:0] in1;
    input wire[31:0] in2;
    input wire[31:0] in3;
    input wire[31:0] in4;
    input wire sign1;
    input wire sign2;
    input wire sign3;
    output wire[31:0] out;
    assign out=sign1?in1:sign2?in2:sign3?in3:in4;
endmodule
module shiftleft16_16(in,out);//��16λ���������ƣ�����Ϊ32λ��
    input wire[15:0]in;
    input wire[31:0] out;
    assign out[31:16]=in[15:0];
    assign out[15:0]=16'b0000000000000000;
endmodule
module nadd(in1,in2,out);
    input wire[31:0] in1;
    input wire[31:0] in2;
    output wire[31:0] out;
    wire[32:0] res;
    assign res=in1+in2;
    assign out[31:0]=res[31:0];
endmodule
module Equel_unit(a,b,op,rt,out,add);
    input wire[31:0] a;
    input wire[31:0] b;
    input wire[5:0] op;
    input wire[5:0] rt;
    output wire out;
    wire equel;
    output wire[31:0] add;
    assign add=a+b;
    assign equel=a==b;
    wire i_bgez=$signed(a)>=0;
    wire i_blez=$signed(a)<=0;
    wire i_bgtz=$signed(a)>0;
    wire i_bltz=$signed(a)<0;
    assign out=(op==6'b000100)?equel://beq
    (op==6'b000101)?~equel://bne
    (op==6'b000001&rt==6'b000001)?i_bgez://bgez
    (op==6'b000110)?i_blez://blez
    (op==6'b000111)?i_bgtz://bgtz
    (op==6'b000001&rt==6'b000000)?i_bltz://bltz
    1'b0;//default
endmodule//����a,b�������ݣ�����op�ж��Ƿ�����beq,bne,beqz��������ͬʱ������
module syscall_unit(vo,ao,syscall,sysblock,clock,reset);
    input wire[31:0]vo,ao;
    input wire syscall,sysblock;
    input wire clock,reset;
    reg[31:0] VO,AO;
    reg SYSCALL,SYSBLOCK;
    always @(posedge clock)begin
        if(reset)begin
            VO=32'b0;
            AO=32'b0;
            SYSCALL=0;
            SYSBLOCK=0;
        end
        else begin
            VO=vo;
            AO=ao;
            SYSCALL=syscall;
            SYSBLOCK=sysblock;
        end
        if(SYSCALL&(!SYSBLOCK))begin
            case(VO)
                1:$display("%d",AO);
                10:$finish;
                default:;
        endcase
     end
    end
endmodule