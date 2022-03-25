// ----------------------------------------------------------------------------
//
// Multi-Dataflow Composer tool - Platform Composer
// Multi-Dataflow Network module 
// Date: 2022/03/25 13:35:14
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
	input [7:0] ID,
	
	
	// System Signal(s)		
	input clock,
	input reset
);	

// internal signals
// ----------------------------------------------------------------------------
// Sboxes Config Wire(s)
wire [3 : 0] sel;
		


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
	
// actor mul_mdc_0
wire [31 : 0] fifo_small_mul_mdc_0_a_data;
wire fifo_small_mul_mdc_0_a_wr;
wire fifo_small_mul_mdc_0_a_full;
wire [31 : 0] mul_mdc_0_a_data;
wire mul_mdc_0_a_rd;
wire mul_mdc_0_a_valid;
wire [31 : 0] fifo_small_mul_mdc_0_b_data;
wire fifo_small_mul_mdc_0_b_wr;
wire fifo_small_mul_mdc_0_b_full;
wire [31 : 0] mul_mdc_0_b_data;
wire mul_mdc_0_b_rd;
wire mul_mdc_0_b_valid;
wire [31 : 0] fifo_small_mul_mdc_0_c_data;
wire fifo_small_mul_mdc_0_c_wr;
wire fifo_small_mul_mdc_0_c_full;
wire [31 : 0] mul_mdc_0_c_data;
wire mul_mdc_0_c_rd;
wire mul_mdc_0_c_valid;
wire [31 : 0] mul_mdc_0_d_data;
wire mul_mdc_0_d_wr;
wire mul_mdc_0_d_full;
	
// actor sbox_0
wire [31 : 0] sbox_0_in1_data;
wire sbox_0_in1_wr;
wire sbox_0_in1_full;
wire [31 : 0] sbox_0_out1_data;
wire sbox_0_out1_wr;
wire sbox_0_out1_full;
wire [31 : 0] sbox_0_out2_data;
wire sbox_0_out2_wr;
wire sbox_0_out2_full;
	
// actor sbox_1
wire [31 : 0] sbox_1_in1_data;
wire sbox_1_in1_wr;
wire sbox_1_in1_full;
wire [31 : 0] sbox_1_out1_data;
wire sbox_1_out1_wr;
wire sbox_1_out1_full;
wire [31 : 0] sbox_1_out2_data;
wire sbox_1_out2_wr;
wire sbox_1_out2_full;
	
// actor sbox_2
wire [31 : 0] sbox_2_in1_data;
wire sbox_2_in1_wr;
wire sbox_2_in1_full;
wire [31 : 0] sbox_2_out1_data;
wire sbox_2_out1_wr;
wire sbox_2_out1_full;
wire [31 : 0] sbox_2_out2_data;
wire sbox_2_out2_wr;
wire sbox_2_out2_full;
	
// actor sbox_3
wire [31 : 0] sbox_3_in1_data;
wire sbox_3_in1_wr;
wire sbox_3_in1_full;
wire [31 : 0] sbox_3_in2_data;
wire sbox_3_in2_wr;
wire sbox_3_in2_full;
wire [31 : 0] sbox_3_out1_data;
wire sbox_3_out1_wr;
wire sbox_3_out1_full;
// ----------------------------------------------------------------------------

// body
// ----------------------------------------------------------------------------
// Network Configurator
configurator config_0 (
	.sel(sel),
	.ID(ID)
);



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


// fifo_small_mul_mdc_0_a
fifo_small #(
	.depth(64),
	.size(32)
) fifo_small_mul_mdc_0_a(
	.datain(fifo_small_mul_mdc_0_a_data),
	.dataout(mul_mdc_0_a_data),
	.enr(mul_mdc_0_a_rd),
	.enw(fifo_small_mul_mdc_0_a_wr),
	.valid(mul_mdc_0_a_valid),
	.full(fifo_small_mul_mdc_0_a_full),
	
	// System Signal(s)
	.clk(clock),
	.rst(reset)
);
// fifo_small_mul_mdc_0_b
fifo_small #(
	.depth(64),
	.size(32)
) fifo_small_mul_mdc_0_b(
	.datain(fifo_small_mul_mdc_0_b_data),
	.dataout(mul_mdc_0_b_data),
	.enr(mul_mdc_0_b_rd),
	.enw(fifo_small_mul_mdc_0_b_wr),
	.valid(mul_mdc_0_b_valid),
	.full(fifo_small_mul_mdc_0_b_full),
	
	// System Signal(s)
	.clk(clock),
	.rst(reset)
);
// fifo_small_mul_mdc_0_c
fifo_small #(
	.depth(64),
	.size(32)
) fifo_small_mul_mdc_0_c(
	.datain(fifo_small_mul_mdc_0_c_data),
	.dataout(mul_mdc_0_c_data),
	.enr(mul_mdc_0_c_rd),
	.enw(fifo_small_mul_mdc_0_c_wr),
	.valid(mul_mdc_0_c_valid),
	.full(fifo_small_mul_mdc_0_c_full),
	
	// System Signal(s)
	.clk(clock),
	.rst(reset)
);

// actor mul_mdc_0
mul_mdc actor_mul_mdc_0 (
	// Input Signal(s)
	.a_TDATA(mul_mdc_0_a_data),
	.a_TREADY(mul_mdc_0_a_rd),
	.a_TVALID(mul_mdc_0_a_valid),
	.b_TDATA(mul_mdc_0_b_data),
	.b_TREADY(mul_mdc_0_b_rd),
	.b_TVALID(mul_mdc_0_b_valid),
	.c_TDATA(mul_mdc_0_c_data),
	.c_TREADY(mul_mdc_0_c_rd),
	.c_TVALID(mul_mdc_0_c_valid)
	,
	
	// Output Signal(s)
	.d_TDATA(mul_mdc_0_d_data),
	.d_TVALID(mul_mdc_0_d_wr),
	.d_TREADY(mul_mdc_0_d_full)
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



// actor sbox_0
sbox1x2 #(
	.SIZE(32)
)
sbox_0 (
	// Input Signal(s)
	.in1_data(sbox_0_in1_data),
	.in1_wr(sbox_0_in1_wr),
	.in1_full(sbox_0_in1_full),
	
	// Output Signal(s)
	.out1_data(sbox_0_out1_data),
	.out1_wr(sbox_0_out1_wr),
	.out1_full(sbox_0_out1_full),
	.out2_data(sbox_0_out2_data),
	.out2_wr(sbox_0_out2_wr),
	.out2_full(sbox_0_out2_full),
	
	// Selector
	.sel(sel[0])	
);


// actor sbox_1
sbox1x2 #(
	.SIZE(32)
)
sbox_1 (
	// Input Signal(s)
	.in1_data(sbox_1_in1_data),
	.in1_wr(sbox_1_in1_wr),
	.in1_full(sbox_1_in1_full),
	
	// Output Signal(s)
	.out1_data(sbox_1_out1_data),
	.out1_wr(sbox_1_out1_wr),
	.out1_full(sbox_1_out1_full),
	.out2_data(sbox_1_out2_data),
	.out2_wr(sbox_1_out2_wr),
	.out2_full(sbox_1_out2_full),
	
	// Selector
	.sel(sel[1])	
);


// actor sbox_2
sbox1x2 #(
	.SIZE(32)
)
sbox_2 (
	// Input Signal(s)
	.in1_data(sbox_2_in1_data),
	.in1_wr(sbox_2_in1_wr),
	.in1_full(sbox_2_in1_full),
	
	// Output Signal(s)
	.out1_data(sbox_2_out1_data),
	.out1_wr(sbox_2_out1_wr),
	.out1_full(sbox_2_out1_full),
	.out2_data(sbox_2_out2_data),
	.out2_wr(sbox_2_out2_wr),
	.out2_full(sbox_2_out2_full),
	
	// Selector
	.sel(sel[2])	
);


// actor sbox_3
sbox2x1 #(
	.SIZE(32)
)
sbox_3 (
	// Input Signal(s)
	.in1_data(sbox_3_in1_data),
	.in1_wr(sbox_3_in1_wr),
	.in1_full(sbox_3_in1_full),
	.in2_data(sbox_3_in2_data),
	.in2_wr(sbox_3_in2_wr),
	.in2_full(sbox_3_in2_full),
	
	// Output Signal(s)
	.out1_data(sbox_3_out1_data),
	.out1_wr(sbox_3_out1_wr),
	.out1_full(sbox_3_out1_full),
	
	// Selector
	.sel(sel[3])	
);

// Module(s) Assignments
assign fifo_small_mac_mdc_0_a_data = sbox_0_out1_data;
assign fifo_small_mac_mdc_0_a_wr = sbox_0_out1_wr;
assign sbox_0_out1_full = fifo_small_mac_mdc_0_a_full;

assign fifo_small_mac_mdc_0_b_data = sbox_1_out1_data;
assign fifo_small_mac_mdc_0_b_wr = sbox_1_out1_wr;
assign sbox_1_out1_full = fifo_small_mac_mdc_0_b_full;

assign fifo_small_mac_mdc_0_c_data = sbox_2_out1_data;
assign fifo_small_mac_mdc_0_c_wr = sbox_2_out1_wr;
assign sbox_2_out1_full = fifo_small_mac_mdc_0_c_full;

assign sbox_3_in1_data = mac_mdc_0_d_data;
assign sbox_3_in1_wr = mac_mdc_0_d_wr;
assign mac_mdc_0_d_full = sbox_3_in1_full;

assign sbox_0_in1_data = inStream0_data;
assign sbox_0_in1_wr = inStream0_wr;
assign inStream0_full = sbox_0_in1_full;

assign fifo_small_mul_mdc_0_a_data = sbox_0_out2_data;
assign fifo_small_mul_mdc_0_a_wr = sbox_0_out2_wr;
assign sbox_0_out2_full = fifo_small_mul_mdc_0_a_full;

assign sbox_1_in1_data = inStream1_data;
assign sbox_1_in1_wr = inStream1_wr;
assign inStream1_full = sbox_1_in1_full;

assign fifo_small_mul_mdc_0_b_data = sbox_1_out2_data;
assign fifo_small_mul_mdc_0_b_wr = sbox_1_out2_wr;
assign sbox_1_out2_full = fifo_small_mul_mdc_0_b_full;

assign sbox_2_in1_data = inStream2_data;
assign sbox_2_in1_wr = inStream2_wr;
assign inStream2_full = sbox_2_in1_full;

assign fifo_small_mul_mdc_0_c_data = sbox_2_out2_data;
assign fifo_small_mul_mdc_0_c_wr = sbox_2_out2_wr;
assign sbox_2_out2_full = fifo_small_mul_mdc_0_c_full;

assign outStream0_data = sbox_3_out1_data;
assign outStream0_wr = sbox_3_out1_wr;
assign sbox_3_out1_full = outStream0_full;

assign sbox_3_in2_data = mul_mdc_0_d_data;
assign sbox_3_in2_wr = mul_mdc_0_d_wr;
assign mul_mdc_0_d_full = sbox_3_in2_full;

endmodule
