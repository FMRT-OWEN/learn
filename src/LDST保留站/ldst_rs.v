`include "constants.vh"
`include "yasuo.v"
`default_nettype none
module rs_ldst_ent
  (
   //这个仲裁电路信号有待确定
   input wire index,
   input grant,
   //
   input wire 			 clk,
   input wire 			 rst,
   input wire 			 wbusy,
   //分支预测单元
   input wire                              Prsuccess,
   input wire [`SPECTAG_LEN-1:0]           prtag,//执行单元执行完bra之后发出的信号
   //分支预测失败后，将当前标签存在先后顺序的tag
   input wire [`SPECTAG_LEN-1:0]           specfixtag,
   //
   input wire clear_busy,//发射后清除
   //
   input wire we,
   //
   input wire [`LDST_ENT_SEL-1:0] waddr,
   //
   input wire [5:0] 	 wsrc1,
   input wire [5:0] 	 wsrc2,
   //
   input wire [`DATA_LEN-1:0] wimm,
   input wire Imm_valid,
   //
   input wire wdest_valid,//目的寄存器有效信号
   input wire [5:0] dest,//目的寄存器编号
   //
   input wire [`ALU_OP_WIDTH-1:0] wldst_op,
   //
   input wire [`SPECTAG_LEN-1:0] wspectag,
   input wire wspecbit,//推测值，比较是否为推测指令，与spectag同款 
   //
   input wire [`RRF_SEL-1:0] wage,
   //
   input wire [`DLAY_WAKE_UP-1:0] wdelay
   //
   output wire busy,//用于查找空闲表象
   //
   output reg  [5:0] src_a,
   output reg  [5:0] src_b,
   output reg  [`DATA_LEN-1:0] 	 imm,
   output reg  [`RRF_SEL-1:0] 	 rrftag,
   output reg 			 dstval,
   output wrie  [5:0]    dest,//被仲裁选中的时候发射到tag——bus
   output reg [1:0] Type,//

   output reg  [`ALU_OP_WIDTH-1:0]    fu_op,

   output reg [`SPECTAG_LEN-1:0] spectag
   output reg                    specbit,//写入到rob中，用于提交

   output wire [7:0]             delay_ldst //这个值不用，只有等到确定hit的情况下才发出
   );


  /*--------------------------------*/
   //存储单元
   reg [0:0] busym         [7:0];
   //reg [0:0] issuedm       [7:0];
   reg [5:0] srcLm         [7:0];
   reg [0:0] srcL_mm       [7:0];//移位使能
   reg [7:0] srcL_shiftm   [7:0];
   reg [5:0] srcRm         [7:0];
   reg [0:0] srcR_mm       [7:0];
   reg [7:0] srcR_shiftm   [7:0];
   reg [31:0] imm          [7:0];
   reg [5:0] destm         [7:0];
   reg [0:0] dstvalm       [7:0];
   reg [7:0] delaym        [7:0];
   reg [5:0] agem          [7:0];
   reg [4:0] spec_tagm     [7:0];
   reg [0:0] specbitm      [7:0];
   reg [`] fu_opm          [7:0]; 
/*----------------------------------------------------*/


   //
   always @ (posedge clk) begin
      if (!rst) begin
	 imm <= 0;
	 rrftag <= 0;
	 dstval <= 0;
	 spectag <= 0;

	 src1 <= 0;
	 src2 <= 0;
	 valid1 <= 0;
	 valid2 <= 0;
      end else if (we) begin
	 imm <= wimm;
	 rrftag <= wrrftag;
	 dstval <= wdstval;
	 spectag <= wspectag;

	 src1 <= wsrc1;
	 src2 <= wsrc2;
	 valid1 <= wvalid1;
	 valid2 <= wvalid2;
      end else begin // if (we)
	 src1 <= nextsrc1;
	 src2 <= nextsrc2;
	 valid1 <= nextvalid1;
	 valid2 <= nextvalid2;
      end
   end
   
   
endmodule // rs_ldst


module rs_ldst
  (
   //System
   input wire 			   clk,
   input wire 			   reset,
   output reg [`LDST_ENT_NUM-1:0]  busyvec,
   input wire 			   prmiss,
   input wire 			   prsuccess,
   input wire [`SPECTAG_LEN-1:0] 	   prtag,
   input wire [`SPECTAG_LEN-1:0] 	   specfixtag,
   output wire [`LDST_ENT_NUM-1:0] prbusyvec_next,
   //WriteSignal
   input wire 			   clearbusy, //Issue 
   input wire [`LDST_ENT_SEL-1:0] 	   issueaddr, //= raddr, clsbsyadr
   input wire 			   we1, //alloc1
   input wire 			   we2, //alloc2
   input wire [`LDST_ENT_SEL-1:0] 	   waddr1, //allocent1
   input wire [`LDST_ENT_SEL-1:0] 	   waddr2, //allocent2
   //WriteSignal1
   input wire [`ADDR_LEN-1:0] 	   wpc_1,
   input wire [`DATA_LEN-1:0] 	   wsrc1_1,
   input wire [`DATA_LEN-1:0] 	   wsrc2_1,
   input wire 			   wvalid1_1,
   input wire 			   wvalid2_1,
   input wire [`DATA_LEN-1:0] 	   wimm_1,
   input wire [`RRF_SEL-1:0] 	   wrrftag_1,
   input wire 			   wdstval_1,
   input wire [`SPECTAG_LEN-1:0] 	   wspectag_1,
   input wire 			   wspecbit_1,
   //WriteSignal2
   input wire [`ADDR_LEN-1:0] 	   wpc_2,
   input wire [`DATA_LEN-1:0] 	   wsrc1_2,
   input wire [`DATA_LEN-1:0] 	   wsrc2_2,
   input wire 			   wvalid1_2,
   input wire 			   wvalid2_2,
   input wire [`DATA_LEN-1:0] 	   wimm_2,
   input wire [`RRF_SEL-1:0] 	   wrrftag_2,
   input wire 			   wdstval_2,
   input wire [`SPECTAG_LEN-1:0] 	   wspectag_2,
   input wire 			   wspecbit_2,

   //ReadSignal
   output wire [`DATA_LEN-1:0] 	   ex_src1,
   output wire [`DATA_LEN-1:0] 	   ex_src2,
   output wire [`LDST_ENT_NUM-1:0] ready,
   output wire [`ADDR_LEN-1:0] 	   pc,
   output wire [`DATA_LEN-1:0] 	   imm,
   output wire [`RRF_SEL-1:0] 	   rrftag,
   output wire 			   dstval,
   output wire [`SPECTAG_LEN-1:0]  spectag,
   output wire 			   specbit,
   //
   //发射后根据发射位置，产生相映的信号
   input wire issu_a,
   input wire issu_b,
   input wrie issu_c,
   input wrie issu_d
   );

//先压缩，后写入
//数据压缩式
  yasuo yasuo_busy(
   	.issu_a(issu_a),
   	.issu_b(issu_b),
   	.issu_c(issu_c),
   	.issu_d(issu_d),
    .data_a(),
    .data_b(),
    .data_c(),
    .data_d(),
    .data_out(),
    .odata_a(),
    .odata_b(),
    .odata_c(),
    .odata_d()
   	);
   
  yasuo yasuo_srcl(
   	.issu_a(issu_a),
   	.issu_b(issu_b),
   	.issu_c(issu_c),
   	.issu_d(issu_d),
    .data_a(),
    .data_b(),
    .data_c(),
    .data_d(),
    .data_out(),
    .odata_a(),
    .odata_b(),
    .odata_c(),
    .odata_d()
   	);
  yasuo yasuo_srcl_m(
   	.issu_a(issu_a),
   	.issu_b(issu_b),
   	.issu_c(issu_c),
   	.issu_d(issu_d),
    .data_a(),
    .data_b(),
    .data_c(),
    .data_d(),
    .data_out(),
    .odata_a(),
    .odata_b(),
    .odata_c(),
    .odata_d()
   	);
   yasuo yasuo_src_shift(
   	.issu_a(issu_a),
   	.issu_b(issu_b),
   	.issu_c(issu_c),
   	.issu_d(issu_d),
    .data_a(),
    .data_b(),
    .data_c(),
    .data_d(),
    .data_out(),
    .odata_a(),
    .odata_b(),
    .odata_c(),
    .odata_d()
   	);
  yasuo yasuo_srcr(
   	.issu_a(issu_a),
   	.issu_b(issu_b),
   	.issu_c(issu_c),
   	.issu_d(issu_d),
    .data_a(),
    .data_b(),
    .data_c(),
    .data_d(),
    .data_out(),
    .odata_a(),
    .odata_b(),
    .odata_c(),
    .odata_d()
   	);
  yasuo yasuo_srcr_m(
   	.issu_a(issu_a),
   	.issu_b(issu_b),
   	.issu_c(issu_c),
   	.issu_d(issu_d),
    .data_a(),
    .data_b(),
    .data_c(),
    .data_d(),
    .data_out(),
    .odata_a(),
    .odata_b(),
    .odata_c(),
    .odata_d()
   	);
  yasuo yasuo_srcr_shift(
   	.issu_a(issu_a),
   	.issu_b(issu_b),
   	.issu_c(issu_c),
   	.issu_d(issu_d),
    .data_a(),
    .data_b(),
    .data_c(),
    .data_d(),
    .data_out(),
    .odata_a(),
    .odata_b(),
    .odata_c(),
    .odata_d()
   	);

  yasuo yasuo_imm(
   	.issu_a(issu_a),
   	.issu_b(issu_b),
   	.issu_c(issu_c),
   	.issu_d(issu_d),
    .data_a(),
    .data_b(),
    .data_c(),
    .data_d(),
    .data_out(),
    .odata_a(),
    .odata_b(),
    .odata_c(),
    .odata_d()
   	);
  yasuo yasuo_delay(
   	.issu_a(issu_a),
   	.issu_b(issu_b),
   	.issu_c(issu_c),
   	.issu_d(issu_d),
    .data_a(),
    .data_b(),
    .data_c(),
    .data_d(),
    .data_out(),
    .odata_a(),
    .odata_b(),
    .odata_c(),
    .odata_d()
   	);
  yasuo yasuo_age(
   	.issu_a(issu_a),
   	.issu_b(issu_b),
   	.issu_c(issu_c),
   	.issu_d(issu_d),
    .data_a(),
    .data_b(),
    .data_c(),
    .data_d(),
    .data_out(),
    .odata_a(),
    .odata_b(),
    .odata_c(),
    .odata_d()
   	);
  yasuo yasuo_spec_tag(
   	.issu_a(issu_a),
   	.issu_b(issu_b),
   	.issu_c(issu_c),
   	.issu_d(issu_d),
    .data_a(),
    .data_b(),
    .data_c(),
    .data_d(),
    .data_out(),
    .odata_a(),
    .odata_b(),
    .odata_c(),
    .odata_d()
   	);
  yasuo yasuo_spec_bit(
   	.issu_a(issu_a),
   	.issu_b(issu_b),
   	.issu_c(issu_c),
   	.issu_d(issu_d),
    .data_a(),
    .data_b(),
    .data_c(),
    .data_d(),
    .data_out(),
    .odata_a(),
    .odata_b(),
    .odata_c(),
    .odata_d()
   	);
  yasuo yasuo_fu_op(
   	.issu_a(issu_a),
   	.issu_b(issu_b),
   	.issu_c(issu_c),
   	.issu_d(issu_d),
    .data_a(),
    .data_b(),
    .data_c(),
    .data_d(),
    .data_out(),
    .odata_a(),
    .odata_b(),
    .odata_c(),
    .odata_d()
   	);
 /*-------------------------------*/
                //over
 /*-------------------------------*/

  
   assign specbit = prsuccess ? 
		    specbitvec_next[issueaddr] : specbitvec[issueaddr];
   
   always @ (posedge clk) begin
      if (reset) begin
	 busyvec <= 0;
	 specbitvec <= 0;
      end else begin
	 if (prmiss) begin
	    busyvec <= prbusyvec_next;
	    specbitvec <= 0;
	 end else if (prsuccess) begin
	    specbitvec <= specbitvec_next;
	    if (clearbusy) begin
	       busyvec[issueaddr] <= 1'b0;
	    end
	 end else begin
	    if (we1) begin
	       busyvec[waddr1] <= 1'b1;
	       specbitvec[waddr1] <= wspecbit_1;
	    end
	    if (we2) begin
	       busyvec[waddr2] <= 1'b1;
	       specbitvec[waddr2] <= wspecbit_2;
	    end
	    if (clearbusy) begin
	       busyvec[issueaddr] <= 1'b0;
	    end
	 end
      end
   end

   rs_ldst_ent ent0(
		    .clk(clk),
		    .reset(reset),
		    .busy(busyvec[0]),
		    .wpc((we1 && (waddr1 == 0)) ? wpc_1 : wpc_2),
		    .wsrc1((we1 && (waddr1 == 0)) ? wsrc1_1 : wsrc1_2),
		    .wsrc2((we1 && (waddr1 == 0)) ? wsrc2_1 : wsrc2_2),
		    .wvalid1((we1 && (waddr1 == 0)) ? wvalid1_1 : wvalid1_2),
		    .wvalid2((we1 && (waddr1 == 0)) ? wvalid2_1 : wvalid2_2),
		    .wimm((we1 && (waddr1 == 0)) ? wimm_1 : wimm_2),
		    .wrrftag((we1 && (waddr1 == 0)) ? wrrftag_1 : wrrftag_2),
		    .wdstval((we1 && (waddr1 == 0)) ? wdstval_1 : wdstval_2),
		    .wspectag((we1 && (waddr1 == 0)) ? wspectag_1 : wspectag_2),
		    .we((we1 && (waddr1 == 0)) || (we2 && (waddr2 == 0))),
		    .ex_src1(ex_src1_0),
		    .ex_src2(ex_src2_0),
		    .ready(ready_0),
		    .pc(pc_0),
		    .imm(imm_0),
		    .rrftag(rrftag_0),
		    .dstval(dstval_0),
		    .spectag(spectag_0),
		    .exrslt1(exrslt1),
		    .exdst1(exdst1),
		    .kill_spec1(kill_spec1),
		    .exrslt2(exrslt2),
		    .exdst2(exdst2),
		    .kill_spec2(kill_spec2),
		    .exrslt3(exrslt3),
		    .exdst3(exdst3),
		    .kill_spec3(kill_spec3),
		    .exrslt4(exrslt4),
		    .exdst4(exdst4),
		    .kill_spec4(kill_spec4),
		    .exrslt5(exrslt5),
		    .exdst5(exdst5),
		    .kill_spec5(kill_spec5)
		    );

   rs_ldst_ent ent1(
		    .clk(clk),
		    .reset(reset),		    
		    .busy(busyvec[1]),
		    .wpc((we1 && (waddr1 == 1)) ? wpc_1 : wpc_2),
		    .wsrc1((we1 && (waddr1 == 1)) ? wsrc1_1 : wsrc1_2),
		    .wsrc2((we1 && (waddr1 == 1)) ? wsrc2_1 : wsrc2_2),
		    .wvalid1((we1 && (waddr1 == 1)) ? wvalid1_1 : wvalid1_2),
		    .wvalid2((we1 && (waddr1 == 1)) ? wvalid2_1 : wvalid2_2),
		    .wimm((we1 && (waddr1 == 1)) ? wimm_1 : wimm_2),
		    .wrrftag((we1 && (waddr1 == 1)) ? wrrftag_1 : wrrftag_2),
		    .wdstval((we1 && (waddr1 == 1)) ? wdstval_1 : wdstval_2),
		    .wspectag((we1 && (waddr1 == 1)) ? wspectag_1 : wspectag_2),
		    .we((we1 && (waddr1 == 1)) || (we2 && (waddr2 == 1))),
		    .ex_src1(ex_src1_1),
		    .ex_src2(ex_src2_1),
		    .ready(ready_1),
		    .pc(pc_1),
		    .imm(imm_1),
		    .rrftag(rrftag_1),
		    .dstval(dstval_1),
		    .spectag(spectag_1),
		    .exrslt1(exrslt1),
		    .exdst1(exdst1),
		    .kill_spec1(kill_spec1),
		    .exrslt2(exrslt2),
		    .exdst2(exdst2),
		    .kill_spec2(kill_spec2),
		    .exrslt3(exrslt3),
		    .exdst3(exdst3),
		    .kill_spec3(kill_spec3),
		    .exrslt4(exrslt4),
		    .exdst4(exdst4),
		    .kill_spec4(kill_spec4),
		    .exrslt5(exrslt5),
		    .exdst5(exdst5),
		    .kill_spec5(kill_spec5)
		    );

   
 wire [1:0] Type_0;
 wire [1:0] Type_0;
 wire [1:0] Type_0;
 wire [1:0] Type_0;

always @()
begin
	if()
endmodule // rs_ldst
`default_nettype wire
