`default_nettype none
`include "head.v"
`include "./comment.v"
`include "./allocate_unit.v"
`include "./alu_alloca.v"
module Dp(
	//input [`Instruction_width-1:0] Preg,
	//input [`Instruction_width-1:0] srcld_1,
    //input [`Instruction_width-1:0] srcld_2,
    //input valid_2,
    //input valid_1, 
    //input Ready,
    input wire busy_alu,
    input wire busy_bra,
    input wire busy_ldst,
    input wire busy_mul,

    input wire prScusses,

    input [`ctl_sign-1:0] ctl_sign,
    input [`Instruction_width-1:0] pc_next,
    input [`inst_type-1:0] inst_type,
    //待确定
    //input [`Instruction_width-1:0] Areg,
    input [`spec_tag_width-1:0] spec_tag,
    input stall,//ze se xin hao

    input [`src_manger_width-1:0] src_manger_bus_r
    //output to ROB
    output [`inst_type-1:0] inst_type,
    output [`Instruction_width-1:0] Preg
    output wire [3:0] waddra_alu,
    output wire [3:0] waddrb_alu,
    output wire [1:0] waddra_bra,
    output wire [1:0] waddrb_bra,
    output wire [1:0] waddra_ldst,
    output wire [1:0] waddrb_ldst,
    output wire [1:0] waddra_mul,
    output wire [1:0] waddrb_mul,
    output wire we1_alu,
    output wire we2_alu,
    output wire we1_bra,
    output wire we2_bra,
    output wire we1_ldst,
    output wire we2_ldst,
    output wire we1_mul,
    output wire we2_mul,
    output wire fu_1,
    output wire fu_2

   ); 

wire [`Instruction_width-1:0] Preg;
wire [`Instruction_width-1:0] srcld_1;
wire [`Instruction_width-1:0] srcld_2;
wire valid_2;
wire valid_1;
wire Ready;
wire [`ctl_sign-1:0] ctl_sign;
wire [`Instruction_width-1:0] pc_next;
wire [`inst_type-1:0] inst_type;
wire [`spec_tag_width-1:0] spec_tag;
wire [1:0] rs_id_1
wire [1:0] rs_id_2;

assign 
assign 
assign
assign
assign
assign
assign
assign
assign
assign
assign

// Dispatch to reservation station
reg Req_alu_1;
reg Req_alu_2;
reg Req_bru_1;
reg Req_bru_2;
reg Req_ldst_1;
reg Req_ldst_2;
reg Req_mul_1;
reg Req_mul_2;
//if stall 所有的
//这个0标志译码单元，因为后面的保留站请求信号最多可能是两个，所以这里做了改动
wire [1:0] rs_id1;
wire [1:0] rs_id2;
//
wire req_alu1;
wire req_bra1;
wire req_ldst1;
wire req_mul1;
//
wire req_alu2;
wire req_bra2;
wire req_ldst2;
wire req_mul2;
//
//提出对应的RS分派请求
req ins1(
    .rs_id(rs_id1),
    .req_alu(req_alu1),
    .req_bar(req_bra1),
    .req_ldst(req_ldst1),
    .req_mul(req_mul1)
    );
req ins2(
    .rs_id(rs_id2),
    .req_alu(req_alu2),
    .req_bar(req_bra2),
    .req_ldst(req_ldst2),
    .req_mul(req_mul2)
    );
wire reqnum_alu;
wire reqnum_bra;
wire reqnum_ldst;
wire reqnum_mul;

assign reqnum_alu = {1'b0, req_alu1} + {1'b0, req_alu2};
assign reqnum_bra = {1'b0,req_bra1} + {1'b0,req_bra2};
assign reqnum_ldst = {1'b0,req_ldst1} + {1'b0,req_ldst2};
assign reqnum_mul =  {1'b0,req_mul} + {1'b0,req_mul2};

/*----------------
//alu空闲表象分配
//
---------------*/
wire entry_alu1;
wire entry_alu2;
wire [3:0] waddr1_alu;
wire [3:0] waddr2_alu;
wire allocatable_alu;

free_entry alu_alloc(
    .busy(busy_alu),
    .en1(entry_alu1),
    .en2(entry_alu2),
    .free_ent1(waddr1_alu),
    .free_ent2(waddr2_alu),
    .reqnum(reqnum_alu),
    .allocatable(allocatable_alu)
    );
//
assign waddra_alu = (req_alu1 == 1'b1)? waddr1_alu:4'bz;
assign waddrb_alu = ((req_alu2 == 1'b1) && (req_alu1 == 1'b0)?waddr1_alu:
                     ((req_alu1 == 1'b1) && (req_alu2 == 1'b1))?waddr2_alu:4'bz;

assign we1_alu = ((req_alu1 && ~allocatable_alu && prScusses) == 1'b1)?1'b1:1'b0;
assign we2_alu = ((req_alu2 && ~allocatable_alu && prScusses) == 1'b1)?1'b1:1'b0;
//功能单元分配
alu_alloca alu_fu(
    .we1(we1_alu),
    .we2(we2_alu),
    .wfu_1(fu_1),
    .wfu_2(fu_2)
    );

/*---------------------------------------
//               bra空闲表象分配
----------------------------------------*/
wire entry_bra1;
wire entry_bra2;
wire waddr1_bra;
wire waddr2_bra;
wire allocatable_bra;

free_entry bra_alloc(
    .busy(busy_bra),
    .en1(entry_bra1),
    .en2(entry_bra2),
    .free_ent1(waddr1_bra),
    .free_ent2(waddr2_bra),
    .reqnum(reqnum_bra),
    .allocatable(allocatable_bra)
    );

assign waddra_bra = (req_bra1 == 1'b1)? waddr1_bra:4'bz;
assign waddrb_bra = ((req_bra2 == 1'b1) && (req_bra1 == 1'b0)?waddr1_bra:
                     ((req_bra == 1'b1) && (req_bra == 1'b1))?waddr2_bra:4'bz;

assign we1_bra = ((req_bra1 && ~allocatable_alu && prScusses) == 1'b1)?1'b1:1'b0;
assign we2_bra = ((req_bra2 && ~allocatable_alu && prScusses) == 1'b1)?1'b1:1'b0;

/*---------------------------------------------
//                     ldst
----------------------------------------------*/
wire entry_ldst1;
wire entry_ldst2;
wire waddr1_ldst;
wire waddr2_ldst;
wire allocatable_ldst;
//
free_entry ldst_alloc(
    .busy(busy_ldst),
    .en1(entry_ldst1),
    .en2(entry_ldst2),
    .free_ent1(waddr1_ldst),
    .free_ent2(waddr2_ldst),
    .reqnum(reqnum_ldst),
    .allocatable(allocatable_ldst)
    );
assign waddra_ldst = (req_ldst1 == 1'b1)? waddr1_ldst:4'bz;
assign waddrb_ldst = ((req_ldst2 == 1'b1) && (req_ldst1 == 1'b0)?waddr1_ldst:
                     ((req_ldst1 == 1'b1) && (req_ldst2 == 1'b1))?waddr2_ldst:4'bz;

assign we1_ldst = ((req_ldst1 && ~allocatable_alu && prScusses) == 1'b1)?1'b1:1'b0;
assign we2_ldst = ((req_ldst2 && ~allocatable_alu && prScusses) == 1'b1)?1'b1:1'b0;

/*---------------------------------------------
//                     mul
----------------------------------------------*/
wire entry_mul1;
wire entry_mul2;
wire waddr1_mul;
wire waddr2_mul;
wire allocatable_mul;
//
free_entry mul_alloc(
    .busy(busy_mul),
    .en1(entry_mul1),
    .en2(entry_mul2),
    .free_ent1(waddr1_mul),
    .free_ent2(waddr2_mul),
    .reqnum(reqnum_mu),
    .allocatable(allocatable_mul)
    );
assign waddra_mul = (req_mul1 == 1'b1)? waddr1_mul:4'bz;
assign waddrb_mul = ((req_mul2 == 1'b1) && (req_mul1 == 1'b0)?waddr1_mul:
                     ((req_alu1 == 1'b1) && (req_mul2 == 1'b1))?waddr2_mul:4'bz;
//
assign we1_mul = ((req_mul1 && ~allocatable_alu && prScusses) == 1'b1)?1'b1:1'b0;
assign we2_mul = ((req_mul2 && ~allocatable_alu && prScusses) == 1'b1)?1'b1:1'b0;



endmodule 
   




