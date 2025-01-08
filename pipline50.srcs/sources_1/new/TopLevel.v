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
    wire[31:0] mux2pc;//mux到pc的通路
    wire[31:0] pc;//pc的值
    wire[31:0] instruction;//指令内容
    wire[25:0] instoshift;//指令到左移器的通路
    wire[31:26] ins2cu_op;//指令到控制单元的op
    wire[5:0] ins2cu_func;//指令到控制单元的func
    wire[25:21] rs;//rs地址
    wire[20:16] rt;//rt地址
    wire[4:0] writereg;//输入GR的写入地址
    wire[15:11] rd;
    wire[15:0] imm16;
    wire[31:0] addout;//add单元输出
    wire[31:0] naddout;//nadd输出
    wire[31:0] shiftout;//<<2单元输出
    wire[31:0] signextendout;//扩展单元输出
    wire[31:0] shiftout2;//第二个《《2单元输出
    wire[31:0] shiftout3;//<<16单元输出
    wire[31:0] mux1out;//pc模块第一个mux输出
    wire[31:0]mux2out;//pc模块第二个mux的输出
    wire[31:0] A;//ALU A
    wire[31:0] B;//ALU B
    wire[5:0] aluoperation;//输入给alu的操作信号
    wire[31:0] readdata2;//rg第二个输出
    wire zero;//ALU ZERO输出
    wire[31:0] aluresult;//alu结果
    wire[31:0]readdata;//dm输出
    wire[31:0] writedata;//rg写入数据
    wire[31:0]sa;//sa
    //控制单元信号
    wire regdst,regwrite,alusrc,pcsrc,memread,memwrite,memtoreg,lui,jal,branch,jr,jump,alusrca,mutstart,syscall;
    wire block_gr;
    wire[1:0] aluop;
    mdu_operation_t mutop;
    wire[2:0] dmop;//运算器的操作信号
    //流水线寄存器控制信号
    wire pc_write;//pc是否有写使能
    wire if_id_enable;//if_id是否可写
    wire id_ex_clean;//是否清除id_ex
    wire id_ex_enable;//是否冻结id_ex
    wire ex_mem_clean;
    wire isslot;//id阶段执行的指令是否为延迟槽指令
    //流水线结构定义
    //回写内容定义
    wire four_regwrite_out,four_memtoreg_out,four_lui_out,four_jal_out;
    wire[31:0]four_alu_out,four_pc_out,four_data_out,four_shiftleft_out;
    wire[4:0]four_wb_out;
    wire[31:0] realwritedata;//写入存储器的真实内容
    //IFID输入：PC+4，instruction,clock,enable,输出：PC+4，instruction
    wire[31:0] one_IR_out;
    wire[31:0] one_PC_out;
    wire one_slot_out;
    instructionmen i_instrucmem(.readaddress(pc),.readresult(instruction));//指令存储器
    IF_ID i_if_id(.PC_in(addout),.IR_in(instruction),.isslot_in(isslot),.is_slot_out(one_slot_out),.clock(clock),.enable(!if_id_enable),.PC_out(one_PC_out),.IR_out(one_IR_out),.reset(reset));//输入的pc为pc+4
    
    //ID_EX 输入：控制器输出,IFID输出pc,id阶段运算部件输出
    //id阶段需要判断是否为延迟槽指令,如果是延迟槽指令且指令为跳转类型则要清空这个阶段的结果。
    wire iscleenslot;
    assign iscleenslot=(one_slot_out&(jump|jr|jal|branch));
    wire two_regwrite_out,two_alusrc_out,two_memread_out,two_memwrite_out,two_memtoreg_out,two_lui_out,two_jal_out,two_branch_out,two_jr_out,two_jump_out,two_alusrca_out,two_mutstart_out;//作为下一个阶段的输入
    wire[31:0] two_a_out,two_b_out,two_extend_out;//作为下一个阶段的输入
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
    mux3_2 mux1(.in1(5'b11111),.in2(rd),.in3(rt),.sign1(jal&(!regdst)),.sign2(regdst),.out(writereg));//控制输入gr中写入地址，如果regdst和jal信号冲突则优先选择regdst,即只有regdst为零时jal才可能有效
    wire[5:0] readaddress1,readaddress2;
    mux2_1 grmux1(.in1(5'b000010),.in2(rs),.sign(syscall),.out(readaddress1));//在rs/rd与syscall读取的寄存器中选取
    mux2_1 grmux2(.in1(5'b000100),.in2(rt),.sign(syscall),.out(readaddress2));
    GR i_gr(.clock(clock),.reset(reset),.rd1(readaddress1),.rd2(readaddress2),.wd1(four_wb_out),.iswriteable(four_regwrite_out),.writedata(writedata),.readresult1(A),.readresult2(readdata2),.pc(four_pc_out-4),.k(k));//寄存器堆(有关写的操作要依靠mem.wb寄存器)
    signextended extendmod(.instruction(one_IR_out),.imm16(imm16),.out(signextendout));//扩展位数模块
    alucontrol i_alucontrol(.INS_OP(ins2cu_op),.rt(rt),.Func(ins2cu_func),.aluop(aluop),.OP(aluoperation));//alu控制器
    dmcontrol i_dmcontrol(.Op(ins2cu_op),.dmop(dmop));//dm操作控制器
    mutcontrol i_mutcontrol(.Op(ins2cu_op),.Func(ins2cu_func),.mutop(mutop));//乘除法操作控制器
    shiftleft16_16 shiftleft1(.in(imm16),.out(shiftout3));//左移16位模块
    controlunit i_control(.reset(reset),.clock(clock),.instruction(one_IR_out),.Op(ins2cu_op),.Func(ins2cu_func),.regdst(regdst),.regwrite(regwrite),.alusrc(alusrc),.aluop(aluop),.memread(memread),.memwrite(memwrite),.memtoreg(memtoreg),.lui(lui),.jal(jal),.branch(branch),.jr(jr),.jump(jump),.pc_write(pc_write),.alusrca(alusrca),.mutstart(mutstart),.syscall(syscall));//控制单元
    ID_EX i_id_ex(.regwrite(regwrite),.alusrc(alusrc),.memread(memread),.memwrite(memwrite),.memtoreg(memtoreg),.lui(lui),.jal(jal),.branch(branch),.jr(jr),.jump(jump),.alusrca(alusrca),.mutstart(mutstart),//输入信号
.regwrite_out(two_regwrite_out),.alusrc_out(two_alusrc_out),.memread_out(two_memread_out),.memwrite_out(two_memwrite_out),.memtoreg_out(two_memtoreg_out),.lui_out(two_lui_out),.jal_out(two_jal_out),.branch_out(two_branch_out),.jr_out(two_jr_out),.jump_out(two_jump_out),.alusrca_out(two_alusrca_out),.mutstart_out(two_mutstart_out),//输出信号
.sa_in(sa),.sa_out(two_sa_out),.pc_in(one_PC_out),.pc_out(two_pc_out),.a_in(A),.a_out(two_a_out),.b_in(readdata2),.b_out(two_b_out),.extend_in(signextendout),.extend_out(two_extend_out),.op_in(aluoperation),.op_out(two_aluop_out),.Op_in(ins2cu_op),.Op_out(two_op_out),.Func_in(ins2cu_func),.Func_out(two_func_out),.shiftleft_in(shiftout3),.shiftleft_out(two_shiftleft_out),.wb_in(writereg),.wb_out(two_wb_out),.mutop_in(mutop),.mutop_out(two_mutop_out),.dmop_in(dmop),.dmop_out(two_dmop_out),
.rs_in(rs),.rs_out(two_rs_out),.rt_in(rt),.rt_out(two_rt_out),.rd_in(rd),.rd_out(two_rd_out),.clock(clock),.reset(id_ex_clean|reset|iscleenslot),.block(id_ex_enable));

    //EX_MEM 输入：ID_EX部分输出+alu输出
    wire three_regwrite_out,three_memtoreg_out,three_memread_out,three_memwrite_out,three_lui_out,three_jal_out;
    wire[31:0]three_pc_out,three_b_out,three_shiftleft_out;
    wire[4:0]three_wb_out;
    wire[31:0]three_alu_out;
    wire[2:0]three_dmop_out;
    wire[31:0] ALUA_IN,ALUB_IN;//进入ALU的真实值A,进入B端选择器的真实值B
    wire[31:0] temp_A;//存储经过旁路修正的A的中间结果
    wire busy;//乘法器是否busy
    wire[31:0] mutout;//乘法器输出
    wire[31:0] mut_alu_result;//ex阶段的最终输出
    mux2_1 mux4(.in1(two_sa_out),.in2(temp_A),.sign(two_alusrca_out),.out(ALUA_IN));//alu a段选择器，在经过旁路修正后的寄存器结果与sa之间选择
    mux2_1 mux2(.in1(two_extend_out),.in2(B),.sign(two_alusrc_out),.out(ALUB_IN));//控制alu输入B的选择器,ALUB为最终输入，B为经过旁路修正后的读寄存器结果
    alu i_alu(.A(ALUA_IN),.B(ALUB_IN),.C(aluresult),.Op(two_aluop_out),.zero(zero));//alu模块
    MultiplicationDivisionUnit i_mut(.reset(reset),.clock(clock),.operand1(temp_A),.operand2(B),.operation(two_mutop_out),.start(two_mutstart_out),.busy(busy),.dataRead(mutout));//乘除法模块 A段为rs寄存器的值，B段为rt的值
    mux2_1 mux5(.in1(mutout),.in2(aluresult),.sign(two_mutstart_out),.out(mut_alu_result));//选择最终输出
    EX_MEM i_ex_mem(.regwrite(two_regwrite_out),.memread(two_memread_out),.memwrite(two_memwrite_out),.memtoreg(two_memtoreg_out),.lui(two_lui_out),.jal(two_jal_out),
.regwrite_out(three_regwrite_out),.memread_out(three_memread_out),.memwrite_out(three_memwrite_out),.memtoreg_out(three_memtoreg_out),.lui_out(three_lui_out),.jal_out(three_jal_out),
.dmop_in(two_dmop_out),.dmop_out(three_dmop_out),.pc_in(two_pc_out),.pc_out(three_pc_out),.b_in(realwritedata),.b_out(three_b_out),.shiftleft_in(two_shiftleft_out),.shiftleft_out(three_shiftleft_out),.wb_in(two_wb_out),.wb_out(three_wb_out),.clock(clock),.reset(0|reset|ex_mem_clean),.alu_in(mut_alu_result),.alu_out(three_alu_out));//EX/MEM寄存器

    //mem_wb 输入：EX_MEM部分输出+dm输出
    
    DM i_dm(.reset(reset),.clock(clock),.dmop(three_dmop_out),.address(three_alu_out),.writeEnabled(three_memwrite_out),.writeInput(three_b_out),.readResult(readdata),.pc(three_pc_out-4));//数据存储器模块
    MEM_WB i_mem_wb(.regwrite(three_regwrite_out),.memtoreg(three_memtoreg_out),.lui(three_lui_out),.jal(three_jal_out),
.regwrite_out(four_regwrite_out),.memtoreg_out(four_memtoreg_out),.lui_out(four_lui_out),.jal_out(four_jal_out),
.pc_in(three_pc_out),.pc_out(four_pc_out),.alu_in(three_alu_out),.alu_out(four_alu_out),.data_in(readdata),.data_out(four_data_out),.shiftleft_in(three_shiftleft_out),.shiftleft_out(four_shiftleft_out),.wb_in(three_wb_out),.wb_out(four_wb_out),.clock(clock),.reset(0|reset));

    //回写阶段
    mux4_3 mux3(.in1(four_shiftleft_out),.in2(four_pc_out+4),.in3(four_data_out),.in4(four_alu_out),.sign1(four_lui_out),.sign2(four_jal_out),.sign3(four_memtoreg_out),.out(writedata));//写回寄存器内容的选择器jal应该存pc+8
    
    //旁路转发部分
    wire[1:0] forwardA,forwardB,forwardPCA,forwardPCB,forwardsysA,forwardsysB;
    Forwarding_unit i_forward_unit(.id_rs(rs),.id_rt(rt),.ex_rs(two_rs_out),.ex_rt(two_rt_out),.ex_regwrite(three_regwrite_out),.wb_regwrite(four_regwrite_out),.ex_rd(three_wb_out),.wb_rd(four_wb_out),.forwardA(forwardA),.forwardB(forwardB),.forwardPCA(forwardPCA),.forwardPCB(forwardPCB),.forwardsysA(forwardsysA),.forwardsysB(forwardsysB));//旁路转发控制器
    
   
    wire[31:0] PCA;
    wire[31:0] PCB;//用于beq和jal命令的真实内容
    wire[31:0]lastex_res;
    wire[31:0]sysA,sysB;
    //ALUA的修正，in1为上一个ex阶段的结果（需要先从aluout,pc+8,<<16中进行选择），in2为上一个mem阶段的结果，in3为本指令id阶段的a
    mux3_2 lastex_reault(.in1(three_shiftleft_out),.in2(three_pc_out+4),.in3(three_alu_out),.sign1(three_lui_out),.sign2(three_jal_out),.out(lastex_res));//选择上一个ex阶段的正确返回
    mux3_2 forwarding_muxa(.in1(lastex_res),.in2(writedata),.in3(two_a_out),.sign1(forwardA[1]),.sign2(forwardA[0]),.out(temp_A));
    mux3_2 forwarding_muxb(.in1(lastex_res),.in2(writedata),.in3(two_b_out),.sign1(forwardB[1]),.sign2(forwardB[0]),.out(B));
    mux3_2 forwarding_muxwritedata(.in1(lastex_res),.in2(writedata),.in3(two_b_out),.sign1(forwardB[1]),.sign2(forwardB[0]),.out(realwritedata));//选择写存储器的内容
    mux3_2 forwarding_pca(.in1(lastex_res),.in2(writedata),.in3(A),.sign1(forwardPCA[1]),.sign2(forwardPCA[0]),.out(PCA));
    mux3_2 forwarding_pcb(.in1(lastex_res),.in2(writedata),.in3(readdata2),.sign1(forwardPCB[1]),.sign2(forwardPCB[0]),.out(PCB));
    
    mux3_2 forwarding_sysa(.in1(lastex_res),.in2(writedata),.in3(A),.sign1(forwardsysA[1]),.sign2(forwardsysA[0]),.out(sysA));//为syscall建立数据通路
    mux3_2 forwarding_sysb(.in1(lastex_res),.in2(writedata),.in3(readdata2),.sign1(forwardsysB[1]),.sign2(forwardsysB[0]),.out(sysB));
    //阻塞控制部分
    wire pcstop;
    Block_unit i_block_unit(.Op(ins2cu_op),.Func(ins2cu_func),.rs(rs),.rt(rt),.ex_Op(two_op_out),.ex_Func(two_func_out),.ex_memread(two_memread_out),.ex_wb(two_wb_out),.ex_regwrite(two_regwrite_out),.ex_mutstart(two_mutstart_out),.ex_busy(busy),.mem_memread(three_memread_out),.mem_wb(three_wb_out),.mem_regwrite(three_regwrite_out),.stoppc(pcstop),.stopif_id(if_id_enable),.reset_idex(id_ex_clean),.reset_exmem(ex_mem_clean),.stop_idex(id_ex_enable),.block_gr(block_gr));
    
    //pc操作部分的模块实例化
    //取指周期完成
    PC i_pc(.reset(reset),.clock(clock),.pcinput(mux2pc),.pc_write(pc_write),.pcValue(pc),.pcstop(pcstop));//pc部件
    Add i_add(.pc(pc),.out(addout));//add模块
    //译码周期完成
    assign instoshift[25:0]=one_IR_out[25:0];
    assign shiftout[31:28]=one_PC_out[31:28];//组合为完整的跳转值
    shiftleft2_26 shiftleft2(.address(instoshift),.out(shiftout));//26位数左移2
   
    shiftleft2_32 shiftleft3(.address(signextendout),.out(shiftout2));//32位数左移2
    nadd i_nadd(.in1(one_PC_out),.in2(shiftout2),.out(naddout));//nadd模块
    
    wire[31:0] jr_result;
    wire equel;
    Equel_unit i_equel_unit(.a(PCA),.b(PCB),.op(ins2cu_op),.rt(rt),.out(equel),.add(jr_result));//beg jr模块

    mux2_2 muxpc_1(.in1(addout),.in2(naddout),.sign1(branch&(!iscleenslot)),.sign2(equel),.out(mux1out));//pc第一个mux，在pc+4与上个指令的beq结果中选择
    mux2_2_2 muxpc_2(.in1(shiftout),.in2(mux1out),.sign1(jal&(!iscleenslot)),.sign2(jump&(!iscleenslot)),.out(mux2out));//pc第二个mux,在mux1输出与上一个指令的j结果中选择,
    mux2_1 muxpc_3(.in1(PCA),.in2(mux2out),.sign(jr&(!iscleenslot)),.out(mux2pc));//pc第三个mux，要在id阶段读取的rs寄存器值经过旁路修正后的值与mux2out中选择
    //在确定pc值后还需要判断一下是否发生跳转，如果发生则此时取指阶段的指令为延迟槽指令，如果延迟槽指令也为跳转指令则要清空（将此周期时从if_id读取的值置为0）
    assign isslot=(!one_slot_out)&(branch|jump|jal|jr)&(mux2pc!=addout);//译码阶段为跳转指令且实际跳转pc!=取指阶段使用的pc
    //debug
    assign pcout=pc;
    //syscall部件
    syscall_unit sys(.vo(A),.ao(readdata2),.syscall(syscall),.sysblock(block_gr),.clock(clock),.reset(reset));

endmodule
module Add(pc,out);//pc自增器
    input wire[31:0] pc;
    output wire[31:0] out;
    assign out[31:0]=pc+4;
endmodule
module shiftleft2_26(address,out);//26位左移
    input wire[25:0] address;
    output wire [31:0] out;
    assign out[27:2]=address[25:0];
    assign out[1:0]=2'b00;
endmodule
module shiftleft2_32(address,out);//32为左移
    input wire[31:0]address;
    output wire[31:0]out;
    assign out[31:2]=address[29:0];
    assign out[1:0]=2'b00;
endmodule
module signextended(instruction,imm16,out);//有符号扩展
    input wire[15:0]imm16;
    input wire[31:0]instruction;
    output wire[31:0]out;
    wire i_unsigned;
    wire[5:0]Op=instruction[31:26];
    assign i_unsigned=(Op==6'b001100|Op==6'b001101|Op==6'b001110);
    assign out[15:0]=imm16[15:0];
    assign out[31:16]=i_unsigned?0:{16{imm16[15]}};
endmodule
module mux2_1(in1,in2,sign,out);//2选1mux,1个信号控制
    input wire[31:0] in1;
    input wire[31:0] in2;
    input wire sign;
    output wire[31:0] out;
    assign out=sign?in1:in2;
endmodule
module mux2_2(in1,in2,sign1,sign2,out);//2选1mux,2个信号控制,用于beq
    input wire[31:0] in1;
    input wire[31:0] in2;
    input wire sign1;
    input wire sign2;
    output wire[31:0] out;
    assign out=(sign1&sign2)?in2:in1;
endmodule
module mux2_2_2(in1,in2,sign1,sign2,out);//2选1mux,2个信号控制，用于j/jal
    input wire[31:0] in1;
    input wire[31:0] in2;
    input wire sign1;
    input wire sign2;
    output wire[31:0] out;
    assign out=(sign1|sign2)?in1:in2;
endmodule
module mux3_2(in1,in2,in3,sign1,sign2,out);//3选mux,2个信号控制
    input wire[31:0]in1;
    input wire[31:0]in2;
    input wire[31:0]in3;
    input wire sign1;
    input wire sign2;
    output wire[31:0] out;
    assign out=sign1?in1:sign2?in2:in3;
endmodule
module mux4_3(in1,in2,in3,in4,sign1,sign2,sign3,out);//4选mux,3个信号控制
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
module shiftleft16_16(in,out);//对16位数进行左移，补充为32位数
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
endmodule//输入a,b两个数据，根据op判断是否满足beq,bne,beqz的条件，同时输出其和
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