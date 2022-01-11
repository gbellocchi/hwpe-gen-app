
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
 * Module: multi_dataflow_fsm.sv
 *
 */

import multi_dataflow_package::*;
import hwpe_ctrl_package::*;

module multi_dataflow_fsm (
  // Global signals
  input  logic                                  clk_i,
  input  logic                                  rst_ni,
  input  logic                                  test_mode_i,
  output logic                                  clear_i,
  // ctrl & flags
  output ctrl_streamer_t                        ctrl_streamer_o,
  input  flags_streamer_t                       flags_streamer_i,
  output ctrl_engine_t                          ctrl_engine_o,
  input  flags_engine_t                         flags_engine_i,
  output ctrl_uloop_t                           ctrl_ucode_o,
  input  flags_uloop_t                          flags_ucode_i,
  output ctrl_slave_t                           ctrl_slave_o,
  input  flags_slave_t                          flags_slave_i,
  input  ctrl_regfile_t                         reg_file_i,
  input  ctrl_fsm_t                             ctrl_i
);

  // State signals
  state_fsm_t curr_state, next_state;

  // State computation
  always_ff @(posedge clk_i or negedge rst_ni)
  begin : main_fsm_seq
    if(~rst_ni) begin
      curr_state <= FSM_IDLE;
    end
    else if(clear_i) begin
      curr_state <= FSM_IDLE;
    end
    else begin
      curr_state <= next_state;
    end
  end

  // State declaration
  always_comb
  begin : main_fsm_comb

    /* Initialize */

    // Address generator

    // Input stream - in1 (programmable)
    ctrl_streamer_o.in1_source_ctrl.addressgen_ctrl.trans_size   = ctrl_i.in1_trans_size;
    ctrl_streamer_o.in1_source_ctrl.addressgen_ctrl.line_stride  = ctrl_i.in1_line_stride;
    ctrl_streamer_o.in1_source_ctrl.addressgen_ctrl.line_length  = ctrl_i.in1_line_length;
    ctrl_streamer_o.in1_source_ctrl.addressgen_ctrl.feat_stride  = ctrl_i.in1_feat_stride;
    ctrl_streamer_o.in1_source_ctrl.addressgen_ctrl.feat_length  = ctrl_i.in1_feat_length;
    ctrl_streamer_o.in1_source_ctrl.addressgen_ctrl.base_addr    = reg_file_i.hwpe_params[REG_IN1_ADDR] + (flags_ucode_i.offs[UCODE_IN1_OFFS]);
    ctrl_streamer_o.in1_source_ctrl.addressgen_ctrl.feat_roll    = ctrl_i.in1_feat_roll;
    ctrl_streamer_o.in1_source_ctrl.addressgen_ctrl.loop_outer   = ctrl_i.in1_loop_outer;
    ctrl_streamer_o.in1_source_ctrl.addressgen_ctrl.realign_type = ctrl_i.in1_realign_type;
    ctrl_streamer_o.in1_source_ctrl.addressgen_ctrl.step         = ctrl_i.in1_step;
    // Input stream - in2 (programmable)
    ctrl_streamer_o.in2_source_ctrl.addressgen_ctrl.trans_size   = ctrl_i.in2_trans_size;
    ctrl_streamer_o.in2_source_ctrl.addressgen_ctrl.line_stride  = ctrl_i.in2_line_stride;
    ctrl_streamer_o.in2_source_ctrl.addressgen_ctrl.line_length  = ctrl_i.in2_line_length;
    ctrl_streamer_o.in2_source_ctrl.addressgen_ctrl.feat_stride  = ctrl_i.in2_feat_stride;
    ctrl_streamer_o.in2_source_ctrl.addressgen_ctrl.feat_length  = ctrl_i.in2_feat_length;
    ctrl_streamer_o.in2_source_ctrl.addressgen_ctrl.base_addr    = reg_file_i.hwpe_params[REG_IN2_ADDR] + (flags_ucode_i.offs[UCODE_IN2_OFFS]);
    ctrl_streamer_o.in2_source_ctrl.addressgen_ctrl.feat_roll    = ctrl_i.in2_feat_roll;
    ctrl_streamer_o.in2_source_ctrl.addressgen_ctrl.loop_outer   = ctrl_i.in2_loop_outer;
    ctrl_streamer_o.in2_source_ctrl.addressgen_ctrl.realign_type = ctrl_i.in2_realign_type;
    ctrl_streamer_o.in2_source_ctrl.addressgen_ctrl.step         = ctrl_i.in2_step;

    // Output stream - out_r (programmable)
    ctrl_streamer_o.out_r_sink_ctrl.addressgen_ctrl.trans_size   = ctrl_i.out_r_trans_size;
    ctrl_streamer_o.out_r_sink_ctrl.addressgen_ctrl.line_stride  = ctrl_i.out_r_line_stride;
    ctrl_streamer_o.out_r_sink_ctrl.addressgen_ctrl.line_length  = ctrl_i.out_r_line_length;
    ctrl_streamer_o.out_r_sink_ctrl.addressgen_ctrl.feat_stride  = ctrl_i.out_r_feat_stride;
    ctrl_streamer_o.out_r_sink_ctrl.addressgen_ctrl.feat_length  = ctrl_i.out_r_feat_length;
    ctrl_streamer_o.out_r_sink_ctrl.addressgen_ctrl.base_addr    = reg_file_i.hwpe_params[REG_OUT_R_ADDR] + (flags_ucode_i.offs[UCODE_OUT_R_OFFS]);
    ctrl_streamer_o.out_r_sink_ctrl.addressgen_ctrl.feat_roll    = ctrl_i.out_r_feat_roll;
    ctrl_streamer_o.out_r_sink_ctrl.addressgen_ctrl.loop_outer   = ctrl_i.out_r_loop_outer;
    ctrl_streamer_o.out_r_sink_ctrl.addressgen_ctrl.realign_type = ctrl_i.out_r_realign_type;
    ctrl_streamer_o.out_r_sink_ctrl.addressgen_ctrl.step         = ctrl_i.out_r_step;

    // Streamer
    ctrl_streamer_o.in1_source_ctrl.req_start    = '0;
    ctrl_streamer_o.in2_source_ctrl.req_start    = '0;

    ctrl_streamer_o.out_r_sink_ctrl.req_start    = '0;

    // Engine
    ctrl_engine_o.clear      = '1; // Clear counters
    ctrl_engine_o.enable     = '1; // Enable execution
    ctrl_engine_o.start      = '0; // Trigger execution
    ctrl_engine_o.cnt_limit_out_r  = ctrl_i.cnt_limit_out_r;

    // Slave
    ctrl_slave_o.done = '0;
    ctrl_slave_o.evt  = '0;

    // Custom Registers

    // Real finite-state machine
    next_state   = curr_state;

    ctrl_ucode_o.enable                        = '0;
    ctrl_ucode_o.clear                         = '0;

    /* States */

    case(curr_state)

      FSM_IDLE: begin
        // Wait for a start signal
        ctrl_ucode_o.clear = '1;
        if(flags_slave_i.start) begin
          next_state = FSM_START;
        end
      end

      FSM_START: begin
        // Update the indeces, then load the first feature
        if(

          flags_streamer_i.in1_source_flags.ready_start &
          flags_streamer_i.in2_source_flags.ready_start &

	      flags_streamer_i.out_r_sink_flags.ready_start
        ) begin

          next_state  = FSM_COMPUTE;
          ctrl_engine_o.start  = 1'b1;
          ctrl_engine_o.clear  = 1'b0;
          ctrl_engine_o.enable = 1'b1;

          // Request data streaming from/to TCDM

          ctrl_streamer_o.in1_source_ctrl.req_start = '1;
          ctrl_streamer_o.in2_source_ctrl.req_start = '1;

          ctrl_streamer_o.out_r_sink_ctrl.req_start = '1;
         end
         else begin
           next_state = FSM_WAIT;
         end
      end

      FSM_COMPUTE: begin
        ctrl_engine_o.clear  = 1'b0;
        if (
        (flags_engine_i.cnt_out_r == ctrl_i.cnt_limit_out_r) 

        ) begin
          next_state = FSM_TERMINATE;
        end
        if(flags_engine_i.ready) begin
          ctrl_engine_o.start  = 1'b1;
          ctrl_engine_o.clear  = 1'b0;
          ctrl_engine_o.enable = 1'b1;
        end
      end

      FSM_UPDATEIDX: begin
        // update the indeces, then go back to load or idle
        if(flags_ucode_i.valid == 1'b0) begin
          ctrl_ucode_o.enable = 1'b1;
        end
        else if(flags_ucode_i.done) begin
          next_state = FSM_TERMINATE;
        end
        else if(

          flags_streamer_i.in1_source_flags.ready_start &
          flags_streamer_i.in2_source_flags.ready_start &

          flags_streamer_i.out_r_sink_flags.ready_start

        )  begin
          next_state = FSM_COMPUTE;

          ctrl_engine_o.start  = 1'b1;
          ctrl_engine_o.clear  = 1'b0;
          ctrl_engine_o.enable = 1'b1;

          // Request data streaming from/to TCDM

          ctrl_streamer_o.in1_source_ctrl.req_start = '1;
          ctrl_streamer_o.in2_source_ctrl.req_start = '1;

    	  ctrl_streamer_o.out_r_sink_ctrl.req_start = '1;

        end
        else begin
          next_state = FSM_WAIT;
        end
      end

      FSM_WAIT: begin
        // wait for the flags to be ok then go back to load
        ctrl_engine_o.clear  = 1'b0;
        ctrl_engine_o.enable = 1'b0;
        ctrl_ucode_o.enable  = 1'b0;
        if(

          flags_streamer_i.in1_source_flags.ready_start &
          flags_streamer_i.in2_source_flags.ready_start &

          flags_streamer_i.out_r_sink_flags.ready_start

        )  begin

          next_state = FSM_COMPUTE;
          ctrl_engine_o.start = 1'b1;
          ctrl_engine_o.enable = 1'b1;

          // Request data streaming from/to TCDM

          ctrl_streamer_o.in1_source_ctrl.req_start = '1;
          ctrl_streamer_o.in2_source_ctrl.req_start = '1;

          ctrl_streamer_o.out_r_sink_ctrl.req_start = '1;

        end
      end

      FSM_TERMINATE: begin
        // wait for the flags to be ok then go back to idle
        ctrl_engine_o.clear  = 1'b0;
        ctrl_engine_o.enable = 1'b0;
        if(

          flags_streamer_i.in1_source_flags.ready_start &
          flags_streamer_i.in2_source_flags.ready_start &

          flags_streamer_i.out_r_sink_flags.ready_start

        )  begin
          next_state = FSM_IDLE;
          ctrl_slave_o.done = 1'b1;
        end
      end
    endcase // curr_state
  end

endmodule // multi_dataflow_fsm
