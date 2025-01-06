`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/09 10:16:09
// Design Name: 
// Module Name: EX_MEM
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


module EX_MEM(regwrite,memread,memwrite,memtoreg,lui,jal,//ex??¦Ê??????,????regdst??id??????,alusrc,op??ex??????,j??????jal????????
regwrite_out,memread_out,memwrite_out,memtoreg_out,lui_out,jal_out,
dmop_in,dmop_out,pc_in,pc_out,b_in,b_out,shiftleft_in,shiftleft_out,wb_in,wb_out,clock,reset,alu_in,alu_out);//PC,ALUOUT,flag,B,<<16,????beg??jr?????????????????????????????????rest???
    input wire regwrite,memread,memwrite,memtoreg,lui,jal;
    output wire regwrite_out,memread_out,memwrite_out,memtoreg_out,lui_out,jal_out;
    input wire[31:0] pc_in;
    output wire[31:0] pc_out;
    input wire[31:0] b_in;
    output wire[31:0] b_out;
    input wire[31:0]shiftleft_in;
    output wire[31:0]shiftleft_out;
    input wire[4:0]wb_in;
    output wire[4:0]wb_out;
    input wire clock,reset;
    input wire[31:0] alu_in;
    output wire[31:0] alu_out;
    input wire[2:0]dmop_in;
    output wire[2:0]dmop_out;
    reg Regwrite,Memread,Memwrite,Memtoreg,Lui,Jal;
    reg[31:0] pc,b,shiftleft;
    reg[4:0]wb;
    reg[31:0] alu;
    reg[2:0]dmop;
    assign regwrite_out=Regwrite;
    assign memread_out=Memread;
    assign memwrite_out=Memwrite;
    assign memtoreg_out=Memtoreg;
    assign lui_out=Lui;
    assign jal_out=Jal;
    assign pc_out=pc;
    assign b_out=b;
    assign shiftleft_out=shiftleft;
    assign wb_out=wb;
    assign alu_out=alu;
    assign dmop_out=dmop;
    always@(posedge clock)begin
        if(reset)begin
            Regwrite=1'b0;
            Memread=1'b0;
            Memwrite=1'b0;
            Memtoreg=1'b0;
            Lui=1'b0;
            Jal=1'b0;
            pc=32'b0;
            b=32'b0;
            shiftleft=32'b0;
            wb=5'b0;
            alu=32'b0;
            dmop=3'b0;
        end
        else begin
            Regwrite=regwrite;
            Memread=memread;
            Memwrite=memwrite;
            Memtoreg=memtoreg;
            Lui=lui;
            Jal=jal;
            pc=pc_in;
            b=b_in;
            shiftleft=shiftleft_in;
            wb=wb_in;
            alu=alu_in;
            dmop=dmop_in;
        end
    end

endmodule
