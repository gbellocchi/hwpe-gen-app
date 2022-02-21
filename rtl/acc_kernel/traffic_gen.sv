/* =====================================================================
 * Project:      Traffic generator
 * Title:        traffic_gen.sv
 * Description:  Top module of traffic generator.
 *
 * $Date:        16.2.2022
 *
 * ===================================================================== */
/*
 * Copyright (C) 2022 University of Modena and Reggio Emilia.
 *
 * Author: Gianluca Bellocchi, University of Modena and Reggio Emilia.
 *
 */

module traffic_gen #(
  parameter int unsigned WORD_WIDTH = 32
) (
  // global signals
  input  logic                                      ap_clk,
  input  logic                                      ap_rst_n,

  // input a stream
  input logic                                       r_reqs_TVALID,
  output logic                                      r_reqs_TREADY,
  input logic [32-1:0]                              r_reqs_TDATA,
  // hwpe_stream_intf_stream.sink                      r_reqs,

  // output d stream
  output logic                                      w_reqs_TVALID,
  input logic                                       w_reqs_TREADY,
  output logic [WORD_WIDTH-1:0]                     w_reqs_TDATA,
  // hwpe_stream_intf_stream.source                    w_reqs,

  // control channel (custom registers)
  input logic unsigned [WORD_WIDTH-1:0]             n_total_reqs,
  input logic unsigned [WORD_WIDTH-1:0]             t_ck_reqs,
  input logic unsigned [WORD_WIDTH-1:0]             t_ck_idle,

  // Control signals
  input logic                                       ap_start,
  output logic                                      ap_done,
  output logic                                      ap_idle,
  output logic                                      ap_ready

  // input  ctrl_engine_t                              ctrl_i, 
  // output flags_engine_t                             flags_o
);

  // registered output
  logic [WORD_WIDTH-1:0] out;
  logic [WORD_WIDTH-1:0] r_out;
  logic r_out_valid;
  logic r_out_ready;

  // counter signals
  logic unsigned [WORD_WIDTH-1:0] read_r_cnt;
  logic unsigned [WORD_WIDTH-1:0] write_r_cnt;

  logic stream_idle, stream_r_idle;
  logic [WORD_WIDTH-1:0] count_idle;

  ////////////////////////////////////////////////////////////////////////////////////////////

  // < PILOT IDLE SIGNAL >

  always_comb
  begin
    if(ap_start & (read_r_cnt == t_ck_reqs-1)) begin
      stream_idle = 1'b1;
    end
    else begin
      stream_idle = 1'b0;
    end
  end

  always_ff @(posedge ap_clk or negedge ap_rst_n)
  begin
    if(~ap_rst_n) begin // reset counter
      stream_r_idle <= '0;
    end
    else if(ap_start) begin
      if (stream_idle) begin
        stream_r_idle <= stream_idle;
      end
      else if (count_idle==t_ck_idle-1) begin
        stream_r_idle <= '0;
      end
    end
    else begin
      stream_r_idle <= '0;
    end
  end

  // Idle timer
  PWM_timer #(
      .WORD_WIDTH (WORD_WIDTH)
  ) i_idle_timer (   
      .clk        ( ap_clk        ),
      .rstn       ( ap_rst_n      ),
      .restart    ( stream_idle   ),
      .count      ( count_idle    )
  );

  ////////////////////////////////////////////////////////////////////////////////////////////

  // < COUNT ACCEPTED READ REQUESTS >

  always_ff @(posedge ap_clk or negedge ap_rst_n)
  begin
    if(~ap_rst_n) begin // reset counter
      read_r_cnt <= '0;
    end
    else if((read_r_cnt == t_ck_reqs-1)) begin // reset counter
      read_r_cnt <= '0;
    end
    else if(ap_start) begin
      if (r_reqs_TVALID & r_reqs_TREADY == 1'b1) begin
        read_r_cnt <= read_r_cnt + 1;
      end
    end
  end

  // < COUNT GENERATED WRITE REQUESTS >

  always_ff @(posedge ap_clk or negedge ap_rst_n)
  begin
    if(~ap_rst_n) begin // reset counter
      write_r_cnt <= '0;
    end
    else if((write_r_cnt == n_total_reqs-1)) begin // reset counter
      write_r_cnt <= '0;
    end
    else if(ap_start) begin
      if (w_reqs_TVALID & w_reqs_TREADY == 1'b1) begin
        write_r_cnt <= write_r_cnt + 1;
      end
    end
  end

  ////////////////////////////////////////////////////////////////////////////////////////////

  // < REGISTER OUTPUT VALUES >

  always_comb
  begin
    out = r_reqs_TDATA;
  end

  always_ff @(posedge ap_clk or negedge ap_rst_n)
  begin : register_out
    if(~ap_rst_n) begin
      r_out <= '0;
    end
    else if (ap_done) begin
      r_out <= '0;
    end
    else if(ap_start) begin // if job
      // r_out value is updated if there is a valid handshake at its input
      if (r_reqs_TVALID & r_reqs_TREADY) begin
        r_out <= out;
      end
    end
  end

  // r_out is valid following a valid handshake
  always_ff @(posedge ap_clk or negedge ap_rst_n)
  begin : out_pipe_valid
    if(~ap_rst_n) begin
      r_out_valid <= '0;
    end
    else if(ap_start) begin // if job
      if ((r_reqs_TVALID) | (r_out_valid & r_out_ready)) begin
        r_out_valid <= r_reqs_TVALID;
      end
    end
  end

  assign r_out_ready = w_reqs_TREADY;

  ////////////////////////////////////////////////////////////////////////////////////////////

  // < DRIVE INPUT READS >

  always_comb
  begin
    r_reqs_TREADY = ap_start & ~stream_r_idle; 
  end

  // < DRIVE OUTPUT WRITES >

  always_comb
  begin
    w_reqs_TDATA  = r_out;
    w_reqs_TVALID = r_out_valid & ~stream_r_idle | '0; 
  end

  ////////////////////////////////////////////////////////////////////////////////////////////

  // < DRIVE DONE SIGNAL >

  always_ff @(posedge ap_clk or negedge ap_rst_n)
  begin: fsm_flags_done
    if(~ap_rst_n) begin
      ap_done <= 1'b0;
    end
    else if((write_r_cnt>0)&&(write_r_cnt == n_total_reqs-1)) begin
      ap_done <= 1'b1;
    end
    else begin
      ap_done <= 1'b0;
    end
  end

  // // < DRIVE IDLE/READY SIGNAL >

  // TO-DO; Need to re-think the generated control interface for handcrafted accelerators.
  // The signals should be standardized and a clear technical guide on how to use them
  // should be written.

  always_ff @(posedge ap_clk or negedge ap_rst_n)
  begin: fsm_flags_status
    if(~ap_rst_n) begin
      ap_ready <= 1'b0;
      ap_idle  <= 1'b0;
    end
    else if(ap_start) begin
      ap_ready <= 1'b1;
      ap_idle  <= 1'b1;
    end
    else if(ap_done) begin
      ap_ready <= 1'b0;
      ap_idle  <= 1'b0;
    end
  end

  ////////////////////////////////////////////////////////////////////////////////////////////

endmodule // traffic_gen
