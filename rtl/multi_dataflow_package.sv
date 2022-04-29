
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
 * Module: multi_dataflow_package.sv
 *
 */

import hwpe_stream_package::*;

package multi_dataflow_package;

  parameter int unsigned CNT_LEN = 1024; // maximum length of the vectors for a scalar product

  /* Registers */

  // TCDM

  // Input ports
  parameter int unsigned REG_TEXT_ADDR              = 0;
  parameter int unsigned REG_KEY_ADDR              = 1;
  parameter int unsigned REG_RC_ADDR              = 2;

  // Output ports
  parameter int unsigned REG_CHIPED_TEXT_ADDR             = 3;

  // Standard registers

  parameter int unsigned REG_NB_ITER              = 4;

  parameter int unsigned REG_SHIFT_LINESTRIDE     = 5;

  parameter int unsigned REG_SHIFT_TILESTRIDE     = 6;

  parameter int unsigned REG_CNT_LIMIT_CHIPED_TEXT             = 7;

  // Custom register files

  // Input stream - text (programmable)
  parameter int unsigned REG_TEXT_TRANS_SIZE       = 8;
  parameter int unsigned REG_TEXT_LINE_STRIDE      = 9;
  parameter int unsigned REG_TEXT_LINE_LENGTH      = 10;
  parameter int unsigned REG_TEXT_FEAT_STRIDE      = 11;
  parameter int unsigned REG_TEXT_FEAT_LENGTH      = 12;
  parameter int unsigned REG_TEXT_FEAT_ROLL        = 13;
  parameter int unsigned REG_TEXT_LOOP_OUTER       = 14;
  parameter int unsigned REG_TEXT_REALIGN_TYPE     = 15;
  parameter int unsigned REG_TEXT_STEP             = 16;
  // Input stream - key (programmable)
  parameter int unsigned REG_KEY_TRANS_SIZE       = 17;
  parameter int unsigned REG_KEY_LINE_STRIDE      = 18;
  parameter int unsigned REG_KEY_LINE_LENGTH      = 19;
  parameter int unsigned REG_KEY_FEAT_STRIDE      = 20;
  parameter int unsigned REG_KEY_FEAT_LENGTH      = 21;
  parameter int unsigned REG_KEY_FEAT_ROLL        = 22;
  parameter int unsigned REG_KEY_LOOP_OUTER       = 23;
  parameter int unsigned REG_KEY_REALIGN_TYPE     = 24;
  parameter int unsigned REG_KEY_STEP             = 25;
  // Input stream - rc (programmable)
  parameter int unsigned REG_RC_TRANS_SIZE       = 26;
  parameter int unsigned REG_RC_LINE_STRIDE      = 27;
  parameter int unsigned REG_RC_LINE_LENGTH      = 28;
  parameter int unsigned REG_RC_FEAT_STRIDE      = 29;
  parameter int unsigned REG_RC_FEAT_LENGTH      = 30;
  parameter int unsigned REG_RC_FEAT_ROLL        = 31;
  parameter int unsigned REG_RC_LOOP_OUTER       = 32;
  parameter int unsigned REG_RC_REALIGN_TYPE     = 33;
  parameter int unsigned REG_RC_STEP             = 34;

  // Output stream - chiped_text (programmable)
  parameter int unsigned REG_CHIPED_TEXT_TRANS_SIZE       = 35;
  parameter int unsigned REG_CHIPED_TEXT_LINE_STRIDE      = 36;
  parameter int unsigned REG_CHIPED_TEXT_LINE_LENGTH      = 37;
  parameter int unsigned REG_CHIPED_TEXT_FEAT_STRIDE      = 38;
  parameter int unsigned REG_CHIPED_TEXT_FEAT_LENGTH      = 39;
  parameter int unsigned REG_CHIPED_TEXT_FEAT_ROLL        = 40;
  parameter int unsigned REG_CHIPED_TEXT_LOOP_OUTER       = 41;
  parameter int unsigned REG_CHIPED_TEXT_REALIGN_TYPE     = 42;
  parameter int unsigned REG_CHIPED_TEXT_STEP             = 43;

  /* Microcode processor */

  // offset indeces -- this should be aligned to the microcode compiler of course!
  parameter int unsigned UCODE_TEXT_OFFS              = 0;

  parameter int unsigned UCODE_KEY_OFFS              = 1;

  parameter int unsigned UCODE_RC_OFFS              = 2;

  parameter int unsigned UCODE_CHIPED_TEXT_OFFS              = 3;

  // mnemonics -- this should be aligned to the microcode compiler of course!

  parameter int unsigned UCODE_MNEM_NBITER     = 0;

  parameter int unsigned UCODE_MNEM_ITERSTRIDE = 1;

  parameter int unsigned UCODE_MNEM_ONESTRIDE  = 2;

  parameter int unsigned UCODE_MNEM_TILESTRIDE = 3;

  /* Typedefs */

  typedef struct packed {
    logic clear;
    logic enable;
    logic start;

    logic unsigned [$clog2(CNT_LEN):0] cnt_limit_chiped_text;

    // Custom register
  } ctrl_engine_t;

  typedef struct packed {

    logic unsigned [$clog2(CNT_LEN):0] cnt_chiped_text;

    logic done;
    logic ready;
  } flags_engine_t;

  typedef struct packed {
    logic start;
  } ctrl_kernel_adapter_t;

  typedef struct packed {
    logic done;
    logic idle;
    logic ready;
  } flags_kernel_adapter_t;

  typedef struct packed {
  	
  hwpe_stream_package::ctrl_sourcesink_t text_source_ctrl;
  hwpe_stream_package::ctrl_sourcesink_t key_source_ctrl;
  hwpe_stream_package::ctrl_sourcesink_t rc_source_ctrl;

  hwpe_stream_package::ctrl_sourcesink_t chiped_text_sink_ctrl;
  
  } ctrl_streamer_t;

  typedef struct packed {

  hwpe_stream_package::flags_sourcesink_t text_source_flags;
  hwpe_stream_package::flags_sourcesink_t key_source_flags;
  hwpe_stream_package::flags_sourcesink_t rc_source_flags;

  hwpe_stream_package::flags_sourcesink_t chiped_text_sink_flags;
  } flags_streamer_t;

  typedef struct packed {

    // Input stream - text (programmable)
    logic unsigned [31:0] text_trans_size;
    logic unsigned [15:0] text_line_stride;
    logic unsigned [15:0] text_line_length;
    logic unsigned [15:0] text_feat_stride;
    logic unsigned [15:0] text_feat_length;
    logic unsigned [15:0] text_feat_roll;
    logic unsigned [15:0] text_step;
    logic unsigned text_loop_outer;
    logic unsigned text_realign_type;
    // Input stream - key (programmable)
    logic unsigned [31:0] key_trans_size;
    logic unsigned [15:0] key_line_stride;
    logic unsigned [15:0] key_line_length;
    logic unsigned [15:0] key_feat_stride;
    logic unsigned [15:0] key_feat_length;
    logic unsigned [15:0] key_feat_roll;
    logic unsigned [15:0] key_step;
    logic unsigned key_loop_outer;
    logic unsigned key_realign_type;
    // Input stream - rc (programmable)
    logic unsigned [31:0] rc_trans_size;
    logic unsigned [15:0] rc_line_stride;
    logic unsigned [15:0] rc_line_length;
    logic unsigned [15:0] rc_feat_stride;
    logic unsigned [15:0] rc_feat_length;
    logic unsigned [15:0] rc_feat_roll;
    logic unsigned [15:0] rc_step;
    logic unsigned rc_loop_outer;
    logic unsigned rc_realign_type;

    // Output stream - chiped_text (programmable)
    logic unsigned [31:0] chiped_text_trans_size;
    logic unsigned [15:0] chiped_text_line_stride;
    logic unsigned [15:0] chiped_text_line_length;
    logic unsigned [15:0] chiped_text_feat_stride;
    logic unsigned [15:0] chiped_text_feat_length;
    logic unsigned [15:0] chiped_text_feat_roll;
    logic unsigned [15:0] chiped_text_step;
    logic unsigned chiped_text_loop_outer;
    logic unsigned chiped_text_realign_type;

    // Computation
    logic unsigned [$clog2(CNT_LEN):0] cnt_limit_chiped_text;

    // Custom register

  } ctrl_fsm_t;

endpackage
