
module kill_gen(
	input clk,
	input wire Prmiss,
	input wire specbit,
	input wire [4:0] spectag,
	input wire [4:0] spcec_fix_tag,
	output wire kill_spec
	);
wire match1_sign;
wire match2_sign;
assign match1_sign = spectag && spcec_fix_tag;
assign match2_sign = match1_sign && specbit;
assign kill_spec = Prmiss && match2_sign;

