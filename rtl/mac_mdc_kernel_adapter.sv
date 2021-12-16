

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

import mac_mdc_package::*;

module mac_mdc_kernel_adapter (
  // Global signals
  input  logic          clk_i,
  input  logic          rst_ni,
  input  logic          test_mode_i,

  // Sink ports
  hwpe_stream_intf_stream.sink a_i,
  hwpe_stream_intf_stream.sink b_i,
  hwpe_stream_intf_stream.sink c_i,

  // Source ports
  hwpe_stream_intf_stream.source d_o,

  // Kernel parameters
  input logic [0:0] reg_simple_mul,
  input logic [7:0] reg_shift,
  input logic [15:0] reg_len,

  // Control signals
  input  ctrl_kernel_adapter_t           ctrl_i,

  // Flag signals
  output  flags_kernel_adapter_t           flags_o

);

  /* mac_mdc control signals. */

  logic kernel_start;

  // START is not always high. For each READY (~(engine_ready | engine_idle)) that is
  // delivered to the FSM, a new START signal is set high and iaaued to the kernel.

  assign kernel_start = ctrl_i.start;

  /* mac_mdc flag signals. */

  // logic kernel_ready_a; //FIXEME: to be removed
  logic kernel_done_a;

  // logic kernel_ready_b; //FIXEME: to be removed
  logic kernel_done_b;

  // logic kernel_ready_c; //FIXEME: to be removed
  logic kernel_done_c;

  logic kernel_done_d;

  logic kernel_idle;
  // logic kernel_ready;

  /* Done. */
  // A done is generated for each output. These are counted and
  // delivered to the FSM that decides when to update the address
  // on the basis of the state of the line processing (see HWPE-docs).

  // FIXME: This temporarily works synch-outputs.
  // EX: What if Out_0 is provided at each input and Out_1 once per 10 inputs?
  assign flags_o.done = kernel_done_d;

  always_ff @(posedge clk_i or negedge rst_ni)
  begin: fsm_done_d
    if(~rst_ni)
      kernel_done_d = 1'b0;
    else if((d_o.valid)&(d_o.ready))
      kernel_done_d = 1'b1;
    else
      kernel_done_d = 1'b0;
  end

  /* Ready. */
  /* This is used in the hwpe-engine to set flags_o.ready.
     The latter triggers the START of accelerator. (see FSM_COMPUTE). */
  /* Driven using input counters. */

  assign flags_o.ready = kernel_done_a & kernel_done_b & kernel_done_c;

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
      if( kernel_done_d ) begin
        /* If the Start signal is Low when Ready is High, the design stops operation, and
            the ap_idle signal goes High one cycle after ap_done.*/
        kernel_idle = 1'b1;
      end
    end
    else begin
			kernel_idle = kernel_idle;
    end
  end

  /* mac_mdc input counters. Ready. */

  logic unsigned [($clog2(MAC_MDC_CNT_LEN)+1):0] kernel_cnt_a;

  always_ff @(posedge clk_i or negedge rst_ni)
  begin: engine_cnt_a
    if((~rst_ni) | kernel_start) begin
      kernel_cnt_a = 32'b0;
    end
    else if(kernel_start) begin
      kernel_cnt_a = 32'b0;
    end
    else if ((a_i.valid) & (a_i.ready)) begin
      kernel_cnt_a = kernel_cnt_a + 1;
    end
    else begin
      kernel_cnt_a = kernel_cnt_a;
    end
  end

  // FIXME: Now kernel_done_in goes High every time an input enters the acc.
  // This should be generalized. Even though the wrapper looper is designed to
  // on counting the ouputs, the number of inputs needed to generate an ouput
  // are usually > 1.
  // SOL: Add to ctrl_i also the information about max_input.
  assign kernel_done_a = (kernel_cnt_a==1) ? 1 : 0;

  logic unsigned [($clog2(MAC_MDC_CNT_LEN)+1):0] kernel_cnt_b;

  always_ff @(posedge clk_i or negedge rst_ni)
  begin: engine_cnt_b
    if((~rst_ni) | kernel_start) begin
      kernel_cnt_b = 32'b0;
    end
    else if(kernel_start) begin
      kernel_cnt_b = 32'b0;
    end
    else if ((b_i.valid) & (b_i.ready)) begin
      kernel_cnt_b = kernel_cnt_b + 1;
    end
    else begin
      kernel_cnt_b = kernel_cnt_b;
    end
  end

  // FIXME: Now kernel_done_in goes High every time an input enters the acc.
  // This should be generalized. Even though the wrapper looper is designed to
  // on counting the ouputs, the number of inputs needed to generate an ouput
  // are usually > 1.
  // SOL: Add to ctrl_i also the information about max_input.
  assign kernel_done_b = (kernel_cnt_b==1) ? 1 : 0;

  logic unsigned [($clog2(MAC_MDC_CNT_LEN)+1):0] kernel_cnt_c;

  always_ff @(posedge clk_i or negedge rst_ni)
  begin: engine_cnt_c
    if((~rst_ni) | kernel_start) begin
      kernel_cnt_c = 32'b0;
    end
    else if(kernel_start) begin
      kernel_cnt_c = 32'b0;
    end
    else if ((c_i.valid) & (c_i.ready)) begin
      kernel_cnt_c = kernel_cnt_c + 1;
    end
    else begin
      kernel_cnt_c = kernel_cnt_c;
    end
  end

  // FIXME: Now kernel_done_in goes High every time an input enters the acc.
  // This should be generalized. Even though the wrapper looper is designed to
  // on counting the ouputs, the number of inputs needed to generate an ouput
  // are usually > 1.
  // SOL: Add to ctrl_i also the information about max_input.
  assign kernel_done_c = (kernel_cnt_c==1) ? 1 : 0;

    /* mac_mdc output counters. */

  logic unsigned [($clog2(MAC_MDC_CNT_LEN)+1):0] kernel_cnt_d;

  // Suggested design:
  //      ap_done = done_out0 & ... & done_outM;
  //      done_outM = cnt_out,i == ctrl_i.max_out,i; (for i=1,..,N)
  // However, loop ctrl is already implemented in micro-code looper that sits
  // in the hwpe-ctrl. Thus, the done information provided by this stage should
  // concern a single output element, not a tile (block,..).
  // FIXME: At this point, cnt_out is not essential here and could be removed.

  always_ff @(posedge clk_i or negedge rst_ni)
  begin: engine_cnt_d
    if((~rst_ni) | kernel_start)
      kernel_cnt_d = 32'b0;
    else if(!kernel_idle) begin
      if((d_o.valid)&(d_o.ready))
        kernel_cnt_d = kernel_cnt_d + 1;
      else
        kernel_cnt_d = kernel_cnt_d;
    end
  end

  assign cnt_d = kernel_cnt_d;

  /* mac_mdc kernel interface. */

  mac_mdc i_mac_mdc (
    // Global signals.
    .ap_clk             ( clk_i            ),
    .ap_rst_n           ( rst_ni           ),

    // Kernel parameters
    .reg_simple_mul        ( reg_simple_mul ),
    .reg_shift        ( reg_shift ),
    .reg_len        ( reg_len ),

    // Sink ports
    .a_TDATA  ( a_i.data  ),
    .a_TVALID ( a_i.valid ),
    .a_TREADY ( a_i.ready ),
    .b_TDATA  ( b_i.data  ),
    .b_TVALID ( b_i.valid ),
    .b_TREADY ( b_i.ready ),
    .c_TDATA  ( c_i.data  ),
    .c_TVALID ( c_i.valid ),
    .c_TREADY ( c_i.ready ),

    // Source ports

    .d_TDATA  ( d_o.data  ),
    .d_TVALID ( d_o.valid ),
    .d_TREADY ( d_o.ready )

  );

endmodule
