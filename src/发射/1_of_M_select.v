module select_1_of_M(
	//age
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
	//req 仲裁请求信号
	input wire       req0,
	input wire       req1,
	input wire       req2,
	input wire       req3,
	input wire       req4,
	input wire       req5,
	input wire       req6,
	input wire       req7,
	//output 
	output wire [2:0] cindex3,
	output wire grant
	);

/*----------------------------
//          第一级仲裁
-----------------------------*/
//年龄大小比较
wire [`RRF_SEL-1:0] cage1_1;
wire [2:0] cindex1_1;
compare compare1(
	.a(age0),
	.b(age1),
	.d(index0),
	.e(index1),
	.c(cage1_1),
	.d(cindex1_1)
	);
wire [`RRF_SEL-1:0] ctag1_2;
wire [2:0] cindex1_2;
compare compare2(
	.a(age2),
	.b(age3),
	.d(index2),
	.e(index3),
	.c(cage1_2),
	.d(cindex1_2)
	);
wire [`RRF_SEL-1:0] cage1_3;
wire [2:0] cindex1_3;
compare compare3(
	.a(age4),
	.b(age5),
	.d(index4),
	.e(index5),
	.c(cage1_3),
	.d(cindex1_3)
	);
wire [`RRF_SEL-1:0] cage1_4;
wire [2:0] cindex1_4;
compare compare4(
	.a(age6),
	.b(age7),
	.d(index6),
	.e(index7),
	.c(cage1_4)，
	.d(cindex1_4)
	);
//选择有age
wire [`RRF_SEL-1:0] age1_1;
mux_4 mux_age1(
	.a(req0),
	.b(req1),
	.win1(age1),
	.win2(age0),
	.win3(cage1_1),
	.cou(age1_1)
	);
wire [`RRF_SEL-1:0] age1_2;
mux_4 mux_age2(
	.a(req2),
	.b(req3),
	.win1(age3),
	.win2(age2),
	.win3(cage1_2),
	.cou(age1_2)
	);
wire [`RRF_SEL-1:0] age1_3;
mux_4 mux_age3(
	.a(req4),
	.b(req5),
	.win1(age5),
	.win2(age4),
	.win3(cage1_3),
	.cou(age1_3)
	);
wire [`RRF_SEL-1:0] age1_4;
mux_4 mux_age4(
	.a(req6),
	.b(req7),
	.win1(age7),
	.win2(age6),
	.win3(cage1_4),
	.cou(age1_4)
	);
//地址索引传递
wire [2:0] index1_1;
mux_4 mux_index1(
	.a(req0),
	.b(req1),
	.win1(index1),
	.win2(index0),
	.win3(cindex1_1),
	.cou(index1_1)
	);
wire [2:0] index1_2;
mux_4 mux_age2(
	.a(req2),
	.b(req3),
	.win1(index3),
	.win2(index2),
	.win3(cindex2),
	.cou(index1_2)
	);
wire [2:0] index1_3;
mux_4 mux_age3(
	.a(req4),
	.b(req5),
	.win1(index5),
	.win2(index4),
	.win3(cindex1_3),
	.cou(index1_3)
	);
wire [2:0] index1_4;
mux_4 mux_age4(
	.a(req6),
	.b(req7),
	.win1(index7),
	.win2(index6),
	.win3(cindex1_4),
	.cou(index1_4)
	);
wire rdy1_0;
wire rdy1_1;
wire ray1_2;
wire rdy1_3;
assign rdy1_0 = rdy0 || rdy1;
assign rdy1_1 = rdy2 || rdy3;
assign rdy1_2 = rdy4 || rdy5;
assign rdy1_3 = rdy6 || rdy7;
/*---------------------------------
//         第一级仲裁结束
----------------------------------*/

/*---------------------------------
//         第二级仲开始
----------------------------------*/
//年龄大小比较
wire [`RRF_SEL-1:0] cage2_1;
wire [2:0] cindex2_1;
compare compare1(
	.a(cage1_1),
	.b(cage1_2),
	.d(cindex1_1),
	.e(cindex1_2),
	.c(cage2_1),
	.d(cindex2_1)
	);
wire [`RRF_SEL-1:0] cage2_2;
wire [2:0] cindex2_2;
compare compare2(
	.a(cage1_3),
	.b(cage1_4),
	.d(cindex1_2),
	.e(cindex1_3),
	.c(cage2_2),
	.d(cindex2_2)
	);
//选择有age
wire wire [`RRF_SEL-1:0] cage3_1;
mux_4 mux_age1(
	.a(rdy1_0),
	.b(rdy1_1),
	.win1(cage1_2),
	.win2(cage1_1),
	.win3(cage2_1),
	.cou(cage3_1)
	);
wire wire [`RRF_SEL-1:0] cage3_2;
mux_4 mux_age2(
	.a(rdy1_2),
	.b(rdy1_3),
	.win1(cage1_3),
	.win2(cage1_2),
	.win3(cage2_2),
	.cou(cage3_2)
	);
//地址索引传递
wire [2:0] cindex3_1;
mux_4 mux_index1(
	.a(rdy1_0),
	.b(rdy1_1),
	.win1(cindex1_2),
	.win2(cindex1_1),
	.win3(cindex2_1),
	.cou(cindex3_1)
	);
wire [2:0] cindex3_2;
mux_4 mux_age2(
	.a(rdy2),
	.b(rdy3),
	.win1(index1_3),
	.win2(index1_2),
	.win3(cindex2_2),
	.cou(cindex3_2)
	);
wire rdy2_0;
wire rdy2_1;
assign rdy2_0 = rdy1_0 || rdy1_1;
assign rdy2_1 = rdy1_2 || rdy1_3; 
/*---------------------------------
//         第二级仲结束
----------------------------------*/

/*---------------------------------
//         第三级仲开始
----------------------------------*/
//年龄大小比较
wire [`RRF_SEL-1:0] cage3_0;
wire [2:0] cindex3_0;
compare compare1(
	.a(cage3_1),
	.b(cage3_2),
	.d(cindex3_1),
	.e(cindex3_2),
	.c(cage3_0),
	.d(cindex3_0)
	);
//选择有age
wire [`RRF_SEL-1:0] cage3;
mux_4 mux_age1(
	.a(rdy2_0),
	.b(rdy2_1),
	.win1(cage2_2),
	.win2(cage2_1),
	.win3(cage3_0),
	.cou(cage3)
	);
//地址索引传递
wire [2:0] cindex3;
mux_4 mux_index1(
	.a(rdy2_0),
	.b(rdy2_1),
	.win1(cindex2_2),
	.win2(cindex2_1),
	.win3(cindex3_0),
	.cou(cindex3)
	);

assign grant = rdy2_0 || rdy2_1;
/*---------------------------------
//         第三级仲结束
----------------------------------*/

endmodule 
//数值小的，年龄老
module compare(
	input wire [5:0] a,
	input wire [5:0] b,
	input wire [2:0] d,
	input wire [2:0] e,
	output wire [5:0] c,
	output wire [2:0] d
	);
assign c = (a>b)?b:a;
assign d = (a>b)?e:d;
endmodule

module mux_4(
	input wire a,
	input wire b,
	input [5:0] win1,
	input [5:0] win2,
	input [5:0] win3,
	output [5:0] cout
	);
always @()
begin
	case({a,b}):
		2'b00:cout = 6'bz;
		2'b01:cout = win1;
		2'b10:cout = win2;
		2'b11:cout = win3;
	default:cout = 6'bz;
    endcase 
end

endmodule