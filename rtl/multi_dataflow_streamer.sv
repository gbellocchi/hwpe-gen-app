
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
  parameter int unsigned MP = 2, // number of master ports
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

  hwpe_stream_intf_stream.source inStream0,

  hwpe_stream_intf_stream.sink outStream0,

  // control channel
  input  ctrl_streamer_t  ctrl_i,
  output flags_streamer_t flags_o
);

  // TCDM ready signals

  logic tcdm_fifo_ready_inStream0;

  // TCDM interface

  hwpe_stream_intf_tcdm tcdm_fifo_inStream0 [0:0] ( .clk (clk_i) );

  hwpe_stream_intf_tcdm tcdm_fifo_outStream0 [0:0] ( .clk (clk_i) );

  // Streaming interface

  hwpe_stream_intf_stream #( .DATA_WIDTH(32) ) stream_fifo_inStream0 ( .clk (clk_i) );

  hwpe_stream_intf_stream #( .DATA_WIDTH(32) ) stream_fifo_outStream0 ( .clk (clk_i) );

  // TCDM-side FIFOs - Inputs

  hwpe_stream_tcdm_fifo_load #(
    .FIFO_DEPTH ( 4 )
  ) i_inStream0_tcdm_fifo_load (
    .clk_i       ( clk_i             ),
    .rst_ni      ( rst_ni            ),
    .clear_i     ( clear_i           ),
    .flags_o     (                   ),
    .ready_i     ( tcdm_fifo_ready_inStream0 ),
    .tcdm_slave  ( tcdm_fifo_inStream0[0]    ),
    .tcdm_master ( tcdm[0]     )
  );

  // TCDM-side FIFOs - Outputs

  hwpe_stream_tcdm_fifo_store #(
    .FIFO_DEPTH ( 4 )
  ) i_outStream0_tcdm_fifo_store (
    .clk_i       ( clk_i          ),
    .rst_ni      ( rst_ni         ),
    .clear_i     ( clear_i        ),
    .flags_o     (                ),
    .tcdm_slave  ( tcdm_fifo_outStream0[0] ),
    .tcdm_master ( tcdm[1] )
  );

  // Engine-side FIFO - Inputs

  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_inStream0_stream_fifo (
    .clk_i   ( clk_i          ),
    .rst_ni  ( rst_ni         ),
    .clear_i ( clear_i        ),
    .push_i  ( stream_fifo_inStream0.sink ),
    .pop_o   ( inStream0            ),
    .flags_o (                )
  );

  // Engine-side FIFO - Outputs

  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_outStream0_stream_fifo (
    .clk_i   ( clk_i             ),
    .rst_ni  ( rst_ni            ),
    .clear_i ( clear_i           ),
    .push_i  ( outStream0               ),
    .pop_o   ( stream_fifo_outStream0.source),
    .flags_o (                   )
  );

  // Source modules (TCDM -> HWPE)

  hwpe_stream_source #(
    .DATA_WIDTH ( 32 ),
    .DECOUPLED  ( 1  ),
    .IS_ADDRESSGEN_PROGR  ( 1  )
  ) i_inStream0_source (
    .clk_i              ( clk_i                  ),
    .rst_ni             ( rst_ni                 ),
    .test_mode_i        ( test_mode_i            ),
    .clear_i            ( clear_i                ),
    .tcdm               ( tcdm_fifo_inStream0	),
    .stream             ( stream_fifo_inStream0.source),
    .ctrl_i             ( ctrl_i.inStream0_source_ctrl   ),
    .flags_o            ( flags_o.inStream0_source_flags ),
    .tcdm_fifo_ready_o  ( tcdm_fifo_ready_inStream0      )
  );

  // Sink modules (TCDM <- HWPE)

  hwpe_stream_sink #(
    .DATA_WIDTH ( 32 ),
    .IS_ADDRESSGEN_PROGR  ( 1  )
    // .NB_TCDM_PORTS (    )
  ) i_outStream0_sink (
    .clk_i       ( clk_i                ),
    .rst_ni      ( rst_ni               ),
    .test_mode_i ( test_mode_i          ),
    .clear_i     ( clear_i              ),
    .tcdm        ( tcdm_fifo_outStream0	),
    .stream      ( stream_fifo_outStream0.sink),
    .ctrl_i      ( ctrl_i.outStream0_sink_ctrl   ),
    .flags_o     ( flags_o.outStream0_sink_flags )
  );

  endmodule // multi_dataflow_streamer
