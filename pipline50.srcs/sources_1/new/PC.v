`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/22 16:01:27
// Design Name: 
// Module Name: PC
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


module PC(reset,clock,pcinput,pc_write,pcValue,pcstop);
    input wire reset;
    input wire clock;
    input wire[31:0] pcinput;
    input wire pc_write;
    input wire pcstop;
    output wire[31:0] pcValue;
    reg[31:0] pcreg;
    assign pcValue=pcreg;
    always @(posedge clock) begin //???????????§Õ???
        if(reset)begin
            pcreg<=32'h00003000;
        end
        else if((!pcstop))begin
            pcreg<=pcinput;
        end        
    end
endmodule
