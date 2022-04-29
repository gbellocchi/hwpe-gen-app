`timescale 1ns / 1ps

`ifndef ith
`define ith *8 +: 8
`endif

module read8x32(
	input [7 : 0] in_token,
	output reg in_token_rd,
	input in_token_empty,
	
	output reg [255 : 0] out_token,
	output reg out_token_wr,
	input out_token_full,	
	
	input clock,
	input reset
);

	reg [6:0] counterTokens;
	reg [6:0] next_CounterTokens;
	reg [255:0] next_out_token;
	reg next_out_token_wr;
	reg next_in_token_rd;

	always@(posedge clock)
		begin
            if (!reset)
            	begin
	            	counterTokens <= 6'd0;
	            	out_token <= 255'd0;
	            	out_token_wr <= 1'd0;
	            	in_token_rd <= 1'd0;
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
	if (counterTokens < 6'd32 && !in_token_empty)
        next_in_token_rd = 1'b1;
	else 
        next_in_token_rd = 1'b0;

always_comb
	if (in_token_rd)
		begin
            next_out_token = out_token;
            next_out_token[counterTokens`ith] = in_token;
            next_CounterTokens = counterTokens + 6'd1;
        end
    else if (counterTokens < 6'd32 && counterTokens != 6'b0)
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
	if (counterTokens == 6'd32 && !out_token_full)
		begin
			next_out_token_wr = 1'b1;
		end		
	else
		begin
			next_out_token_wr = 1'b0;
		end
endmodule