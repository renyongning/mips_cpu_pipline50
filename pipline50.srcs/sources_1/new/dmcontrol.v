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

//�������ݴ洢����������
//LB:ȡ8λ�з�����չ / LBU��ȡ8λ�޷�����չ / LH��ȡ16λ�з�����չ / LHU��ȡ16λ�޷�����չ / LW / SB������8λ��ָ��Ϊֹ / SH������16λ��ָ��Ϊֹ sw
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
