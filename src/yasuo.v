module yasuo(
   //sign
   input wire issu_a,
   input wire issu_b,
   input wire issu_c,
   input wire issu_d,
   //shuru
   input wire [`LDST_WIDTH-1:0] data_a,
   input wire [`LDST_WIDTH-1:0] data_b,
   //
   input wire [`LDST_WIDTH-1:0] data_c,
   input wire [`LDST_WIDTH-1:0] data_d,
   //
   input wire [`LDST_WIDTH-1:0] data_out,

   output wire [`LDST_WIDTH-1:0] odata_a,
   output wire [`LDST_WIDTH-1:0] odata_b,
   output wire [`LDST_WIDTH-1:0] odata_c,
   output wire [`LDST_WIDTH-1:0] odata_d
  );





mux_ldst_2 mux_a(
	.a(data_a),
	.b(data_b),
	.c(issu_a),
	.d(odata_a)
	);

mux_ldst_2 mux_b(
	.a(data_b),
	.b(data_c),
	.c(issu_b),
	.d(odata_b)
	);

mux_ldst_2 mux_c(
	.a(data_c),
	.b(data_d),
	.c(issu_c),
	.d(odata_c)
	);

mux_ldst_2 mux_d(
	.a(data_d),
	.b(data_out),
	.c(issu_d),
	.d(odata_d)
	);
