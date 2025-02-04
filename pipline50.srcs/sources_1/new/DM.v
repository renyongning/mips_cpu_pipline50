`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/23 19:38:45
// Design Name: 
// Module Name: DM
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


module DM(reset,clock,dmop,address,writeEnabled,writeInput,readResult,pc);//处理lw/lh/lhu/lb/lbu/sw/sh/sb
    input wire reset;
    input wire[2:0]dmop;//表示dm的操作
    input wire[31:0] address;
    input wire clock;
    input wire[31:0] writeInput;
    input wire writeEnabled;
    input wire[31:0]pc;
    reg[31:0]data[2047:0];
    reg[31:0] i;
    output wire[31:0] readResult;
    wire[31:0] tem_result;
    wire[31:0] i_lb1,i_lb2,i_lb3,i_lb4;
    wire[31:0] i_lh1,i_lh2;
    assign tem_result=data[address[31:2]];//获取对其的word的内容
    assign i_lb1[7:0]=tem_result[7:0];
    assign i_lb2[7:0]=tem_result[15:8];
    assign i_lb3[7:0]=tem_result[23:16];
    assign i_lb4[7:0]=tem_result[31:24];
    assign i_lb1[31:8]=(tem_result[7]==1)?24'hFFFFFF:24'h000000;
    assign i_lb2[31:8]=(tem_result[15]==1)?24'hFFFFFF:24'h000000;
    assign i_lb3[31:8]=(tem_result[23]==1)?24'hFFFFFF:24'h000000;
    assign i_lb4[31:8]=(tem_result[31]==1)?24'hFFFFFF:24'h000000;

    assign i_lh1[15:0]=tem_result[15:0];
    assign i_lh2[15:0]=tem_result[31:16];
    assign i_lh1[31:16]=(tem_result[15]==1)?16'hFFFF:16'h0000;
    assign i_lh2[31:16]=(tem_result[31]==1)?16'hFFFF:16'h0000;
    assign readResult=(dmop==3'b000)?tem_result://lw//根据op获取输出
    (dmop==3'b001)?((address[1:0]==2'b00)?i_lh1:(address[1:0]==2'b10)?i_lh2:32'b0)://lh address[1:0]要么是00，要么是10
    (dmop==3'b010)?((address[1:0]==2'b00)?tem_result[15:0]:(address[1:0]==2'b10)?tem_result[31:16]:32'b0)://lhu
    (dmop==3'b011)?((address[1:0]==2'b00)?i_lb1:(address[1:0]==2'b01)?i_lb2:(address[1:0]==2'b10)?i_lb3:(address[1:0]==2'b11)?i_lb4:32'b0)://lb
    (dmop==3'b100)?((address[1:0]==2'b00)?tem_result[7:0]:(address[1:0]==2'b01)?tem_result[15:8]:(address[1:0]==2'b10)?tem_result[23:16]:(address[1:0]==2'b11)?tem_result[31:24]:32'b0)://lbu
    32'b0;

    always @(posedge clock)begin
        if(reset)begin
            for (i = 0; i < 2048; i = i + 1) begin
                data[i] = 32'b0;
            end
        end
        else begin
            if(writeEnabled)begin
                if(dmop==3'b101)begin
                    case (address[1:0])
                        2'b00:data[address[31:2]][7:0]=writeInput[7:0];
                        2'b01:data[address[31:2]][15:8]=writeInput[7:0];
                        2'b10:data[address[31:2]][23:16]=writeInput[7:0];
                        2'b11:data[address[31:2]][31:24]=writeInput[7:0];
                        default: data[address[31:2]]=32'b0;
                    endcase
                    $display("@%h: *%h <= %h", pc, {address[31:2],2'b00},data[address[31:2]]);
                end//SB
                else if(dmop==3'b110)begin
                    case (address[1:0])
                        2'b00:data[address[31:2]][15:0]=writeInput[15:0];
                        2'b10:data[address[31:2]][31:16]=writeInput[15:0];
                        default: data[address[31:2]]=32'b0;
                    endcase
                    $display("@%h: *%h <= %h", pc,{address[31:2],2'b00},data[address[31:2]]);
               end//SH
               else if(dmop==3'b111)begin
                    data[address[31:2]]=writeInput;
                    $display("@%h: *%h <= %h", pc, address,writeInput);
               end//SW
               else begin
               end
            end
            else begin
                //readResult<=data[address[31:2]];
            end
        end
    end
endmodule
