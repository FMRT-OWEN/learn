`include "constants.vh"
`include "alu_ops.vh"
`include "rv32_opcodes.vh"
`default_nettype non
//加一个延迟唤醒逻辑电路
module Rs_alu_en(
   input wire clk,
   input wire rst,
   input wire busy,
   //分支预测单元,
   input wire                              prmiss,
   input wire                              prsuccess,
   input wire [`SPECTAG_LEN-1:0]           prtag,//输入的清除匹配标签
   input wire [`SPECTAG_LEN-1:0]           specfixtag,
   //
   input wire fu,
   //
   input wire clear_busy,
   //
   input wire we,
   //
   input wire [`ALU_ENT_SEL-1:0] waddr,
   //
   input wire [4:0] wsrc1,
   input wire [4:0] wsrc2,
   //
   input wire [`ADDR_LEN-1:0] wpc,
   //Valid 标记操作数是否就绪
   input wire [1:0]           wvalid1,
   input wire [1:0]           wvalid2,
   //
   input wire [`DATA_LEN-1:0] wimm,
   //
   input wire wdstval,
   //
   input wire [`ALU_OP_WIDTH-1:0] walu_op,  
   //
   input wire [`SPECTAG_LEN-1:0] wspectag,
   //
   input wire [`RRF_SEL-1:0] wrrftag,
   //
   input wire wfu,
   //
   input wire [`DLAY_WAKE_UP-1:0] wdy,
   //
/*-------------------------------------------*/ 
   //唤醒电路输入信号，置valid和bypass
   input wire [1:0]           ivalid1,
   input wire [1:0]           ivalid2,
/*-------------------------------------------*/
   output wire                        ready,
   output reg  [`ADDR_LEN-1:0]        pc,
   output reg  [`DATA_LEN-1:0]        imm,
   output reg  [`RRF_SEL-1:0]         rrftag,
   output reg                         dstval,
   output reg  [5:0]                  src_a,//
   output reg  [5:0]                  src_b,
   output wire                        fu,
   output wire                        bypass_1,
   output wire                        bypass_2,
   output reg  [`ALU_OP_WIDTH-1:0]    alu_op,
   output reg  [`SPECTAG_LEN-1:0]     spectag,
   output wire [`DLY_LEN-1:0]         delay
   );

   reg [`ALU_ENT_NUM-1:0]        specbitvec;
   reg [`ALU_ENT_NUM-1:0]        sortbit;

/*--------------------------------*/
   //存储单元
   reg [4:0] src1_m [15:0];
   reg [4:0] sec2_m [15:0];
   reg valid1_m [15:0];
   reg valid2_m [15:0];
   reg ready_m  [15:0];
   reg fu_m     [15:0];
   reg [5:0] age_m [15:0];
   reg [] op_m  [15:0]; //
   reg [31:0] imm_m [15:0];
   reg [31:0] pc_m [15:0];
   reg dstval_m [15:0];
   reg [4:0] spec_tag_m [15:0];
   reg [4:0] delay_m [15:0];
   reg bypass_m [15:0];
/*-------------------------------*/
assign ready = busy & Valid1[1] & Valid2[1];
assign bypass_1 = Valid1[0];
assign bypass_2 = Valid2[0];


always @(posedge clk)
begin
   if(!rst)
      begin
         pc        <= 0;
         imm       <= 0;
         rrftag    <= 0;
         dstval    <= 0;
         src_a     <= 0;
         src_b     <= 0;
         alu_op    <= 0;
         spectag   <= 0; 
      end
   else if(we)
      begin
         pc_m[waddr]     <= wpc;
         imm[waddr]      <= wimm;
         rrftag[waddr]   <= wrrftag;
         dstval[waddr]   <= wdstva;
         src_a[waddr]    <= wsrc1;
         src_b[waddr]    <= wsrc2;
         alu_op[waddr]   <= walu_op;
         spectag[waddr]  <= wspectag;
      end
   else 
      begin
         pc      <= pc;
         imm     <= imm;
         rrftag  <= rrftag;
         dstval  <= dstval;
         src_a   <= src_a;
         src_b   <= src_b;
         alu_op  <= alu_op;
         spectag <= spectag;
      end
end 
//只有Prscuccess 成功的，不需要进行比较，DP预测判断一次，发射预测一次。
//这个prsuccess是发射时候输入的，
assign alu_op = (prsuccess == 1'b1)?alu_op:'b0;
//这个用于清除
assign alu_op = (spectag == prtag)?'b0:alu_op;
/*----------------------------------------------------*/
always @(posedge clk)
begin
  if(we)
  begin
    src1_m[waddr] <= wsrc1;
    src2_m[waddr] <= wsrc2;
    valid1_m[waddr] <= wvalid1; //2
    valid2_m[waddr] <= wvalid2; //3
    fu_m[waddr] <= wfu;
    age_m[waddr] <= wrrftag;
    op_m[waddr] <= walu_op;
    imm_m[waddr] <= wimm;       //
    pc_m[waddr] <= wpc;         //1
    dstval_m[waddr] <= wdstva;
    spec_tag_m[waddr] <= wspectag;
    delay_m[waddr] <= wdy;
  end
  else
  begin
    src1_m[waddr] <= src1_m[waddr];
    src2_m[waddr] <= src2_m[waddr];
    valid1_m[waddr] <= valid1_m[waddr];
    valid2_m[waddr] <= valid2_m[waddr];
    fu_m[waddr] <= fu_m[waddr];
    age_m[waddr] <= age_m[waddr];
    op_m[waddr] <= op_m[waddr];
    imm_m[waddr] <= imm_m[waddr];       //
    pc_m[waddr] <= pc_m[waddr];         //1
    dstval_m[waddr] <= dstval_m[waddr];
    spec_tag_m[waddr] <= spec_tag_m[waddr];
    delay_m[waddr] <= delay_m[waddr];
  end
end



module rs_alu
  (
   //System
   input wire                              clk,
   input wire                              rst,
   //分配单元
   output reg                              busy,
   input wire [`ALU_LEN-1:0]               wpc,
   //分支预测单元,这玩意DP后都应该有
   input wire                              prmiss,
   input wire                              prsuccess,
   input wire [`SPECTAG_LEN-1:0]           prtag,
   input wire [`SPECTAG_LEN-1:0]           specfixtag,
   //与分配单元例化
   input wire fu_1,//deter the alu
   input wire fu_2,
   //WriteSignal
   input wire                              clear_busy, //Issue
   //input wire [`ALU_ENT_SEL-1:0]           issueaddr,
   input wire                              we1, //alloc1
   input wire                              we2, //alloc2
   input wire [`ALU_ENT_SEL-1:0]           waddr1, //allocent1
   input wire [`ALU_ENT_SEL-1:0]           waddr2, //allocent2
   input wire [4:0]                        src_a_1,//register id
   input wire [4:0]                        src_b_1,

   input wire [4:0]                        src_a_2,//register id
   input wire [4:0]                        src_b_2,
   //这是啥？
   output wire [`ALU_ENT_NUM*(`RRF_SEL+2)-1:0] histvect,
   input wire                              nextrrfcyc, 
   //WriteSignal1
   input wire [`ADDR_LEN-1:0]              wpc_1,
   input wire                              wvalid1_1,
   input wire                              wvalid2_1,
   input wire [`DATA_LEN-1:0]              wimm_1,
   input wire                              wdstval_1,//确定是否需要写回目的寄存器
   input wire [`ALU_OP_WIDTH-1:0]          walu_op_1,
   input wire [`SPECTAG_LEN-1:0]           wspectag_1,
   input wire                              wspecbit_1,
   input wire [`RRF_SEL-1:0]               wrrftag_2, //保留站的年龄信息
   input wire                              fu_2,//define the fu to 0
   input wire [`DLAY_WAKE_UP-1:0]          dy_1,//delay wake up data
   input wire                              bypass_1,//操作数可以通过转发获得信号，发射后为1的可以通过旁路转发获得操作数
   //WriteSignal2
   input wire [`ADDR_LEN-1:0]              wpc_2,
   input wire                              wvalid1_2,
   input wire                              wvalid2_2,
   input wire [`DATA_LEN-1:0]              wimm_2,
   input wire                              wdstval_2,
   input wire [`ALU_OP_WIDTH-1:0]          walu_op_2,
   input wire [`SPECTAG_LEN-1:0]           wspectag_2,
   input wire                              wspecbit_2,
   input wire [`RRF_SEL-1:0]               wrrftag_2,//保留站的年龄信息
   input wire                              fu_1,//define the fu t0 1
   input wire [`DLAY_WAKE_UP-1:0]          dy_2,//delay wake up data
   input wire                              bypass_2,//操作数可以通过转发获得信号，发射后为1的可以通过旁路转发获得操作数
   //ReadSignal
   output wire                             ready,
   output wire [`ADDR_LEN-1:0]             pc1,
   output wire [`ADDR_LEN-1:0]             pc2,
   output wire [`DATA_LEN-1:0]             imm1,
   output wire [`DATA_LEN-1:0]             imm2,
   output wire [`RRF_SEL-1:0]              rrftag1,
   output wire [`RRF_SEL-1:0]              rrftag1,
   output wire                             dstval,
   output wire                             dstva2,
   output wire [4:0]                       src_a_1,//
   output wire [4:0]                       src_b_1,
   output wire [4:0]                       src_a_2,
   output wire [4:0]                       src_b_2,//
   output wire                             fu_1,//
   output wire                             fu_2,//
   output wire                             bypass,//
   output wire [`ALU_OP_WIDTH-1:0]         alu_op,
   output wire [`SPECTAG_LEN-1:0]          spectag,
   output wire [`DLY_LEN-1:0]              delay  //执行周期数-1
   //output wire                             specbit
   );

   reg [`ALU_ENT_NUM-1:0]        specbitvec;
   reg [`ALU_ENT_NUM-1:0]        sortbit;

 
rs_alu_ent ent0(
       .clk(clk),
       .reset(reset),
       .busy(busy),
       .wpc(wpc_1),
       .wvalid1(wvalid1_1),
       .wvalid2(wvalid2_1),
       .wimm(wimm_1),
       .wrrftag(wrrftag_1),
       .wsrc_a(wsrc_a_1),
       .wsrc_b(wsrc_b_1),
       .walu_op(walu_op_1),
       .wdstval(wdstval_1),
       .wspectag(wspectag_1),
       .we(we1),
       .ready(ready),
       .pc(pc),
       .imm(imm),
       .rrftag(rrftag),
       .dstval(dstval),
       .src_a(src_a_1),
       .src_b(src_b_1),
       .alu_op(alu_op),
       .spectag(spectag),
       .delay(dy)
       );
rs_alu_ent ent1(
       .clk(clk),
       .reset(reset),
       .busy(busy),
       .wpc(wpc_2),
       .wvalid1(wvalid1_2),
       .wvalid2(wvalid2_2),
       .wimm(wimm_2),
       .wrrftag(wrrftag_2),
       .wsrc_b(wsrc_b_2),
       .walu_op(walu_op_1),
       .wdstval(wdstval_1),
       .wsrc_a(wsrc_a_1),
       .wspectag(wspectag_1),
       .we(we1),
       .ready(ready),
       .pc(pc),
       .imm(imm),
       .rrftag(rrftag),
       .dstval(dstval),
       .src_a(src_a_1),
       .src_b(src_b_1),
       .alu_op(alu_op),
       .spectag(spectag),
       .delay(dy)
       );
   //发出
   assign busy = prsuccess ? 
          specbitvec_next[issueaddr] : specbitvec[issueaddr];
   assign 
   
endmodule // rs_alu
`default_nettype wire













   

