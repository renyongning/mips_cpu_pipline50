`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/13 17:12:40
// Design Name: 
// Module Name: instructionmen
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

//只读的指令寄存器，在启动时初始化
module instructionmen(readaddress,readresult);
    input wire[31:0]readaddress;
    output wire[31:0]readresult;
    reg[31:0]data[0:1023];
    initial begin
        $readmemh("E:/learn/cpuhomework/finallab/Pipeline50/pipeline-tester-py/code.txt", data);
    end
    assign readresult=data[readaddress[11:2]];
endmodule