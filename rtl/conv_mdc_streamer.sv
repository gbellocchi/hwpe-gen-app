

/*
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
 * Module: conv_mdc_streamer.sv
 *
 */

import conv_mdc_package::*;
import hwpe_stream_package::*;

module conv_mdc_streamer
#(
  parameter int unsigned MP  = 2, // number of master ports
  parameter int unsigned FD  = 2 // FIFO depth
)
(
  // Global signals
  input  logic          clk_i,
  input  logic          rst_ni,
  input  logic          test_mode_i,

  // Local enable & clear
  input  logic          enable_i,
  input  logic          clear_i,

  // TCDM interface

  hwpe_stream_intf_tcdm.master tcdm [MP-1:0],

  // Streaming interfaces

  hwpe_stream_intf_stream.source src_V,

  hwpe_stream_intf_stream.sink dst_V,

  // control channel
  input  ctrl_streamer_t  ctrl_i,
  output flags_streamer_t flags_o
);

  // TCDM ready signals

  logic tcdm_fifo_ready_src_V;

  // TCDM interface

  hwpe_stream_intf_tcdm tcdm_fifo_src_V [0:0] ( .clk (clk_i) );

  hwpe_stream_intf_tcdm tcdm_fifo_dst_V [0:0] ( .clk (clk_i) );

  // Streaming interface

  hwpe_stream_intf_stream #( .DATA_WIDTH(32) ) stream_fifo_src_V ( .clk (clk_i) );

  hwpe_stream_intf_stream #( .DATA_WIDTH(32) ) stream_fifo_dst_V ( .clk (clk_i) );

  // TCDM-side FIFO - Inputs

  hwpe_stream_tcdm_fifo_load #(
    .FIFO_DEPTH ( 4 )
  ) i_src_V_tcdm_fifo_load (
    .clk_i       ( clk_i                                    ),
    .rst_ni      ( rst_ni                                   ),
    .clear_i     ( clear_i                                  ),
    .flags_o     (                                          ),
    .ready_i     ( tcdm_fifo_ready_src_V          ),
    .tcdm_slave  ( tcdm_fifo_src_V[0]             ),
    .tcdm_master ( tcdm[0]                     )
  );

  // TCDM-side FIFO - Outputs

  hwpe_stream_tcdm_fifo_store #(
    .FIFO_DEPTH ( 4 )
  ) i_dst_V_tcdm_fifo_store (
    .clk_i       ( clk_i                                    ),
    .rst_ni      ( rst_ni                                   ),
    .clear_i     ( clear_i                                  ),
    .flags_o     (                                          ),
    .tcdm_slave  ( tcdm_fifo_dst_V[0]             ),
    .tcdm_master ( tcdm[1]                     )
  );

  // Engine-side FIFO - Inputs

  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_src_V_stream_fifo (
    .clk_i   ( clk_i                                      ),
    .rst_ni  ( rst_ni                                     ),
    .clear_i ( clear_i                                    ),
    .push_i  ( stream_fifo_src_V.sink      ),
    .pop_o   ( src_V                            ),
    .flags_o (                                            )
  );

  // Engine-side FIFO - Outputs

  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_dst_V_stream_fifo (
    .clk_i   ( clk_i                                      ),
    .rst_ni  ( rst_ni                                     ),
    .clear_i ( clear_i                                    ),
    .push_i  ( dst_V                           ),
    .pop_o   ( stream_fifo_dst_V.source         ),
    .flags_o (                                            )
  );

  // Source modules (TCDM -> HWPE)

  hwpe_stream_source #(
    .DATA_WIDTH   ( 32 ),
    .DECOUPLED    ( 1  ),
    .IS_ADDRESSGEN_PROGR  ( 1  )
  ) i_src_V_source (
    .clk_i              ( clk_i                                       ),
    .rst_ni             ( rst_ni                                      ),
    .test_mode_i        ( test_mode_i                                 ),
    .clear_i            ( clear_i                                     ),
    .tcdm               ( tcdm_fifo_src_V                   ),
    .stream             ( stream_fifo_src_V.source          ),
    .ctrl_i             ( ctrl_i.src_V_source_ctrl          ),
    .flags_o            ( flags_o.src_V_source_flags        ),
    .tcdm_fifo_ready_o  ( tcdm_fifo_ready_src_V             )
  );

  // Sink modules (TCDM <- HWPE)

  hwpe_stream_sink #(
    .DATA_WIDTH ( 32 ),
    .IS_ADDRESSGEN_PROGR  ( 1  )
    // .NB_TCDM_PORTS (    )
  ) i_dst_V_sink (
    .clk_i              ( clk_i                                       ),
    .rst_ni             ( rst_ni                                      ),
    .test_mode_i        ( test_mode_i                                 ),
    .clear_i            ( clear_i                                     ),
    .tcdm               ( tcdm_fifo_dst_V                  ),
    .stream             ( stream_fifo_dst_V.sink           ),
    .ctrl_i             ( ctrl_i.dst_V_sink_ctrl         ),
    .flags_o            ( flags_o.dst_V_sink_flags       )
  );

endmodule
