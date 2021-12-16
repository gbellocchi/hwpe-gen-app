/*
 * mac_engine.sv
 * Francesco Conti <fconti@iis.ee.ethz.ch>
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
 * The architecture that follows is relatively straightforward; it supports two modes:
 *  - in 'reg_simple_mult' mode, the a and b streams feed the 32b x 32b multiplier (mult).
 *    The output of the multiplier (64b) is registered in a pipeline stage
 *    (r_mult), which is then shifted by reg_shift to the right and streamed out as d.
 *    There is no control local to the module except for handshakes.
 *  - in 'scalar_prod' mode, the c stream is first shifted left by reg_shift, extended
 *    to 64b and saved in r_acc. Then, the a and b streams feed the 32b x 32b multiplier
 *    (mult) for reg_len cycles, controlled by a local counter. The output of mult is 
 *    registered in a pipeline stage (r_mult), whose value is used as input to an accumulator
 *    (r_acc) -- the one which was inited by the shifted value of c. At the end of the
 *    reg_len cycles, the output of r_acc is shifted back to the right by reg_shift
 *    bits and streamed out as d.
 */

package local_mac_package;
  parameter int unsigned MAC_CNT_LEN = 4096; // maximum length of the vectors for a scalar product
endpackage

module mul_mdc import local_mac_package::*;
(

  // global signals
  input  logic                                      ap_clk,
  input  logic                                      ap_rst_n,

  // input a stream
  input logic                                       a_TVALID,
  output logic                                      a_TREADY,
  input logic [32-1:0]                              a_TDATA,

  // input b stream
  input logic                                       b_TVALID,
  output logic                                      b_TREADY,
  input logic [32-1:0]                              b_TDATA,

  // input c stream
  input logic                                       c_TVALID,
  output logic                                      c_TREADY,
  input logic [32-1:0]                              c_TDATA,

  // output d stream
  output logic                                      d_TVALID,
  input logic                                       d_TREADY,
  output logic [32-1:0]                             d_TDATA,

  // custom registers
  input logic unsigned                              reg_simple_mul,
  input logic unsigned [$clog2(32)-1:0]             reg_shift,
  input logic unsigned [$clog2(MAC_CNT_LEN)-1:0]    reg_len
);

  logic unsigned [$clog2(MAC_CNT_LEN):0] cnt;
  logic unsigned [$clog2(MAC_CNT_LEN):0] r_cnt;

  logic signed [63:0] c_shifted;
  logic signed [63:0] mult;
  logic signed [63:0] r_mult;
  logic               r_mult_valid;
  logic               r_mult_ready;
  logic signed [64+$clog2(MAC_CNT_LEN)-1:0] r_acc;
  logic                                     r_acc_valid;
  logic                                     r_acc_ready;
  logic signed [64+$clog2(MAC_CNT_LEN)-1:0] d_nonshifted;
  logic                                     d_nonshifted_valid;

  // A design choice of this accelerator is that at the interface of modules only a few categories
  // of signals are exposed:
  //  - global signals (clk, rst_n)
  //  - HWPE-Stream or TCDM interfaces (a, ...)
  //  - a control packed struct (ctrl_i) and a state packed struct (flags_o)
  // The flags_o packed struct encapsulates all of the information about the internal state
  // of the module that must be exposed to the controller, and the ctrl_i all the control
  // information necessary for configuring the current module. In this way, it is possible to
  // make significant changes to the control interface (which can typically propagate through
  // a big hierarchy of modules) without manually modifying the interface in all modules; it
  // is sufficient to change the packed struct definition in the package where it is defined.
  // Packed structs are essentially bit vectors where bit fields have a name, and as such
  // are easily synthesizable and much more readable than Verilog-2001-ish code.

  // reg_shift c by reg_shift bits to the left
  always_comb
  begin : shift_c
    c_shifted = $signed(c_TDATA <<< reg_shift);
  end

  // multiply a by b
  always_comb
  begin : mult_a_X_b
    mult = $signed(a_TDATA) * $signed(b_TDATA);
  end

  // r_mult stores a * b
  always_ff @(posedge ap_clk or negedge ap_rst_n)
  begin : mult_pipe_data
    if(~ap_rst_n) begin
      r_mult <= '0;
    end
    else if (a_TVALID & b_TVALID & a_TREADY & b_TREADY) begin
      r_mult <= mult;
    end
  end

  // r_mult is valid following a valid handshake
  always_ff @(posedge ap_clk or negedge ap_rst_n)
  begin : mult_pipe_valid
    if(~ap_rst_n) begin
      r_mult_valid <= '0;
    end
    else if ((a_TVALID & b_TVALID) | (r_mult_valid & r_mult_ready)) begin
      r_mult_valid <= a_TVALID & b_TVALID;
    end
  end

  // accumulator
  always_ff @(posedge ap_clk or negedge ap_rst_n)
  begin : accumulator
    if(~ap_rst_n) begin
      r_acc <= '0;
    end
    // // else if (clear) begin
    // //   r_acc <= '0;
    // // end
    // // else if (enable) begin
    //   // r_acc value is updated if there are both c and r_mult valid handshakes at its input
    // else if (r_mult_valid & r_mult_ready & c_TVALID & c_TREADY) begin
    //   r_acc <= $signed(c_shifted + r_mult);
    // end
    // // r_acc value is updated if there is a c valid handshake at its input
    // else if (c_TVALID & c_TREADY) begin
    //   r_acc <= $signed(c_shifted);
    // end
    // r_acc value is updated if there is a r_mult valid handshake at its input
    else if (r_mult_valid & r_mult_ready) begin
      r_acc <= $signed(r_acc + r_mult);
    end
  end

  // r_acc is valid if all input arrays values have undergone dot product
  always_ff @(posedge ap_clk or negedge ap_rst_n)
  begin : accumulator_valid
    if(~ap_rst_n) begin
      r_acc_valid <= '0;
    end
      // r_acc_valid is re-evaluated after a valid handshake or in transition to 1
    else if((r_cnt == reg_len) & r_mult_valid & r_mult_ready) begin
      r_acc_valid <= '1;
    end
    else begin
      r_acc_valid <= '0;
    end
  end

  always_comb
  begin : d_nonshifted_comb
    if(reg_simple_mul) begin
      d_nonshifted       = $signed(r_mult);
      d_nonshifted_valid = r_mult_valid;
    end
    else begin
      d_nonshifted       = r_acc;
      d_nonshifted_valid = r_acc_valid;
    end
  end

  always_comb
  begin
    d_TDATA  = $signed(d_nonshifted >>> reg_shift); // no saturation/clipping
    d_TVALID = d_nonshifted_valid; // enable & d_nonshifted_valid;
  end

  // The control counter is implemented directly inside this module; as the control is
  // minimal, it was not deemed convenient to move it to another submodule. For bigger
  // FSMs that is typically the most advantageous choice.
  always_comb
  begin
    cnt = r_cnt + 1;
  end

  always_ff @(posedge ap_clk or negedge ap_rst_n)
  begin
    if(~ap_rst_n) begin
      r_cnt <= '0;
    end
    else if ((r_cnt < reg_len) && (r_mult_valid & r_mult_ready == 1'b1)) begin
      r_cnt <= (r_acc_valid & r_acc_ready) ? '0 : cnt;
    end
    else if(r_acc_valid) begin
      r_cnt <= '0;
    end
  end

  // Ready signals have to be propagated backwards through pipeline stages (combinationally).
  // To avoid deadlocks, the following rules have to be followed:
  //  1) transition of ready CAN depend on the current state of valid
  //  2) transition of valid CANNOT depend on the current state of ready
  //  3) transition 1->0 of valid MUST depend on (previous) ready (i.e., once the valid goes
  //     to 1 it cannot go back to 0 until there is a valid handshake)
  // In the following:
  // R_valid & R_ready denominate the handshake at the *output* (Q port) of pipe register R

  // output accepts new value from accumulator when the output is ready or r_acc is invalid
  assign r_acc_ready  = d_TREADY | ~r_acc_valid;
  // accumulator accepts new value from multiplier when
  //   1) output is ready or r_mult is invalid (if in simple multiplication mode)
  //   2) r_acc is ready or r_mult is invalid (if in scalar product mode)
  assign r_mult_ready = (reg_simple_mul) ? d_TREADY   | ~r_mult_valid
                                            : r_acc_ready | ~r_mult_valid;
  // multiplier accepts new value from a/b when r_mult is ready and both a/b are valid, or when both a/b are invalid
  assign a_TREADY = (r_mult_ready & a_TVALID & b_TVALID) | (~a_TVALID & ~b_TVALID);
  assign b_TREADY = (r_mult_ready & a_TVALID & b_TVALID) | (~a_TVALID & ~b_TVALID);
  // multiplier accepts new value from c when r_acc is ready or c is invalid
  assign c_TREADY    = r_acc_ready  | ~c_TVALID;

  // The following assertions help in getting the rules on ready & valid right.
  // They are copied from the general stream rules in hwpe_stream_interfaces.sv
  // and adapted to the internal r_acc and r_mult signals.
  `ifndef SYNTHESIS
  `ifndef VERILATOR
    // The data and strb can change their value 1) when valid is deasserted,
    // 2) in the cycle after a valid handshake, even if valid remains asserted.
    // In other words, valid data must remain on the interface until
    // a valid handshake has occurred.
    property r_acc_change_rule;
      @(posedge ap_clk)
      ($past(r_acc_valid) & ~($past(r_acc_valid) & $past(r_acc_ready))) |-> (r_acc == $past(r_acc));
    endproperty;
    property r_mult_change_rule;
      @(posedge ap_clk)
      ($past(r_mult_valid) & ~($past(r_mult_valid) & $past(r_mult_ready))) |-> (r_mult == $past(r_mult));
    endproperty;
    
    // The deassertion of valid (transition 1í0) can happen only in the cycle
    // after a valid handshake. In other words, valid data produced by a source
    // must be consumed on the sink side before valid is deasserted.
    property r_acc_valid_deassert_rule;
      @(posedge ap_clk)
      ($past(r_acc_valid) & ~r_acc_valid) |-> $past(r_acc_valid) & $past(r_acc_ready);
    endproperty;
    property r_mult_valid_deassert_rule;
      @(posedge ap_clk)
      ($past(r_mult_valid) & ~r_mult_valid) |-> $past(r_mult_valid) & $past(r_mult_ready);
    endproperty;

    R_ACC_VALUE_CHANGE:    assert property(r_acc_change_rule)
      else $fatal("ASSERTION FAILURE: R_ACC_VALUE_CHANGE", 1);

    R_ACC_VALID_DEASSERT:  assert property(r_acc_valid_deassert_rule)
      else $fatal("ASSERTION FAILURE R_ACC_VALID_DEASSERT", 1);

    R_MULT_VALUE_CHANGE:   assert property(r_mult_change_rule)
      else $fatal("ASSERTION FAILURE: R_MULT_VALUE_CHANGE", 1);

    R_MULT_VALID_DEASSERT: assert property(r_mult_valid_deassert_rule)
      else $fatal("ASSERTION FAILURE R_MULT_VALID_DEASSERT", 1);
  `endif /* VERILATOR */
  `endif /* SYNTHESIS */

endmodule // mac_engine
