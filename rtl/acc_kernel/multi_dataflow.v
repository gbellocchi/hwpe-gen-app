// ----------------------------------------------------------------------------
//
// Multi-Dataflow Composer tool - Platform Composer
// Multi-Dataflow Network module 
// Date: 2022/04/01 13:15:24
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
	
	// Monitoring
	
	// Configuration ID
	
	
	// System Signal(s)		
	input clock,
	input reset
);	

// internal signals
// ----------------------------------------------------------------------------
		


// Actors Wire(s)
	
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
// ----------------------------------------------------------------------------

// body
// ----------------------------------------------------------------------------



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


// Module(s) Assignments
assign fifo_small_fir_64_mdc_0_x_V_data = inStream0_data;
assign fifo_small_fir_64_mdc_0_x_V_wr = inStream0_wr;
assign inStream0_full = fifo_small_fir_64_mdc_0_x_V_full;

assign outStream0_data = fir_64_mdc_0_y_V_data;
assign outStream0_wr = fir_64_mdc_0_y_V_wr;
assign fir_64_mdc_0_y_V_full = outStream0_full;

endmodule
