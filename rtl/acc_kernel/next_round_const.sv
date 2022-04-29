`ifndef ith
`define ith *8 +: 8
`endif



module next_round_const(
	input [7 : 0] in_rc,
	output reg in_rc_rd,
	input in_rc_empty,
	
	output reg [7 : 0] out_rc,
	output reg out_rc_wr,
	input out_rc_full,
	
	input clock,
	input reset
);

function automatic [7 : 0] F(input [7 : 0] x);
		F = ((x << 1) ^ (((x >> 7) & 1) * 8'h1b));
endfunction	



//always_comb
always @(in_rc_empty, out_rc_full, in_rc)
	if(!in_rc_empty && !out_rc_full)
		begin
		in_rc_rd = 1;
		out_rc_wr = 1;
		out_rc = F(in_rc);
		end
		
	else
		begin
		in_rc_rd = 0;
		out_rc_wr = 0;	
		out_rc = 'x;
		end

endmodule