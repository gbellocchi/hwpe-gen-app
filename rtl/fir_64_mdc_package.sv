

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
 * Module: fir_64_mdc_package.sv
 *
 */

import hwpe_stream_package::*;

package fir_64_mdc_package;

  parameter int unsigned FIR_64_MDC_CNT_LEN = 1024; // maximum length of the vectors for a scalar product

  /* Registers */

  // TCDM

  // Input ports
  parameter int unsigned FIR_64_MDC_REG_X_V_ADDR                = 0;

  // Output ports
  parameter int unsigned FIR_64_MDC_REG_Y_V_ADDR                = 1;

  // Standard registers

  parameter int unsigned FIR_64_MDC_REG_NB_ITER              = 2;

  parameter int unsigned FIR_64_MDC_REG_SHIFT_LINESTRIDE     = 3;

  parameter int unsigned FIR_64_MDC_REG_SHIFT_TILESTRIDE     = 4;

  parameter int unsigned FIR_64_MDC_REG_CNT_LIMIT_Y_V     = 5;

    // Input stream - x_V (programmable)
    parameter int unsigned FIR_64_MDC_REG_X_V_TRANS_SIZE       = 6;
    parameter int unsigned FIR_64_MDC_REG_X_V_LINE_STRIDE      = 7;
    parameter int unsigned FIR_64_MDC_REG_X_V_LINE_LENGTH      = 8;
    parameter int unsigned FIR_64_MDC_REG_X_V_FEAT_STRIDE      = 9;
    parameter int unsigned FIR_64_MDC_REG_X_V_FEAT_LENGTH      = 10;
    parameter int unsigned FIR_64_MDC_REG_X_V_FEAT_ROLL        = 11;
    parameter int unsigned FIR_64_MDC_REG_X_V_LOOP_OUTER       = 12;
    parameter int unsigned FIR_64_MDC_REG_X_V_REALIGN_TYPE     = 13;
    parameter int unsigned FIR_64_MDC_REG_X_V_STEP             = 14;

    // Output stream - y_V (programmable)
    parameter int unsigned FIR_64_MDC_REG_Y_V_TRANS_SIZE       = 15;
    parameter int unsigned FIR_64_MDC_REG_Y_V_LINE_STRIDE      = 16;
    parameter int unsigned FIR_64_MDC_REG_Y_V_LINE_LENGTH      = 17;
    parameter int unsigned FIR_64_MDC_REG_Y_V_FEAT_STRIDE      = 18;
    parameter int unsigned FIR_64_MDC_REG_Y_V_FEAT_LENGTH      = 19;
    parameter int unsigned FIR_64_MDC_REG_Y_V_FEAT_ROLL        = 20;
    parameter int unsigned FIR_64_MDC_REG_Y_V_LOOP_OUTER       = 21;
    parameter int unsigned FIR_64_MDC_REG_Y_V_REALIGN_TYPE     = 22;
    parameter int unsigned FIR_64_MDC_REG_Y_V_STEP             = 23;

  /* Microcode processor */

  // offset indeces -- this should be aligned to the microcode compiler of course!
  parameter int unsigned FIR_64_MDC_UCODE_X_V_OFFS               = 0;

  parameter int unsigned FIR_64_MDC_UCODE_Y_V_OFFS              = 1;

  // mnemonics -- this should be aligned to the microcode compiler of course!

  parameter int unsigned FIR_64_MDC_UCODE_MNEM_NBITER      = 0;

  parameter int unsigned FIR_64_MDC_UCODE_MNEM_ITERSTRIDE  = 1;

  parameter int unsigned FIR_64_MDC_UCODE_MNEM_ONESTRIDE   = 2;

  parameter int unsigned FIR_64_MDC_UCODE_MNEM_TILESTRIDE  = 3;

  /* Typedefs */

  typedef struct packed {
    logic clear;
    logic enable;
    logic start;

    logic unsigned [$clog2(FIR_64_MDC_CNT_LEN):0] cnt_limit_y_V;

  } ctrl_engine_t;

  typedef struct packed {

    logic unsigned [$clog2(FIR_64_MDC_CNT_LEN):0] cnt_y_V;

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

    hwpe_stream_package::ctrl_sourcesink_t x_V_source_ctrl;

    hwpe_stream_package::ctrl_sourcesink_t y_V_sink_ctrl;

  } ctrl_streamer_t;

  typedef struct packed {

    hwpe_stream_package::flags_sourcesink_t x_V_source_flags;

    hwpe_stream_package::flags_sourcesink_t y_V_sink_flags;

  } flags_streamer_t;

  typedef struct packed {

    // Input stream - x_V (programmable)
    logic unsigned [31:0] x_V_trans_size;
    logic unsigned [15:0] x_V_line_stride;
    logic unsigned [15:0] x_V_line_length;
    logic unsigned [15:0] x_V_feat_stride;
    logic unsigned [15:0] x_V_feat_length;
    logic unsigned [15:0] x_V_feat_roll;
    logic unsigned [15:0] x_V_step;
    logic unsigned x_V_loop_outer;
    logic unsigned x_V_realign_type;

    // Output stream - y_V (programmable)
    logic unsigned [31:0] y_V_trans_size;
    logic unsigned [15:0] y_V_line_stride;
    logic unsigned [15:0] y_V_line_length;
    logic unsigned [15:0] y_V_feat_stride;
    logic unsigned [15:0] y_V_feat_length;
    logic unsigned [15:0] y_V_feat_roll;
    logic unsigned [15:0] y_V_step;
    logic unsigned y_V_loop_outer;
    logic unsigned y_V_realign_type;

    // Computation
    logic unsigned [$clog2(FIR_64_MDC_CNT_LEN):0] cnt_limit_y_V;

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