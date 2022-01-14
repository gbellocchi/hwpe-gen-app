
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
  parameter int unsigned REG_IN_PEL_ADDR              = 0;
  parameter int unsigned REG_IN_SIZE_ADDR              = 1;

  // Output ports
  parameter int unsigned REG_OUT_PEL_ADDR             = 2;

  // Standard registers

  parameter int unsigned REG_NB_ITER              = 3;

  parameter int unsigned REG_SHIFT_LINESTRIDE     = 4;

  parameter int unsigned REG_SHIFT_TILESTRIDE     = 5;

  parameter int unsigned REG_CNT_LIMIT_OUT_PEL             = 6;

  // Custom register files

  parameter int unsigned CONFIG             = 7;

  // Input stream - in_pel (programmable)
  parameter int unsigned REG_IN_PEL_TRANS_SIZE       = 8;
  parameter int unsigned REG_IN_PEL_LINE_STRIDE      = 9;
  parameter int unsigned REG_IN_PEL_LINE_LENGTH      = 10;
  parameter int unsigned REG_IN_PEL_FEAT_STRIDE      = 11;
  parameter int unsigned REG_IN_PEL_FEAT_LENGTH      = 12;
  parameter int unsigned REG_IN_PEL_FEAT_ROLL        = 13;
  parameter int unsigned REG_IN_PEL_LOOP_OUTER       = 14;
  parameter int unsigned REG_IN_PEL_REALIGN_TYPE     = 15;
  parameter int unsigned REG_IN_PEL_STEP             = 16;
  // Input stream - in_size (programmable)
  parameter int unsigned REG_IN_SIZE_TRANS_SIZE       = 17;
  parameter int unsigned REG_IN_SIZE_LINE_STRIDE      = 18;
  parameter int unsigned REG_IN_SIZE_LINE_LENGTH      = 19;
  parameter int unsigned REG_IN_SIZE_FEAT_STRIDE      = 20;
  parameter int unsigned REG_IN_SIZE_FEAT_LENGTH      = 21;
  parameter int unsigned REG_IN_SIZE_FEAT_ROLL        = 22;
  parameter int unsigned REG_IN_SIZE_LOOP_OUTER       = 23;
  parameter int unsigned REG_IN_SIZE_REALIGN_TYPE     = 24;
  parameter int unsigned REG_IN_SIZE_STEP             = 25;

  // Output stream - out_pel (programmable)
  parameter int unsigned REG_OUT_PEL_TRANS_SIZE       = 26;
  parameter int unsigned REG_OUT_PEL_LINE_STRIDE      = 27;
  parameter int unsigned REG_OUT_PEL_LINE_LENGTH      = 28;
  parameter int unsigned REG_OUT_PEL_FEAT_STRIDE      = 29;
  parameter int unsigned REG_OUT_PEL_FEAT_LENGTH      = 30;
  parameter int unsigned REG_OUT_PEL_FEAT_ROLL        = 31;
  parameter int unsigned REG_OUT_PEL_LOOP_OUTER       = 32;
  parameter int unsigned REG_OUT_PEL_REALIGN_TYPE     = 33;
  parameter int unsigned REG_OUT_PEL_STEP             = 34;

  /* Microcode processor */

  // offset indeces -- this should be aligned to the microcode compiler of course!
  parameter int unsigned UCODE_IN_PEL_OFFS              = 0;

  parameter int unsigned UCODE_IN_SIZE_OFFS              = 1;

  parameter int unsigned UCODE_OUT_PEL_OFFS              = 2;

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

    logic unsigned [$clog2(CNT_LEN):0] cnt_limit_out_pel;

    // Custom register
  logic unsigned [(32-1):0] configuration;
  } ctrl_engine_t;

  typedef struct packed {

    logic unsigned [$clog2(CNT_LEN):0] cnt_out_pel;

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
  	
  hwpe_stream_package::ctrl_sourcesink_t in_pel_source_ctrl;
  hwpe_stream_package::ctrl_sourcesink_t in_size_source_ctrl;

  hwpe_stream_package::ctrl_sourcesink_t out_pel_sink_ctrl;
  
  } ctrl_streamer_t;

  typedef struct packed {

  hwpe_stream_package::flags_sourcesink_t in_pel_source_flags;
  hwpe_stream_package::flags_sourcesink_t in_size_source_flags;

  hwpe_stream_package::flags_sourcesink_t out_pel_sink_flags;
  } flags_streamer_t;

  typedef struct packed {

    // Input stream - in_pel (programmable)
    logic unsigned [31:0] in_pel_trans_size;
    logic unsigned [15:0] in_pel_line_stride;
    logic unsigned [15:0] in_pel_line_length;
    logic unsigned [15:0] in_pel_feat_stride;
    logic unsigned [15:0] in_pel_feat_length;
    logic unsigned [15:0] in_pel_feat_roll;
    logic unsigned [15:0] in_pel_step;
    logic unsigned in_pel_loop_outer;
    logic unsigned in_pel_realign_type;
    // Input stream - in_size (programmable)
    logic unsigned [31:0] in_size_trans_size;
    logic unsigned [15:0] in_size_line_stride;
    logic unsigned [15:0] in_size_line_length;
    logic unsigned [15:0] in_size_feat_stride;
    logic unsigned [15:0] in_size_feat_length;
    logic unsigned [15:0] in_size_feat_roll;
    logic unsigned [15:0] in_size_step;
    logic unsigned in_size_loop_outer;
    logic unsigned in_size_realign_type;

    // Output stream - out_pel (programmable)
    logic unsigned [31:0] out_pel_trans_size;
    logic unsigned [15:0] out_pel_line_stride;
    logic unsigned [15:0] out_pel_line_length;
    logic unsigned [15:0] out_pel_feat_stride;
    logic unsigned [15:0] out_pel_feat_length;
    logic unsigned [15:0] out_pel_feat_roll;
    logic unsigned [15:0] out_pel_step;
    logic unsigned out_pel_loop_outer;
    logic unsigned out_pel_realign_type;

    // Computation
    logic unsigned [$clog2(CNT_LEN):0] cnt_limit_out_pel;

    // Custom register
    logic unsigned [(32-1):0] configuration;

  } ctrl_fsm_t;

  typedef enum {
    FSM_IDLE,
    FSM_START,
    FSM_COMPUTE,
    FSM_WAIT,
    FSM_UPDATEIDX,
    FSM_TERMINATE
  } state_fsm_t;

endpackage
