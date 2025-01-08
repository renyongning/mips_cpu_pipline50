`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/25 23:43:55
// Design Name: 
// Module Name: mutcontrol
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
//控制乘法器操作输�?
module mutcontrol(Op,Func,mutop);//MULT / MULTU / DIV / DIVU / MFHI / MTHI / MFLO / 
input wire[5:0] Func;
input wire[5:0]Op;
output mdu_operation_t mutop;
assign mutop=(Op == 6'b000000 &Func==6'b010000)?MDU_READ_HI://MFHI
             (Op == 6'b000000 &Func==6'b010010)?MDU_READ_LO://MFLO
             (Op == 6'b000000 &Func==6'b010001)?MDU_WRITE_HI://MTHI
             (Op == 6'b000000 &Func==6'b010011)?MDU_WRITE_LO://MTLO
             (Op == 6'b000000 &Func==6'b011000)?MDU_START_SIGNED_MUL://MULT
             (Op == 6'b000000 &Func==6'b011001)?MDU_START_UNSIGNED_MUL://MULTU
             (Op == 6'b000000 &Func==6'b011010)?MDU_START_SIGNED_DIV://DIV
             (Op == 6'b000000 &Func==6'b011011)?MDU_START_UNSIGNED_DIV://DIVU
             MDU_READ_HI;
endmodule
