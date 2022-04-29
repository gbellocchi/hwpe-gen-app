
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
  parameter int unsigned MP = 4, // number of master ports
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

  hwpe_stream_intf_stream.source text,
  hwpe_stream_intf_stream.source key,
  hwpe_stream_intf_stream.source rc,

  hwpe_stream_intf_stream.sink chiped_text,

  // control channel
  input  ctrl_streamer_t  ctrl_i,
  output flags_streamer_t flags_o
);

  // TCDM ready signals

  logic tcdm_fifo_ready_text;
  logic tcdm_fifo_ready_key;
  logic tcdm_fifo_ready_rc;

  // TCDM interface

  hwpe_stream_intf_tcdm tcdm_fifo_text [0:0] ( .clk (clk_i) );

  hwpe_stream_intf_tcdm tcdm_fifo_key [0:0] ( .clk (clk_i) );

  hwpe_stream_intf_tcdm tcdm_fifo_rc [0:0] ( .clk (clk_i) );

  hwpe_stream_intf_tcdm tcdm_fifo_chiped_text [0:0] ( .clk (clk_i) );

  // Streaming interface

  hwpe_stream_intf_stream #( .DATA_WIDTH(32) ) stream_fifo_text ( .clk (clk_i) );

  hwpe_stream_intf_stream #( .DATA_WIDTH(32) ) stream_fifo_key ( .clk (clk_i) );

  hwpe_stream_intf_stream #( .DATA_WIDTH(32) ) stream_fifo_rc ( .clk (clk_i) );

  hwpe_stream_intf_stream #( .DATA_WIDTH(32) ) stream_fifo_chiped_text ( .clk (clk_i) );

  // TCDM-side FIFOs - Inputs

  hwpe_stream_tcdm_fifo_load #(
    .FIFO_DEPTH ( 4 )
  ) i_text_tcdm_fifo_load (
    .clk_i       ( clk_i             ),
    .rst_ni      ( rst_ni            ),
    .clear_i     ( clear_i           ),
    .flags_o     (                   ),
    .ready_i     ( tcdm_fifo_ready_text ),
    .tcdm_slave  ( tcdm_fifo_text[0]    ),
    .tcdm_master ( tcdm[0]     )
  );
  hwpe_stream_tcdm_fifo_load #(
    .FIFO_DEPTH ( 4 )
  ) i_key_tcdm_fifo_load (
    .clk_i       ( clk_i             ),
    .rst_ni      ( rst_ni            ),
    .clear_i     ( clear_i           ),
    .flags_o     (                   ),
    .ready_i     ( tcdm_fifo_ready_key ),
    .tcdm_slave  ( tcdm_fifo_key[0]    ),
    .tcdm_master ( tcdm[1]     )
  );
  hwpe_stream_tcdm_fifo_load #(
    .FIFO_DEPTH ( 4 )
  ) i_rc_tcdm_fifo_load (
    .clk_i       ( clk_i             ),
    .rst_ni      ( rst_ni            ),
    .clear_i     ( clear_i           ),
    .flags_o     (                   ),
    .ready_i     ( tcdm_fifo_ready_rc ),
    .tcdm_slave  ( tcdm_fifo_rc[0]    ),
    .tcdm_master ( tcdm[2]     )
  );

  // TCDM-side FIFOs - Outputs

  hwpe_stream_tcdm_fifo_store #(
    .FIFO_DEPTH ( 4 )
  ) i_chiped_text_tcdm_fifo_store (
    .clk_i       ( clk_i          ),
    .rst_ni      ( rst_ni         ),
    .clear_i     ( clear_i        ),
    .flags_o     (                ),
    .tcdm_slave  ( tcdm_fifo_chiped_text[0] ),
    .tcdm_master ( tcdm[3] )
  );

  // Engine-side FIFO - Inputs

  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_text_stream_fifo (
    .clk_i   ( clk_i          ),
    .rst_ni  ( rst_ni         ),
    .clear_i ( clear_i        ),
    .push_i  ( stream_fifo_text.sink ),
    .pop_o   ( text            ),
    .flags_o (                )
  );
  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_key_stream_fifo (
    .clk_i   ( clk_i          ),
    .rst_ni  ( rst_ni         ),
    .clear_i ( clear_i        ),
    .push_i  ( stream_fifo_key.sink ),
    .pop_o   ( key            ),
    .flags_o (                )
  );
  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_rc_stream_fifo (
    .clk_i   ( clk_i          ),
    .rst_ni  ( rst_ni         ),
    .clear_i ( clear_i        ),
    .push_i  ( stream_fifo_rc.sink ),
    .pop_o   ( rc            ),
    .flags_o (                )
  );

  // Engine-side FIFO - Outputs

  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_chiped_text_stream_fifo (
    .clk_i   ( clk_i             ),
    .rst_ni  ( rst_ni            ),
    .clear_i ( clear_i           ),
    .push_i  ( chiped_text               ),
    .pop_o   ( stream_fifo_chiped_text.source),
    .flags_o (                   )
  );

  // Source modules (TCDM -> HWPE)

  hwpe_stream_source #(
    .DATA_WIDTH ( 32 ),
    .DECOUPLED  ( 1  ),
    .IS_ADDRESSGEN_PROGR  ( 1  )
  ) i_text_source (
    .clk_i              ( clk_i                  ),
    .rst_ni             ( rst_ni                 ),
    .test_mode_i        ( test_mode_i            ),
    .clear_i            ( clear_i                ),
    .tcdm               ( tcdm_fifo_text	),
    .stream             ( stream_fifo_text.source),
    .ctrl_i             ( ctrl_i.text_source_ctrl   ),
    .flags_o            ( flags_o.text_source_flags ),
    .tcdm_fifo_ready_o  ( tcdm_fifo_ready_text      )
  );
  hwpe_stream_source #(
    .DATA_WIDTH ( 32 ),
    .DECOUPLED  ( 1  ),
    .IS_ADDRESSGEN_PROGR  ( 1  )
  ) i_key_source (
    .clk_i              ( clk_i                  ),
    .rst_ni             ( rst_ni                 ),
    .test_mode_i        ( test_mode_i            ),
    .clear_i            ( clear_i                ),
    .tcdm               ( tcdm_fifo_key	),
    .stream             ( stream_fifo_key.source),
    .ctrl_i             ( ctrl_i.key_source_ctrl   ),
    .flags_o            ( flags_o.key_source_flags ),
    .tcdm_fifo_ready_o  ( tcdm_fifo_ready_key      )
  );
  hwpe_stream_source #(
    .DATA_WIDTH ( 32 ),
    .DECOUPLED  ( 1  ),
    .IS_ADDRESSGEN_PROGR  ( 1  )
  ) i_rc_source (
    .clk_i              ( clk_i                  ),
    .rst_ni             ( rst_ni                 ),
    .test_mode_i        ( test_mode_i            ),
    .clear_i            ( clear_i                ),
    .tcdm               ( tcdm_fifo_rc	),
    .stream             ( stream_fifo_rc.source),
    .ctrl_i             ( ctrl_i.rc_source_ctrl   ),
    .flags_o            ( flags_o.rc_source_flags ),
    .tcdm_fifo_ready_o  ( tcdm_fifo_ready_rc      )
  );

  // Sink modules (TCDM <- HWPE)

  hwpe_stream_sink #(
    .DATA_WIDTH ( 32 ),
    .IS_ADDRESSGEN_PROGR  ( 1  )
    // .NB_TCDM_PORTS (    )
  ) i_chiped_text_sink (
    .clk_i       ( clk_i                ),
    .rst_ni      ( rst_ni               ),
    .test_mode_i ( test_mode_i          ),
    .clear_i     ( clear_i              ),
    .tcdm        ( tcdm_fifo_chiped_text	),
    .stream      ( stream_fifo_chiped_text.sink),
    .ctrl_i      ( ctrl_i.chiped_text_sink_ctrl   ),
    .flags_o     ( flags_o.chiped_text_sink_flags )
  );

  endmodule // multi_dataflow_streamer
