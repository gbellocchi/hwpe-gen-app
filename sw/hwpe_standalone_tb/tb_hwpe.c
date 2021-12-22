
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
  #include "inc/stim/inStream0.h"
  #include "inc/stim/inStream1.h"
  #include "inc/stim/inStream2.h"

  // Golden results
  #include "inc/stim/outStream0_dut.h"
  #include "inc/stim/outStream0_ref.h"

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

  unsigned engine_runs_outStream0 = ;

  // 3. Custom registers
  unsigned reg_simple_mul_val = ;
  unsigned reg_shift_val = ;
  unsigned reg_len_val = ;

  /* General parameters. */

  volatile unsigned errors = 0;
  unsigned i, j;
  int offload_id_tmp, offload_id;

  /* Stream-specific parameters. */

  unsigned inStream0_width              = width;
  unsigned inStream0_height             = height;
  unsigned inStream0_stripe_height      = stripe_height;
  unsigned inStream1_width              = width;
  unsigned inStream1_height             = height;
  unsigned inStream1_stripe_height      = stripe_height;
  unsigned inStream2_width              = width;
  unsigned inStream2_height             = height;
  unsigned inStream2_stripe_height      = stripe_height;
  unsigned outStream0_width              = width;
  unsigned outStream0_height             = height;
  unsigned outStream0_stripe_height      = stripe_height;

  /* Dataset parameters. */
  unsigned inStream0_stim_dim               = inStream0_width * inStream0_height;
  unsigned inStream0_stripe_in_len          = inStream0_width * inStream0_stripe_height;
  unsigned inStream1_stim_dim               = inStream1_width * inStream1_height;
  unsigned inStream1_stripe_in_len          = inStream1_width * inStream1_stripe_height;
  unsigned inStream2_stim_dim               = inStream2_width * inStream2_height;
  unsigned inStream2_stripe_in_len          = inStream2_width * inStream2_stripe_height;

  unsigned outStream0_stim_dim              = outStream0_width * outStream0_height;
  unsigned outStream0_stripe_out_len        = outStream0_width * outStream0_stripe_height;

  /* Address generator (input) - Parameters */

  const unsigned inStream0_trans_size             = inStream0_width * inStream0_stripe_height;
  const unsigned inStream0_line_stride            = 0;
  const unsigned inStream0_line_length            = inStream0_width * inStream0_stripe_height;
  const unsigned inStream0_feat_stride            = 0;
  const unsigned inStream0_feat_length            = 1;
  const unsigned inStream0_feat_roll              = 0;
  const unsigned inStream0_loop_outer             = 0;
  const unsigned inStream0_realign_type           = 0;
  const unsigned inStream0_step                   = 4;
  const unsigned inStream1_trans_size             = inStream1_width * inStream1_stripe_height;
  const unsigned inStream1_line_stride            = 0;
  const unsigned inStream1_line_length            = inStream1_width * inStream1_stripe_height;
  const unsigned inStream1_feat_stride            = 0;
  const unsigned inStream1_feat_length            = 1;
  const unsigned inStream1_feat_roll              = 0;
  const unsigned inStream1_loop_outer             = 0;
  const unsigned inStream1_realign_type           = 0;
  const unsigned inStream1_step                   = 4;
  const unsigned inStream2_trans_size             = inStream2_width * inStream2_stripe_height;
  const unsigned inStream2_line_stride            = 0;
  const unsigned inStream2_line_length            = inStream2_width * inStream2_stripe_height;
  const unsigned inStream2_feat_stride            = 0;
  const unsigned inStream2_feat_length            = 1;
  const unsigned inStream2_feat_roll              = 0;
  const unsigned inStream2_loop_outer             = 0;
  const unsigned inStream2_realign_type           = 0;
  const unsigned inStream2_step                   = 4;

  /* Address generator (output) - Parameters */
  
  const unsigned outStream0_trans_size             = outStream0_width * outStream0_stripe_height + 1;
  const unsigned outStream0_line_stride            = 0;
  const unsigned outStream0_line_length            = outStream0_width * outStream0_stripe_height;
  const unsigned outStream0_feat_stride            = 0;
  const unsigned outStream0_feat_length            = 1;
  const unsigned outStream0_feat_roll              = 0;
  const unsigned outStream0_loop_outer             = 0;
  const unsigned outStream0_realign_type           = 0;
  const unsigned outStream0_step                   = 4;

  /* Allocation of I/O arrays. */

  // Stimuli
  
  int32_t *inStream0_l1 = inStream0;
  int32_t *inStream1_l1 = inStream1;
  int32_t *inStream2_l1 = inStream2;

  // Results

  int32_t *outStream0_l1 = outStream0_dut;

  // Golden results

  int32_t *outStream0_golden_l1 = outStream0_ref;

  /* Initialization of I/O arrays. */

  // Stimuli

  // for (i = 0; i < inStream0_stripe_height; i++){
  //   for (j = 0; j < inStream0_width; j++){
  //     inStream0_l1[i*inStream0_width+j] = inStream0[i*inStream0_width+j];
  //   }
  // }
  // for (i = 0; i < inStream1_stripe_height; i++){
  //   for (j = 0; j < inStream1_width; j++){
  //     inStream1_l1[i*inStream1_width+j] = inStream1[i*inStream1_width+j];
  //   }
  // }
  // for (i = 0; i < inStream2_stripe_height; i++){
  //   for (j = 0; j < inStream2_width; j++){
  //     inStream2_l1[i*inStream2_width+j] = inStream2[i*inStream2_width+j];
  //   }
  // }

  // Golden results

  // for (i = 0; i < outStream0_stripe_height; i++){
  //   for (j = 0; j < outStream0_width; j++){
  //     outStream0_golden_l1[i*outStream0_width+j] = outStream0[i*outStream0_width+j];
  //   }
  // }

  /* HWPE initialization */

  hwpe_cg_enable();
  while((offload_id_tmp = hwpe_acquire_job()) < 0)

  /* FSM programming */

  hwpe_len_iter_set_outStream0(engine_runs_outStream0-1);

  /* Address generator programming */

  // Input inStream0
  hwpe_addr_gen_inStream0(
    inStream0_trans_size,
    inStream0_line_stride,
    inStream0_line_length,
    inStream0_feat_stride,
    inStream0_feat_length,
    inStream0_feat_roll,
    inStream0_loop_outer,
    inStream0_realign_type,
    inStream0_step
  );
  // Input inStream1
  hwpe_addr_gen_inStream1(
    inStream1_trans_size,
    inStream1_line_stride,
    inStream1_line_length,
    inStream1_feat_stride,
    inStream1_feat_length,
    inStream1_feat_roll,
    inStream1_loop_outer,
    inStream1_realign_type,
    inStream1_step
  );
  // Input inStream2
  hwpe_addr_gen_inStream2(
    inStream2_trans_size,
    inStream2_line_stride,
    inStream2_line_length,
    inStream2_feat_stride,
    inStream2_feat_length,
    inStream2_feat_roll,
    inStream2_loop_outer,
    inStream2_realign_type,
    inStream2_step
  );

  // Output outStream0
  hwpe_addr_gen_outStream0(
    outStream0_trans_size,
    outStream0_line_stride,
    outStream0_line_length,
    outStream0_feat_stride,
    outStream0_feat_length,
    outStream0_feat_roll,
    outStream0_loop_outer,
    outStream0_realign_type,
    outStream0_step
  );

  /* Set TCDM address reg values */

  // input inStream0
  hwpe_inStream0_addr_set( (int32_t)inStream0_l1 );
  // input inStream1
  hwpe_inStream1_addr_set( (int32_t)inStream1_l1 );
  // input inStream2
  hwpe_inStream2_addr_set( (int32_t)inStream2_l1 );

  // output outStream0
  hwpe_outStream0_addr_set( (int32_t)outStream0_l1 );

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

  // error check on outStream0
  for(i=0; i<outStream0_height; i++){
    for(j=0; j<outStream0_width; j++){
      if(outStream0_l1[i*outStream0_width+j] != outStream0_golden_l1[i*outStream0_width+j]) errors++;
    }
  }

  // return errors
  *(int *) 0x80000000 = errors;
  return errors;

}
