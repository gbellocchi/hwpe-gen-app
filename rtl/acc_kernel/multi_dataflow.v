// ----------------------------------------------------------------------------
//
// Multi-Dataflow Composer tool - Platform Composer
// Multi-Dataflow Network module 
// Date: 2021/12/20 18:16:29
//
// ----------------------------------------------------------------------------

module multi_dataflow (
	// Input(s)
	input [31 : 0] inStream0_data,
	input inStream0_wr,
	output inStream0_full,
	
	// Output(s)
	output [31 : 0] outStream0_data,
	output outStream0_wr,
	input outStream0_full,
	
	// Dynamic Parameter(s)
	input [31:0] width,
	input [31:0] height,
	
	// Monitoring
	
	// Configuration ID
	
	
	// System Signal(s)		
	input clock,
	input reset
);	

// internal signals
// ----------------------------------------------------------------------------
		


// Actors Wire(s)
	
// actor conv_mdc_0
wire [31 : 0] fifo_small_conv_mdc_0_src_V_data;
wire fifo_small_conv_mdc_0_src_V_wr;
wire fifo_small_conv_mdc_0_src_V_full;
wire [31 : 0] conv_mdc_0_src_V_data;
wire conv_mdc_0_src_V_rd;
wire conv_mdc_0_src_V_valid;
wire [31 : 0] conv_mdc_0_dst_V_data;
wire conv_mdc_0_dst_V_wr;
wire conv_mdc_0_dst_V_full;
// ----------------------------------------------------------------------------

// body
// ----------------------------------------------------------------------------



// fifo_small_conv_mdc_0_src_V
fifo_small #(
	.depth(64),
	.size(32)
) fifo_small_conv_mdc_0_src_V(
	.datain(fifo_small_conv_mdc_0_src_V_data),
	.dataout(conv_mdc_0_src_V_data),
	.enr(conv_mdc_0_src_V_rd),
	.enw(fifo_small_conv_mdc_0_src_V_wr),
	.valid(conv_mdc_0_src_V_valid),
	.full(fifo_small_conv_mdc_0_src_V_full),
	
	// System Signal(s)
	.clk(clock),
	.rst(reset)
);

// actor conv_mdc_0
conv_mdc actor_conv_mdc_0 (
	// Input Signal(s)
	.src_V_TDATA(conv_mdc_0_src_V_data),
	.src_V_TREADY(conv_mdc_0_src_V_rd),
	.src_V_TVALID(conv_mdc_0_src_V_valid)
	,
	
	// Output Signal(s)
	.dst_V_TDATA(conv_mdc_0_dst_V_data),
	.dst_V_TVALID(conv_mdc_0_dst_V_wr),
	.dst_V_TREADY(conv_mdc_0_dst_V_full)
	,
	
	// Dynamic Parameter(s)
	.width(width),
	.height(height)
	,
	
	// System Signal(s)
	.ap_clk(clock),
	.ap_rst_n(reset)
);


// Module(s) Assignments
assign fifo_small_conv_mdc_0_src_V_data = inStream0_data;
assign fifo_small_conv_mdc_0_src_V_wr = inStream0_wr;
assign inStream0_full = fifo_small_conv_mdc_0_src_V_full;

assign outStream0_data = conv_mdc_0_dst_V_data;
assign outStream0_wr = conv_mdc_0_dst_V_wr;
assign conv_mdc_0_dst_V_full = outStream0_full;

endmodule
