`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/09 11:41:52
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB(regwrite,memtoreg,lui,jal,
regwrite_out,memtoreg_out,lui_out,jal_out,//ÐÅºÅlui,jal,memtoreg,regwrite
pc_in,pc_out,alu_in,alu_out,data_in,data_out,shiftleft_in,shiftleft_out,wb_in,wb_out,clock,reset);//Êý¾Ýaluout,data,pc,<<16,wb
    input wire regwrite,memtoreg,lui,jal;
    output wire regwrite_out,memtoreg_out,lui_out,jal_out;
    input wire[31:0] pc_in;
    output wire[31:0] pc_out;
    input wire[31:0] alu_in;
    output wire[31:0] alu_out;
    input wire[31:0] data_in;
    output wire[31:0] data_out;
    input wire[31:0]shiftleft_in;
    output wire[31:0]shiftleft_out;
    input wire[4:0]wb_in;
    output wire[4:0]wb_out;
    input wire clock,reset;
    reg Regwrite,Memtoreg,Lui,Jal;
    reg[31:0] pc,alu,data,shiftleft;
    reg[4:0]wb;
    assign regwrite_out=Regwrite;
    assign memtoreg_out=Memtoreg;
    assign lui_out=Lui;
    assign jal_out=Jal;
    assign pc_out=pc;
    assign alu_out=alu;
    assign data_out=data;
    assign shiftleft_out=shiftleft;
    assign wb_out=wb;
    always@(posedge clock)begin
        if(reset)begin
            Regwrite=0;
            Memtoreg=0;
            Lui=0;
            Jal=0;
            pc=0;
            alu=0;
            data=0;
            shiftleft=0;
            wb=0;
        end
        else begin
            Regwrite=regwrite;
            Memtoreg=memtoreg;
            Lui=lui;
            Jal=jal;
            pc=pc_in;
            alu=alu_in;
            data=data_in;
            shiftleft=shiftleft_in;
            wb=wb_in;
        end
    end
endmodule
