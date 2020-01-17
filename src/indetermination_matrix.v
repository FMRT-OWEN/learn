`include "./"
`default_nettype none
//Dp分派进来的
module indeter_matrix(
	input wire [1:0] waddra_ldst,
	input wire [1:0] waddrb_ldst,
	input wire we1_ldst,
	input wire we2_ldst,
	input wire rst_colum,//重置矩阵上的列
	input wire [1:0] Type
	);



reg [0:0] matrix [9:0];
//矩阵复位
always @(!rst)
begin
	if(!rst)
		begin
		matrix[0] <= 0;
		matrix[1] <= 0;
		matrix[2] <= 0;
		matrix[3] <= 0;
		matrix[4] <= 0;
		matrix[5] <= 0;
		matrix[6] <= 0;
		matrix[7] <= 0;
		matrix[8] <= 0;
		matrix[9] <= 0;
	end
//这因该是压缩后的数据
wire [1:0] Type_0;
wire [1:0] Type_1;
wire [1:0] Type_2;
wire [1:0] Type_3;

always @(*)
begin
	if(Type_0 == 2'b10)
		begin
			matrix[0] <= 1'b1;
			matrix[1] <= 1'b1;
			matrix[3] <= 1'b1;
			matrix[6] <= 1'b1;
		end 
	else 
	begin
			matrix[0] <= 1'b0;
			matrix[1] <= 1'b0;
			matrix[3] <= 1'b0;
			matrix[6] <= 1'b0;
	end
end

always @(*)
begin
	if(Type_1 == 2'b10)
		begin
			matrix[2] <= 1'b1;
			matrix[4] <= 1'b1;
			matrix[7] <= 1'b1;
		end 
	else 
	begin
			matrix[2] <= 1'b0;
			matrix[4] <= 1'b0;
			matrix[7] <= 1'b0;
	end
end

always @(*)
begin
	if(Type_2 == 2'b10)
		begin
			matrix[5] <= 1'b1;
			matrix[8] <= 1'b1;
		end 
	else 
	begin
			matrix[5] <= 1'b0;
			matrix[8] <= 1'b0;
	end
end

always @(*)
begin
	if(Type_3 == 2'b10)
		begin
			matrix[9] <= 1'b1;
		end 
	else 
	begin
			matrix[9] <= 1'b0;
	end
end



