`include "constants.vh"
`include "alu_ops.vh"
`include "rv32_opcodes.vh"
`include "kill_gen.v"
`default_nettype non
//加一个延迟唤醒逻辑电路
module Rs_alu_en(
   input wire index,
   input grant,
   //               
   input wire clk,
   input wire rst,
   input wire wbusy,//可以分配，则置为1
   //分支预测单元,
   //input wire                              Prmiss,
   input wire                              Prsuccess,
   input wire [`SPECTAG_LEN-1:0]           prtag,//执行单元执行完bra之后发出的信号
   //分支预测失败后，将当前标签存在先后顺序的tag
   input wire [`SPECTAG_LEN-1:0]           specfixtag,
   //
   input wire clear_busy,//发射后清除
   //
   input wire we,
   //
   input wire [`ALU_ENT_SEL-1:0] waddr,
   //
   input wire [5:0] wsrc1,
   input wire [5:0] wsrc2,
   //
   //input wire [`ADDR_LEN-1:0] wpc,//先留着
   //
   input wire [`DATA_LEN-1:0] wimm,
   input wire Imm_valid,
   //
   input wire wdest_valid,//目的寄存器有效信号
   input wire [5:0] dest,//目的寄存器编号
   //
   input wire [`ALU_OP_WIDTH-1:0] walu_op,  
   //
   input wire [`SPECTAG_LEN-1:0] wspectag,
   input wire wspecbit,//推测值，比较是否为推测指令，与spectag同款
   //
   input wire [`RRF_SEL-1:0] wage,
   //
   input wire wfu,
   //
   input wire [`DLAY_WAKE_UP-1:0] wdelay,//延迟唤醒的指令周期数编码，为指令执行周期数减一，单周期则为全一
   //
/*-------------------------------------------*/ 
 
   output wire busy,//用于分配单元
   //
   output reg  [5:0]                  src_a,
   output reg  [5:0]                  src_b,
   output reg  [`DATA_LEN-1:0]        imm,
   output wrie [5:0]                  dest,//被仲裁选中的时候发射到tag——bus
   //output reg                         Rrf_we,//运算之写入到RRF
   output reg  [1:0]                  Type,//应该是指令类型，根据类型进行相应的动作
   //
   output reg  [`ALU_OP_WIDTH-1:0]    fu_op,
   output reg                         specbit,//写入到rob中，用于提交
   output reg  [4:0]                  spectag,
   //
   output wire [7:0]                  delay_alu,

  );
/*--------------------------------------*/
             //用于仲裁电路
/*--------------------------------------*/             
wire fu0;
wire fu1;
wire fu2;
wire fu3;
wire fu4;
wire fu5;
wire fu6;
wire fu7;

assign fu0 = fum[3'b000];
assign fu1 = fum[3'b001];
assign fu2 = fum[3'b010];
assign fu3 = fum[3'b011];
assign fu4 = fum[3'b100];
assign fu5 = fum[3'b101];
assign fu6 = fum[3'b110];
assign fu7 = fum[3'b111];

wire issued0;
wire issued1;
wire issued2;
wire issued3;
wire issued4;
wire issued5;
wire issued6;
wire issued7;

assign issued0 = issuedm[3'b000];
assign issued1 = issuedm[3'b001];
assign issued2 = issuedm[3'b010];
assign issued3 = issuedm[3'b011];
assign issued4 = issuedm[3'b100];
assign issued5 = issuedm[3'b101];
assign issued6 = issuedm[3'b110];
assign issued7 = issuedm[3'b111];
//0
wire rdy0_0;
wire rdy0_1;
//1
wire rdy1_0;
wire rdy1_1;
//2
wire rdy2_0;
wire rdy2_1;
//3
wire rdy3_0;
wire rdy3_1;
//4
wire rdy4_0;
wire rdy4_1;
//5
wire rdy5_0;
wire rdy5_1;
//6
wire rdy6_0;
wire rdy6_1;
//7
wire rdy7_0;
wire rdy7_1;
//0
wire rdy0_0 = srcL_shiftm[3'b000][0];
wire rdy0_1 = srcR_shiftm[3'b000][0];
//1
wire rdy1_0 = srcL_shiftm[3'b001][0];
wire rdy1_1 = srcR_shiftm[3'b001][0];
//2
wire rdy2_0 = srcL_shiftm[3'b010][0];
wire rdy2_1 = srcR_shiftm[3'b010][0];
//3
wire rdy3_0 = srcL_shiftm[3'b011][0];
wire rdy3_1 = srcR_shiftm[3'b011][0];
//4
wire rdy4_0 = srcL_shiftm[3'b100][0];
wire rdy4_1 = srcR_shiftm[3'b100][0];
//5
wire rdy5_0 = srcL_shiftm[3'b101][0];
wire rdy5_1 = srcR_shiftm[3'b101][0];
//6
wire rdy6_0 = srcL_shiftm[3'b110][0];
wire rdy6_1 = srcR_shiftm[3'b110][0];
//7
wire rdy7_0 = srcL_shiftm[3'b111][0];
wire rdy7_1 = srcR_shiftm[3'b111][0];
//
//目的寄存器tag
wire [5:0] dest0;
wire [5:0] dest1;
wire [5:0] dest2;
wire [5:0] dest3;
wire [5:0] dest4;
wire [5:0] dest5;
wire [5:0] dest6;
wire [5:0] dest7;

assign dest0 = destm[3'b000];
assign dest1 = destm[3'b001];
assign dest2 = destm[3'b010];
assign dest3 = destm[3'b011];
assign dest4 = destm[3'b100];
assign dest5 = destm[3'b101];
assign dest6 = destm[3'b110];
assign dest7 = destm[3'b111];
//目的寄存器有效标识
wire dstval0;
wire dstval1;
wire dstval2;
wire dstval3;
wire dstval4;
wire dstval5;
wire dstval6;
wire dstval7;

assign dstval0 = dstvalm[3'b000];
assign dstval1 = dstvalm[3'b001];
assign dstval2 = dstvalm[3'b010];
assign dstval3 = dstvalm[3'b011];
assign dstval4 = dstvalm[3'b100];
assign dstval5 = dstvalm[3'b101];
assign dstval6 = dstvalm[3'b110];
assign dstval7 = dstvalm[3'b111];

//延迟值
wire [7:0] delay0;
wire [7:0] delay1;
wire [7:0] delay2;
wire [7:0] delay3;
wire [7:0] delay4;
wire [7:0] delay5;
wire [7:0] delay6;
wire [7:0] delay7;

assign delay0 = delaym[3'b000];
assign delay1 = delaym[3'b001];
assign delay2 = delaym[3'b010];
assign delay3 = delaym[3'b011];
assign delay4 = delaym[3'b100];
assign delay5 = delaym[3'b101];
assign delay6 = delaym[3'b110];
assign delay7 = delaym[3'b111];
//年龄信息
 wire [`RRF_SEL-1:0] age0,
 wire [`RRF_SEL-1:0] age1,
 wire [`RRF_SEL-1:0] age2,
 wire [`RRF_SEL-1:0] age3,
 wire [`RRF_SEL-1:0] age4,
 wire [`RRF_SEL-1:0] age5,
 wire [`RRF_SEL-1:0] age6,
 wire [`RRF_SEL-1:0] age7,

assign age0 = agem[3'b000];
assign age1 = agem[3'b001];
assign age2 = agem[3'b010];
assign age3 = agem[3'b011];
assign age4 = agem[3'b100];
assign age5 = agem[3'b101];
assign age6 = agem[3'b110];
assign age7 = agem[3'b111];




   
/*--------------------------------*/
   //存储单元
   reg [0:0] busym         [7:0];
   reg [0:0] issuedm       [7:0];
   reg [5:0] srcLm         [7:0];
   reg [0:0] srcL_mm       [7:0];
   reg [7:0] srcL_shiftm   [7:0];
   reg [5:0] srcRm         [7:0];
   reg [0:0] srcR_mm       [7:0];
   reg [7:0] srcR_shiftm   [7:0];
   reg [31:0] imm          [7:0];
   reg [0:0] imm_validm    [7:0];
   reg [5:0] destm         [7:0];
   reg [0:0] dstvalm       [7:0];
   reg [7:0] delaym        [7:0];
   reg [5:0] agem          [7:0];
   reg [0:0]   fum         [7:0];
   reg [4:0] spec_tagm     [7:0];
   reg [0:0]     specbitm  [7:0];
   reg [`] fu_opm          [7:0]; 
/*----------------------------------------------------*/
                          //写入RS
/*----------------------------------------------------*/
always @(posedge clk)
begin
  if(we)
  begin
    busym[waddr]    <= wbusy;
    issuedm[waddr]  <= wissued;
    srcLm[waddr]    <= wsrc1;
    srcL_mm[waddr]  <= wsrcL_m;
    srcL_shiftm[waddr]     <= wsrcL_shift;
    srcRm[waddr]    <= wsrc2;
    srcR_mm[waddr]  <= wsrcR_m;
    srcR_shiftm[waddr]     <= wsrcR_shift;
    imm[waddr]      <= wimm;
    imm_validm[waddr] <= wimm_valid;
    destm[waddr]    <= wdest;
    dstvalm[waddr]  <= wdstva;
    delaym[waddr]   <= wdelay;
    agem[waddr]     <= wage;
    fum[waddr]      <= wfu;
    spec_tagm[waddr] <= wspec_tag;
    specbitm[waddr]  <= wspecbit;
    fu_opm[waddr]    <= wfu_op;
  end
  else
  begin
    busym[waddr]    <= busym[waddr];
    issuedm[waddr]  <= issuedm[waddr];
    srcLm[waddr]    <= srcLm[waddr];
    srcL_mm[waddr]  <= srcL_mm[waddr];
    srcL_shiftm[waddr]     <= srcL_shiftm[waddr];
    srcRm[waddr]    <= srcRm[waddr];
    srcR_mm[waddr]  <= srcR_mm[waddr];
    srcR_shiftm[waddr]     <= srcR_shiftm[waddr];
    imm[waddr]      <= imm[waddr];
    imm_validm[waddr] <= imm_validm[waddr];
    destm[waddr]    <= destm[waddr];
    dstvalm[waddr]  <= dstvalm[waddr];
    delaym[waddr]   <= delaym[waddr];
    agem[waddr]     <= agem[waddr];
    fum[waddr]      <= fum[waddr];
    spec_tagm[waddr] <= spec_tagm[waddr];
    specbitm[waddr]  <= specbitm[waddr];
    fu_opm[waddr]    <= fu_opm[waddr];
  end
end
/*----------------------------------------------------*/
                          //写入RS over
/*----------------------------------------------------*/

/*----------------------------------------------------*/
                          //发射
/*----------------------------------------------------*/
always @(posedge clk)
begin
   if(!rst)
      begin
       src_a <= 0;
       src_b <= 0;
       imm <= 0;
       dest <= 0;
       Rrf_we <= 0;
       fu_op <= 0;
       specbit <= 0;
       spectag <= 0;
      end
   else if(grant)
      begin
       src_a <= src_a[index];
       src_b <= src_b[index];
       imm <= imm[index];
       dest <= dest[index];
       Rrf_we <= Rrf_we[index];
       fu_op <= fu_op[index];
       specbit <= specbit[index];
       spectag <= spectag[index];
      end
   else 
      begin
       src_a <= src_a;
       src_b <= src_b;
       imm <= imm;
       dest <= dest;
       Rrf_we <= Rrf_we;
       fu_op <= fu_op;
       specbit <= specbit;
       spectag <= spectag;
      end
end 

/*----------------------------------------------------*/
                          //发射 over
/*----------------------------------------------------*/
/*----------------------------------------------------*/
                          //推测更新 specbit
/*----------------------------------------------------*/
always @(*)
begin
  if(Prsuccess && (prtag == spec_tagm[3'b000]))
       specbitm[3'b000] <= 1'b0;
  else 
       specbitm[3'b000] <= specbitm[3'b000];
end 

always @(*)
begin
  if(Prsuccess && (prtag == spec_tagm[3'b001]))
      specbitm[3'b001] <= 1'b0;
  else 
       specbitm[3'b001] <= specbitm[3'b001];
end 

always @(*)
begin
  if(Prsuccess && (prtag == spec_tagm[3'b010]))
      specbitm[3'b010] <= 1'b0;
  else 
       specbitm[3'b010] <= specbitm[3'b010];
end 

always @(*)
begin
  if(Prsuccess && (prtag == spec_tagm[3'b011]))
      specbitm[3'b011] <= 1'b0;
  else 
       specbitm[3'b011] <= specbitm[3'b011];
end 

always @(*)
begin
  if(Prsuccess && (prtag == spec_tagm[3'b100]))
      specbitm[3'b100] <= 1'b0;
  else 
       specbitm[3'b100] <= specbitm[3'b100];
end 

always @(*)
begin
  if(Prsuccess && (prtag == spec_tagm[3'b101]))
      specbitm[3'b101] <= 1'b0;
  else 
       specbitm[3'b101] <= specbitm[3'b101];
end 

always @(*)
begin
  if(Prsuccess && (prtag == spec_tagm[3'b110]))
      specbitm[3'b110] <= 1'b0;
  else 
       specbitm[3'b110] <= specbitm[3'b110];
end 

always @(*)
begin
  if(Prsuccess && (prtag == spec_tagm[3'b111]))
      specbitm[3'b111] <= 1'b0;
  else 
       specbitm[3'b111] <= specbitm[3'b111];
end 

/*----------------------------------------------------*/
           //推测更新 分支预测错误 将匹配的表象置为无效
/*----------------------------------------------------*/
always @(*)
begin
  if(!Prsuccess && (prtag == spec_tagm[3'b000]))
       busym[3'b000] <= 1'b0;
  else 
       busym[3'b000] <= busym[3'b000];
end 

always @(*)
begin
  if(!Prsuccess && (prtag == spec_tagm[3'b001]))
       busym[3'b001] <= 1'b0;
  else 
       busym[3'b001] <= busym[3'b001];
end 

always @(*)
begin
  if(!Prsuccess && (prtag == spec_tagm[3'b010]))
       busym[3'b010] <= 1'b0;
  else 
       busym[3'b010] <= busym[3'b010];
end 

always @(*)
begin
  if(!Prsuccess && (prtag == spec_tagm[3'b011]))
       busym[3'b011] <= 1'b0;
  else 
       busym[3'b011] <= busym[3'b011];
end 

always @(*)
begin
  if(!Prsuccess && (prtag == spec_tagm[3'b100]))
       busym[3'b100] <= 1'b0;
  else 
       busym[3'b100] <= busym[3'b100];
end 

always @(*)
begin
  if(!Prsuccess && (prtag == spec_tagm[3'b101]))
       busym[3'b101] <= 1'b0;
  else 
       busym[3'b101] <= busy[3'b101];
end 

always @(*)
begin
  if(!Prsuccess && (prtag == spec_tagm[3'b110]))
       busym[3'b110] <= 1'b0;
  else 
       busym[3'b110] <= busym[3'b110];
end 

always @(*)
begin
  if(!Prsuccess && (prtag == spec_tagm[3'b111]))
       busym[3'b111] <= 1'b0;
  else 
       busym[3'b111] <= busym[3'b111];
end 

//分支预测路径上的指令置为无效
always @(*)
begin
  if(!Prsuccess && (specfixtag == spec_tagm[3'b000]))
       busym[3'b000] <= 1'b0;
  else 
       busym[3'b000] <= busym[3'b000];
end 

always @(*)
begin
  if(!Prsuccess && (specfixtag == spec_tagm[3'b001]))
       busym[3'b001] <= 1'b0;
  else 
       busym[3'b001] <= busym[3'b001];
end 

always @(*)
begin
  if(!Prsuccess && (specfixtag == spec_tagm[3'b010]))
       busym[3'b010] <= 1'b0;
  else 
       busym[3'b010] <= busym[3'b010];
end 

always @(*)
begin
  if(!Prsuccess && (specfixtag == spec_tagm[3'b011]))
       busym[3'b011] <= 1'b0;
  else 
       busym[3'b011] <= busym[3'b011];
end 

always @(*)
begin
  if(!Prsuccess && (specfixtag == spec_tagm[3'b100]))
       busym[3'b100] <= 1'b0;
  else 
       busym[3'b100] <= busym[3'b100];
end 

always @(*)
begin
  if(!Prsuccess && (specfixtag == spec_tagm[3'b101]))
       busym[3'b101] <= 1'b0;
  else 
       busym[3'b101] <= busym[3'b101];
end 

always @(*)
begin
  if(!Prsuccess && (specfixtag == spec_tagm[3'b110]))
       busym[3'b110] <= 1'b0;
  else 
       busym[3'b110] <= busym[3'b110];
end 

always @(*)
begin
  if(!Prsuccess && (specfixtag == spec_tagm[3'b111]))
       busym[3'b111] <= 1'b0;
  else 
       busym[3'b111] <= busym[3'b111];
end 

/*----------------------------------------------------*/
      //推测更新 分支预测错误 将匹配的表象置为无效 over
/*----------------------------------------------------*/











/*----------------------------------------------------*/
                          //移位使能信号
/*----------------------------------------------------*/
always @(grant0)
begin
  if(grant0)
      srcL_shiftm[oindex0] <= 1'b0;
      srcR_shiftm[oindex0] <= 1'b0;
  else
      srcL_shiftm[oindex0] <= srcL_shiftm[oindex0];
      srcR_shiftm[oindex0] <= srcR_shiftm[oindex0];
end

always @(grant1)
begin
  if(grant1)
      srcL_shiftm[oindex1] <= 1'b0;
      srcR_shiftm[oindex1] <= 1'b0;
  else
      srcL_shiftm[oindex1] <= srcL_shiftm[oindex1];
      srcR_shiftm[oindex1] <= srcR_shiftm[oindex1];
end

assign srcL_m_0_0 = srcL_shiftm[3'b000];
assign srcR_m_0_1 = srcR_shiftm[3'b000];
//1
assign srcL_m_1_0 = srcL_shiftm[3'b001];
assign srcR_m_1_1 = srcR_shiftm[3'b001];
//2
assign srcL_m_2_0 = srcL_shiftm[3'b010];
assign srcR_m_2_1 = srcR_shiftm[3'b010];
//3
assign srcL_m_3_0 = srcL_shiftm[3'b011];
assign srcR_m_3_1 = srcR_shiftm[3'b011];
//4
assign srcL_m_4_0 = srcL_shiftm[3'b100];
assign srcR_m_4_1 = srcR_shiftm[3'b100];
//5
assign srcL_m_5_0 = srcL_shiftm[3'b101];
assign srcR_m_5_1 = srcR_shiftm[3'b101];
//6
assign srcL_m_6_0 = srcL_shiftm[3'b110];
assign srcR_m_6_1 = srcR_shiftm[3'b110];
//7
assign srcL_m_7_0 = srcL_shiftm[3'b111];
assign srcR_m_7_1 = srcR_shiftm[3'b111];

//进行移位0
always @(posedge clk)
begin
  if(srcL_m_0_0 == 1'b1)//移位控制信号
    srcL_shiftm[3'b000] = srcl_shift_0_0>>1;
  else 
    srcL_shiftm[3'b000] = srcL_shiftm[3'b000];
end

always @(posedge clk)
begin
  if(srcR_m_0_1 == 1'b1)
    srcR_shiftm[3'b000] = srcR_shift_0_1>>1;
  else 
    srcR_shiftm[3'b000] = srcR_shiftm[3'b000];
end

//进行移位1
always @(posedge clk)
begin
  if(srcL_m_1_0 == 1'b1)
    srcL_shiftm[3'b001] = srcl_shift_1_0>>1;
  else 
    srcL_shiftm[3'b001] = srcL_shiftm[3'b001];
end

always @(posedge clk)
begin
  if(srcR_m_1_1 == 1'b1)
    srcR_shiftm[3'b001] = srcR_shift_1_1>>1;
  else 
    srcR_shiftm[3'b001] = srcR_shiftm[3'b001];
end
//进行移位2
always @(posedge clk)
begin
  if(srcL_m_2_0 == 1'b1)
    srcL_shiftm[3'b010] = srcl_shift_2_0>>1;
  else 
    srcL_shiftm[3'b010] = srcL_shiftm[3'b010];
end

always @(posedge clk)
begin
  if(srcR_m_2_1 == 1'b1)
    srcR_shiftm[3'b010] = srcR_shift_2_1>>1;
  else 
    srcR_shiftm[3'b010] = srcR_shiftm[3'b010];
end
//进行移位3
always @(posedge clk)
begin
  if(srcL_m_3_0 == 1'b1)
    srcL_shiftm[3'b011] = srcl_shift_3_0>>1;
  else 
    srcL_shiftm[3'b011] = srcL_shiftm[3'b011];
end

always @(posedge clk)
begin
  if(srcR_m_3_1 == 1'b1)
    srcR_shiftm[3'b011] = srcR_shift_3_1>>1;
  else 
    srcR_shiftm[3'b011] = srcR_shiftm[3'b011];
end
//进行移位4
always @(posedge clk)
begin
  if(srcL_m_4_0 == 1'b1)
    srcL_shiftm[3'b100] = srcl_shift_4_0>>1;
  else 
    srcL_shiftm[3'b100] = srcL_shiftm[3'b100];
end

always @(posedge clk)
begin
  if(srcR_m_4_1 == 1'b1)
    srcR_shiftm[3'b100] = srcR_shift_4_1>>1;
  else 
    srcR_shiftm[3'b100] = srcR_shiftm[3'b100];
end
//进行移位5
always @(posedge clk)
begin
  if(srcL_m_5_0 == 1'b1)
    srcL_shiftm[3'b101] = srcl_shift_5_0>>1;
  else 
    srcL_shiftm[3'b101] = srcL_shiftm[3'b101];
end

always @(posedge clk)
begin
  if(srcR_m_5_1 == 1'b1)
    srcR_shiftm[3'b101] = srcR_shift_5_1>>1;
  else 
    srcR_shiftm[3'b101] = srcR_shiftm[3'b101];
end
//进行移位6
always @(posedge clk)
begin
  if(srcL_m_6_0 == 1'b1)
    srcL_shiftm[3'b110] = srcl_shift_6_0>>1;
  else 
    srcL_shiftm[3'b110] = srcL_shiftm[3'b110];
end

always @(posedge clk)
begin
  if(srcR_m_6_1 == 1'b1)
    srcR_shiftm[3'b110] = srcR_shift_6_1>>1;
  else 
    srcR_shiftm[3'b110] = srcR_shiftm[3'b110];
end
//进行移位7
always @(posedge clk)
begin
  if(srcL_m_7_0 == 1'b1)
    srcL_shiftm[3'b111] = srcl_shift_7_0>>1;
  else 
    srcL_shiftm[3'b111] = srcL_shiftm[3'b111];
end

always @(posedge clk)
begin
  if(srcR_m_7_1 == 1'b1)
    srcR_shiftm[3'b111] = srcR_shift_7_1>>1;
  else 
    srcR_shiftm[3'b111] = srcR_shiftm[3'b111];
end
/*----------------------------------------------------*/


module rs_alu
  (
   //System
   input wire                              clk,
   input wire                              rst,
   //分配单元
   output reg                              busy,
   input wire [`ALU_LEN-1:0]               wpc,
   //分支预测单元,这玩意DP后都应该有
   input wire                            specbit,
   input wire                              prsuccess,
   input wire [`SPECTAG_LEN-1:0]           prtag,
   input wire [`SPECTAG_LEN-1:0]           specfixtag,
   //与分配单元例化
   input wire fu_1,//deter the alu
   input wire fu_2,
   //WriteSignal
   input wire                              clear_busy1, //Issue
   input wire                              clear_busy2,
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
   //output wire [`ALU_ENT_NUM*(`RRF_SEL+2)-1:0] histvect,
  // input wire                              nextrrfcyc, 
   //WriteSignal1
   input wire [`ADDR_LEN-1:0]              wpc_1,
   // input wire                              wvalid1_1,
   // input wire                              wvalid2_1,
   input wire [`DATA_LEN-1:0]              wimm_1,
   input wire                              wdstval_1,//确定是否需要写回目的寄存器
   input wire [`ALU_OP_WIDTH-1:0]          walu_op_1,
   input wire [`SPECTAG_LEN-1:0]           wspectag_1,
   input wire                              wspecbit_1,
   input wire [`RRF_SEL-1:0]               wrrftag_1, //保留站的年龄信息
   input wire                              wfu_1,//define the fu to 0
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
   input wire                              wfu_2,//define the fu t0 1
   input wire [`DLAY_WAKE_UP-1:0]          dy_2,//delay wake up data
   input wire                              bypass_2,//操作数可以通过转发获得信号，发射后为1的可以通过旁路转发获得操作数
   //ReadSignal
   output wire                             busy,
   output wire                             ready,
   output wire [`ADDR_LEN-1:0]             pc1,
   output wire [`ADDR_LEN-1:0]             pc2,
   output wire [`DATA_LEN-1:0]             imm1,
   output wire [`DATA_LEN-1:0]             imm2,
   output wire [`RRF_SEL-1:0]              rrftag1,
   output wire [`RRF_SEL-1:0]              rrftag2,
   output wire                             dstval,
   output wire                             dstva2,
   output wire [4:0]                       src_a_1,//
   output wire [4:0]                       src_b_1,
   output wire [4:0]                       src_a_2,
   output wire [4:0]                       src_b_2,//
   output wire                             fu_1,//
   output wire                             fu_2,//
   output wire [`ALU_OP_WIDTH-1:0]         alu_op1,
   output wire [`ALU_OP_WIDTH-1:0]         alu_op2,
   output wire [`SPECTAG_LEN-1:0]          spectag1,
   output wire [`SPECTAG_LEN-1:0]          spectag2,
   output wire                             specbit1,
   output wire                             specbit2,
   output wire [`DLY_LEN-1:0]              delay1,
   output wire [`DLY_LEN-1:0]              delay2,
   output wire [1:0]                       ins_type1,
   output wire [1:0]                       ins_type2
   );

   reg [`ALU_ENT_NUM-1:0]        specbitvec;
   reg [`ALU_ENT_NUM-1:0]        sortbit;

 
rs_alu_ent ent0(
       .clk(clk),
       .rst(rst),
       .busy(busy),
       .prtag(prtag),
       .specfixtag(specfixtag),
       .clear_busy(clear_busy1),
       .we(we1),
       .waddr(waddr1),
       .wsrc1(src_a_1),
       .wsrc2(src_b_1)，
       .wpc(wpc_1),
       .wvalid1(wvalid1_1),
       .wvalid2(wvalid2_1),
       .wimm(wimm_1),
       .wdstval(wdstval_1),
       .walu_op(walu_op_1),
       .wspectag(wspectag_1),
       .wspecbit(wspecbit_1),
       .wrrftag(wrrftag_1),
       .wfu(wfu_1),
       .wdy(wdy_1),
       //output
       .busy(busy),
       .ready(ready),
       .pc(pc1),
       .imm(imm1),
       .rrftag(rrftag1),
       .dstval(dstval),
       .src_a(src_a_1),
       .src_b(src_b_1),
       .fu(fu_1)，
       //.bypass_1(bypass1_a),
       //.bypass_2(bypass1_b),
       .alu_op(alu_op1),
       .spectag(spectag1),
       .specbit(spectag1),
       .delay(delay1),
       .ins_type(ins_type1)
       );
rs_alu_ent ent1(
       .clk(clk),
       .rst(rst),
       .busy(busy),
       .prtag(prtag),
       .specfixtag(specfixtag),
       .clear_busy(clear_busy2),
       .we(we2),
       .waddr(waddr2),
       .wsrc1(src_a_2),
       .wsrc2(src_b_2)，
       .wpc(wpc_2),
       .wvalid1(wvalid1_2),
       .wvalid2(wvalid2_2),
       .wimm(wimm_2),
       .wdstval(wdstval_2),
       .walu_op(walu_op_2),
       .wspectag(wspectag_2),
       .wspecbit(wspecbit_2),
       .wrrftag(wrrftag_2),
       .wfu(wfu_2),
       .wdy(wdy_2),
       //output
       .busy(busy),
       .ready(ready),
       .pc(pc2),
       .imm(imm2),
       .rrftag(rrftag2),
       .dstval(dstva2),
       .src_a(src_a_2),
       .src_b(src_b_2),
       .fu(fu_2)，
       //.bypass_1(bypass2_a),
       //.bypass_2(bypass2_b),
       .alu_op(alu_op2),
       .spectag(spectag2),
       .specbit(specbit2),
       .delay(delay2),
       .ins_type(ins_type2)
       );
   //发出

     //仲裁电路发出的信号
   input wire grant0,
   input wire grant1,
   input wire [2:0] oindex0,
   input wire [2:0] oindex1,
   input wire wissued1,
   input wire wissued2,
/*-------------------------------------------*/
              //唤醒电路
/*-------------------------------------------*/  
   //0          
   input  wire shift_0_0,
   input  wire shift_0_1,
  //1
   input  wire shift_1_0,
   input  wire shift_1_1,
  //2
   input  wire shift_2_0,
   input  wire shift_2_1,
  //3
   input  wire shift_3_0,
   input  wire shift_2_1,
  //4
   input  wire shift_4_0,
   input  wire shift_4_1,
  //5
   input  wire shift_5_0,
   input  wire shift_5_1,
  //6
   input  wire shift_6_0,
   input  wire shift_6_1,
   //7
   input  wire shift_7_0,
   input  wire shift_7_1,
   //0
   input  wire [7:0] srcl_shift_0_0,
   input  wire [7:0] srcR_shift_0_1,
   //1
   input  wire [7:0] srcl_shift_1_0,
   input  wire [7:0] srcR_shift_1_1,
   //2
   input  wire [7:0] srcl_shift_2_0,
   input  wire [7:0] srcR_shift_2_1,
   //3
   input  wire [7:0] srcl_shift_3_0,
   input  wire [7:0] srcR_shift_3_1,
   //4
   input  wire [7:0] srcl_shift_4_0,
   input  wire [7:0] srcR_shift_4_1,
   //5
   input  wire [7:0] srcl_shift_5_0,
   input  wire [7:0] srcR_shift_5_1,
   //6
   input  wire [7:0] srcl_shift_6_0,
   input  wire [7:0] srcR_shift_6_1,
   //7
   input  wire [7:0] srcl_shift_7_0,
   input  wire [7:0] srcR_shift_7_1,
/*---------------------------------------------*/
                 //唤醒over
/*---------------------------------------------*/  

   assign busy = prsuccess ? 
          specbitvec_next[issueaddr] : specbitvec[issueaddr];
   
endmodule // rs_alu
`default_nettype wire













   

