/*-------------------------------------------
//   功能单元分配,采用轮转发的方式分配，不应该写着
//------------------------------------------*/
module alu_alloca(
	input we1,
	input we2,
	output wire wfu_1,
	output wire wfu_2
	);

assign wfu_1 = ((we1 && we2 == 1'b1) || (((we1 == 1'b1) && (we2 == 1'b0)) == 1'b1)) ? 1'b0:1'bz;
assign wfu_2 = ((we1 && we2 == 1'b1) || (((we1 == 1'b0) && (we2 == 1'b1)) == 1'b1)) ? 1'b1:1'bz;
endmodule		 