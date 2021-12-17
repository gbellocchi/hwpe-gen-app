

/*
 * HWPE: Francesco Conti <fconti@iis.ee.ethz.ch>
 *
 * Copyright (C) 2018 ETH Zurich, University of Bologna
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * HWPE author: Francesco Conti <fconti@iis.ee.ethz.ch>
 * HWPE specialization tool: Gianluca Bellocchi <gianluca.bellocchi@unimore.it>
 *
 * Module: conv_mdc_engine.sv
 *
 */

import conv_mdc_package::*;

module conv_mdc_engine (
  // Global signals
  input  logic          clk_i,
  input  logic          rst_ni,
  input  logic          test_mode_i,

  // Sink ports
  hwpe_stream_intf_stream.sink src_V_i,

  // Source ports
  hwpe_stream_intf_stream.source dst_V_o,

  // Control channel
  input  ctrl_engine_t            ctrl_i,
  output flags_engine_t           flags_o
);

  /* Control signals */

  ctrl_kernel_adapter_t ctrl_k_ad;

  assign ctrl_k_ad.start = ctrl_i.start;

  /* Flag signals */

  flags_kernel_adapter_t flags_k_ad;

  assign flags_o.done = flags_k_ad.done;

  always_ff @(posedge clk_i or negedge rst_ni)
  begin: fsm_ready
    if(~rst_ni)
      flags_o.ready = 1'b0;
    else if(~(flags_k_ad.ready | flags_k_ad.idle))
      flags_o.ready = 1'b0;
    else
      flags_o.ready = 1'b1;
  end

  /* Count outputs */

  // Declaration of trackers

  logic track_dst_V_q, track_dst_V_d;

  // Declaration of counters

  logic unsigned [($clog2(CONV_MDC_CNT_LEN)+1):0] cnt_dst_V;

  // AND-ed trackers implementation (FF)

  always_comb
  begin: dst_V_track_q
    if(~rst_ni | ctrl_i.clear) begin
      track_dst_V_d = '0;
    end
    else if(dst_V_o.valid & dst_V_o.ready) begin
      track_dst_V_d = '1;
    end
    else begin
      track_dst_V_d = '0;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni)
  begin: dst_V_track_d
    if(~rst_ni) begin
      track_dst_V_q <= '0;
    end
    else if(ctrl_i.clear) begin
      track_dst_V_q <= '0;
    end
    else begin
      track_dst_V_q <= track_dst_V_d;
    end
  end

  // Counter implementation (FF)

  always_ff @(posedge clk_i or negedge rst_ni)
  begin: dst_V_cnt
    if((~rst_ni) | ctrl_i.clear)
      cnt_dst_V = 32'b0;
    else if( track_dst_V_q & flags_o.done )
      cnt_dst_V = cnt_dst_V + 1;
    else
      cnt_dst_V = cnt_dst_V;
  end

  // Assign to fsm flags
  assign flags_o.cnt_dst_V = cnt_dst_V;

  /* Kernel adapter */

  conv_mdc_kernel_adapter i_conv_mdc_adapter (

    // Global signals
    .clk_i           ( clk_i            ),
    .rst_ni          ( rst_ni           ),
    .test_mode_i     ( test_mode_i      ),

    // Data streams
    .src_V_i ( src_V_i  ),
    .dst_V_o ( dst_V_o  ),

    // Kernel parameters
    .width        ( ctrl_i.width      ),
    .height        ( ctrl_i.height      ),

    // Control signals
    .ctrl_i      ( ctrl_k_ad            ),

    // Flag signals
    .flags_o       ( flags_k_ad             )

  );

  // At the moment output strobe is always '1
  // All bytes of output streams are written
  // to TCDM
  always_comb
  begin
    dst_V_o.strb = '1;
  end

endmodule
