
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
  #include "inc/stim/in_pel.h"
  #include "inc/stim/in_size.h"

  // Golden results
  #include "inc/stim/out_pel_dut.h"
  #include "inc/stim/out_pel_ref.h"

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

  unsigned engine_runs_out_pel = ;

  // 3. Custom registers
  

  /* General parameters. */

  volatile unsigned errors = 0;
  unsigned i, j;
  int offload_id_tmp, offload_id;

  /* Stream-specific parameters. */

  unsigned in_pel_width              = width;
  unsigned in_pel_height             = height;
  unsigned in_pel_stripe_height      = stripe_height;
  unsigned in_size_width              = width;
  unsigned in_size_height             = height;
  unsigned in_size_stripe_height      = stripe_height;
  unsigned out_pel_width              = width;
  unsigned out_pel_height             = height;
  unsigned out_pel_stripe_height      = stripe_height;

  /* Dataset parameters. */
  unsigned in_pel_stim_dim               = in_pel_width * in_pel_height;
  unsigned in_pel_stripe_in_len          = in_pel_width * in_pel_stripe_height;
  unsigned in_size_stim_dim               = in_size_width * in_size_height;
  unsigned in_size_stripe_in_len          = in_size_width * in_size_stripe_height;

  unsigned out_pel_stim_dim              = out_pel_width * out_pel_height;
  unsigned out_pel_stripe_out_len        = out_pel_width * out_pel_stripe_height;

  /* Address generator (input) - Parameters */

  const unsigned in_pel_trans_size             = in_pel_width * in_pel_stripe_height;
  const unsigned in_pel_line_stride            = 0;
  const unsigned in_pel_line_length            = in_pel_width * in_pel_stripe_height;
  const unsigned in_pel_feat_stride            = 0;
  const unsigned in_pel_feat_length            = 1;
  const unsigned in_pel_feat_roll              = 0;
  const unsigned in_pel_loop_outer             = 0;
  const unsigned in_pel_realign_type           = 0;
  const unsigned in_pel_step                   = 4;
  const unsigned in_size_trans_size             = in_size_width * in_size_stripe_height;
  const unsigned in_size_line_stride            = 0;
  const unsigned in_size_line_length            = in_size_width * in_size_stripe_height;
  const unsigned in_size_feat_stride            = 0;
  const unsigned in_size_feat_length            = 1;
  const unsigned in_size_feat_roll              = 0;
  const unsigned in_size_loop_outer             = 0;
  const unsigned in_size_realign_type           = 0;
  const unsigned in_size_step                   = 4;

  /* Address generator (output) - Parameters */
  
  const unsigned out_pel_trans_size             = out_pel_width * out_pel_stripe_height + 1;
  const unsigned out_pel_line_stride            = 0;
  const unsigned out_pel_line_length            = out_pel_width * out_pel_stripe_height;
  const unsigned out_pel_feat_stride            = 0;
  const unsigned out_pel_feat_length            = 1;
  const unsigned out_pel_feat_roll              = 0;
  const unsigned out_pel_loop_outer             = 0;
  const unsigned out_pel_realign_type           = 0;
  const unsigned out_pel_step                   = 4;

  /* Allocation of I/O arrays. */

  // Stimuli
  
  int32_t *in_pel_l1 = in_pel;
  int32_t *in_size_l1 = in_size;

  // Results

  int32_t *out_pel_l1 = out_pel_dut;

  // Golden results

  int32_t *out_pel_golden_l1 = out_pel_ref;

  /* Initialization of I/O arrays. */

  // Stimuli

  // for (i = 0; i < in_pel_stripe_height; i++){
  //   for (j = 0; j < in_pel_width; j++){
  //     in_pel_l1[i*in_pel_width+j] = in_pel[i*in_pel_width+j];
  //   }
  // }
  // for (i = 0; i < in_size_stripe_height; i++){
  //   for (j = 0; j < in_size_width; j++){
  //     in_size_l1[i*in_size_width+j] = in_size[i*in_size_width+j];
  //   }
  // }

  // Golden results

  // for (i = 0; i < out_pel_stripe_height; i++){
  //   for (j = 0; j < out_pel_width; j++){
  //     out_pel_golden_l1[i*out_pel_width+j] = out_pel[i*out_pel_width+j];
  //   }
  // }

  /* HWPE initialization */

  hwpe_cg_enable();
  while((offload_id_tmp = hwpe_acquire_job()) < 0)

  /* FSM programming */

  hwpe_len_iter_set_out_pel(engine_runs_out_pel-1);

  /* Address generator programming */

  // Input in_pel
  hwpe_addr_gen_in_pel(
    in_pel_trans_size,
    in_pel_line_stride,
    in_pel_line_length,
    in_pel_feat_stride,
    in_pel_feat_length,
    in_pel_feat_roll,
    in_pel_loop_outer,
    in_pel_realign_type,
    in_pel_step
  );
  // Input in_size
  hwpe_addr_gen_in_size(
    in_size_trans_size,
    in_size_line_stride,
    in_size_line_length,
    in_size_feat_stride,
    in_size_feat_length,
    in_size_feat_roll,
    in_size_loop_outer,
    in_size_realign_type,
    in_size_step
  );

  // Output out_pel
  hwpe_addr_gen_out_pel(
    out_pel_trans_size,
    out_pel_line_stride,
    out_pel_line_length,
    out_pel_feat_stride,
    out_pel_feat_length,
    out_pel_feat_roll,
    out_pel_loop_outer,
    out_pel_realign_type,
    out_pel_step
  );

  /* Set TCDM address reg values */

  // input in_pel
  hwpe_in_pel_addr_set( (int32_t)in_pel_l1 );
  // input in_size
  hwpe_in_size_addr_set( (int32_t)in_size_l1 );

  // output out_pel
  hwpe_out_pel_addr_set( (int32_t)out_pel_l1 );

  /* Set user custom registers */

  // Trigger execution
  hwpe_trigger_job();

  // wait for end of computation
  asm volatile ("wfi" ::: "memory");

  /* Clean and disable HWPE */

  hwpe_soft_clear();
  hwpe_cg_disable();

  // error check on out_pel
  for(i=0; i<out_pel_height; i++){
    for(j=0; j<out_pel_width; j++){
      if(out_pel_l1[i*out_pel_width+j] != out_pel_golden_l1[i*out_pel_width+j]) errors++;
    }
  }

  // return errors
  *(int *) 0x80000000 = errors;
  return errors;

}
