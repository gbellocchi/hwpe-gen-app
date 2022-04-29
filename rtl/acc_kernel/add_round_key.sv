`timescale 1ns / 1ps

`ifndef ith
`define ith *8 +: 8
`endif



module add_round_key(
	input [127 : 0] in_state,
	output reg in_state_rd,
	input in_state_empty,
	
	input [127 : 0] round_key,
	output reg round_key_rd,
	input round_key_empty,
	
	output reg [127 : 0] out_state,
	output reg out_state_wr,
	input out_state_full,	
	
	input clock,
	input reset
);


always_comb
	if(!in_state_empty && !round_key_empty && !out_state_full)
		begin
		in_state_rd = 1;
		round_key_rd = 1;
		out_state_wr = 1;
		out_state = in_state ^ round_key;
		end
	else
		begin
		in_state_rd = 0;
		round_key_rd = 0;
		out_state_wr = 0;
		out_state = 'x;
		end		

endmodule