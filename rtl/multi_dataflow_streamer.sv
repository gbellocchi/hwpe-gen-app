
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
 * Module: multi_dataflow_streamer.sv
 *
 */

import multi_dataflow_package::*;
import hwpe_stream_package::*;

module multi_dataflow_streamer
#(
  parameter int unsigned MP = 3, // number of master ports
  parameter int unsigned FD = 2  // FIFO depth
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

  hwpe_stream_intf_stream.source in_pel,
  hwpe_stream_intf_stream.source in_size,

  hwpe_stream_intf_stream.sink out_pel,

  // control channel
  input  ctrl_streamer_t  ctrl_i,
  output flags_streamer_t flags_o
);

  // TCDM ready signals

  logic tcdm_fifo_ready_in_pel;
  logic tcdm_fifo_ready_in_size;

  // TCDM interface

  hwpe_stream_intf_tcdm tcdm_fifo_in_pel [0:0] ( .clk (clk_i) );

  hwpe_stream_intf_tcdm tcdm_fifo_in_size [0:0] ( .clk (clk_i) );

  hwpe_stream_intf_tcdm tcdm_fifo_out_pel [0:0] ( .clk (clk_i) );

  // Streaming interface

  hwpe_stream_intf_stream #( .DATA_WIDTH(32) ) stream_fifo_in_pel ( .clk (clk_i) );

  hwpe_stream_intf_stream #( .DATA_WIDTH(32) ) stream_fifo_in_size ( .clk (clk_i) );

  hwpe_stream_intf_stream #( .DATA_WIDTH(32) ) stream_fifo_out_pel ( .clk (clk_i) );

  // TCDM-side FIFOs - Inputs

  hwpe_stream_tcdm_fifo_load #(
    .FIFO_DEPTH ( 4 )
  ) i_in_pel_tcdm_fifo_load (
    .clk_i       ( clk_i             ),
    .rst_ni      ( rst_ni            ),
    .clear_i     ( clear_i           ),
    .flags_o     (                   ),
    .ready_i     ( tcdm_fifo_ready_in_pel ),
    .tcdm_slave  ( tcdm_fifo_in_pel[0]    ),
    .tcdm_master ( tcdm[0]     )
  );
  hwpe_stream_tcdm_fifo_load #(
    .FIFO_DEPTH ( 4 )
  ) i_in_size_tcdm_fifo_load (
    .clk_i       ( clk_i             ),
    .rst_ni      ( rst_ni            ),
    .clear_i     ( clear_i           ),
    .flags_o     (                   ),
    .ready_i     ( tcdm_fifo_ready_in_size ),
    .tcdm_slave  ( tcdm_fifo_in_size[0]    ),
    .tcdm_master ( tcdm[1]     )
  );

  // TCDM-side FIFOs - Outputs

  hwpe_stream_tcdm_fifo_store #(
    .FIFO_DEPTH ( 4 )
  ) i_out_pel_tcdm_fifo_store (
    .clk_i       ( clk_i          ),
    .rst_ni      ( rst_ni         ),
    .clear_i     ( clear_i        ),
    .flags_o     (                ),
    .tcdm_slave  ( tcdm_fifo_out_pel[0] ),
    .tcdm_master ( tcdm[2] )
  );

  // Engine-side FIFO - Inputs

  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_in_pel_stream_fifo (
    .clk_i   ( clk_i          ),
    .rst_ni  ( rst_ni         ),
    .clear_i ( clear_i        ),
    .push_i  ( stream_fifo_in_pel.sink ),
    .pop_o   ( in_pel            ),
    .flags_o (                )
  );
  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_in_size_stream_fifo (
    .clk_i   ( clk_i          ),
    .rst_ni  ( rst_ni         ),
    .clear_i ( clear_i        ),
    .push_i  ( stream_fifo_in_size.sink ),
    .pop_o   ( in_size            ),
    .flags_o (                )
  );

  // Engine-side FIFO - Outputs

  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_out_pel_stream_fifo (
    .clk_i   ( clk_i             ),
    .rst_ni  ( rst_ni            ),
    .clear_i ( clear_i           ),
    .push_i  ( out_pel               ),
    .pop_o   ( stream_fifo_out_pel.source),
    .flags_o (                   )
  );

  // Source modules (TCDM -> HWPE)

  hwpe_stream_source #(
    .DATA_WIDTH ( 32 ),
    .DECOUPLED  ( 1  ),
    .IS_ADDRESSGEN_PROGR  ( 1  )
  ) i_in_pel_source (
    .clk_i              ( clk_i                  ),
    .rst_ni             ( rst_ni                 ),
    .test_mode_i        ( test_mode_i            ),
    .clear_i            ( clear_i                ),
    .tcdm               ( tcdm_fifo_in_pel	),
    .stream             ( stream_fifo_in_pel.source),
    .ctrl_i             ( ctrl_i.in_pel_source_ctrl   ),
    .flags_o            ( flags_o.in_pel_source_flags ),
    .tcdm_fifo_ready_o  ( tcdm_fifo_ready_in_pel      )
  );
  hwpe_stream_source #(
    .DATA_WIDTH ( 32 ),
    .DECOUPLED  ( 1  ),
    .IS_ADDRESSGEN_PROGR  ( 1  )
  ) i_in_size_source (
    .clk_i              ( clk_i                  ),
    .rst_ni             ( rst_ni                 ),
    .test_mode_i        ( test_mode_i            ),
    .clear_i            ( clear_i                ),
    .tcdm               ( tcdm_fifo_in_size	),
    .stream             ( stream_fifo_in_size.source),
    .ctrl_i             ( ctrl_i.in_size_source_ctrl   ),
    .flags_o            ( flags_o.in_size_source_flags ),
    .tcdm_fifo_ready_o  ( tcdm_fifo_ready_in_size      )
  );

  // Sink modules (TCDM <- HWPE)

  hwpe_stream_sink #(
    .DATA_WIDTH ( 32 ),
    .IS_ADDRESSGEN_PROGR  ( 1  )
    // .NB_TCDM_PORTS (    )
  ) i_out_pel_sink (
    .clk_i       ( clk_i                ),
    .rst_ni      ( rst_ni               ),
    .test_mode_i ( test_mode_i          ),
    .clear_i     ( clear_i              ),
    .tcdm        ( tcdm_fifo_out_pel	),
    .stream      ( stream_fifo_out_pel.sink),
    .ctrl_i      ( ctrl_i.out_pel_sink_ctrl   ),
    .flags_o     ( flags_o.out_pel_sink_flags )
  );

  endmodule // multi_dataflow_streamer
