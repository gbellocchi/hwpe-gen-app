// ----------------------------------------------------------------------------
//
// Multi-Dataflow Composer tool - Platform Composer
// Multi-Dataflow Network module 
// Date: 2022/01/11 14:07:22
//
// ----------------------------------------------------------------------------

module multi_dataflow (
	// Input(s)
	input [31 : 0] in1_data,
	input in1_wr,
	output in1_full,
	
	// Output(s)
	input [31 : 0] in2_data,
	input in2_wr,
	output in2_full,
	
	// Output(s)
	output [31 : 0] out_r_data,
	output out_r_wr,
	input out_r_full,
	
	// Dynamic Parameter(s)
	
	// Monitoring
	
	// Configuration ID
	
	
	// System Signal(s)		
	input clock,
	input reset
);	

// internal signals
// ----------------------------------------------------------------------------
		


// Actors Wire(s)
	
// actor mmult_opt_mdc_0
wire [31 : 0] fifo_small_mmult_opt_mdc_0_in1_data;
wire fifo_small_mmult_opt_mdc_0_in1_wr;
wire fifo_small_mmult_opt_mdc_0_in1_full;
wire [31 : 0] mmult_opt_mdc_0_in1_data;
wire mmult_opt_mdc_0_in1_rd;
wire mmult_opt_mdc_0_in1_valid;
wire [31 : 0] fifo_small_mmult_opt_mdc_0_in2_data;
wire fifo_small_mmult_opt_mdc_0_in2_wr;
wire fifo_small_mmult_opt_mdc_0_in2_full;
wire [31 : 0] mmult_opt_mdc_0_in2_data;
wire mmult_opt_mdc_0_in2_rd;
wire mmult_opt_mdc_0_in2_valid;
wire [31 : 0] mmult_opt_mdc_0_out_r_data;
wire mmult_opt_mdc_0_out_r_wr;
wire mmult_opt_mdc_0_out_r_full;
// ----------------------------------------------------------------------------

// body
// ----------------------------------------------------------------------------



// fifo_small_mmult_opt_mdc_0_in1
fifo_small #(
	.depth(64),
	.size(32)
) fifo_small_mmult_opt_mdc_0_in1(
	.datain(fifo_small_mmult_opt_mdc_0_in1_data),
	.dataout(mmult_opt_mdc_0_in1_data),
	.enr(mmult_opt_mdc_0_in1_rd),
	.enw(fifo_small_mmult_opt_mdc_0_in1_wr),
	.valid(mmult_opt_mdc_0_in1_valid),
	.full(fifo_small_mmult_opt_mdc_0_in1_full),
	
	// System Signal(s)
	.clk(clock),
	.rst(reset)
);
// fifo_small_mmult_opt_mdc_0_in2
fifo_small #(
	.depth(64),
	.size(32)
) fifo_small_mmult_opt_mdc_0_in2(
	.datain(fifo_small_mmult_opt_mdc_0_in2_data),
	.dataout(mmult_opt_mdc_0_in2_data),
	.enr(mmult_opt_mdc_0_in2_rd),
	.enw(fifo_small_mmult_opt_mdc_0_in2_wr),
	.valid(mmult_opt_mdc_0_in2_valid),
	.full(fifo_small_mmult_opt_mdc_0_in2_full),
	
	// System Signal(s)
	.clk(clock),
	.rst(reset)
);

// actor mmult_opt_mdc_0
mmult_opt_mdc actor_mmult_opt_mdc_0 (
	// Input Signal(s)
	.in1_TDATA(mmult_opt_mdc_0_in1_data),
	.in1_TREADY(mmult_opt_mdc_0_in1_rd),
	.in1_TVALID(mmult_opt_mdc_0_in1_valid),
	.in2_TDATA(mmult_opt_mdc_0_in2_data),
	.in2_TREADY(mmult_opt_mdc_0_in2_rd),
	.in2_TVALID(mmult_opt_mdc_0_in2_valid)
	,
	
	// Output Signal(s)
	.out_r_TDATA(mmult_opt_mdc_0_out_r_data),
	.out_r_TVALID(mmult_opt_mdc_0_out_r_wr),
	.out_r_TREADY(mmult_opt_mdc_0_out_r_full)
		,
	
	// System Signal(s)
	.ap_clk(clock),
	.ap_rst_n(reset)
);


// Module(s) Assignments
assign fifo_small_mmult_opt_mdc_0_in1_data = in1_data;
assign fifo_small_mmult_opt_mdc_0_in1_wr = in1_wr;
assign in1_full = fifo_small_mmult_opt_mdc_0_in1_full;

assign fifo_small_mmult_opt_mdc_0_in2_data = in2_data;
assign fifo_small_mmult_opt_mdc_0_in2_wr = in2_wr;
assign in2_full = fifo_small_mmult_opt_mdc_0_in2_full;

assign out_r_data = mmult_opt_mdc_0_out_r_data;
assign out_r_wr = mmult_opt_mdc_0_out_r_wr;
assign mmult_opt_mdc_0_out_r_full = out_r_full;

endmodule
