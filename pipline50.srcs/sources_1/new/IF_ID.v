`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/07 22:04:03
// Design Name: 
// Module Name: IF_ID
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


module IF_ID(PC_in,IR_in,isslot_in,is_slot_out,clock,enable,PC_out,IR_out,reset);//????pc,ir?????????????????????????ß÷????
    input wire[31:0] PC_in;
    input wire[31:0]IR_in;
    input wire isslot_in;
    input wire clock,reset;
    input wire enable;//??????????Å£????????
    output wire[31:0] PC_out;
    output wire[31:0] IR_out;
    output wire is_slot_out;
    reg[31:0] PC;
    reg[31:0] IR;
    reg slot;
    assign PC_out=PC;
    assign IR_out=IR;
    assign is_slot_out=slot;
    always @(posedge clock) begin //???????????ß’???
        if(reset)begin
            PC=32'h0;
            IR=32'h0;
            slot=1'b0;
        end
        else if(enable)begin
            PC=PC_in;
            IR=IR_in;
            slot=isslot_in;
        end//?????????
        else begin
        end        
    end
endmodule
