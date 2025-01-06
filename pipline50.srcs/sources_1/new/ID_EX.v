`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/07 22:15:47
// Design Name: 
// Module Name: ID_EX
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

`include "E:\learn\cpuhomework\Pipeline50\lab_5\lab_5.srcs\sources_1\imports\Pipeline 50\MultiplicationDivisionUnit.sv"
module ID_EX(regwrite,alusrc,memread,memwrite,memtoreg,lui,jal,branch,jr,jump,alusrca,mutstart,
regwrite_out,alusrc_out,memread_out,memwrite_out,memtoreg_out,lui_out,jal_out,branch_out,jr_out,jump_out,alusrca_out,mutstart_out,
sa_in,sa_out,pc_in,pc_out,a_in,a_out,b_in,b_out,extend_in,extend_out,op_in,op_out,Op_in,Op_out,Func_in,Func_out,mutop_in,mutop_out,dmop_in,dmop_out,shiftleft_in,shiftleft_out,wb_in,wb_out,rs_in,rs_out,rt_in,rt_out,rd_in,rd_out,clock,reset,block);
    input wire regwrite,alusrc,memread,memwrite,memtoreg,lui,jal,branch,jr,jump;
    output wire regwrite_out,alusrc_out,memread_out,memwrite_out,memtoreg_out,lui_out,jal_out,branch_out,jr_out,jump_out;
    input wire[31:0] pc_in;
    output wire[31:0] pc_out;//pc
    input wire[31:0] a_in;
    output wire[31:0] a_out;//a
    input wire[31:0] b_in;
    output wire[31:0] b_out;//b
    input wire[31:0]extend_in;
    output wire[31:0] extend_out;//32¦Ë???
    input wire[5:0]op_in;
    output wire[5:0] op_out;//6¦Ëaluop
    input wire[5:0] Op_in;//6¦Ë???op
    output wire[5:0]Op_out;
    input wire[5:0]Func_in;
    output wire[5:0]Func_out;//6¦Ë???func
    input wire[31:0] shiftleft_in;
    output wire[31:0]shiftleft_out;//<<16
    input wire[4:0]wb_in;
    output wire[4:0]wb_out;//5¦Ë??§Õ???
    input wire[4:0]rs_in,rt_in,rd_in;
    output wire[4:0]rs_out,rt_out,rd_out;
    input wire clock,reset;//?????¦Ë
    input wire alusrca;
    input wire mutstart;
    output wire alusrca_out,mutstart_out;//alusrca,mutstart
    input mdu_operation_t mutop_in;
    output mdu_operation_t mutop_out;//mutop
    input wire[2:0]dmop_in;
    output wire[2:0]dmop_out;//dmop
    input wire block;
    input wire[31:0]sa_in;
    output wire[31:0]sa_out;
    reg Regwrite,Alusrc,Memread,Memwrite,Memtoreg,Lui,Jal,Branch,Jr,Jump,Alusrca,Mutstart;
    reg[31:0] pc,a,b,extend,shiftleft,Sa;
    reg[5:0]op,Op,Func;
    reg[4:0]wb;
    reg[4:0]Rs,Rd,Rt;
    reg[2:0]dmop;
    mdu_operation_t mutop;
    assign regwrite_out=Regwrite;
    assign alusrc_out=Alusrc;
    assign memread_out=Memread;
    assign memwrite_out=Memwrite;
    assign memtoreg_out=Memtoreg;
    assign lui_out=Lui;
    assign jal_out=Jal;
    assign branch_out=Branch;
    assign jr_out=Jr;
    assign jump_out=Jump;
    assign pc_out=pc;
    assign a_out=a;
    assign b_out=b;
    assign extend_out=extend;
    assign op_out=op;
    assign shiftleft_out=shiftleft;
    assign wb_out=wb;
    assign rs_out=Rs;
    assign rt_out=Rt;
    assign rd_out=Rd;
    assign alusrca_out=Alusrca;
    assign mutstart_out=Mutstart;
    assign mutop_out=mutop;
    assign dmop_out=dmop;
    assign sa_out=Sa;
    assign Op_out=Op;
    assign Func_out=Func;
    always@(posedge clock)begin
        if (reset) begin
            Regwrite=1'b0;
            Alusrc=1'b0;
            Memread=1'b0;
            Memwrite=1'b0;
            Memtoreg=1'b0;
            Lui=1'b0;
            Jr=1'b0;
            Jump=1'b0;
            Branch=1'b0;
            Jal=1'b0;
            pc=32'b0;
            a=32'b0;
            b=32'b0;
            extend=32'b0;
            op=6'b0;
            shiftleft=32'b0;
            wb=5'b0;
            Rs=5'b0;
            Rd=5'b0;
            Rt=5'b0;
            mutop=MDU_READ_HI;
            dmop=3'b0;
            Mutstart=1'b0;
            Alusrca=1'b0;
            Sa=32'b0;
            Op=32'b0;
            Func=32'b0;
        end//??¦Ë
        else begin
            if(!block)begin
                Regwrite<=regwrite;
                Alusrc=alusrc;
                Memread=memread;
                Memwrite=memwrite;
                Memtoreg=memtoreg;
                Lui=lui;
                Jr=jr;
                Jump=jump;
                Branch=branch;
                Jal=jal;
                pc=pc_in;
                a=a_in;
                b=b_in;
                extend=extend_in;
                op=op_in;
                shiftleft=shiftleft_in;
                wb=wb_in;
                Rs=rs_in;
                Rd=rd_in;
                Rt=rt_in;
                mutop=mutop_in;
                dmop=dmop_in;
                Mutstart=mutstart;
                Alusrca=alusrca;
                Sa=sa_in;
                Op=Op_in;
                Func=Func_in;
            end
            else begin
            end
        end//????¦Ë????????????
    end
    
endmodule
