`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/25 23:43:55
// Design Name: 
// Module Name: dmcontrol
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

//控制数据存储器操作输入
//LB:取8位有符号扩展 / LBU：取8位无符号扩展 / LH：取16位有符号扩展 / LHU：取16位无符号扩展 / LW / SB：保存8位到指定为止 / SH：保存16位到指定为止 sw
module dmcontrol(Op,dmop);
input wire[5:0]Op;
output wire[2:0]dmop;
assign dmop=
    (Op==6'b100000)?3'b011://LB
    (Op==6'b100100)?3'b100://LBU
    (Op==6'b100001)?3'b001://LH
    (Op==6'b100101)?3'b010://LHU
    (Op==6'b100011)?3'b000://LW
    (Op==6'b101000)?3'b101://SB
    (Op==6'b101001)?3'b110://SH
    (Op==6'b101011)?3'b111://SW
    3'b000;
endmodule
