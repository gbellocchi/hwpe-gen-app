// ----------------------------------------------------------------------------
//
// This file has been automatically generated by:
// Multi-Dataflow Composer tool - Platform Composer
// Template Interface Layer module - Memory-Mapped type
// on 2022/03/25 13:35:14
// More info available at http://sites.unica.it/rpct/
//
// ----------------------------------------------------------------------------
import multi_dataflow_package::*;
import hwpe_ctrl_package::*;

// ----------------------------------------------------------------------------
// Module Interface
// ----------------------------------------------------------------------------
module multi_dataflow_reconf_datapath_top 
(
	// Sink ports
	hwpe_stream_intf_stream.sink    inStream0,
	hwpe_stream_intf_stream.sink    inStream1,
	hwpe_stream_intf_stream.sink    inStream2,
	// Source ports
	hwpe_stream_intf_stream.source  outStream0,
	// Algorithm parameters
	logic unsigned [(32-1):0] 		reg_simple_mul,
	logic unsigned [(32-1):0] 		reg_shift,
	logic unsigned [(32-1):0] 		reg_len,
	// Multi-Dataflow Kernel ID
	  input logic [7:0]					ID,
	// Global signals
	input  logic                      clk_i,
	input  logic                      rst_ni
);


// ----------------------------------------------------------------------------
// Module Signals
// ----------------------------------------------------------------------------
// Communication signals
wire [31 : 0] inStream0_data;
wire inStream0_push;
wire inStream0_full;
wire [31:0] stream_if_inStream0_data;
wire stream_if_inStream0_valid;
wire stream_if_inStream0_ready;
wire [31 : 0] inStream1_data;
wire inStream1_push;
wire inStream1_full;
wire [31:0] stream_if_inStream1_data;
wire stream_if_inStream1_valid;
wire stream_if_inStream1_ready;
wire [31 : 0] inStream2_data;
wire inStream2_push;
wire inStream2_full;
wire [31:0] stream_if_inStream2_data;
wire stream_if_inStream2_valid;
wire stream_if_inStream2_ready;
wire [31 : 0] outStream0_data;
wire outStream0_push;
wire outStream0_full;
wire [31:0] stream_if_outStream0_data;
wire stream_if_outStream0_valid;
wire stream_if_outStream0_ready;


// ----------------------------------------------------------------------------
// Body
// ----------------------------------------------------------------------------
// hwpe strem interface wrappers
// hwpe stream intf in inStream0
interface_wrapper_in i_interface_wrapper_in_inStream0(
	.in_data(stream_if_inStream0_data),
	.in_valid(stream_if_inStream0_valid),
	.in_ready(stream_if_inStream0_ready),
	.in(inStream0)
);
// hwpe stream intf in inStream1
interface_wrapper_in i_interface_wrapper_in_inStream1(
	.in_data(stream_if_inStream1_data),
	.in_valid(stream_if_inStream1_valid),
	.in_ready(stream_if_inStream1_ready),
	.in(inStream1)
);
// hwpe stream intf in inStream2
interface_wrapper_in i_interface_wrapper_in_inStream2(
	.in_data(stream_if_inStream2_data),
	.in_valid(stream_if_inStream2_valid),
	.in_ready(stream_if_inStream2_ready),
	.in(inStream2)
);
// hwpe stream intf out outStream0
interface_wrapper_out i_interface_wrapper_out_outStream0(
	.out_data(stream_if_outStream0_data),
	.out_valid(stream_if_outStream0_valid),
	.out_ready(stream_if_outStream0_ready),
	.out(outStream0)
);

// Multi-Dataflow Reconfigurable Datapath
// ----------------------------------------------------------------------------
// to adapt profiling
multi_dataflow reconf_dpath (
	// Multi-Dataflow Input(s)
	.inStream0_data(inStream0_data),
	.inStream0_wr(inStream0_push),
	.inStream0_full(inStream0_full),
	.inStream1_data(inStream1_data),
	.inStream1_wr(inStream1_push),
	.inStream1_full(inStream1_full),
	.inStream2_data(inStream2_data),
	.inStream2_wr(inStream2_push),
	.inStream2_full(inStream2_full),
	// Multi-Dataflow Output(s)
	.outStream0_data(outStream0_data),
	.outStream0_wr(outStream0_push),
	.outStream0_full(outStream0_full),
	// Algorithm parameters
	   .reg_simple_mul        (  reg_simple_mul      ),
	   .reg_shift        (  reg_shift      ),
	   .reg_len        (  reg_len      ),
	.clock(clk_i),
	.reset(rst_ni),
// Multi-Dataflow Kernel ID
	.ID(ID)
);
assign stream_if_inStream0_ready = ~inStream0_full;
assign inStream0_data = stream_if_inStream0_data;
assign inStream0_push = stream_if_inStream0_valid;
assign stream_if_inStream1_ready = ~inStream1_full;
assign inStream1_data = stream_if_inStream1_data;
assign inStream1_push = stream_if_inStream1_valid;
assign stream_if_inStream2_ready = ~inStream2_full;
assign inStream2_data = stream_if_inStream2_data;
assign inStream2_push = stream_if_inStream2_valid;
assign stream_if_outStream0_valid = outStream0_push;
assign stream_if_outStream0_data = outStream0_data;
assign outStream0_full = stream_if_outStream0_ready;

endmodule
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
