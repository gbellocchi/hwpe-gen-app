`timescale 1ns / 1ps

`ifndef ith
`define ith *8 +: 8
`endif

module read8x16(
	input [7 : 0] in_token,
	output reg in_token_rd,
	input in_token_empty,
	
	output reg [127 : 0] out_token,
	output reg out_token_wr,
	input out_token_full,	
	
	input clock,
	input reset
);

	reg [5:0] counterTokens;
	reg [5:0] next_CounterTokens;
	reg [127:0] next_out_token;
	reg next_out_token_wr;
	reg next_in_token_rd;

	always@(posedge clock)
		begin
            if (!reset)
            	begin
	            	counterTokens <= 5'b0;
	            	out_token <= 127'b0;
	            	out_token_wr <= 1'b0;
	            	in_token_rd <= 1'b0;
            	end
           	else 
           		begin
	            	counterTokens <= next_CounterTokens;
	            	out_token <= next_out_token;
	            	out_token_wr <= next_out_token_wr;
	            	in_token_rd <= next_in_token_rd;
	            end
		end

always_comb
	if (counterTokens < 5'd16 && !in_token_empty)
        next_in_token_rd = 1'b1;
	else 
        next_in_token_rd = 1'b0;

always_comb
	if (in_token_rd)
		begin
            next_out_token = out_token;
            next_out_token[counterTokens`ith] = in_token[7:0];
            next_CounterTokens = counterTokens + 5'd1;
        end
    else if (counterTokens < 5'd16 && counterTokens != 5'b0)
        begin
            next_out_token = out_token;
            next_CounterTokens = counterTokens;			
        end
	else
		begin
			next_out_token = out_token;
			next_CounterTokens = 1'b0;
		end
always_comb
	if (counterTokens == 5'd16 && !out_token_full)
		begin
			next_out_token_wr = 1'b1;
		end		
	else
		begin
			next_out_token_wr = 1'b0;
		end
endmodule