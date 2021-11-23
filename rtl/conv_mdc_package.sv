

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
 * Module: conv_mdc_package.sv
 *
 */

import hwpe_stream_package::*;

package conv_mdc_package;

  parameter int unsigned CONV_MDC_CNT_LEN = 1024; // maximum length of the vectors for a scalar product

  /* Registers */

  // TCDM

  // Input ports
  parameter int unsigned CONV_MDC_REG_SRC_V_ADDR                = 0;

  // Output ports
  parameter int unsigned CONV_MDC_REG_DST_V_ADDR                = 1;

  // Standard registers

  parameter int unsigned CONV_MDC_REG_NB_ITER              = 2;

  parameter int unsigned CONV_MDC_REG_SHIFT_LINESTRIDE     = 3;

  parameter int unsigned CONV_MDC_REG_SHIFT_TILESTRIDE     = 4;

  parameter int unsigned CONV_MDC_REG_CNT_LIMIT_DST_V     = 5;

  // Custom registers

  parameter int unsigned CONV_MDC_REG_WIDTH             = 6;

  parameter int unsigned CONV_MDC_REG_HEIGHT             = 7;

    // Input stream - src_V (programmable)
    parameter int unsigned CONV_MDC_REG_SRC_V_TRANS_SIZE       = 8;
    parameter int unsigned CONV_MDC_REG_SRC_V_LINE_STRIDE      = 9;
    parameter int unsigned CONV_MDC_REG_SRC_V_LINE_LENGTH      = 10;
    parameter int unsigned CONV_MDC_REG_SRC_V_FEAT_STRIDE      = 11;
    parameter int unsigned CONV_MDC_REG_SRC_V_FEAT_LENGTH      = 12;
    parameter int unsigned CONV_MDC_REG_SRC_V_FEAT_ROLL        = 13;
    parameter int unsigned CONV_MDC_REG_SRC_V_LOOP_OUTER       = 14;
    parameter int unsigned CONV_MDC_REG_SRC_V_REALIGN_TYPE     = 15;
    parameter int unsigned CONV_MDC_REG_SRC_V_STEP             = 16;

    // Output stream - dst_V (programmable)
    parameter int unsigned CONV_MDC_REG_DST_V_TRANS_SIZE       = 17;
    parameter int unsigned CONV_MDC_REG_DST_V_LINE_STRIDE      = 18;
    parameter int unsigned CONV_MDC_REG_DST_V_LINE_LENGTH      = 19;
    parameter int unsigned CONV_MDC_REG_DST_V_FEAT_STRIDE      = 20;
    parameter int unsigned CONV_MDC_REG_DST_V_FEAT_LENGTH      = 21;
    parameter int unsigned CONV_MDC_REG_DST_V_FEAT_ROLL        = 22;
    parameter int unsigned CONV_MDC_REG_DST_V_LOOP_OUTER       = 23;
    parameter int unsigned CONV_MDC_REG_DST_V_REALIGN_TYPE     = 24;
    parameter int unsigned CONV_MDC_REG_DST_V_STEP             = 25;

  /* Microcode processor */

  // offset indeces -- this should be aligned to the microcode compiler of course!
  parameter int unsigned CONV_MDC_UCODE_SRC_V_OFFS               = 0;

  parameter int unsigned CONV_MDC_UCODE_DST_V_OFFS              = 1;

  // mnemonics -- this should be aligned to the microcode compiler of course!

  parameter int unsigned CONV_MDC_UCODE_MNEM_NBITER      = 0;

  parameter int unsigned CONV_MDC_UCODE_MNEM_ITERSTRIDE  = 1;

  parameter int unsigned CONV_MDC_UCODE_MNEM_ONESTRIDE   = 2;

  parameter int unsigned CONV_MDC_UCODE_MNEM_TILESTRIDE  = 3;

  /* Typedefs */

  typedef struct packed {
    logic clear;
    logic enable;
    logic start;

    logic unsigned [$clog2(CONV_MDC_CNT_LEN):0] cnt_limit_dst_V;

    // Custom registers
    logic unsigned [32-1:0] width;
    logic unsigned [32-1:0] height;
  } ctrl_engine_t;

  typedef struct packed {

    logic unsigned [$clog2(CONV_MDC_CNT_LEN):0] cnt_dst_V;

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

    hwpe_stream_package::ctrl_sourcesink_t src_V_source_ctrl;

    hwpe_stream_package::ctrl_sourcesink_t dst_V_sink_ctrl;

  } ctrl_streamer_t;

  typedef struct packed {

    hwpe_stream_package::flags_sourcesink_t src_V_source_flags;

    hwpe_stream_package::flags_sourcesink_t dst_V_sink_flags;

  } flags_streamer_t;

  typedef struct packed {

    // Input stream - src_V (programmable)
    logic unsigned [31:0] src_V_trans_size;
    logic unsigned [15:0] src_V_line_stride;
    logic unsigned [15:0] src_V_line_length;
    logic unsigned [15:0] src_V_feat_stride;
    logic unsigned [15:0] src_V_feat_length;
    logic unsigned [15:0] src_V_feat_roll;
    logic unsigned [15:0] src_V_step;
    logic unsigned src_V_loop_outer;
    logic unsigned src_V_realign_type;

    // Output stream - dst_V (programmable)
    logic unsigned [31:0] dst_V_trans_size;
    logic unsigned [15:0] dst_V_line_stride;
    logic unsigned [15:0] dst_V_line_length;
    logic unsigned [15:0] dst_V_feat_stride;
    logic unsigned [15:0] dst_V_feat_length;
    logic unsigned [15:0] dst_V_feat_roll;
    logic unsigned [15:0] dst_V_step;
    logic unsigned dst_V_loop_outer;
    logic unsigned dst_V_realign_type;

    // Computation
    logic unsigned [$clog2(CONV_MDC_CNT_LEN):0] cnt_limit_dst_V;

    // Custom registers
    logic unsigned [32-1:0] width;
    logic unsigned [32-1:0] height;

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