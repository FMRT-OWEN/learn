`include "./constants.vh"
module Dealy_wakeup(
	input wire clk,
	input wire rst,
    input wire [`DLAY_LEN-1:0] wdy,
    output reg valid
    );
reg [`DLAY_LEN-1:0] shift_reg;
always @(posedge clk)
begin
	if(!rst)
		valid <= 1'b0;
		shift_reg <= 8'd0;
	else 
		shift_reg <= wdy;
		valid <= 1'b0
end
always @(posedge clk)
begin
	if(shift_reg[0] != 1'b1)
	begin
		shift_reg <= shift_reg>>1;
		valid <= 1'b0;
	end
	else if(shift_reg[0] == 1'b1)
	begin
		shift_reg <= `DLAY_LEN'b0;
		valid <= 1'b1;
	end
endmodule 
