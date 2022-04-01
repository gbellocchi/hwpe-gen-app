// ----------------------------------------------------------------------------
//
// Multi-Dataflow Composer tool - Platform Composer
// Multi-Dataflow Network module 
// Date: 2022/04/01 14:01:00
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
	
// actor fir_128_mdc_0
wire [31 : 0] fifo_small_fir_128_mdc_0_x_V_data;
wire fifo_small_fir_128_mdc_0_x_V_wr;
wire fifo_small_fir_128_mdc_0_x_V_full;
wire [31 : 0] fir_128_mdc_0_x_V_data;
wire fir_128_mdc_0_x_V_rd;
wire fir_128_mdc_0_x_V_valid;
wire [31 : 0] fir_128_mdc_0_y_V_data;
wire fir_128_mdc_0_y_V_wr;
wire fir_128_mdc_0_y_V_full;
	
// actor fir_64_mdc_0
wire [31 : 0] fifo_small_fir_64_mdc_0_x_V_data;
wire fifo_small_fir_64_mdc_0_x_V_wr;
wire fifo_small_fir_64_mdc_0_x_V_full;
wire [31 : 0] fir_64_mdc_0_x_V_data;
wire fir_64_mdc_0_x_V_rd;
wire fir_64_mdc_0_x_V_valid;
wire [31 : 0] fir_64_mdc_0_y_V_data;
wire fir_64_mdc_0_y_V_wr;
wire fir_64_mdc_0_y_V_full;
	
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
wire [31 : 0] sbox_1_in2_data;
wire sbox_1_in2_wr;
wire sbox_1_in2_full;
wire [31 : 0] sbox_1_out1_data;
wire sbox_1_out1_wr;
wire sbox_1_out1_full;
	
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



// fifo_small_fir_128_mdc_0_x_V
fifo_small #(
	.depth(64),
	.size(32)
) fifo_small_fir_128_mdc_0_x_V(
	.datain(fifo_small_fir_128_mdc_0_x_V_data),
	.dataout(fir_128_mdc_0_x_V_data),
	.enr(fir_128_mdc_0_x_V_rd),
	.enw(fifo_small_fir_128_mdc_0_x_V_wr),
	.valid(fir_128_mdc_0_x_V_valid),
	.full(fifo_small_fir_128_mdc_0_x_V_full),
	
	// System Signal(s)
	.clk(clock),
	.rst(reset)
);

// actor fir_128_mdc_0
fir_128_mdc actor_fir_128_mdc_0 (
	// Input Signal(s)
	.x_V_TDATA(fir_128_mdc_0_x_V_data),
	.x_V_TREADY(fir_128_mdc_0_x_V_rd),
	.x_V_TVALID(fir_128_mdc_0_x_V_valid)
	,
	
	// Output Signal(s)
	.y_V_TDATA(fir_128_mdc_0_y_V_data),
	.y_V_TVALID(fir_128_mdc_0_y_V_wr),
	.y_V_TREADY(fir_128_mdc_0_y_V_full)
		,
	
	// System Signal(s)
	.ap_clk(clock),
	.ap_rst_n(reset)
);


// fifo_small_fir_64_mdc_0_x_V
fifo_small #(
	.depth(64),
	.size(32)
) fifo_small_fir_64_mdc_0_x_V(
	.datain(fifo_small_fir_64_mdc_0_x_V_data),
	.dataout(fir_64_mdc_0_x_V_data),
	.enr(fir_64_mdc_0_x_V_rd),
	.enw(fifo_small_fir_64_mdc_0_x_V_wr),
	.valid(fir_64_mdc_0_x_V_valid),
	.full(fifo_small_fir_64_mdc_0_x_V_full),
	
	// System Signal(s)
	.clk(clock),
	.rst(reset)
);

// actor fir_64_mdc_0
fir_64_mdc actor_fir_64_mdc_0 (
	// Input Signal(s)
	.x_V_TDATA(fir_64_mdc_0_x_V_data),
	.x_V_TREADY(fir_64_mdc_0_x_V_rd),
	.x_V_TVALID(fir_64_mdc_0_x_V_valid)
	,
	
	// Output Signal(s)
	.y_V_TDATA(fir_64_mdc_0_y_V_data),
	.y_V_TVALID(fir_64_mdc_0_y_V_wr),
	.y_V_TREADY(fir_64_mdc_0_y_V_full)
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
sbox2x1 #(
	.SIZE(32)
)
sbox_1 (
	// Input Signal(s)
	.in1_data(sbox_1_in1_data),
	.in1_wr(sbox_1_in1_wr),
	.in1_full(sbox_1_in1_full),
	.in2_data(sbox_1_in2_data),
	.in2_wr(sbox_1_in2_wr),
	.in2_full(sbox_1_in2_full),
	
	// Output Signal(s)
	.out1_data(sbox_1_out1_data),
	.out1_wr(sbox_1_out1_wr),
	.out1_full(sbox_1_out1_full),
	
	// Selector
	.sel(sel[1])	
);

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
assign fifo_small_fir_128_mdc_0_x_V_data = sbox_0_out1_data;
assign fifo_small_fir_128_mdc_0_x_V_wr = sbox_0_out1_wr;
assign sbox_0_out1_full = fifo_small_fir_128_mdc_0_x_V_full;

assign sbox_1_in1_data = fir_128_mdc_0_y_V_data;
assign sbox_1_in1_wr = fir_128_mdc_0_y_V_wr;
assign fir_128_mdc_0_y_V_full = sbox_1_in1_full;

assign sbox_0_in1_data = sbox_2_out1_data;
assign sbox_0_in1_wr = sbox_2_out1_wr;
assign sbox_2_out1_full = sbox_0_in1_full;

assign fifo_small_fir_64_mdc_0_x_V_data = sbox_0_out2_data;
assign fifo_small_fir_64_mdc_0_x_V_wr = sbox_0_out2_wr;
assign sbox_0_out2_full = fifo_small_fir_64_mdc_0_x_V_full;

assign sbox_3_in1_data = sbox_1_out1_data;
assign sbox_3_in1_wr = sbox_1_out1_wr;
assign sbox_1_out1_full = sbox_3_in1_full;

assign sbox_1_in2_data = fir_64_mdc_0_y_V_data;
assign sbox_1_in2_wr = fir_64_mdc_0_y_V_wr;
assign fir_64_mdc_0_y_V_full = sbox_1_in2_full;

assign sbox_2_in1_data = inStream0_data;
assign sbox_2_in1_wr = inStream0_wr;
assign inStream0_full = sbox_2_in1_full;

assign fifo_small_conv_mdc_0_src_V_data = sbox_2_out2_data;
assign fifo_small_conv_mdc_0_src_V_wr = sbox_2_out2_wr;
assign sbox_2_out2_full = fifo_small_conv_mdc_0_src_V_full;

assign outStream0_data = sbox_3_out1_data;
assign outStream0_wr = sbox_3_out1_wr;
assign sbox_3_out1_full = outStream0_full;

assign sbox_3_in2_data = conv_mdc_0_dst_V_data;
assign sbox_3_in2_wr = conv_mdc_0_dst_V_wr;
assign conv_mdc_0_dst_V_full = sbox_3_in2_full;

endmodule
