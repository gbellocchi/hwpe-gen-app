`timescale 1ns / 1ps

`ifndef ith
`define ith *8 +: 8
`endif

/* implements the mix column operators
 * functions are used for convenience as the new value of a bytes depends on the bytes of its column elaborated by a function. 
 * The function to be applied depeneds on the row of the bytes. */

module mix_cols(
	input [127 : 0] in_state,
	output reg in_state_rd,
	input in_state_empty,
	
	output reg [127 : 0] out_state,
	output reg out_state_wr,
	input out_state_full,	
	
	input clock,
	input reset
);


function automatic [7 : 0] xtime(input [7 : 0] x);
		xtime = (x & 8'h80) ? ((x << 1) ^ 8'h1b) : (x << 1);
endfunction		


function automatic [7 : 0] row0(
		input [7 : 0] s0c,	// 1st byte of the column 
		input [7 : 0] s1c,	// 2nd byte of the column 
		input [7 : 0] s2c,	// 3rd byte of the column 
		input [7 : 0] s3c	// 4th byte of the column 
		);
		
		reg [7 : 0] e = s0c ^ s1c ^ s2c ^ s3c;
		row0 = s0c ^ e ^ xtime(s0c ^ s1c);
		
endfunction


function automatic [7 : 0] row1(
		input [7 : 0] s0c,	// 1st byte of the column 
		input [7 : 0] s1c,	// 2nd byte of the column 
		input [7 : 0] s2c,	// 3rd byte of the column 
		input [7 : 0] s3c	// 4th byte of the column 
		);
		
		reg [7 : 0] e = s0c ^ s1c ^ s2c ^ s3c;
		row1 = s1c ^ e ^ xtime(s1c ^ s2c);
		
endfunction


function automatic [7 : 0] row2(
		input [7 : 0] s0c,	// 1st byte of the column 
		input [7 : 0] s1c,	// 2nd byte of the column 
		input [7 : 0] s2c,	// 3rd byte of the column 
		input [7 : 0] s3c	// 4th byte of the column 
		);
		
		reg [7 : 0] e = s0c ^ s1c ^ s2c ^ s3c;
		row2 = s2c ^ e ^ xtime(s2c ^ s3c);
		
endfunction


function automatic [7 : 0] row3(
		input [7 : 0] s0c,	// 1st byte of the column 
		input [7 : 0] s1c,	// 2nd byte of the column 
		input [7 : 0] s2c,	// 3rd byte of the column 
		input [7 : 0] s3c	// 4th byte of the column 
		);
		
		reg [7 : 0] e = s0c ^ s1c ^ s2c ^ s3c;
		row3 = s3c ^ e ^ xtime(s3c ^ s0c);
		
endfunction


//always_comb
always @(in_state_empty, out_state_full, in_state)
	if(!in_state_empty && !out_state_full)
		begin
		in_state_rd = 1;
		out_state_wr = 1;
		// mix cols in parallel
		out_state[15`ith] = row3(in_state[12`ith], in_state[13`ith], in_state[14`ith], in_state[15`ith]);		// s'33
		out_state[14`ith] = row2(in_state[12`ith], in_state[13`ith], in_state[14`ith], in_state[15`ith]);		// s'23 
		out_state[13`ith] = row1(in_state[12`ith], in_state[13`ith], in_state[14`ith], in_state[15`ith]);		// s'13
		out_state[12`ith] = row0(in_state[12`ith], in_state[13`ith], in_state[14`ith], in_state[15`ith]); 		// s'03 
		out_state[11`ith] = row3(in_state[8`ith], in_state[9`ith], in_state[10`ith], in_state[11`ith]);		// s'32 
		out_state[10`ith] = row2(in_state[8`ith], in_state[9`ith], in_state[10`ith], in_state[11`ith]);		// s'22 
		out_state[9`ith] = row1(in_state[8`ith], in_state[9`ith], in_state[10`ith], in_state[11`ith]);			// s'12 
		out_state[8`ith] = row0(in_state[8`ith], in_state[9`ith], in_state[10`ith], in_state[11`ith]);			// s'02
		out_state[7`ith] = row3(in_state[4`ith], in_state[5`ith], in_state[6`ith], in_state[7`ith]);			// s'31 
		out_state[6`ith] = row2(in_state[4`ith], in_state[5`ith], in_state[6`ith], in_state[7`ith]);			// s'21 
		out_state[5`ith] = row1(in_state[4`ith], in_state[5`ith], in_state[6`ith], in_state[7`ith]);			// s'11
		out_state[4`ith] = row0(in_state[4`ith], in_state[5`ith], in_state[6`ith], in_state[7`ith]);			// s'01
		out_state[3`ith] = row3(in_state[0`ith], in_state[1`ith], in_state[2`ith], in_state[3`ith]);			// s'30 
		out_state[2`ith] = row2(in_state[0`ith], in_state[1`ith], in_state[2`ith], in_state[3`ith]);			// s'20 
		out_state[1`ith] = row1(in_state[0`ith], in_state[1`ith], in_state[2`ith], in_state[3`ith]); 			// s'10 
		out_state[0`ith] = row0(in_state[0`ith], in_state[1`ith], in_state[2`ith], in_state[3`ith]);			// s'00 		
		end
	else
		begin
		in_state_rd = 0;
		out_state_wr = 0;
		out_state = 'x;
		end

endmodule