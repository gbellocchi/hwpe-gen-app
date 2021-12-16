

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
  #include "inc/stim/x_V.h"

  // Golden results
  #include "inc/stim/y_V_dut.h"
  #include "inc/stim/y_V_ref.h"

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

  unsigned engine_runs_y_V = ;

  // 3. Custom registers
  unsigned coeff_0_V_val = ;
  unsigned coeff_1_V_val = ;
  unsigned coeff_2_V_val = ;
  unsigned coeff_3_V_val = ;

  /* General parameters. */

  volatile unsigned errors = 0;
  unsigned i, j;
  int offload_id_tmp, offload_id;

  /* Stream-specific parameters. */

  unsigned x_V_width              = width;
  unsigned x_V_height             = height;
  unsigned x_V_stripe_height      = stripe_height;

  unsigned y_V_width             = width;
  unsigned y_V_height            = height;
  unsigned y_V_stripe_height     = stripe_height;

  /* Dataset parameters. */
  unsigned x_V_stim_dim               = x_V_width * x_V_height;
  unsigned x_V_stripe_in_len          = x_V_width * x_V_stripe_height;

  unsigned y_V_stim_dim              = y_V_width * y_V_height;
  unsigned y_V_stripe_out_len        = y_V_width * y_V_stripe_height;

  /* Address generator (input) - Parameters */

  const unsigned x_V_trans_size             = x_V_width * x_V_stripe_height;
  const unsigned x_V_line_stride            = 0;
  const unsigned x_V_line_length            = x_V_width * x_V_stripe_height;
  const unsigned x_V_feat_stride            = 0;
  const unsigned x_V_feat_length            = 1;
  const unsigned x_V_feat_roll              = 0;
  const unsigned x_V_loop_outer             = 0;
  const unsigned x_V_realign_type           = 0;
  const unsigned x_V_step                   = 4;

  /* Address generator (output) - Parameters */

  const unsigned y_V_trans_size             = y_V_width * y_V_stripe_height + 1;
  const unsigned y_V_line_stride            = 0;
  const unsigned y_V_line_length            = y_V_width * y_V_stripe_height;
  const unsigned y_V_feat_stride            = 0;
  const unsigned y_V_feat_length            = 1;
  const unsigned y_V_feat_roll              = 0;
  const unsigned y_V_loop_outer             = 0;
  const unsigned y_V_realign_type           = 0;
  const unsigned y_V_step                   = 4;

  /* Allocation of I/O arrays. */

  // Stimuli

  int32_t *x_V_l1 = x_V;

  // Results

  int32_t *y_V_l1 = y_V_dut;

  // Golden results

  int32_t *y_V_golden_l1 = y_V_ref;

  /* Initialization of I/O arrays. */

  // Stimuli

  // for (i = 0; i < x_V_stripe_height; i++){
  //   for (j = 0; j < x_V_width; j++){
  //     x_V_l1[i*x_V_width+j] = x_V[i*x_V_width+j];
  //   }
  // }

  // Golden results

  // for (i = 0; i < y_V_stripe_height; i++){
  //   for (j = 0; j < y_V_width; j++){
  //     y_V_golden_l1[i*y_V_width+j] = y_V[i*y_V_width+j];
  //   }
  // }

  /* HWPE initialization */

  hwpe_cg_enable();
  while((offload_id_tmp = hwpe_acquire_job()) < 0)

  /* FSM programming */

  hwpe_len_iter_set_y_V(engine_runs_y_V-1);

  /* Address generator programming */

  // Input x_V
  hwpe_addr_gen_x_V(
    x_V_trans_size,
    x_V_line_stride,
    x_V_line_length,
    x_V_feat_stride,
    x_V_feat_length,
    x_V_feat_roll,
    x_V_loop_outer,
    x_V_realign_type,
    x_V_step
  );

  // Output y_V
  hwpe_addr_gen_y_V(
    y_V_trans_size,
    y_V_line_stride,
    y_V_line_length,
    y_V_feat_stride,
    y_V_feat_length,
    y_V_feat_roll,
    y_V_loop_outer,
    y_V_realign_type,
    y_V_step
  );

  /* Set TCDM address reg values */

  // input x_V
  hwpe_x_V_addr_set( (int32_t)x_V_l1 );

  // output y_V
  hwpe_y_V_addr_set( (int32_t)y_V_l1 );

  /* Set user custom registers */
  hwpe_coeff_0_V_set( coeff_0_V_val );
  hwpe_coeff_1_V_set( coeff_1_V_val );
  hwpe_coeff_2_V_set( coeff_2_V_val );
  hwpe_coeff_3_V_set( coeff_3_V_val );

  // Trigger execution
  hwpe_trigger_job();

  // wait for end of computation
  asm volatile ("wfi" ::: "memory");

  /* Clean and disable HWPE */

  hwpe_soft_clear();
  hwpe_cg_disable();

  // error check on y_V
  for(i=0; i<y_V_height; i++){
    for(j=0; j<y_V_width; j++){
      if(y_V_l1[i*y_V_width+j] != y_V_golden_l1[i*y_V_width+j]) errors++;
    }
  }

  // return errors
  *(int *) 0x80000000 = errors;
  return errors;

}