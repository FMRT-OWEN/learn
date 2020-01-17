`include "./delay_wakeup.v"
module tb_test ();
	reg clk;   
	reg rst;
	reg [7:0] wdy;
	wire valid;
always #10 clk = ~clk;

delay_wakeup uut(
	.clk(clk),
	.rst(rst),
	.wdy(wdy),
	.valid)(valid)
	);
initial
begin
	clk = 1;
	rst = 1;
	wdy = 8'd0;
	#10
	rst = 0;
	wdy = 8'b11111000;
	#1000 $finish;
end
  initial
     begin
			$dumpfile ("tb_test.vcd");
            $dumpvars (0,tb__test);
     end 


endmodule