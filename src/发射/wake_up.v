`include "./"
`include "./"
module wake_up(
	//tag compare
	input wire [4:0] tag_alu1,
	input wire [4:0] tag_alu2,
	input wire [4:0] tag_bra,
	input wire [4:0] tag_ldst,
	input wire [4:0] tag_mul,
	//delay instruction cycles
	input wire [`DLY_LEN-1:0] delay_alu1,
	input wire [`DLY_LEN-1:0] delay_alu2,
	input wire [`DLY_LEN-1:0] delay_bra,
	input wire [`DLY_LEN-1:0] delay_ldst,
	input wire [`DLY_LEN-1:0] delay_mul,
	//0
	// output wire  rdyl0_0,
	// output wire  rdyr0_1,
	// //1
	// output wire  rdyl1_0,
	// output wire  rdyr1_1,
	// //2
	// output wire  rdyl2_0,
	// output wire  rdyr2_1,
	// //3
	// output wire  rdyl3_0,
	// output wire  rdyr3_1,
	// //4
	// output wire  rdyl4_0,
	// output wire  rdyr4_1,
	// //5
	// output wire  rdyl5_0,
	// output wire  rdyr5_1,
	// //6
	// output wire  rdyl6_0,
	// output wire  rdyr6_1,
	// //7
	// output wire  rdyl7_0,
	// output wire  rdyr7_1,
	/*------------------------------*/
	//移位使能信号
	output wire shift_0_0,
	output wire shift_0_1,
	//
	output wire shift_1_0,
	output wire shift_1_1,
	//
	output wire shift_2_0,
	output wire shift_2_1,
	//
	output wire shift_3_0,
	output wire shift_2_1,
	//
	output wire shift_4_0,
	output wire shift_4_1,
	//
	output wire shift_5_0,
	output wire shift_5_1,
	//
	output wire shift_6_0,
	output wire shift_6_1,
	//
	output wire shift_7_0,
	output wire shift_7_1
	);


//这是一个ALU RS一个表象的匹配
//alu -0
wire  [2:0] a0;
wire  [2:0] a1;
wire  [7:0] srcl_shift_0_0;
wire  [7:0] srcR_shift_0_1;
assign a0 = (src1_m[3'b000] == tag_alu1)?4'b1000:
			(src1_m[3'b000] == tag_alu2)?4'b1001:
            (src1_m[3'b000] == tag_bra)?4'b1010:
            (src1_m[3'b000] == tag_ldst)?4'b1011:
            (src1_m[3'b000] == tag_mul)?4'b1100:4'b0000;

assign a1 = (src1_m[3'b000] == tag_alu1)?4'b1000:
			(src1_m[3'b000] == tag_alu2)?4'b1001:
            (src1_m[3'b000] == tag_bra)?4'b1010:
            (src1_m[3'b000] == tag_ldst)?4'b1011:
            (src1_m[3'b000] == tag_mul)?4'b1100:4'b0000;

//ready 信号 
assign rdyl0_0 = srcl_shift_0_0[0];
assign rdyr0_1 = srcR_shift_0_1[0];
//移位使能信号，当为1的时候，控制移位，直到被仲裁电路选中
assign shift_0_0 = a0[3];
assign shift_0_1 = a1[3];
//request 请求
assign req0 = (busy0 && ~issude0 && rdyl0_0 && rdyr0_1);
//选择延迟寄存器写入值
mux5 rs_alu0(
	.d0(delay_alu1),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(a0),
	.y(srcl_shift_0_0)
	);
mux5 rs_alu1(
	.d0(delay_alu1),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(a1),
	.y(srcR_shift_0_1)
	);

//alu -1
wire [2:0] a2;
wire [2:0] a3;
wire [7:0] srcl_shift_1_0;
wire [7:0] srcR_shift_1_1;
assign a2 = (src1_m[3'b001] == tag_alu1)?4'b1000:
			(src1_m[3'b001] == tag_alu2)?4'b1001:
            (src1_m[3'b001] == tag_bra)?4'b1010:
            (src1_m[3'b001] == tag_ldst)?4'b1011:
            (src1_m[3'b00] == tag_mul)?4'b1100:4'b0000;


assign a3 = (src1_m[3'b001] == tag_alu1)?4'b1000:
			(src1_m[3'b001] == tag_alu2)?4'b1001:
            (src1_m[3'b001] == tag_bra)?4'b1010:
            (src1_m[3'b001] == tag_ldst)?4'b1011:
            (src1_m[3'b001] == tag_mul)?4'b1100:4'b0000;

//ready 信号
assign rdyl1_0 = srcl_shift_1_0[0];
assign rdyr1_1 = srcR_shift_1_1[0];
//移位使能信号，当为1的时候，控制移位，直到被仲裁电路选中
assign shift_1_0 = a2[3];//SrcL_M
assign shift_1_1 = a3[3];//SrcR_M
//request 请求
assign req1 = (busy1 && ~issude1 && rdyl1_0 && rdyr1_1 && );
//选择延迟寄存器写入值
mux5 rs_alu2(
	.d0(delay_alu1),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(a2),
	.y(srcl_shift_1_0)
	);
mux5 rs_alu3(
	.d0(delay_alu1),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(a3),
	.y(srcR_shift_1_1)
	);

//alu -2
wire [2:0] a4;
wire [2:0] a5;
wire [7:0] srcl_shift_2_0;
wire [7:0] srcR_shift_2_1;
assign a4 = (src1_m[3'b010] == tag_alu1)?4'b1000:
			(src1_m[3'b010] == tag_alu2)?4'b1001:
            (src1_m[3'b010] == tag_bra)?4'b1010:
            (src1_m[3'b010] == tag_ldst)?4'b1011:
            (src1_m[3'b010] == tag_mul)?4'b1100:4'b0000;

assign a5 = (src1_m[3'b0010] == tag_alu1)?4'b1000:
			(src1_m[3'b0010] == tag_alu2)?4'b1001:
            (src1_m[3'b0010] == tag_bra)?4'b1010:
            (src1_m[3'b0010] == tag_ldst)?4'b1011:
            (src1_m[3'b0010] == tag_mul)?4'b1100:4'b0000;

//ready 信号
assign rdyl2_0 = srcl_shift_2_0;
assign rdyr2_1 = srcR_shift_2_1;
//移位使能信号，当为1的时候，控制移位，直到被仲裁电路选中
assign shift_2_0 = a4[3];
assign shift_2_1 = a5[3];
//request 请求
assign req2 = (busy2 && ~issude2 && rdyl2_0 && rdyr2_1);
//选择延迟寄存器写入值
mux5 rs_alu4(
	.d0(delay_alu1),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(a5),
	.y(d5)
	);
mux5 rs_alu5(
	.d0(delay_alu1),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(srcR_shift_2_0),
	.y(srcR_shift_2_1)
	);

// -3
wire [2:0] a6;
wire [2:0] a7;
wrie [7:0] srcl_shift_3_0;
wire [7:0] srcR_shift_3_1;

assign a6 = (src1_m[3'b011] == tag_alu1)?4'b1000:
			(src1_m[3'b011] == tag_alu2)?4'b1001:
            (src1_m[3'b011] == tag_bra)?4'b1010:
            (src1_m[3'b011] == tag_ldst)?4'b1011:
            (src1_m[3'b011] == tag_mul)?4'b1100:4'b0000;

assign a7 = (src1_m[3'b011] == tag_alu1)?4'b1000:
			(src1_m[3'b011] == tag_alu2)?4'b1001:
            (src1_m[3'b011] == tag_bra)?4'b1010:
            (src1_m[3'b011] == tag_ldst)?4'b1011:
            (src1_m[3'b011] == tag_mul)?4'b1100:4'b0000;

//ready 信号
assign rdyl3_0 = srcl_shift_3_0[0];
assign rdyr3_1 = srcR_shift_3_1[0];
//移位使能信号，当为1的时候，控制移位，直到被仲裁电路选中
assign shift_3_0 = a6[3];
assign shift_3_1 = a7[3];
//request 请求
assign req3 = (busy3 && ~issude3 && rdyl3_0 && rdyr3_1);
//选择延迟寄存器写入值
mux5 rs_alu6(
	.d0(delay_alu1),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(a6),
	.y(srcl_shift_3_0)
	);
mux5 rs_alu7(
	.d0(delay_alu1),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(a7),
	.y(srcR_shift_3_1)
	);

// -4
wire [2:0] a8;
wire [2:0] a9;
wire [7:0] srcl_shift_4_0;
wire [7:0] srcR_shift_4_1;

assign a8 = (src1_m[3'b100] == tag_alu1)?4'b1000:
			(src1_m[3'b100] == tag_alu2)?4'b1001:
            (src1_m[3'b100] == tag_bra)?4'b1010:
            (src1_m[3'b100] == tag_ldst)?4'b1011:
            (src1_m[3'b100] == tag_mul)?4'b1100:4'b0000;


assign a9 = (src1_m[3'b100] == tag_alu1)?4'b1000:
			(src1_m[3'b100] == tag_alu2)?4'b1001:
            (src1_m[3'b100] == tag_bra)?4'b1010:
            (src1_m[3'b100] == tag_ldst)?4'b1011:
            (src1_m[3'b100] == tag_mul)?4'b1100:4'b0000;

//ready 信号
assign rdyl4_0 = srcl_shift_4_0[0];
assign rdyr4_1 = srcR_shift_4_1[0];
//移位使能信号，当为1的时候，控制移位，直到被仲裁电路选中
assign shift_4_0 = a8[3];
assign shift_4_1 = a9[3];
//request 请求
assign req4 = (busy4 && ~issude4 && rdyl4_0 && rdyr4_1);
//选择延迟寄存器写入值
mux6 rs_alu8(
	.d0(delay_alu1),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(a8),
	.y(srcl_shift_4_0)
	);
mux5 rs_alu9(
	.d0(delay_alu),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(a9),
	.y(srcR_shift_4_1)
	);

// -5
wire [2:0] a10;
wire [2:0] a11;
wire [7:0] srcl_shift_5_0;
wire [7:0] srcR_shift_5_1;

assign a10 =(src1_m[3'b101] == tag_alu1)?4'b1000:
			(src1_m[3'b101] == tag_alu2)?4'b1001:
            (src1_m[3'b101] == tag_bra)?4'b1010:
            (src1_m[3'b101] == tag_ldst)?4'b1011:
            (src1_m[3'b101] == tag_mul)?4'b1100:4'b0000;


assign a11 =(src1_m[3'b101] == tag_alu1)?4'b1000:
			(src1_m[3'b101] == tag_alu2)?4'b1001:
            (src1_m[3'b101] == tag_bra)?4'b1010:
            (src1_m[3'b101] == tag_ldst)?4'b1011:
            (src1_m[3'b101] == tag_mul)?4'b1100:4'b0000;

//ready 信号
assign rdyl10_0 = srcl_shift_5_0[0];
assign rdyr11_1 = srcR_shift_5_1[0];
//移位使能信号，当为1的时候，控制移位，直到被仲裁电路选中
assign shift_5_0 = a10[3];
assign shift_5_1 = a11[3];
//request 请求
assign req5 = (busy5 && ~issude5 && rdyl5_0 && rdyr5_1);
//选择延迟寄存器写入值
mux5 rs_alu10(
	.d0(delay_alu1),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(a10),
	.y(srcl_shift_5_0)
	);
mux5 rs_alu11(
	.d0(delay_alu),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(a11),
	.y(srcR_shift_5_1)
	); 

// -6
wire [2:0] a12;
wire [2:0] a13;
wire [7:0] srcl_shift_6_0;
wire [7:0] srcR_shift_6_1;

assign a12 =(src1_m[3'b110] == tag_alu1)?4'b1000:
			(src1_m[3'b110] == tag_alu2)?4'b1001:
            (src1_m[3'b110] == tag_bra)?4'b1010:
            (src1_m[3'b110] == tag_ldst)?4'b1011:
            (src1_m[3'b110] == tag_mul)?4'b1100:4'b0000;


assign a13 =(src1_m[3'b110] == tag_alu1)?4'b1000:
			(src1_m[3'b110] == tag_alu2)?4'b1001:
            (src1_m[3'b110] == tag_bra)?4'b1010:
            (src1_m[3'b110] == tag_ldst)?4'b1011:
            (src1_m[3'b110] == tag_mul)?4'b1100:4'b0000;


//ready 信号
assign rdyl6_0 = srcl_shift_6_0[0];
assign rdyr6_1 = srcR_shift_6_1[0];
//移位使能信号，当为1的时候，控制移位，直到被仲裁电路选中
assign shift_6_0 = a12[3];
assign shift_6_1 = a13[3];
//request 请求
assign req6 = (busy6 && ~issude6 && rdyl6_0 && rdyr6_1);
//选择延迟寄存器写入值
mux5 rs_alu12(
	.d0(delay_alu1),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(a12),
	.y(srcl_shift_6_0)
	);
mux5 rs_alu13(
	.d0(delay_alu),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(a13),
	.y(srcR_shift_6_1)
	); 

// -7
wire [2:0] a14;
wire [2:0] a15;
wire [7:0] srcl_shift_7_0;
wire [7:0] srcR_shift_7_1;

assign a14 =(src1_m[3'b111] == tag_alu1)?4'b1000:
			(src1_m[3'b111] == tag_alu2)?4'b1001:
            (src1_m[3'b111] == tag_bra)?4'b1010:
            (src1_m[3'b111] == tag_ldst)?4'b1011:
            (src1_m[3'b111] == tag_mul)?4'b1100:4'b0000;


assign a15 =(src1_m[3'b111] == tag_alu1)?4'b1000:
			(src1_m[3'b111] == tag_alu2)?4'b1001:
            (src1_m[3'b111] == tag_bra)?4'b1010:
            (src1_m[3'b111] == tag_ldst)?4'b1011:
            (src1_m[3'b111] == tag_mul)?4'b1100:4'b0000;
                               

//ready 信号
assign rdyl7_0 = srcl_shift_7_0[0];
assign rdyr7_1 = srcR_shift_7_1[0];
//移位使能信号，当为1的时候，控制移位，直到被仲裁电路选中
assign shift_7_0 = a14[3];
assign shift_7_1 = a15[3];
//request 请求
assign req7 = (busy7 && ~issude7 && rdyl7_0 && rdyr7_1);
//选择延迟寄存器写入值
mux5 rs_alu14(
	.d0(delay_alu1),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(a14),
	.y(srcl_shift_7_0)
	);
mux5 rs_alu15(
	.d0(delay_alu1),
	.d1(delay_bra),
	.d2(delay_ldst),
	.d3(delay_mul),
	.d4(delay_alu2),
	.s(a15),
	.y(srcR_shift_7_1)
	);

endmodule 