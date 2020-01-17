`include "./1_of_M_select.v"
`include "./rs_alu.v"

module select_alu(
	input wire [`RRF_SEL-1:0] age0,
	input wire [`RRF_SEL-1:0] age1,
	input wire [`RRF_SEL-1:0] age2,
	input wire [`RRF_SEL-1:0] age3,
	input wire [`RRF_SEL-1:0] age4,
	input wire [`RRF_SEL-1:0] age5,
	input wire [`RRF_SEL-1:0] age6,
	input wire [`RRF_SEL-1:0] age7,
	//index
	input wire [2:0] index0,
	input wire [2:0] index1,
	input wire [2:0] index2,
	input wire [2:0] index3,
	input wire [2:0] index4,
	input wire [2:0] index5,
	input wire [2:0] index6,
	input wire [2:0] index7,
	//rdy0
	input wire       rdy0_0,
	input wire       rdy0_1,
	//1
	input wire       rdy1_0,
	input wire       rdy1_1,
	//2
	input wire       rdy2_0,
	input wire       rdy2_1,
	//3
	input wire       rdy3_0,
	input wire       rdy3_1,
	//4
	input wire       rdy4_0,
	input wire       rdy4_1,
	//5
	input wire       rdy5_0,
	input wire       rdy5_1,
	//6
	input wire       rdy6_0,
	input wire       rdy6_1,
	//7
	input wire       rdy7_0,
	input wire       rdy7_1,
	//fu
	input wire       fu0,
	input wire       fu1,
	input wire       fu2,
	input wire       fu3,
	input wire       fu4,
	input wire       fu5,
	input wire       fu6,
	input wire       fu7
	//
	);

//ALU 仲裁
fu_select fu_select0(
	.a(age0),
	.b(index0),
	.c(rdy0),
	.d(fu0),
	//
	.e(age0_0),
	.f(index0_0),
	.g(rdy0_0),
	//
	.h(age0_1),
	.i(index0_1),
	.j(rdy0_1)
	);
//前面的0代表表项，后面的0或者1代表fu0 fu1
u_select fu_select1(
	.a(age1),
	.b(index1),
	.c(rdy1),
	.d(fu1),
	//
	.e(age1_0),
	.f(index1_0),
	.g(rdy1_0),
	//
	.h(age1_1),
	.i(index1_1),
	.j(rdy1_1)
	);
u_select fu_select2(
	.a(age2),
	.b(index2),
	.c(rdy2),
	.d(fu2),
	//
	.e(age2_0),
	.f(index2_0),
	.g(rdy2_0),
	//
	.h(age2_1),
	.i(index2_1),
	.j(rdy2_1)
	);
u_select fu_select3(
	.a(age3),
	.b(index3),
	.c(rdy3),
	.d(fu3),
	//
	.e(age3_0),
	.f(index3_0),
	.g(rdy3_0),
	//
	.h(age3_1),
	.i(index3_1),
	.j(rdy3_1)
	);
u_select fu_select4(
	.a(age4),
	.b(index4),
	.c(rdy4),
	.d(fu4),
	//
	.e(age4_0),
	.f(index4_0),
	.g(rdy4_0),
	//
	.h(age4_1),
	.i(index4_1),
	.j(rdy4_1)
	);
u_select fu_select5(
	.a(age5),
	.b(index5),
	.c(rdy5),
	.d(fu5),
	//
	.e(age5_0),
	.f(index5_0),
	.g(rdy5_0),
	//
	.h(age5_1),
	.i(index5_1),
	.j(rdy5_1)
	);
u_select fu_select6(
	.a(age6),
	.b(index6),
	.c(rdy6),
	.d(fu6),
	//
	.e(age6_0),
	.f(index6_0),
	.g(rdy6_0),
	//
	.h(age6_1),
	.i(index6_1),
	.j(rdy6_1)
	);
u_select fu_select7(
	.a(age7),
	.b(index7),
	.c(rdy7),
	.d(fu7),
	//
	.e(age7_0),
	.f(index7_0),
	.g(rdy7_0),
	//
	.h(age7_1),
	.i(index7_1),
	.j(rdy7_1)
	);
wire [5:0] age0_0;
wire [5:0] age1_0;
wire [5:0] age2_0;
wire [5:0] age3_0;
wire [5:0] age4_0;
wire [5:0] age5_0;
wire [5:0] age6_0;
wire [5:0] age7_0;
//
wrie [2:0] index0_0;
wrie [2:0] index1_0;
wrie [2:0] index2_0;
wrie [2:0] index3_0;
wrie [2:0] index4_0;
wrie [2:0] index5_0;
wrie [2:0] index6_0;
wrie [2:0] index7_0;
//
wire rdy0_0;
wire rdy1_0;
wire rdy2_0;
wire rdy3_0;
wire rdy4_0;
wire rdy5_0;
wire rdy6_0;
wire rdy7_0;
//
wire [2:0] oindex0;
wire grant0;

select_1_of_M select_1_of_M_0(
	.age0    (age0_0),
	.age1    (age1_0),
	.age2    (age2_0),
	.age3    (age3_0),
	.age4    (age4_0),
	.age5    (age5_),
	.age6    (age6_0),
	.age7    (age7_0),
	.index0    (index0_0),
	.index1    (index1_0),
	.index2    (index2_0),
	.index3    (index3_0),
	.index4    (index4_0),
	.index5    (index5_0),
	.index6    (index6_0),
	.index7    (index7_0),
	.rdy0    (rdy0_0),
	.rdy1    (rdy1_0),
	.rdy2    (rdy2_0),
	.rdy3    (rdy3_0),
	.rdy4    (rdy4_0),
	.rdy5    (rdy5_0),
	.rdy6    (rdy6_0),
	.rdy7    (rdy7_0),
	.cindex3 (oindex0),
	.grant   (grant0)//zhuyi
	);

wire [5:0] age0_1;
wire [5:0] age1_1;
wire [5:0] age2_1;
wire [5:0] age3_1;
wire [5:0] age4_1;
wire [5:0] age5_1;
wire [5:0] age6_1;
wire [5:0] age7_1;
//
wrie [2:0] index0_1;
wrie [2:0] index1_1;
wrie [2:0] index2_1;
wrie [2:0] index3_1;
wrie [2:0] index4_1;
wrie [2:0] index5_1;
wrie [2:0] index6_1;
wrie [2:0] index7_1;
//
wire rdy0_1;
wire rdy1_1;
wire rdy2_1;
wire rdy3_1;
wire rdy4_1;
wire rdy5_1;
wire rdy6_1;
wire rdy7_1;
//
wire [2:0] oindex1;
wire grant1;
select_1_of_M select_1_of_M_1(
	.age0    (age0_1),
	.age1    (age1_1),
	.age2    (age2_1),
	.age3    (age3_1),
	.age4    (age4_1),
	.age5    (age5_1),
	.age6    (age6_1),
	.age7    (age7_1),
	.index0    (index0_1),
	.index1    (index1_1),
	.index2    (index2_1),
	.index3    (index3_1),
	.index4    (index4_1),
	.index5    (index5_1),
	.index6    (index6_1),
	.index7    (index7_1),
	.rdy0    (rdy0_1),
	.rdy1    (rdy1_1),
	.rdy2    (rdy2_1),
	.rdy3    (rdy3_1),
	.rdy4    (rdy4_1),
	.rdy5    (rdy5_1),
	.rdy6    (rdy6_1),
	.rdy7    (rdy7_1),
	.cindex3 (oindex1),
	.grant   (grant1)//注意
	);

assign tag_alu1 =  (grant0 && dstval_m[oindex0])?dest_m[oindex0]:5'bz;

assign tag_alu2 =  (grant1 && dstval_m[oindex1])?dest_m[oindex1]:5'bz;

assign tag_alu1 =  ((grant0 == 1'b1) && (dstval_m[oindex0] == 1'b1))?dest_m[oindex0]:5'bz;

assign tag_alu2 =  ((grant1 == 1'b1) && (dstval_m[oindex1] == 1'b1))?dest_m[oindex1]:5'bz;

assign delay_alu1 = ((grant0 == 1'b1) && (dstval_m[oindex0] == 1'b1))?dly_m[oindex0]:8'bz;

assign delay_alu2 = ((grant0 == 1'b1) && (dstval_m[oindex0] == 1'b1))?dly_m[oindex1]:8'bz;

assign wissued1 = ((grant0 == 1'b1) && (dstval_m[oindex0] == 1'b1))?issued_m[oindex0]:1'bz;

assign wissued2 = ((grant0 == 1'b1) && (dstval_m[oindex0] == 1'b1))?issued_m[oindex0]:1'bz;




endmodule



module fu_select(
	input wire [5:0] a,//age
	input wire [2:0] b,//index
	input wire c,      //rdy
	input wire d,      //fu
	output wire [5:0] e,
	output wire [2:0] f,
	output wire  g,

	output wire [5:0] h,
	output wire [2:0] i,
	output wire  j
	);

assign e = (d == 1'b0)? a:'bz;
assign f = (d == 1'b0)? b:'bz;
assign g = (d == 1'b0)? c:'bz;

assign h = (d == 1'b1)? a:'bz;
assign i = (d == 1'b1)? b:'bz;
assign j = (d == 1'b1)? c:'bz;

endmodule