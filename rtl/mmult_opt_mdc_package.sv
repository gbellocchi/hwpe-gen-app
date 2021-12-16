

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
 * Module: mmult_opt_mdc_package.sv
 *
 */

import hwpe_stream_package::*;

package mmult_opt_mdc_package;

  parameter int unsigned MMULT_OPT_MDC_CNT_LEN = 1024; // maximum length of the vectors for a scalar product

  /* Registers */

  // TCDM

  // Input ports
  parameter int unsigned MMULT_OPT_MDC_REG_IN1_ADDR                = 0;

  parameter int unsigned MMULT_OPT_MDC_REG_IN2_ADDR                = 1;

  // Output ports
  parameter int unsigned MMULT_OPT_MDC_REG_OUT_R_ADDR                = 2;

  // Standard registers

  parameter int unsigned MMULT_OPT_MDC_REG_NB_ITER              = 3;

  parameter int unsigned MMULT_OPT_MDC_REG_SHIFT_LINESTRIDE     = 4;

  parameter int unsigned MMULT_OPT_MDC_REG_SHIFT_TILESTRIDE     = 5;

  parameter int unsigned MMULT_OPT_MDC_REG_CNT_LIMIT_OUT_R     = 6;

    // Input stream - in1 (programmable)
    parameter int unsigned MMULT_OPT_MDC_REG_IN1_TRANS_SIZE       = 7;
    parameter int unsigned MMULT_OPT_MDC_REG_IN1_LINE_STRIDE      = 8;
    parameter int unsigned MMULT_OPT_MDC_REG_IN1_LINE_LENGTH      = 9;
    parameter int unsigned MMULT_OPT_MDC_REG_IN1_FEAT_STRIDE      = 10;
    parameter int unsigned MMULT_OPT_MDC_REG_IN1_FEAT_LENGTH      = 11;
    parameter int unsigned MMULT_OPT_MDC_REG_IN1_FEAT_ROLL        = 12;
    parameter int unsigned MMULT_OPT_MDC_REG_IN1_LOOP_OUTER       = 13;
    parameter int unsigned MMULT_OPT_MDC_REG_IN1_REALIGN_TYPE     = 14;
    parameter int unsigned MMULT_OPT_MDC_REG_IN1_STEP             = 15;
    // Input stream - in2 (programmable)
    parameter int unsigned MMULT_OPT_MDC_REG_IN2_TRANS_SIZE       = 16;
    parameter int unsigned MMULT_OPT_MDC_REG_IN2_LINE_STRIDE      = 17;
    parameter int unsigned MMULT_OPT_MDC_REG_IN2_LINE_LENGTH      = 18;
    parameter int unsigned MMULT_OPT_MDC_REG_IN2_FEAT_STRIDE      = 19;
    parameter int unsigned MMULT_OPT_MDC_REG_IN2_FEAT_LENGTH      = 20;
    parameter int unsigned MMULT_OPT_MDC_REG_IN2_FEAT_ROLL        = 21;
    parameter int unsigned MMULT_OPT_MDC_REG_IN2_LOOP_OUTER       = 22;
    parameter int unsigned MMULT_OPT_MDC_REG_IN2_REALIGN_TYPE     = 23;
    parameter int unsigned MMULT_OPT_MDC_REG_IN2_STEP             = 24;

    // Output stream - out_r (programmable)
    parameter int unsigned MMULT_OPT_MDC_REG_OUT_R_TRANS_SIZE       = 25;
    parameter int unsigned MMULT_OPT_MDC_REG_OUT_R_LINE_STRIDE      = 26;
    parameter int unsigned MMULT_OPT_MDC_REG_OUT_R_LINE_LENGTH      = 27;
    parameter int unsigned MMULT_OPT_MDC_REG_OUT_R_FEAT_STRIDE      = 28;
    parameter int unsigned MMULT_OPT_MDC_REG_OUT_R_FEAT_LENGTH      = 29;
    parameter int unsigned MMULT_OPT_MDC_REG_OUT_R_FEAT_ROLL        = 30;
    parameter int unsigned MMULT_OPT_MDC_REG_OUT_R_LOOP_OUTER       = 31;
    parameter int unsigned MMULT_OPT_MDC_REG_OUT_R_REALIGN_TYPE     = 32;
    parameter int unsigned MMULT_OPT_MDC_REG_OUT_R_STEP             = 33;

  /* Microcode processor */

  // offset indeces -- this should be aligned to the microcode compiler of course!
  parameter int unsigned MMULT_OPT_MDC_UCODE_IN1_OFFS               = 0;
  parameter int unsigned MMULT_OPT_MDC_UCODE_IN2_OFFS               = 1;

  parameter int unsigned MMULT_OPT_MDC_UCODE_OUT_R_OFFS              = 2;

  // mnemonics -- this should be aligned to the microcode compiler of course!

  parameter int unsigned MMULT_OPT_MDC_UCODE_MNEM_NBITER      = 0;

  parameter int unsigned MMULT_OPT_MDC_UCODE_MNEM_ITERSTRIDE  = 1;

  parameter int unsigned MMULT_OPT_MDC_UCODE_MNEM_ONESTRIDE   = 2;

  parameter int unsigned MMULT_OPT_MDC_UCODE_MNEM_TILESTRIDE  = 3;

  /* Typedefs */

  typedef struct packed {
    logic clear;
    logic enable;
    logic start;

    logic unsigned [$clog2(MMULT_OPT_MDC_CNT_LEN):0] cnt_limit_out_r;

  } ctrl_engine_t;

  typedef struct packed {

    logic unsigned [$clog2(MMULT_OPT_MDC_CNT_LEN):0] cnt_out_r;

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

    hwpe_stream_package::ctrl_sourcesink_t in1_source_ctrl;
    hwpe_stream_package::ctrl_sourcesink_t in2_source_ctrl;

    hwpe_stream_package::ctrl_sourcesink_t out_r_sink_ctrl;

  } ctrl_streamer_t;

  typedef struct packed {

    hwpe_stream_package::flags_sourcesink_t in1_source_flags;
    hwpe_stream_package::flags_sourcesink_t in2_source_flags;

    hwpe_stream_package::flags_sourcesink_t out_r_sink_flags;

  } flags_streamer_t;

  typedef struct packed {

    // Input stream - in1 (programmable)
    logic unsigned [31:0] in1_trans_size;
    logic unsigned [15:0] in1_line_stride;
    logic unsigned [15:0] in1_line_length;
    logic unsigned [15:0] in1_feat_stride;
    logic unsigned [15:0] in1_feat_length;
    logic unsigned [15:0] in1_feat_roll;
    logic unsigned [15:0] in1_step;
    logic unsigned in1_loop_outer;
    logic unsigned in1_realign_type;
    // Input stream - in2 (programmable)
    logic unsigned [31:0] in2_trans_size;
    logic unsigned [15:0] in2_line_stride;
    logic unsigned [15:0] in2_line_length;
    logic unsigned [15:0] in2_feat_stride;
    logic unsigned [15:0] in2_feat_length;
    logic unsigned [15:0] in2_feat_roll;
    logic unsigned [15:0] in2_step;
    logic unsigned in2_loop_outer;
    logic unsigned in2_realign_type;

    // Output stream - out_r (programmable)
    logic unsigned [31:0] out_r_trans_size;
    logic unsigned [15:0] out_r_line_stride;
    logic unsigned [15:0] out_r_line_length;
    logic unsigned [15:0] out_r_feat_stride;
    logic unsigned [15:0] out_r_feat_length;
    logic unsigned [15:0] out_r_feat_roll;
    logic unsigned [15:0] out_r_step;
    logic unsigned out_r_loop_outer;
    logic unsigned out_r_realign_type;

    // Computation
    logic unsigned [$clog2(MMULT_OPT_MDC_CNT_LEN):0] cnt_limit_out_r;

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