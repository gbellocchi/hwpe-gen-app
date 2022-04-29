
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
 * Module: multi_dataflow_ctrl.sv
 *
 */
 
import multi_dataflow_package::*;
import hwpe_ctrl_package::*;
module multi_dataflow_ctrl
#(
  parameter int unsigned N_CORES         = 2,
  parameter int unsigned N_CONTEXT       = 2,
  parameter int unsigned N_IO_REGS       = 16,
  parameter int unsigned ID              = 10,
  parameter int unsigned UCODE_HARDWIRED = 0
)
(  // Global signals
  input  logic                                  clk_i,
  input  logic                                  rst_ni,
  input  logic                                  test_mode_i,
  output logic                                  clear_o,
  // events
  output logic [N_CORES-1:0][REGFILE_N_EVT-1:0] evt_o,
  // ctrl & flags
  output ctrl_streamer_t                        ctrl_streamer_o,
  input  flags_streamer_t                       flags_streamer_i,
  output ctrl_engine_t                          ctrl_engine_o,
  input  flags_engine_t                         flags_engine_i,
  // periph slave port
  hwpe_ctrl_intf_periph.slave                   periph
);

  /* Ctrl/flag signals */

  // Slave
  ctrl_slave_t   slave_ctrl;
  flags_slave_t  slave_flags;

  // Register file
  ctrl_regfile_t reg_file;

  // Uloop
  logic [223:0]  ucode_flat;
  uloop_code_t   ucode;
  ctrl_uloop_t   ucode_ctrl;
  flags_uloop_t  ucode_flags;
  logic [11:0][31:0] ucode_registers_read;

  /* Standard registers */

  // Uloop
  logic unsigned [31:0] static_reg_nb_iter;
  logic unsigned [31:0] static_reg_vectstride;
  logic unsigned [31:0] static_reg_onestride;

  // Address generator
  // Controls - text
  logic unsigned [31:0] static_reg_text_trans_size;
  logic unsigned [15:0] static_reg_text_line_stride;
  logic unsigned [15:0] static_reg_text_line_length;
  logic unsigned [15:0] static_reg_text_feat_stride;
  logic unsigned [15:0] static_reg_text_feat_length;
  logic unsigned [15:0] static_reg_text_feat_roll;
  logic unsigned [15:0] static_reg_text_step;
  logic unsigned static_reg_text_loop_outer;
  logic unsigned static_reg_text_realign_type;
  // Controls - key
  logic unsigned [31:0] static_reg_key_trans_size;
  logic unsigned [15:0] static_reg_key_line_stride;
  logic unsigned [15:0] static_reg_key_line_length;
  logic unsigned [15:0] static_reg_key_feat_stride;
  logic unsigned [15:0] static_reg_key_feat_length;
  logic unsigned [15:0] static_reg_key_feat_roll;
  logic unsigned [15:0] static_reg_key_step;
  logic unsigned static_reg_key_loop_outer;
  logic unsigned static_reg_key_realign_type;
  // Controls - rc
  logic unsigned [31:0] static_reg_rc_trans_size;
  logic unsigned [15:0] static_reg_rc_line_stride;
  logic unsigned [15:0] static_reg_rc_line_length;
  logic unsigned [15:0] static_reg_rc_feat_stride;
  logic unsigned [15:0] static_reg_rc_feat_length;
  logic unsigned [15:0] static_reg_rc_feat_roll;
  logic unsigned [15:0] static_reg_rc_step;
  logic unsigned static_reg_rc_loop_outer;
  logic unsigned static_reg_rc_realign_type;

  // Controls - chiped_text
  logic unsigned [31:0] static_reg_chiped_text_trans_size;
  logic unsigned [15:0] static_reg_chiped_text_line_stride;
  logic unsigned [15:0] static_reg_chiped_text_line_length;
  logic unsigned [15:0] static_reg_chiped_text_feat_stride;
  logic unsigned [15:0] static_reg_chiped_text_feat_length;
  logic unsigned [15:0] static_reg_chiped_text_feat_roll;
  logic unsigned [15:0] static_reg_chiped_text_step;
  logic unsigned static_reg_chiped_text_loop_outer;
  logic unsigned static_reg_chiped_text_realign_type;

  // FSM
  logic unsigned [31:0] static_reg_cnt_limit_chiped_text;

  /* Custom registers */

  /* FSM input signals */
  ctrl_fsm_t fsm_ctrl;

  /* Peripheral slave & register file */
  hwpe_ctrl_slave #(
    .N_CORES        ( N_CORES               ),
    .N_CONTEXT      ( N_CONTEXT             ),
    .N_IO_REGS      ( N_IO_REGS             ),
    .N_GENERIC_REGS ( (1-UCODE_HARDWIRED)*8 ),
    .ID_WIDTH       ( ID                    )
  ) i_slave (
    .clk_i    ( clk_i       ),
    .rst_ni   ( rst_ni      ),
    .clear_o  ( clear_o     ),
    .cfg      ( periph      ),
    .ctrl_i   ( slave_ctrl  ),
    .flags_o  ( slave_flags ),
    .reg_file ( reg_file    )
  );

  /* Events */
  assign evt_o = slave_flags.evt;

  /* Direct register file mappings */

  // Uloop registers
  assign static_reg_nb_iter    = reg_file.hwpe_params[REG_NB_ITER]  + 1;
  assign static_reg_linestride = reg_file.hwpe_params[REG_SHIFT_LINESTRIDE];
  assign static_reg_tilestride = reg_file.hwpe_params[REG_SHIFT_TILESTRIDE];
  assign static_reg_onestride  = 4;

  // FSM signals
  assign static_reg_cnt_limit_chiped_text = reg_file.hwpe_params[REG_CNT_LIMIT_CHIPED_TEXT] + 1;
  // Address generator
  // Mapping - text
  assign static_reg_text_trans_size          = reg_file.hwpe_params[REG_TEXT_TRANS_SIZE];
  assign static_reg_text_line_stride         = reg_file.hwpe_params[REG_TEXT_LINE_STRIDE];
  assign static_reg_text_line_length         = reg_file.hwpe_params[REG_TEXT_LINE_LENGTH];
  assign static_reg_text_feat_stride         = reg_file.hwpe_params[REG_TEXT_FEAT_STRIDE];
  assign static_reg_text_feat_length         = reg_file.hwpe_params[REG_TEXT_FEAT_LENGTH];
  assign static_reg_text_feat_roll           = reg_file.hwpe_params[REG_TEXT_FEAT_ROLL];
  assign static_reg_text_step                = reg_file.hwpe_params[REG_TEXT_STEP];
  assign static_reg_text_loop_outer          = reg_file.hwpe_params[REG_TEXT_LOOP_OUTER];
  assign static_reg_text_realign_type        = reg_file.hwpe_params[REG_TEXT_REALIGN_TYPE];
  // Mapping - key
  assign static_reg_key_trans_size          = reg_file.hwpe_params[REG_KEY_TRANS_SIZE];
  assign static_reg_key_line_stride         = reg_file.hwpe_params[REG_KEY_LINE_STRIDE];
  assign static_reg_key_line_length         = reg_file.hwpe_params[REG_KEY_LINE_LENGTH];
  assign static_reg_key_feat_stride         = reg_file.hwpe_params[REG_KEY_FEAT_STRIDE];
  assign static_reg_key_feat_length         = reg_file.hwpe_params[REG_KEY_FEAT_LENGTH];
  assign static_reg_key_feat_roll           = reg_file.hwpe_params[REG_KEY_FEAT_ROLL];
  assign static_reg_key_step                = reg_file.hwpe_params[REG_KEY_STEP];
  assign static_reg_key_loop_outer          = reg_file.hwpe_params[REG_KEY_LOOP_OUTER];
  assign static_reg_key_realign_type        = reg_file.hwpe_params[REG_KEY_REALIGN_TYPE];
  // Mapping - rc
  assign static_reg_rc_trans_size          = reg_file.hwpe_params[REG_RC_TRANS_SIZE];
  assign static_reg_rc_line_stride         = reg_file.hwpe_params[REG_RC_LINE_STRIDE];
  assign static_reg_rc_line_length         = reg_file.hwpe_params[REG_RC_LINE_LENGTH];
  assign static_reg_rc_feat_stride         = reg_file.hwpe_params[REG_RC_FEAT_STRIDE];
  assign static_reg_rc_feat_length         = reg_file.hwpe_params[REG_RC_FEAT_LENGTH];
  assign static_reg_rc_feat_roll           = reg_file.hwpe_params[REG_RC_FEAT_ROLL];
  assign static_reg_rc_step                = reg_file.hwpe_params[REG_RC_STEP];
  assign static_reg_rc_loop_outer          = reg_file.hwpe_params[REG_RC_LOOP_OUTER];
  assign static_reg_rc_realign_type        = reg_file.hwpe_params[REG_RC_REALIGN_TYPE];

  // Mapping - chiped_text
  assign static_reg_chiped_text_trans_size         = reg_file.hwpe_params[REG_CHIPED_TEXT_TRANS_SIZE];
  assign static_reg_chiped_text_line_stride        = reg_file.hwpe_params[REG_CHIPED_TEXT_LINE_STRIDE];
  assign static_reg_chiped_text_line_length        = reg_file.hwpe_params[REG_CHIPED_TEXT_LINE_LENGTH];
  assign static_reg_chiped_text_feat_stride        = reg_file.hwpe_params[REG_CHIPED_TEXT_FEAT_STRIDE];
  assign static_reg_chiped_text_feat_length        = reg_file.hwpe_params[REG_CHIPED_TEXT_FEAT_LENGTH];
  assign static_reg_chiped_text_feat_roll          = reg_file.hwpe_params[REG_CHIPED_TEXT_FEAT_ROLL];
  assign static_reg_chiped_text_step               = reg_file.hwpe_params[REG_CHIPED_TEXT_STEP];
  assign static_reg_chiped_text_loop_outer         = reg_file.hwpe_params[REG_CHIPED_TEXT_LOOP_OUTER];
  assign static_reg_chiped_text_realign_type       = reg_file.hwpe_params[REG_CHIPED_TEXT_REALIGN_TYPE];

  // Custom registers

  /* Microcode processor */
  generate
    if(UCODE_HARDWIRED != 0) begin
      // equivalent to the microcode in ucode/code.yml
      assign ucode_flat = 224'h0000000000040000000000000000000000000000000008cd11a12c05;
    end
    else begin
      // the microcode is stored in registers independent of context (job)
      assign ucode_flat = reg_file.generic_params[6:0];
    end
  endgenerate
  assign ucode = {
    // loops & bytecode
    ucode_flat,
    // ranges
    12'b0,
    12'b0,
    12'b0,
    12'b0,
    12'b0,
    static_reg_nb_iter[11:0]
  };
  assign ucode_registers_read[UCODE_MNEM_NBITER]     = static_reg_nb_iter;
  assign ucode_registers_read[UCODE_MNEM_ITERSTRIDE] = static_reg_linestride;
  assign ucode_registers_read[UCODE_MNEM_ONESTRIDE]  = static_reg_onestride;
  assign ucode_registers_read[UCODE_MNEM_TILESTRIDE] = static_reg_tilestride;
  assign ucode_registers_read[11:4] = '0;

  hwpe_ctrl_uloop #(
    .NB_LOOPS       ( 2  ), // Default: 1
    .NB_REG         ( 4  ),
    .NB_RO_REG      ( 12 ),
    .DEBUG_DISPLAY  ( 1  )  // Default: 0
  ) i_uloop (
    .clk_i            ( clk_i                ),
    .rst_ni           ( rst_ni               ),
    .test_mode_i      ( test_mode_i          ),
    .clear_i          ( clear_o              ),
    .ctrl_i           ( ucode_ctrl           ),
    .flags_o          ( ucode_flags          ),
    .uloop_code_i     ( ucode                ),
    .registers_read_i ( ucode_registers_read )
  );

  /* Main FSM */
  multi_dataflow_fsm i_fsm (
    .clk_i            ( clk_i              ),
    .rst_ni           ( rst_ni             ),
    .test_mode_i      ( test_mode_i        ),
    .clear_i          ( clear_o            ),
    .ctrl_streamer_o  ( ctrl_streamer_o    ),
    .flags_streamer_i ( flags_streamer_i   ),
    .ctrl_engine_o    ( ctrl_engine_o      ),
    .flags_engine_i   ( flags_engine_i     ),
    .ctrl_ucode_o     ( ucode_ctrl         ),
    .flags_ucode_i    ( ucode_flags        ),
    .ctrl_slave_o     ( slave_ctrl         ),
    .flags_slave_i    ( slave_flags        ),
    .reg_file_i       ( reg_file           ),
    .ctrl_i           ( fsm_ctrl           )
  );
  always_comb
  begin

    // Address generator
    // Mapping - text
    fsm_ctrl.text_trans_size     = static_reg_text_trans_size;
    fsm_ctrl.text_line_stride    = static_reg_text_line_stride;
    fsm_ctrl.text_line_length    = static_reg_text_line_length;
    fsm_ctrl.text_feat_stride    = static_reg_text_feat_stride;
    fsm_ctrl.text_feat_length    = static_reg_text_feat_length;
    fsm_ctrl.text_feat_roll      = static_reg_text_feat_roll;
    fsm_ctrl.text_step           = static_reg_text_step;
    fsm_ctrl.text_loop_outer     = static_reg_text_loop_outer;
    fsm_ctrl.text_realign_type   = static_reg_text_realign_type;
    // Mapping - key
    fsm_ctrl.key_trans_size     = static_reg_key_trans_size;
    fsm_ctrl.key_line_stride    = static_reg_key_line_stride;
    fsm_ctrl.key_line_length    = static_reg_key_line_length;
    fsm_ctrl.key_feat_stride    = static_reg_key_feat_stride;
    fsm_ctrl.key_feat_length    = static_reg_key_feat_length;
    fsm_ctrl.key_feat_roll      = static_reg_key_feat_roll;
    fsm_ctrl.key_step           = static_reg_key_step;
    fsm_ctrl.key_loop_outer     = static_reg_key_loop_outer;
    fsm_ctrl.key_realign_type   = static_reg_key_realign_type;
    // Mapping - rc
    fsm_ctrl.rc_trans_size     = static_reg_rc_trans_size;
    fsm_ctrl.rc_line_stride    = static_reg_rc_line_stride;
    fsm_ctrl.rc_line_length    = static_reg_rc_line_length;
    fsm_ctrl.rc_feat_stride    = static_reg_rc_feat_stride;
    fsm_ctrl.rc_feat_length    = static_reg_rc_feat_length;
    fsm_ctrl.rc_feat_roll      = static_reg_rc_feat_roll;
    fsm_ctrl.rc_step           = static_reg_rc_step;
    fsm_ctrl.rc_loop_outer     = static_reg_rc_loop_outer;
    fsm_ctrl.rc_realign_type   = static_reg_rc_realign_type;

    // Mapping - chiped_text
    fsm_ctrl.chiped_text_trans_size     = static_reg_chiped_text_trans_size;
    fsm_ctrl.chiped_text_line_stride    = static_reg_chiped_text_line_stride;
    fsm_ctrl.chiped_text_line_length    = static_reg_chiped_text_line_length;
    fsm_ctrl.chiped_text_feat_stride    = static_reg_chiped_text_feat_stride;
    fsm_ctrl.chiped_text_feat_length    = static_reg_chiped_text_feat_length;
    fsm_ctrl.chiped_text_feat_roll      = static_reg_chiped_text_feat_roll;
    fsm_ctrl.chiped_text_step           = static_reg_chiped_text_step;
    fsm_ctrl.chiped_text_loop_outer     = static_reg_chiped_text_loop_outer;
    fsm_ctrl.chiped_text_realign_type   = static_reg_chiped_text_realign_type;

    /* Custom register file mappings to FSM */
    fsm_ctrl.cnt_limit_chiped_text             = static_reg_cnt_limit_chiped_text;

    // Custom registers
  end
endmodule
