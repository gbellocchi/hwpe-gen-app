

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
 * Module: mac_mdc_engine.sv
 *
 */

import mac_mdc_package::*;

module mac_mdc_engine (
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

  logic track_d_q, track_d_d;

  // Declaration of counters

  logic unsigned [($clog2(MAC_MDC_CNT_LEN)+1):0] cnt_d;

  // AND-ed trackers implementation (FF)

  always_comb
  begin: d_track_q
    if(~rst_ni | ctrl_i.clear) begin
      track_d_d = '0;
    end
    else if(d_o.valid & d_o.ready) begin
      track_d_d = '1;
    end
    else begin
      track_d_d = '0;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni)
  begin: d_track_d
    if(~rst_ni) begin
      track_d_q <= '0;
    end
    else if(ctrl_i.clear) begin
      track_d_q <= '0;
    end
    else begin
      track_d_q <= track_d_d;
    end
  end

  // Counter implementation (FF)

  always_ff @(posedge clk_i or negedge rst_ni)
  begin: d_cnt
    if((~rst_ni) | ctrl_i.clear)
      cnt_d = 32'b0;
    else if( track_d_q & flags_o.done )
      cnt_d = cnt_d + 1;
    else
      cnt_d = cnt_d;
  end

  // Assign to fsm flags
  assign flags_o.cnt_d = cnt_d;

  /* Kernel adapter */

  mac_mdc_kernel_adapter i_mac_mdc_adapter (

    // Global signals
    .clk_i           ( clk_i            ),
    .rst_ni          ( rst_ni           ),
    .test_mode_i     ( test_mode_i      ),

    // Data streams
    .a_i ( a_i  ),
    .b_i ( b_i  ),
    .c_i ( c_i  ),
    .d_o ( d_o  ),

    // Kernel parameters
    .reg_simple_mul        ( ctrl_i.reg_simple_mul      ),
    .reg_shift        ( ctrl_i.reg_shift      ),
    .reg_len        ( ctrl_i.reg_len      ),

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
    d_o.strb = '1;
  end

endmodule
