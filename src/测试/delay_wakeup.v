module delay_wakeup(
	input wire clk,
	input wire rst,
	input wire issu_en,
    input wire [7:0] wdy,
    output reg valid
    );
reg [7:0] shift_reg;
always @(posedge clk)
begin
	if(!rst)
	begin
		valid <= 1'b0;
		shift_reg <= 8'b00000000;
	end
	else if(issu_en)
	begin
		shift_reg <= wdy;
		valid <= 1'b0;
	end
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
		shift_reg <= 8'b00000000;
		valid <= 1'b1;
	end
end
endmodule 