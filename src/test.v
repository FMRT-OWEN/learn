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

   reg [4:0] src1_m [15:0];
   reg [4:0] sec2_m [15:0];
   reg valid1_m [15:0];
   reg valid2_m [15:0];
   //reg ready_m  [15:0];
   reg fu_m     [15:0];
   reg [5:0] age_m [15:0];
   reg [] op_m  [15:0]; //
   reg [31:0] imm_m [15:0];
   reg [31:0] pc_m [15:0];
   reg [4:0] delay_m [15:0];
   reg [4:0] spec_tag_m [15:0];
























module Rs_alu_en(
   input wire clk,
   input wire rst,
   input wire busy,
   //分支预测单元,
   input wire                              prmiss,
   input wire                              prsuccess,
   input wire [`SPECTAG_LEN-1:0]           prtag,
   input wire [`SPECTAG_LEN-1:0]           specfixtag,
   //
   input wire fu,
   //
   input wire clear_busy,
   //
   input wire we,
   //
   input wire [`ALU_ENT_SEL-1:0] waddr1,
   input wire [`ALU_ENT_SEL-1:0] waddr2,
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
   output wire                       ready,
   output reg  [`ADDR_LEN-1:0]        pc,
   output reg  [`DATA_LEN-1:0]        imm,
   output reg  [`RRF_SEL-1:0]         rrftag,
   output reg                        dstval,
   output reg  [5:0]                  src_a,//
   output reg  [5:0]                  src_b,
   output wire                       fu,
   output wire                       bypass_1,
   output wire                       bypass_2,
   output reg  [`ALU_OP_WIDTH-1:0]    alu_op,
   output reg  [`SPECTAG_LEN-1:0]     spectag,
   output wire [`DLY_LEN-1:0]         delay
   );