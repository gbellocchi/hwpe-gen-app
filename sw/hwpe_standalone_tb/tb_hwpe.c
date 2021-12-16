

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
  #include "inc/stim/a.h"
  #include "inc/stim/b.h"
  #include "inc/stim/c.h"

  // Golden results
  #include "inc/stim/d_dut.h"
  #include "inc/stim/d_ref.h"

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

  unsigned engine_runs_d = ;

  // 3. Custom registers
  unsigned reg_simple_mul_val = ;
  unsigned reg_shift_val = ;
  unsigned reg_len_val = ;

  /* General parameters. */

  volatile unsigned errors = 0;
  unsigned i, j;
  int offload_id_tmp, offload_id;

  /* Stream-specific parameters. */

  unsigned a_width              = width;
  unsigned a_height             = height;
  unsigned a_stripe_height      = stripe_height;
  unsigned b_width              = width;
  unsigned b_height             = height;
  unsigned b_stripe_height      = stripe_height;
  unsigned c_width              = width;
  unsigned c_height             = height;
  unsigned c_stripe_height      = stripe_height;

  unsigned d_width             = width;
  unsigned d_height            = height;
  unsigned d_stripe_height     = stripe_height;

  /* Dataset parameters. */
  unsigned a_stim_dim               = a_width * a_height;
  unsigned a_stripe_in_len          = a_width * a_stripe_height;
  unsigned b_stim_dim               = b_width * b_height;
  unsigned b_stripe_in_len          = b_width * b_stripe_height;
  unsigned c_stim_dim               = c_width * c_height;
  unsigned c_stripe_in_len          = c_width * c_stripe_height;

  unsigned d_stim_dim              = d_width * d_height;
  unsigned d_stripe_out_len        = d_width * d_stripe_height;

  /* Address generator (input) - Parameters */

  const unsigned a_trans_size             = a_width * a_stripe_height;
  const unsigned a_line_stride            = 0;
  const unsigned a_line_length            = a_width * a_stripe_height;
  const unsigned a_feat_stride            = 0;
  const unsigned a_feat_length            = 1;
  const unsigned a_feat_roll              = 0;
  const unsigned a_loop_outer             = 0;
  const unsigned a_realign_type           = 0;
  const unsigned a_step                   = 4;
  const unsigned b_trans_size             = b_width * b_stripe_height;
  const unsigned b_line_stride            = 0;
  const unsigned b_line_length            = b_width * b_stripe_height;
  const unsigned b_feat_stride            = 0;
  const unsigned b_feat_length            = 1;
  const unsigned b_feat_roll              = 0;
  const unsigned b_loop_outer             = 0;
  const unsigned b_realign_type           = 0;
  const unsigned b_step                   = 4;
  const unsigned c_trans_size             = c_width * c_stripe_height;
  const unsigned c_line_stride            = 0;
  const unsigned c_line_length            = c_width * c_stripe_height;
  const unsigned c_feat_stride            = 0;
  const unsigned c_feat_length            = 1;
  const unsigned c_feat_roll              = 0;
  const unsigned c_loop_outer             = 0;
  const unsigned c_realign_type           = 0;
  const unsigned c_step                   = 4;

  /* Address generator (output) - Parameters */

  const unsigned d_trans_size             = d_width * d_stripe_height + 1;
  const unsigned d_line_stride            = 0;
  const unsigned d_line_length            = d_width * d_stripe_height;
  const unsigned d_feat_stride            = 0;
  const unsigned d_feat_length            = 1;
  const unsigned d_feat_roll              = 0;
  const unsigned d_loop_outer             = 0;
  const unsigned d_realign_type           = 0;
  const unsigned d_step                   = 4;

  /* Allocation of I/O arrays. */

  // Stimuli

  int32_t *a_l1 = a;
  int32_t *b_l1 = b;
  int32_t *c_l1 = c;

  // Results

  int32_t *d_l1 = d_dut;

  // Golden results

  int32_t *d_golden_l1 = d_ref;

  /* Initialization of I/O arrays. */

  // Stimuli

  // for (i = 0; i < a_stripe_height; i++){
  //   for (j = 0; j < a_width; j++){
  //     a_l1[i*a_width+j] = a[i*a_width+j];
  //   }
  // }
  // for (i = 0; i < b_stripe_height; i++){
  //   for (j = 0; j < b_width; j++){
  //     b_l1[i*b_width+j] = b[i*b_width+j];
  //   }
  // }
  // for (i = 0; i < c_stripe_height; i++){
  //   for (j = 0; j < c_width; j++){
  //     c_l1[i*c_width+j] = c[i*c_width+j];
  //   }
  // }

  // Golden results

  // for (i = 0; i < d_stripe_height; i++){
  //   for (j = 0; j < d_width; j++){
  //     d_golden_l1[i*d_width+j] = d[i*d_width+j];
  //   }
  // }

  /* HWPE initialization */

  hwpe_cg_enable();
  while((offload_id_tmp = hwpe_acquire_job()) < 0)

  /* FSM programming */

  hwpe_len_iter_set_d(engine_runs_d-1);

  /* Address generator programming */

  // Input a
  hwpe_addr_gen_a(
    a_trans_size,
    a_line_stride,
    a_line_length,
    a_feat_stride,
    a_feat_length,
    a_feat_roll,
    a_loop_outer,
    a_realign_type,
    a_step
  );
  // Input b
  hwpe_addr_gen_b(
    b_trans_size,
    b_line_stride,
    b_line_length,
    b_feat_stride,
    b_feat_length,
    b_feat_roll,
    b_loop_outer,
    b_realign_type,
    b_step
  );
  // Input c
  hwpe_addr_gen_c(
    c_trans_size,
    c_line_stride,
    c_line_length,
    c_feat_stride,
    c_feat_length,
    c_feat_roll,
    c_loop_outer,
    c_realign_type,
    c_step
  );

  // Output d
  hwpe_addr_gen_d(
    d_trans_size,
    d_line_stride,
    d_line_length,
    d_feat_stride,
    d_feat_length,
    d_feat_roll,
    d_loop_outer,
    d_realign_type,
    d_step
  );

  /* Set TCDM address reg values */

  // input a
  hwpe_a_addr_set( (int32_t)a_l1 );
  // input b
  hwpe_b_addr_set( (int32_t)b_l1 );
  // input c
  hwpe_c_addr_set( (int32_t)c_l1 );

  // output d
  hwpe_d_addr_set( (int32_t)d_l1 );

  /* Set user custom registers */
  hwpe_reg_simple_mul_set( reg_simple_mul_val );
  hwpe_reg_shift_set( reg_shift_val );
  hwpe_reg_len_set( reg_len_val );

  // Trigger execution
  hwpe_trigger_job();

  // wait for end of computation
  asm volatile ("wfi" ::: "memory");

  /* Clean and disable HWPE */

  hwpe_soft_clear();
  hwpe_cg_disable();

  // error check on d
  for(i=0; i<d_height; i++){
    for(j=0; j<d_width; j++){
      if(d_l1[i*d_width+j] != d_golden_l1[i*d_width+j]) errors++;
    }
  }

  // return errors
  *(int *) 0x80000000 = errors;
  return errors;

}