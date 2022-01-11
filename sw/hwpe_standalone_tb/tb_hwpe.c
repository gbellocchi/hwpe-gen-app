
/*
 *
 * Copyright (C) 2018-2019 ETH Zurich, University of Bologna
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
 * Module: tb_hwpe.c
 *
 */

// Standard libs
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

// HWPE
#include "inc/hwpe_lib/archi_hwpe.h"
#include "inc/hwpe_lib/hal_hwpe.h"

  // Synthetic stimuli
  #include "inc/stim/in1.h"
  #include "inc/stim/in2.h"

  // Golden results
  #include "inc/stim/out_r_dut.h"
  #include "inc/stim/out_r_ref.h"

/* - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / */

/*
 *
 *     HWPE SW test.
 *
 */

int main() {

  /* Application-specific parameters. */

  // These parameters have to be set by the user before to compile the application.

  // 1. Workload

  unsigned width                  = ;
  unsigned height                 = ;
  unsigned stripe_height          = ;

  // 2. Accelerator execution

  // Number of engine runs needed to terminate the accelerator job.
  // This is equivalent to the number of 'done' signals that are
  // produced by the engine itself.

  unsigned engine_runs_out_r = ;

  // 3. Custom registers

  /* General parameters. */

  volatile unsigned errors = 0;
  unsigned i, j;
  int offload_id_tmp, offload_id;

  /* Stream-specific parameters. */

  unsigned in1_width              = width;
  unsigned in1_height             = height;
  unsigned in1_stripe_height      = stripe_height;
  unsigned in2_width              = width;
  unsigned in2_height             = height;
  unsigned in2_stripe_height      = stripe_height;
  unsigned out_r_width              = width;
  unsigned out_r_height             = height;
  unsigned out_r_stripe_height      = stripe_height;

  /* Dataset parameters. */
  unsigned in1_stim_dim               = in1_width * in1_height;
  unsigned in1_stripe_in_len          = in1_width * in1_stripe_height;
  unsigned in2_stim_dim               = in2_width * in2_height;
  unsigned in2_stripe_in_len          = in2_width * in2_stripe_height;

  unsigned out_r_stim_dim              = out_r_width * out_r_height;
  unsigned out_r_stripe_out_len        = out_r_width * out_r_stripe_height;

  /* Address generator (input) - Parameters */

  const unsigned in1_trans_size             = in1_width * in1_stripe_height;
  const unsigned in1_line_stride            = 0;
  const unsigned in1_line_length            = in1_width * in1_stripe_height;
  const unsigned in1_feat_stride            = 0;
  const unsigned in1_feat_length            = 1;
  const unsigned in1_feat_roll              = 0;
  const unsigned in1_loop_outer             = 0;
  const unsigned in1_realign_type           = 0;
  const unsigned in1_step                   = 4;
  const unsigned in2_trans_size             = in2_width * in2_stripe_height;
  const unsigned in2_line_stride            = 0;
  const unsigned in2_line_length            = in2_width * in2_stripe_height;
  const unsigned in2_feat_stride            = 0;
  const unsigned in2_feat_length            = 1;
  const unsigned in2_feat_roll              = 0;
  const unsigned in2_loop_outer             = 0;
  const unsigned in2_realign_type           = 0;
  const unsigned in2_step                   = 4;

  /* Address generator (output) - Parameters */
  
  const unsigned out_r_trans_size             = out_r_width * out_r_stripe_height + 1;
  const unsigned out_r_line_stride            = 0;
  const unsigned out_r_line_length            = out_r_width * out_r_stripe_height;
  const unsigned out_r_feat_stride            = 0;
  const unsigned out_r_feat_length            = 1;
  const unsigned out_r_feat_roll              = 0;
  const unsigned out_r_loop_outer             = 0;
  const unsigned out_r_realign_type           = 0;
  const unsigned out_r_step                   = 4;

  /* Allocation of I/O arrays. */

  // Stimuli
  
  int32_t *in1_l1 = in1;
  int32_t *in2_l1 = in2;

  // Results

  int32_t *out_r_l1 = out_r_dut;

  // Golden results

  int32_t *out_r_golden_l1 = out_r_ref;

  /* Initialization of I/O arrays. */

  // Stimuli

  // for (i = 0; i < in1_stripe_height; i++){
  //   for (j = 0; j < in1_width; j++){
  //     in1_l1[i*in1_width+j] = in1[i*in1_width+j];
  //   }
  // }
  // for (i = 0; i < in2_stripe_height; i++){
  //   for (j = 0; j < in2_width; j++){
  //     in2_l1[i*in2_width+j] = in2[i*in2_width+j];
  //   }
  // }

  // Golden results

  // for (i = 0; i < out_r_stripe_height; i++){
  //   for (j = 0; j < out_r_width; j++){
  //     out_r_golden_l1[i*out_r_width+j] = out_r[i*out_r_width+j];
  //   }
  // }

  /* HWPE initialization */

  hwpe_cg_enable();
  while((offload_id_tmp = hwpe_acquire_job()) < 0)

  /* FSM programming */

  hwpe_len_iter_set_out_r(engine_runs_out_r-1);

  /* Address generator programming */

  // Input in1
  hwpe_addr_gen_in1(
    in1_trans_size,
    in1_line_stride,
    in1_line_length,
    in1_feat_stride,
    in1_feat_length,
    in1_feat_roll,
    in1_loop_outer,
    in1_realign_type,
    in1_step
  );
  // Input in2
  hwpe_addr_gen_in2(
    in2_trans_size,
    in2_line_stride,
    in2_line_length,
    in2_feat_stride,
    in2_feat_length,
    in2_feat_roll,
    in2_loop_outer,
    in2_realign_type,
    in2_step
  );

  // Output out_r
  hwpe_addr_gen_out_r(
    out_r_trans_size,
    out_r_line_stride,
    out_r_line_length,
    out_r_feat_stride,
    out_r_feat_length,
    out_r_feat_roll,
    out_r_loop_outer,
    out_r_realign_type,
    out_r_step
  );

  /* Set TCDM address reg values */

  // input in1
  hwpe_in1_addr_set( (int32_t)in1_l1 );
  // input in2
  hwpe_in2_addr_set( (int32_t)in2_l1 );

  // output out_r
  hwpe_out_r_addr_set( (int32_t)out_r_l1 );

  /* Set user custom registers */

  // Trigger execution
  hwpe_trigger_job();

  // wait for end of computation
  asm volatile ("wfi" ::: "memory");

  /* Clean and disable HWPE */

  hwpe_soft_clear();
  hwpe_cg_disable();

  // error check on out_r
  for(i=0; i<out_r_height; i++){
    for(j=0; j<out_r_width; j++){
      if(out_r_l1[i*out_r_width+j] != out_r_golden_l1[i*out_r_width+j]) errors++;
    }
  }

  // return errors
  *(int *) 0x80000000 = errors;
  return errors;

}
