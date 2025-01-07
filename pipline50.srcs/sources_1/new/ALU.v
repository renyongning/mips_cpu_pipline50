`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/16 10:01:41
// Design Name: 
// Module Name: ALU
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

module alu(A,B,C,Op,zero);//???????50???CPU?��?R?????????OP??????????
    input wire[31:0] A;
    input wire[31:0] B;
    input wire[5:0] Op;
    output wire[31:0] C;
    output wire zero;
    wire addoverflow;//?????????????��??
    wire[31:0]addout;//?????????????
    wire suboverflow;//??????????????��??
    wire[31:0]subout;//??????????????
    adder add32(.a(A),.b(B),.min_c(1'b0),.sum(addout),.cout(addoverflow));//????????
    adder sub32(.a(A),.b(~B),.min_c(1'b1),.sum(subout),.cout(suboverflow));//?????????
    wire[31:0] i_sra_srav=($signed(B))>>> A[4:0];
    wire[31:0] i_slt=$signed(A)<$signed(B);
    assign C = (Op == 6'b100000) ? addout :
               (Op == 6'b100001) ? addout:
               (Op == 6'b100010) ? subout :
               (Op == 6'b100011) ? subout:
               (Op == 6'b000000|Op ==6'b000100) ? (B << A[4:0]) ://SLL SLLV
               (Op == 6'b000010|Op ==6'b000110) ? (B >> A[4:0]) ://SRL SRLV
               (Op == 6'b000011|Op ==6'b000111) ? i_sra_srav ://SRA/SRAV
               (Op == 6'b100100) ? (A & B) :
               (Op == 6'b100101) ? (A | B) :
               (Op == 6'b100110) ? (A ^ B) :
               (Op == 6'b100111) ? (~(A | B)) :
               (Op==6'b101010)?i_slt://SLT
               (Op==6'b101011)?A<B://SLTU
               32'b0; // ????
    assign zero=(C==0);
endmodule
module adder(a,b,min_c,sum,cout);
    input wire[31:0]a;
    input wire[31:0]b;
    input wire min_c;//???��??��?????
    output wire[31:0]sum;
    output wire cout;//???????????
    wire c[6:0];//?��??��????
    wire GM[7:0];//?????��???????
    wire PM[7:0];//????��????????
    //8??4��?????????
    adder_4 add1(.a(a[3:0]),.b(b[3:0]),.cin(min_c),.sum(sum[3:0]),.PM(PM[0]),.GM(GM[0]));//??��???????��?0
    adder_4 add2(.a(a[7:4]),.b(b[7:4]),.cin(c[0]),.sum(sum[7:4]),.PM(PM[1]),.GM(GM[1]));
    adder_4 add3(.a(a[11:8]),.b(b[11:8]),.cin(c[1]),.sum(sum[11:8]),.PM(PM[2]),.GM(GM[2]));
    adder_4 add4(.a(a[15:12]),.b(b[15:12]),.cin(c[2]),.sum(sum[15:12]),.PM(PM[3]),.GM(GM[3]));
    adder_4 add5(.a(a[19:16]),.b(b[19:16]),.cin(c[3]),.sum(sum[19:16]),.PM(PM[4]),.GM(GM[4]));
    adder_4 add6(.a(a[23:20]),.b(b[23:20]),.cin(c[4]),.sum(sum[23:20]),.PM(PM[5]),.GM(GM[5]));
    adder_4 add7(.a(a[27:24]),.b(b[27:24]),.cin(c[5]),.sum(sum[27:24]),.PM(PM[6]),.GM(GM[6]));
    adder_4 add8(.a(a[31:28]),.b(b[31:28]),.cin(c[6]),.sum(sum[31:28]),.PM(PM[7]),.GM(GM[7]));
    //cin?��????��????ALU??????????????????????????????��?????
    assign c[0]=GM[0]|(PM[0]&min_c);
    assign c[1]=GM[1]|(PM[1]&GM[0])|(PM[1]&PM[0]&min_c);
    assign c[2]=GM[2]|(PM[2]&GM[1])|(PM[2]&PM[1]&GM[0])|(PM[2]&PM[1]&PM[0]&min_c);
    assign c[3]=GM[3]|(PM[3]&GM[2])|(PM[3]&PM[2]&GM[1])|(PM[3]&PM[2]&PM[1]&GM[0])|(PM[3]&PM[2]&PM[1]&PM[0]&min_c);
    assign c[4]=GM[4]|(PM[4]&GM[3])|(PM[4]&PM[3]&GM[2])|(PM[4]&PM[3]&PM[2]&GM[1])|(PM[4]&PM[3]&PM[2]&PM[1]&GM[0])|(PM[4]&PM[3]&PM[2]&PM[1]&PM[0]&min_c);
    assign c[5]=GM[5]|(PM[5]&GM[4])|(PM[5]&PM[4]&GM[3])|(PM[5]&PM[4]&PM[3]&GM[2])|(PM[5]&PM[4]&PM[3]&PM[2]&GM[1])|(PM[5]&PM[4]&PM[3]&PM[2]&PM[1]&GM[0])|(PM[5]&PM[4]&PM[3]&PM[2]&PM[1]&PM[0]&min_c);
    assign c[6]=GM[6]|(PM[6]&GM[5])|(PM[6]&PM[5]&GM[4])|(PM[6]&PM[5]&PM[4]&GM[3])|(PM[6]&PM[5]&PM[4]&PM[3]&GM[2])|(PM[6]&PM[5]&PM[4]&PM[3]&PM[2]&GM[1])|(PM[6]&PM[5]&PM[4]&PM[3]&PM[2]&PM[1]&GM[0])|(PM[6]&PM[5]&PM[4]&PM[3]&PM[2]&PM[1]&PM[0]&min_c);
    //assign cout=GM[7]|(PM[7]&GM[6])|(PM[7]&PM[6]&GM[5])|(PM[7]&PM[6]&PM[5]&GM[4])|(PM[7]&PM[6]&PM[5]&PM[4]&GM[3])|(PM[7]&PM[6]&PM[5]&PM[4]&PM[3]&GM[2])|(PM[7]&PM[6]&PM[5]&PM[4]&PM[3]&PM[2]&GM[1])|(PM[7]&PM[6]&PM[5]&PM[4]&PM[3]&PM[2]&PM[1]&GM[0])|(PM[7]&PM[6]&PM[5]&PM[4]&PM[3]&PM[2]&PM[1]&PM[0]&min_c);
    assign cout=(a[31]==b[31]&&a[31]!=sum[31]);
endmodule

module adder_4(a,b,cin,sum,PM,GM);//4��?????
    input wire [3:0]a;//��???4??????????
    input wire[3:0]b;//��???4??????????
    input wire cin;//1��??��????C0
    output wire[3:0]sum;//4��??????
    output wire PM;//????��????????
    output wire GM;//????��????
    
    wire[3:0] G;//?????��????????????????????
    wire[3:0] P;//?????��???????????????????
    wire[2:0]C;//?��C1,C2,C3???��???
    wire[9:0]PG;//?��?��???
    //?????��?????
    //?????��???????????��???????
    //assign cin = 0;
    xor(P[0],a[0],b[0]);
    xor(P[1],a[1],b[1]);
    xor(P[2],a[2],b[2]);
    xor(P[3],a[3],b[3]);
    and(G[0],a[0],b[0]);
    and(G[1],a[1],b[1]);
    and(G[2],a[2],b[2]);
    and(G[3],a[3],b[3]);
    //?????��?????��??��????
    and(PG[0],P[0],cin);
    and(PG[1],P[0],P[1],cin);
    and(PG[2],P[0],P[1],P[2],cin);
    and(PG[3],P[0],P[1],P[2],P[3],cin);
    and(PG[4],P[1],G[0]);
    and(PG[5],P[1],P[2],G[0]);
    and(PG[6],P[1],P[2],P[3],G[0]);
    and(PG[7],P[2],G[1]);
    and(PG[8],P[2],P[3],G[1]);
    and(PG[9],P[3],G[2]);
    //?????��???
    or(C[0],G[0],PG[0]);
    or(C[1],G[1],PG[4],PG[1]);
    or(C[2],G[2],PG[5],PG[7],PG[2]);
    //????????��
    and(PM,P[0],P[1],P[2],P[3]);
    or(GM,G[3],PG[9],PG[8],PG[6]);
    //????��???????
    xor(sum[0],P[0],cin);
    xor(sum[1],P[1],C[0]);
    xor(sum[2],P[2],C[1]);
    xor(sum[3],P[3],C[2]);
endmodule