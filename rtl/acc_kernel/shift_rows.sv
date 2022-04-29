`timescale 1ns / 1ps

`ifndef ith
`define ith *8 +: 8
`endif


module shift_rows(
	input [127 : 0] in_state,
	output reg in_state_rd,
	input in_state_empty,
	
	output reg [127 : 0] out_state,
	output reg out_state_wr,
	input out_state_full,	
	
	input clock,
	input reset
);


always_comb
	if(!in_state_empty && !out_state_full)
		begin
		in_state_rd = 1;
		out_state_wr = 1;
		// shift rows in parallel
		out_state[15`ith] = in_state[11`ith];		// s'33 = s32
		out_state[14`ith] = in_state[6`ith];		// s'23 = s21
		out_state[13`ith] = in_state[1`ith];		// s'13 = s10
		out_state[12`ith] = in_state[12`ith];		// s'03 = s03
		out_state[11`ith] = in_state[7`ith];		// s'32 = s31
		out_state[10`ith] = in_state[2`ith];		// s'22 = s20
		out_state[9`ith] = in_state[13`ith];		// s'12 = s13
		out_state[8`ith] = in_state[8`ith];		// s'02 = s02
		out_state[7`ith] = in_state[3`ith];		// s'31 = s30
		out_state[6`ith] = in_state[14`ith];		// s'21 = s23
		out_state[5`ith] = in_state[9`ith];		// s'11 = s12
		out_state[4`ith] = in_state[4`ith];		// s'01 = s01
		out_state[3`ith] = in_state[15`ith];		// s'30 = s33
		out_state[2`ith] = in_state[10`ith];		// s'20 = s22
		out_state[1`ith] = in_state[5`ith];		// s'10 = s11
		out_state[0`ith] = in_state[0`ith];		// s'00 = s00		
		end
	else
		begin
		in_state_rd = 0;
		out_state_wr = 0;
		out_state = 'x;
		end

endmodule