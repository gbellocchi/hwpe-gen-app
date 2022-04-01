
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
  parameter int unsigned REG_INSTREAM0_ADDR              = 0;

  // Output ports
  parameter int unsigned REG_OUTSTREAM0_ADDR             = 1;

  // Standard registers

  parameter int unsigned REG_NB_ITER              = 2;

  parameter int unsigned REG_SHIFT_LINESTRIDE     = 3;

  parameter int unsigned REG_SHIFT_TILESTRIDE     = 4;

  parameter int unsigned REG_CNT_LIMIT_OUTSTREAM0             = 5;

  // Custom register files

  parameter int unsigned REG_WIDTH             = 6;

  parameter int unsigned REG_HEIGHT             = 7;

  parameter int unsigned CONFIG             = 8;

  // Input stream - inStream0 (programmable)
  parameter int unsigned REG_INSTREAM0_TRANS_SIZE       = 9;
  parameter int unsigned REG_INSTREAM0_LINE_STRIDE      = 10;
  parameter int unsigned REG_INSTREAM0_LINE_LENGTH      = 11;
  parameter int unsigned REG_INSTREAM0_FEAT_STRIDE      = 12;
  parameter int unsigned REG_INSTREAM0_FEAT_LENGTH      = 13;
  parameter int unsigned REG_INSTREAM0_FEAT_ROLL        = 14;
  parameter int unsigned REG_INSTREAM0_LOOP_OUTER       = 15;
  parameter int unsigned REG_INSTREAM0_REALIGN_TYPE     = 16;
  parameter int unsigned REG_INSTREAM0_STEP             = 17;

  // Output stream - outStream0 (programmable)
  parameter int unsigned REG_OUTSTREAM0_TRANS_SIZE       = 18;
  parameter int unsigned REG_OUTSTREAM0_LINE_STRIDE      = 19;
  parameter int unsigned REG_OUTSTREAM0_LINE_LENGTH      = 20;
  parameter int unsigned REG_OUTSTREAM0_FEAT_STRIDE      = 21;
  parameter int unsigned REG_OUTSTREAM0_FEAT_LENGTH      = 22;
  parameter int unsigned REG_OUTSTREAM0_FEAT_ROLL        = 23;
  parameter int unsigned REG_OUTSTREAM0_LOOP_OUTER       = 24;
  parameter int unsigned REG_OUTSTREAM0_REALIGN_TYPE     = 25;
  parameter int unsigned REG_OUTSTREAM0_STEP             = 26;

  /* Microcode processor */

  // offset indeces -- this should be aligned to the microcode compiler of course!
  parameter int unsigned UCODE_INSTREAM0_OFFS              = 0;

  parameter int unsigned UCODE_OUTSTREAM0_OFFS              = 1;

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

    logic unsigned [$clog2(CNT_LEN):0] cnt_limit_outStream0;

    // Custom register
  logic unsigned [(32-1):0] width;
  logic unsigned [(32-1):0] height;
  logic unsigned [(32-1):0] configuration;
  } ctrl_engine_t;

  typedef struct packed {

    logic unsigned [$clog2(CNT_LEN):0] cnt_outStream0;

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
  	
  hwpe_stream_package::ctrl_sourcesink_t inStream0_source_ctrl;

  hwpe_stream_package::ctrl_sourcesink_t outStream0_sink_ctrl;
  
  } ctrl_streamer_t;

  typedef struct packed {

  hwpe_stream_package::flags_sourcesink_t inStream0_source_flags;

  hwpe_stream_package::flags_sourcesink_t outStream0_sink_flags;
  } flags_streamer_t;

  typedef struct packed {

    // Input stream - inStream0 (programmable)
    logic unsigned [31:0] inStream0_trans_size;
    logic unsigned [15:0] inStream0_line_stride;
    logic unsigned [15:0] inStream0_line_length;
    logic unsigned [15:0] inStream0_feat_stride;
    logic unsigned [15:0] inStream0_feat_length;
    logic unsigned [15:0] inStream0_feat_roll;
    logic unsigned [15:0] inStream0_step;
    logic unsigned inStream0_loop_outer;
    logic unsigned inStream0_realign_type;

    // Output stream - outStream0 (programmable)
    logic unsigned [31:0] outStream0_trans_size;
    logic unsigned [15:0] outStream0_line_stride;
    logic unsigned [15:0] outStream0_line_length;
    logic unsigned [15:0] outStream0_feat_stride;
    logic unsigned [15:0] outStream0_feat_length;
    logic unsigned [15:0] outStream0_feat_roll;
    logic unsigned [15:0] outStream0_step;
    logic unsigned outStream0_loop_outer;
    logic unsigned outStream0_realign_type;

    // Computation
    logic unsigned [$clog2(CNT_LEN):0] cnt_limit_outStream0;

    // Custom register
    logic unsigned [(32-1):0] width;
    logic unsigned [(32-1):0] height;
    logic unsigned [(32-1):0] configuration;

  } ctrl_fsm_t;

endpackage
