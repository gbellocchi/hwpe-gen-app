`timescale 1ns / 1ps

`ifndef ith
`define ith *8 +: 8
`endif

module write16x8(
	input [127 : 0] in_token,
	output reg in_token_rd,
	input in_token_empty,
	
	output reg [7 : 0] out_token,
	output reg out_token_wr,
	input out_token_full,	
	
	input clock,
	input reset
);

	reg [5:0] counterTokens;
	reg [5:0] next_CounterTokens;
	reg [7:0] next_out_token;
	reg next_out_token_wr;
	reg next_in_token_rd;
	reg [127 : 0] internal_in_token;
	reg [127 : 0] next_internal_in_token;

	always@(posedge clock)
		begin
            if (!reset)
            	begin
	            	counterTokens <= 5'b0;
	            	out_token <= 7'b0;
	            	out_token_wr <= 1'b0;
	            	in_token_rd <= 1'b0;
	            	internal_in_token <= 127'b0;
	            end
           	else 
           		begin
	            	counterTokens <= next_CounterTokens;
	            	out_token <= next_out_token;
	            	out_token_wr <= next_out_token_wr;
	            	in_token_rd <= next_in_token_rd;
	            	internal_in_token <= next_internal_in_token;
	            end
		end

always_comb
	if (counterTokens == 5'b0)
		begin
			if (!in_token_empty)
				begin
					next_in_token_rd = 1'b1;
					next_internal_in_token = in_token;
					next_CounterTokens = counterTokens + 5'd1;
				end
			else
				begin
					next_in_token_rd = 1'b0;
					next_internal_in_token = internal_in_token;
					next_CounterTokens = 5'b0;			
				end
		end		
	else if (counterTokens < (5'd16 + 5'd1) && !out_token_full)
		begin
			next_in_token_rd = 1'b0;
			next_internal_in_token = internal_in_token;
			if (counterTokens == 5'd16)
				next_CounterTokens = 5'd0;
			else 
				next_CounterTokens = counterTokens + 5'd1;
		end
	else
		begin
			next_in_token_rd = 1'b0;
			next_internal_in_token = internal_in_token;
			next_CounterTokens = counterTokens;
		end

always_comb
	if (counterTokens == 5'b0)
		begin
			next_out_token = out_token;
			next_out_token_wr = 1'b0;
		end		
	else if (counterTokens < (5'd16 + 5'd1) && !out_token_full)
		begin
			next_out_token = internal_in_token[(counterTokens-1)`ith];
			next_out_token_wr = 1'b1;
		end		
	else
		begin
			next_out_token = out_token;
			next_out_token_wr = 1'b0;
		end
endmodule
