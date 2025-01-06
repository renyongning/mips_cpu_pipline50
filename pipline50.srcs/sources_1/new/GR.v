`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/13 18:45:01
// Design Name: 
// Module Name: GR
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


module GR(clock,reset,rd1,rd2,wd1,iswriteable,writedata,readresult1,readresult2,pc,k);
    input wire clock;
    input wire reset;
    input wire[4:0]rd1;
    input wire[4:0] rd2;
    input wire[4:0]wd1;
    input wire iswriteable;
    input wire[31:0]writedata;
    input wire[31:0]pc;
    input wire[31:0]k;
    output wire[31:0]readresult1;
    output wire[31:0]readresult2;
    reg[31:0]data[31:0];//32????จน????
    reg[31:0]PC;
    assign readresult1=data[rd1[4:0]];
    assign readresult2=data[rd2[4:0]];
    reg[31:0] i=0;
    always @(posedge clock)begin
    end
    always @(negedge clock)begin
        PC=pc;
        if(reset)begin
            for(i=0;i<32;i=i+1)begin
                data[i]=0;
            end
        end
        if(iswriteable)begin
            case (wd1)
                  5'b00000:data[0]=0;
                  default: data[wd1]=writedata;
            endcase
            //data[wd1]=(writedata);
            if($signed(PC)>=0)begin
            $display("@%h: $%d <= %h", pc, wd1, writedata);
            end
        end
    end
    
endmodule
