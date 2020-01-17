`include "constants.vh"
module req(
	input wire [1:0] rs_id,
	output wire req_alu,
	output wire req_bra,
	output wire req_ldst,
	output wire req_mul
	);
assign req_alu = (rs_id == 2'b00)?1'b1:1'b0;
assign req_bra = (rs_id == 2'b01)?1'b1:1'b0;
assign req_ldst = (rs_id == 2'b10)?1'b1:1'b0;
assign req_mul = (rs_id == 2'b11)?1'b1:1'b0;

module mul_2(
	input [`GRANT_LEN-1:0] a,
	input [`GRANT_LEN-1:)] b,
    input )






module mux5	#(parameter width = 8)
			 (d0, d1, d2,d3,d4,s, y);

	input  [width-1:0] d0, d1, d2,d3,d4;
	input  [3:0]	     s;
	output [width - 1:0] y;
	always @(*)
	case(s):
		4'b1000:y = d0;
		4'b1001:y = d1;
		4'b1010:y = d2;
		4'b1011:y = d3;
		4'b1100:y = d4;
	default:y = d0;//
    endcase 
endmodule

module mux_ldst_2(
	input [`LDST_WIDTH-1:0] a,
	input [`LDST_WIDTH-1:)] b,
	input c,
	output [`LDST_WIDTH-1:0] d
	);
assign d = (c == 1)?b:a;

endmodule