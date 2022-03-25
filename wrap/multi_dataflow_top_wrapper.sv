
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
 * Module: multi_dataflow_wrapper.sv
 *
 */

import multi_dataflow_package::*;
import hwpe_ctrl_package::*;

module multi_dataflow_top_wrap
#(
  parameter int unsigned N_CORES = 2,
  parameter int unsigned MP  = 4,
  parameter int unsigned ID  = 10
)
(
  // Global signals
  input  logic          clk_i,
  input  logic          rst_ni,
  input  logic          test_mode_i,

  // Events
  output logic [N_CORES-1:0][REGFILE_N_EVT-1:0] evt_o,

  // TCDM master ports
  output logic [MP-1:0]                         tcdm_req,
  input  logic [MP-1:0]                         tcdm_gnt,
  output logic [MP-1:0][31:0]                   tcdm_add,
  output logic [MP-1:0]                         tcdm_wen,
  output logic [MP-1:0][3:0]                    tcdm_be,
  output logic [MP-1:0][31:0]                   tcdm_data,
  input  logic [MP-1:0][31:0]                   tcdm_r_data,
  input  logic [MP-1:0]                         tcdm_r_valid,

  // Peripheral slave port
  input  logic                                  periph_req,
  output logic                                  periph_gnt,
  input  logic         [31:0]                   periph_add,
  input  logic                                  periph_wen,
  input  logic         [3:0]                    periph_be,
  input  logic         [31:0]                   periph_data,
  input  logic       [ID-1:0]                   periph_id,
  output logic         [31:0]                   periph_r_data,
  output logic                                  periph_r_valid,
  output logic       [ID-1:0]                   periph_r_id
);

  hwpe_stream_intf_tcdm tcdm[MP-1:0] (
    .clk ( clk_i )
  );

  hwpe_ctrl_intf_periph #(
    .ID_WIDTH ( ID )
  ) periph (
    .clk ( clk_i )
  );

  // bindings
  generate
    for(genvar ii=0; ii<MP; ii++) begin: tcdm_binding
      assign tcdm_req  [ii] = tcdm[ii].req;
      assign tcdm_add  [ii] = tcdm[ii].add;
      assign tcdm_wen  [ii] = tcdm[ii].wen;
      assign tcdm_be   [ii] = tcdm[ii].be;
      assign tcdm_data [ii] = tcdm[ii].data;
      assign tcdm[ii].gnt     = tcdm_gnt     [ii];
      assign tcdm[ii].r_data  = tcdm_r_data  [ii];
      assign tcdm[ii].r_valid = tcdm_r_valid [ii];
    end
  endgenerate

  always_comb
  begin
    periph.req  = periph_req;
    periph.add  = periph_add;
    periph.wen  = periph_wen;
    periph.be   = periph_be;
    periph.data = periph_data;
    periph.id   = periph_id;
    periph_gnt     = periph.gnt;
    periph_r_data  = periph.r_data;
    periph_r_valid = periph.r_valid;
    periph_r_id    = periph.r_id;
  end

  multi_dataflow_top #(
    .N_CORES ( N_CORES ),
    .MP      ( MP      ),
    .ID      ( ID      )
  ) i_multi_dataflow_top (
    .clk_i       ( clk_i       ),
    .rst_ni      ( rst_ni      ),
    .test_mode_i ( test_mode_i ),
    .evt_o       ( evt_o       ),
    .tcdm        ( tcdm        ),
    .periph      ( periph      )
  );

endmodule // multi_dataflow_top_wrap

