// ----------------------------------------------------------------------------
//
// Multi-Dataflow Composer tool - Platform Composer
// Multi-Dataflow Network module 
// Date: 2021/12/22 13:23:38
//
// ----------------------------------------------------------------------------

module multi_dataflow (
	// Input(s)
	input [31 : 0] inStream0_data,
	input inStream0_wr,
	output inStream0_full,
	
	// Output(s)
	input [31 : 0] inStream1_data,
	input inStream1_wr,
	output inStream1_full,
	
	// Output(s)
	input [31 : 0] inStream2_data,
	input inStream2_wr,
	output inStream2_full,
	
	// Output(s)
	output [31 : 0] outStream0_data,
	output outStream0_wr,
	input outStream0_full,
	
	// Dynamic Parameter(s)
	input [31:0] reg_simple_mul,
	input [7:0] reg_shift,
	input [15:0] reg_len,
	
	// Monitoring
	
	// Configuration ID
	
	
	// System Signal(s)		
	input clock,
	input reset
);	

// internal signals
// ----------------------------------------------------------------------------
		


// Actors Wire(s)
	
// actor mac_mdc_0
wire [31 : 0] fifo_small_mac_mdc_0_a_data;
wire fifo_small_mac_mdc_0_a_wr;
wire fifo_small_mac_mdc_0_a_full;
wire [31 : 0] mac_mdc_0_a_data;
wire mac_mdc_0_a_rd;
wire mac_mdc_0_a_valid;
wire [31 : 0] fifo_small_mac_mdc_0_b_data;
wire fifo_small_mac_mdc_0_b_wr;
wire fifo_small_mac_mdc_0_b_full;
wire [31 : 0] mac_mdc_0_b_data;
wire mac_mdc_0_b_rd;
wire mac_mdc_0_b_valid;
wire [31 : 0] fifo_small_mac_mdc_0_c_data;
wire fifo_small_mac_mdc_0_c_wr;
wire fifo_small_mac_mdc_0_c_full;
wire [31 : 0] mac_mdc_0_c_data;
wire mac_mdc_0_c_rd;
wire mac_mdc_0_c_valid;
wire [31 : 0] mac_mdc_0_d_data;
wire mac_mdc_0_d_wr;
wire mac_mdc_0_d_full;
// ----------------------------------------------------------------------------

// body
// ----------------------------------------------------------------------------



// fifo_small_mac_mdc_0_a
fifo_small #(
	.depth(64),
	.size(32)
) fifo_small_mac_mdc_0_a(
	.datain(fifo_small_mac_mdc_0_a_data),
	.dataout(mac_mdc_0_a_data),
	.enr(mac_mdc_0_a_rd),
	.enw(fifo_small_mac_mdc_0_a_wr),
	.valid(mac_mdc_0_a_valid),
	.full(fifo_small_mac_mdc_0_a_full),
	
	// System Signal(s)
	.clk(clock),
	.rst(reset)
);
// fifo_small_mac_mdc_0_b
fifo_small #(
	.depth(64),
	.size(32)
) fifo_small_mac_mdc_0_b(
	.datain(fifo_small_mac_mdc_0_b_data),
	.dataout(mac_mdc_0_b_data),
	.enr(mac_mdc_0_b_rd),
	.enw(fifo_small_mac_mdc_0_b_wr),
	.valid(mac_mdc_0_b_valid),
	.full(fifo_small_mac_mdc_0_b_full),
	
	// System Signal(s)
	.clk(clock),
	.rst(reset)
);
// fifo_small_mac_mdc_0_c
fifo_small #(
	.depth(64),
	.size(32)
) fifo_small_mac_mdc_0_c(
	.datain(fifo_small_mac_mdc_0_c_data),
	.dataout(mac_mdc_0_c_data),
	.enr(mac_mdc_0_c_rd),
	.enw(fifo_small_mac_mdc_0_c_wr),
	.valid(mac_mdc_0_c_valid),
	.full(fifo_small_mac_mdc_0_c_full),
	
	// System Signal(s)
	.clk(clock),
	.rst(reset)
);

// actor mac_mdc_0
mac_mdc actor_mac_mdc_0 (
	// Input Signal(s)
	.a_TDATA(mac_mdc_0_a_data),
	.a_TREADY(mac_mdc_0_a_rd),
	.a_TVALID(mac_mdc_0_a_valid),
	.b_TDATA(mac_mdc_0_b_data),
	.b_TREADY(mac_mdc_0_b_rd),
	.b_TVALID(mac_mdc_0_b_valid),
	.c_TDATA(mac_mdc_0_c_data),
	.c_TREADY(mac_mdc_0_c_rd),
	.c_TVALID(mac_mdc_0_c_valid)
	,
	
	// Output Signal(s)
	.d_TDATA(mac_mdc_0_d_data),
	.d_TVALID(mac_mdc_0_d_wr),
	.d_TREADY(mac_mdc_0_d_full)
	,
	
	// Dynamic Parameter(s)
	.reg_simple_mul(reg_simple_mul),
	.reg_shift(reg_shift),
	.reg_len(reg_len)
	,
	
	// System Signal(s)
	.ap_clk(clock),
	.ap_rst_n(reset)
);


// Module(s) Assignments
assign fifo_small_mac_mdc_0_a_data = inStream0_data;
assign fifo_small_mac_mdc_0_a_wr = inStream0_wr;
assign inStream0_full = fifo_small_mac_mdc_0_a_full;

assign fifo_small_mac_mdc_0_b_data = inStream1_data;
assign fifo_small_mac_mdc_0_b_wr = inStream1_wr;
assign inStream1_full = fifo_small_mac_mdc_0_b_full;

assign fifo_small_mac_mdc_0_c_data = inStream2_data;
assign fifo_small_mac_mdc_0_c_wr = inStream2_wr;
assign inStream2_full = fifo_small_mac_mdc_0_c_full;

assign outStream0_data = mac_mdc_0_d_data;
assign outStream0_wr = mac_mdc_0_d_wr;
assign mac_mdc_0_d_full = outStream0_full;

endmodule
