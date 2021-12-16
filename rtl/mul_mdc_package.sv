

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
 * Module: mul_mdc_package.sv
 *
 */

import hwpe_stream_package::*;

package mul_mdc_package;

  parameter int unsigned MUL_MDC_CNT_LEN = 1024; // maximum length of the vectors for a scalar product

  /* Registers */

  // TCDM

  // Input ports
  parameter int unsigned MUL_MDC_REG_A_ADDR                = 0;

  parameter int unsigned MUL_MDC_REG_B_ADDR                = 1;

  parameter int unsigned MUL_MDC_REG_C_ADDR                = 2;

  // Output ports
  parameter int unsigned MUL_MDC_REG_D_ADDR                = 3;

  // Standard registers

  parameter int unsigned MUL_MDC_REG_NB_ITER              = 4;

  parameter int unsigned MUL_MDC_REG_SHIFT_LINESTRIDE     = 5;

  parameter int unsigned MUL_MDC_REG_SHIFT_TILESTRIDE     = 6;

  parameter int unsigned MUL_MDC_REG_CNT_LIMIT_D     = 7;

  // Custom registers

  parameter int unsigned MUL_MDC_REG_REG_SIMPLE_MUL             = 8;

  parameter int unsigned MUL_MDC_REG_REG_SHIFT             = 9;

  parameter int unsigned MUL_MDC_REG_REG_LEN             = 10;

    // Input stream - a (programmable)
    parameter int unsigned MUL_MDC_REG_A_TRANS_SIZE       = 11;
    parameter int unsigned MUL_MDC_REG_A_LINE_STRIDE      = 12;
    parameter int unsigned MUL_MDC_REG_A_LINE_LENGTH      = 13;
    parameter int unsigned MUL_MDC_REG_A_FEAT_STRIDE      = 14;
    parameter int unsigned MUL_MDC_REG_A_FEAT_LENGTH      = 15;
    parameter int unsigned MUL_MDC_REG_A_FEAT_ROLL        = 16;
    parameter int unsigned MUL_MDC_REG_A_LOOP_OUTER       = 17;
    parameter int unsigned MUL_MDC_REG_A_REALIGN_TYPE     = 18;
    parameter int unsigned MUL_MDC_REG_A_STEP             = 19;
    // Input stream - b (programmable)
    parameter int unsigned MUL_MDC_REG_B_TRANS_SIZE       = 20;
    parameter int unsigned MUL_MDC_REG_B_LINE_STRIDE      = 21;
    parameter int unsigned MUL_MDC_REG_B_LINE_LENGTH      = 22;
    parameter int unsigned MUL_MDC_REG_B_FEAT_STRIDE      = 23;
    parameter int unsigned MUL_MDC_REG_B_FEAT_LENGTH      = 24;
    parameter int unsigned MUL_MDC_REG_B_FEAT_ROLL        = 25;
    parameter int unsigned MUL_MDC_REG_B_LOOP_OUTER       = 26;
    parameter int unsigned MUL_MDC_REG_B_REALIGN_TYPE     = 27;
    parameter int unsigned MUL_MDC_REG_B_STEP             = 28;
    // Input stream - c (programmable)
    parameter int unsigned MUL_MDC_REG_C_TRANS_SIZE       = 29;
    parameter int unsigned MUL_MDC_REG_C_LINE_STRIDE      = 30;
    parameter int unsigned MUL_MDC_REG_C_LINE_LENGTH      = 31;
    parameter int unsigned MUL_MDC_REG_C_FEAT_STRIDE      = 32;
    parameter int unsigned MUL_MDC_REG_C_FEAT_LENGTH      = 33;
    parameter int unsigned MUL_MDC_REG_C_FEAT_ROLL        = 34;
    parameter int unsigned MUL_MDC_REG_C_LOOP_OUTER       = 35;
    parameter int unsigned MUL_MDC_REG_C_REALIGN_TYPE     = 36;
    parameter int unsigned MUL_MDC_REG_C_STEP             = 37;

    // Output stream - d (programmable)
    parameter int unsigned MUL_MDC_REG_D_TRANS_SIZE       = 38;
    parameter int unsigned MUL_MDC_REG_D_LINE_STRIDE      = 39;
    parameter int unsigned MUL_MDC_REG_D_LINE_LENGTH      = 40;
    parameter int unsigned MUL_MDC_REG_D_FEAT_STRIDE      = 41;
    parameter int unsigned MUL_MDC_REG_D_FEAT_LENGTH      = 42;
    parameter int unsigned MUL_MDC_REG_D_FEAT_ROLL        = 43;
    parameter int unsigned MUL_MDC_REG_D_LOOP_OUTER       = 44;
    parameter int unsigned MUL_MDC_REG_D_REALIGN_TYPE     = 45;
    parameter int unsigned MUL_MDC_REG_D_STEP             = 46;

  /* Microcode processor */

  // offset indeces -- this should be aligned to the microcode compiler of course!
  parameter int unsigned MUL_MDC_UCODE_A_OFFS               = 0;
  parameter int unsigned MUL_MDC_UCODE_B_OFFS               = 1;
  parameter int unsigned MUL_MDC_UCODE_C_OFFS               = 2;

  parameter int unsigned MUL_MDC_UCODE_D_OFFS              = 3;

  // mnemonics -- this should be aligned to the microcode compiler of course!

  parameter int unsigned MUL_MDC_UCODE_MNEM_NBITER      = 0;

  parameter int unsigned MUL_MDC_UCODE_MNEM_ITERSTRIDE  = 1;

  parameter int unsigned MUL_MDC_UCODE_MNEM_ONESTRIDE   = 2;

  parameter int unsigned MUL_MDC_UCODE_MNEM_TILESTRIDE  = 3;

  /* Typedefs */

  typedef struct packed {
    logic clear;
    logic enable;
    logic start;

    logic unsigned [$clog2(MUL_MDC_CNT_LEN):0] cnt_limit_d;

    // Custom registers
    logic unsigned [1-1:0] reg_simple_mul;
    logic unsigned [8-1:0] reg_shift;
    logic unsigned [16-1:0] reg_len;
  } ctrl_engine_t;

  typedef struct packed {

    logic unsigned [$clog2(MUL_MDC_CNT_LEN):0] cnt_d;

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

    hwpe_stream_package::ctrl_sourcesink_t a_source_ctrl;
    hwpe_stream_package::ctrl_sourcesink_t b_source_ctrl;
    hwpe_stream_package::ctrl_sourcesink_t c_source_ctrl;

    hwpe_stream_package::ctrl_sourcesink_t d_sink_ctrl;

  } ctrl_streamer_t;

  typedef struct packed {

    hwpe_stream_package::flags_sourcesink_t a_source_flags;
    hwpe_stream_package::flags_sourcesink_t b_source_flags;
    hwpe_stream_package::flags_sourcesink_t c_source_flags;

    hwpe_stream_package::flags_sourcesink_t d_sink_flags;

  } flags_streamer_t;

  typedef struct packed {

    // Input stream - a (programmable)
    logic unsigned [31:0] a_trans_size;
    logic unsigned [15:0] a_line_stride;
    logic unsigned [15:0] a_line_length;
    logic unsigned [15:0] a_feat_stride;
    logic unsigned [15:0] a_feat_length;
    logic unsigned [15:0] a_feat_roll;
    logic unsigned [15:0] a_step;
    logic unsigned a_loop_outer;
    logic unsigned a_realign_type;
    // Input stream - b (programmable)
    logic unsigned [31:0] b_trans_size;
    logic unsigned [15:0] b_line_stride;
    logic unsigned [15:0] b_line_length;
    logic unsigned [15:0] b_feat_stride;
    logic unsigned [15:0] b_feat_length;
    logic unsigned [15:0] b_feat_roll;
    logic unsigned [15:0] b_step;
    logic unsigned b_loop_outer;
    logic unsigned b_realign_type;
    // Input stream - c (programmable)
    logic unsigned [31:0] c_trans_size;
    logic unsigned [15:0] c_line_stride;
    logic unsigned [15:0] c_line_length;
    logic unsigned [15:0] c_feat_stride;
    logic unsigned [15:0] c_feat_length;
    logic unsigned [15:0] c_feat_roll;
    logic unsigned [15:0] c_step;
    logic unsigned c_loop_outer;
    logic unsigned c_realign_type;

    // Output stream - d (programmable)
    logic unsigned [31:0] d_trans_size;
    logic unsigned [15:0] d_line_stride;
    logic unsigned [15:0] d_line_length;
    logic unsigned [15:0] d_feat_stride;
    logic unsigned [15:0] d_feat_length;
    logic unsigned [15:0] d_feat_roll;
    logic unsigned [15:0] d_step;
    logic unsigned d_loop_outer;
    logic unsigned d_realign_type;

    // Computation
    logic unsigned [$clog2(MUL_MDC_CNT_LEN):0] cnt_limit_d;

    // Custom registers
    logic unsigned [1-1:0] reg_simple_mul;
    logic unsigned [8-1:0] reg_shift;
    logic unsigned [16-1:0] reg_len;

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