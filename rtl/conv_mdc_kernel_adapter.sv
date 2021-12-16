

/* =====================================================================
 * Project:      HWPE kernel adapter
 * Title:        hwpe_kernel_adapter.sv
 * Description:  Interface between hardware wrapper and accelerated kernel.
 *
 * $Date:        15.09.2021
 * ===================================================================== */
/*
 * Copyright (C) 2021 University of Modena and Reggio Emilia..
 *
 * Author: Gianluca Bellocchi, University of Modena and Reggio Emilia.
 *
 */

import conv_mdc_package::*;

module conv_mdc_kernel_adapter (
  // Global signals
  input  logic          clk_i,
  input  logic          rst_ni,
  input  logic          test_mode_i,

  // Sink ports
  hwpe_stream_intf_stream.sink src_V_i,

  // Source ports
  hwpe_stream_intf_stream.source dst_V_o,

  // Kernel parameters
  input logic [31:0] width,
  input logic [31:0] height,

  // Control signals
  input  ctrl_kernel_adapter_t           ctrl_i,

  // Flag signals
  output  flags_kernel_adapter_t           flags_o

);

  /* conv_mdc control signals. */

  logic kernel_start;

  // START is not always high. For each READY (~(engine_ready | engine_idle)) that is
  // delivered to the FSM, a new START signal is set high and iaaued to the kernel.

  assign kernel_start = ctrl_i.start;

  /* conv_mdc flag signals. */

  // logic kernel_ready_src_V; //FIXEME: to be removed
  logic kernel_done_src_V;

  logic kernel_done_dst_V;

  logic kernel_idle;
  // logic kernel_ready;

  /* Done. */
  // A done is generated for each output. These are counted and
  // delivered to the FSM that decides when to update the address
  // on the basis of the state of the line processing (see HWPE-docs).

  // FIXME: This temporarily works synch-outputs.
  // EX: What if Out_0 is provided at each input and Out_1 once per 10 inputs?
  assign flags_o.done = kernel_done_dst_V;

  always_ff @(posedge clk_i or negedge rst_ni)
  begin: fsm_done_dst_V
    if(~rst_ni)
      kernel_done_dst_V = 1'b0;
    else if((dst_V_o.valid)&(dst_V_o.ready))
      kernel_done_dst_V = 1'b1;
    else
      kernel_done_dst_V = 1'b0;
  end

  /* Ready. */
  /* This is used in the hwpe-engine to set flags_o.ready.
     The latter triggers the START of accelerator. (see FSM_COMPUTE). */
  /* Driven using input counters. */

  assign flags_o.ready = kernel_done_src_V;

  /* Idle. */
  /* This is used in the hwpe-engine to set flags_o.ready.
     The latter triggers the START of accelerator. (see FSM_COMPUTE). */
  /* For more infos refer to UG902. */

  assign flags_o.idle = kernel_idle;

  /* The Idle signal indicates when the design is idle and not operating. */
  always_ff @(posedge clk_i or negedge rst_ni)
  begin: fsm_idle
		if(~rst_ni) begin
      kernel_idle = 1'b0;
    end
    else if(kernel_start) begin
      /* Idle goes Low immediately after Start to indicate the design is no longer idle. */
      /* If the Start signal is High when Ready is High, the design continues to operate,
          and the Idle signal remains Low. */
			kernel_idle = 1'b0;
    end
    else if(!kernel_start) begin
    // else if((!kernel_start) & (ready)) begin # removed ready signal
      if( kernel_done_dst_V ) begin
        /* If the Start signal is Low when Ready is High, the design stops operation, and
            the ap_idle signal goes High one cycle after ap_done.*/
        kernel_idle = 1'b1;
      end
    end
    else begin
			kernel_idle = kernel_idle;
    end
  end

  /* conv_mdc input counters. Ready. */

  logic unsigned [($clog2(CONV_MDC_CNT_LEN)+1):0] kernel_cnt_src_V;

  always_ff @(posedge clk_i or negedge rst_ni)
  begin: engine_cnt_src_V
    if((~rst_ni) | kernel_start) begin
      kernel_cnt_src_V = 32'b0;
    end
    else if(kernel_start) begin
      kernel_cnt_src_V = 32'b0;
    end
    else if ((src_V_i.valid) & (src_V_i.ready)) begin
      kernel_cnt_src_V = kernel_cnt_src_V + 1;
    end
    else begin
      kernel_cnt_src_V = kernel_cnt_src_V;
    end
  end

  // FIXME: Now kernel_done_in goes High every time an input enters the acc.
  // This should be generalized. Even though the wrapper looper is designed to
  // on counting the ouputs, the number of inputs needed to generate an ouput
  // are usually > 1.
  // SOL: Add to ctrl_i also the information about max_input.
  assign kernel_done_src_V = (kernel_cnt_src_V==1) ? 1 : 0;

    /* conv_mdc output counters. */

  logic unsigned [($clog2(CONV_MDC_CNT_LEN)+1):0] kernel_cnt_dst_V;

  // Suggested design:
  //      ap_done = done_out0 & ... & done_outM;
  //      done_outM = cnt_out,i == ctrl_i.max_out,i; (for i=1,..,N)
  // However, loop ctrl is already implemented in micro-code looper that sits
  // in the hwpe-ctrl. Thus, the done information provided by this stage should
  // concern a single output element, not a tile (block,..).
  // FIXME: At this point, cnt_out is not essential here and could be removed.

  always_ff @(posedge clk_i or negedge rst_ni)
  begin: engine_cnt_dst_V
    if((~rst_ni) | kernel_start)
      kernel_cnt_dst_V = 32'b0;
    else if(!kernel_idle) begin
      if((dst_V_o.valid)&(dst_V_o.ready))
        kernel_cnt_dst_V = kernel_cnt_dst_V + 1;
      else
        kernel_cnt_dst_V = kernel_cnt_dst_V;
    end
  end

  assign cnt_dst_V = kernel_cnt_dst_V;

  /* conv_mdc kernel interface. */

  conv_mdc i_conv_mdc (
    // Global signals.
    .ap_clk             ( clk_i            ),
    .ap_rst_n           ( rst_ni           ),

    // Kernel parameters
    .width        ( width ),
    .height        ( height ),

    // Sink ports
    .src_V_TDATA  ( src_V_i.data  ),
    .src_V_TVALID ( src_V_i.valid ),
    .src_V_TREADY ( src_V_i.ready ),

    // Source ports

    .dst_V_TDATA  ( dst_V_o.data  ),
    .dst_V_TVALID ( dst_V_o.valid ),
    .dst_V_TREADY ( dst_V_o.ready )

  );

endmodule
