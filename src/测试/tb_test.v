`include "./delay_wakeup.v"
module tb_test ();
	reg clk;   
	reg rst;
	reg issu_en;
	reg [7:0] wdy;
	wire valid;
always #10 clk = ~clk;

delay_wakeup uut(
	.clk(clk),
	.rst(rst),
	.wdy(wdy),
	.issu_en(issu_en),
	.valid(valid)
	);
initial
begin
	clk = 1;
	rst = 1;
	wdy = 8'd0;
	#20
	rst = 0;
	#10
	rst = 1;
	#10
	issu_en = 1;
	wdy = 8'b11111000;
	#20 issu_en = 0;
	#1000 $finish;
end
  initial
     begin
			$dumpfile ("tb_test.vcd");
            $dumpvars (0,tb_test);
     end 


endmodule