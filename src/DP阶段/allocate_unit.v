`default_nettype none
`include "constants.vh"
//优先级编码器
module prioenc( 
    input wire [`REQ_LEN-1:0]   in,
    output reg [`GRANT_LEN-1:0] out,
    output reg en
   );
   
   integer 	i;
   always @ (*) 
   begin
      en = 0;
      out = 0;
      for (i = 0;i < `REQ_LEN ; i = i + 1) 
        begin
	         if (~in[i]) 
              begin
	               out = i;
	               en = 1;
	            end
        end
   end
endmodule

module mask_unit(
    input wire [`GRANT_LEN-1:0] mask,
    input wire [`REQ_LEN-1:0]   in,
    output reg [`REQ_LEN-1:0]   out
   );
   
   integer i;
   always @ (*) 
   begin
      out = 0;
      for (i = 0 ; i < `REQ_LEN ; i = i+1) 
      begin
	     out[i] = (mask < i) ? 1'b0 : 1'b1;
      end
   end
endmodule

module free_entry(
    input  wire [`REQ_LEN-1:0] 	busy,
    output wire 		en1,
    output wire 		en2,
    output wire [`GRANT_LEN-1:0] free_ent1,
    output wire [`GRANT_LEN-1:0] free_ent2,
    input  wire [1:0] 		reqnum,
    output wire 		allocatable
)
   
   wire [`REQ_LEN-1:0] 	       busy_msk;
   
   prioenc #(`REQ_LEN, GRANT_LEN) p1
     (
      .in(busy),
      .out(free_ent1),
      .en(en1)
      );

   maskunit #(`REQ_LEN, GRANT_LEN) msku
     (
      .mask(free_ent1),
      .in(busy),
      .out(busy_msk)
      );
   
   prioenc #(`REQ_LEN, GRANT_LEN) p2
     (
      .in(busy | busy_msk),
      .out(free_ent2),
      .en(en2)
      );
   assign allocatable = (reqnum > ({1'b0,en1}+{1'b0,en2})) ? 1'b0 : 1'b1;
endmodule


module allocateunit_1(
  input wire allocatable,
  input wire req1,
  input wire req2,
  input prSuccess,
  output wire en1,
  output wire en2，
  output wire [`ALU_ENT_SEL-1:0] waddr1,
  output wire [`ALU_ENT_SEL-1:0] waddr2
  );

assign en1 = (~allocatable & req1 & prSuccess)?1'b1:1'b0;
assign en2 = (~allocatable & req2 & prSuccess)?1'b1:1'b0;
assign waddr1 = 
`default_nettype wire