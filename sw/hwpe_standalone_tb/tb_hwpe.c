

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
  #include "inc/stim/src_V.h"

  // Golden results
  #include "inc/stim/dst_V_dut.h"
  #include "inc/stim/dst_V_ref.h"

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

  unsigned engine_runs_dst_V = ;

  // 3. Custom registers
  unsigned width_val = ;
  unsigned height_val = ;

  /* General parameters. */

  volatile unsigned errors = 0;
  unsigned i, j;
  int offload_id_tmp, offload_id;

  /* Stream-specific parameters. */

  unsigned src_V_width              = width;
  unsigned src_V_height             = height;
  unsigned src_V_stripe_height      = stripe_height;

  unsigned dst_V_width             = width;
  unsigned dst_V_height            = height;
  unsigned dst_V_stripe_height     = stripe_height;

  /* Dataset parameters. */
  unsigned src_V_stim_dim               = src_V_width * src_V_height;
  unsigned src_V_stripe_in_len          = src_V_width * src_V_stripe_height;

  unsigned dst_V_stim_dim              = dst_V_width * dst_V_height;
  unsigned dst_V_stripe_out_len        = dst_V_width * dst_V_stripe_height;

  /* Address generator (input) - Parameters */

  const unsigned src_V_trans_size             = src_V_width * src_V_stripe_height;
  const unsigned src_V_line_stride            = 0;
  const unsigned src_V_line_length            = src_V_width * src_V_stripe_height;
  const unsigned src_V_feat_stride            = 0;
  const unsigned src_V_feat_length            = 1;
  const unsigned src_V_feat_roll              = 0;
  const unsigned src_V_loop_outer             = 0;
  const unsigned src_V_realign_type           = 0;
  const unsigned src_V_step                   = 4;

  /* Address generator (output) - Parameters */

  const unsigned dst_V_trans_size             = dst_V_width * dst_V_stripe_height + 1;
  const unsigned dst_V_line_stride            = 0;
  const unsigned dst_V_line_length            = dst_V_width * dst_V_stripe_height;
  const unsigned dst_V_feat_stride            = 0;
  const unsigned dst_V_feat_length            = 1;
  const unsigned dst_V_feat_roll              = 0;
  const unsigned dst_V_loop_outer             = 0;
  const unsigned dst_V_realign_type           = 0;
  const unsigned dst_V_step                   = 4;

  /* Allocation of I/O arrays. */

  // Stimuli

  int32_t *src_V_l1 = src_V;

  // Results

  int32_t *dst_V_l1 = dst_V_dut;

  // Golden results

  int32_t *dst_V_golden_l1 = dst_V_ref;

  /* Initialization of I/O arrays. */

  // Stimuli

  // for (i = 0; i < src_V_stripe_height; i++){
  //   for (j = 0; j < src_V_width; j++){
  //     src_V_l1[i*src_V_width+j] = src_V[i*src_V_width+j];
  //   }
  // }

  // Golden results

  // for (i = 0; i < dst_V_stripe_height; i++){
  //   for (j = 0; j < dst_V_width; j++){
  //     dst_V_golden_l1[i*dst_V_width+j] = dst_V[i*dst_V_width+j];
  //   }
  // }

  /* HWPE initialization */

  hwpe_cg_enable();
  while((offload_id_tmp = hwpe_acquire_job()) < 0)

  /* FSM programming */

  hwpe_len_iter_set_dst_V(engine_runs_dst_V-1);

  /* Address generator programming */

  // Input src_V
  hwpe_addr_gen_src_V(
    src_V_trans_size,
    src_V_line_stride,
    src_V_line_length,
    src_V_feat_stride,
    src_V_feat_length,
    src_V_feat_roll,
    src_V_loop_outer,
    src_V_realign_type,
    src_V_step
  );

  // Output dst_V
  hwpe_addr_gen_dst_V(
    dst_V_trans_size,
    dst_V_line_stride,
    dst_V_line_length,
    dst_V_feat_stride,
    dst_V_feat_length,
    dst_V_feat_roll,
    dst_V_loop_outer,
    dst_V_realign_type,
    dst_V_step
  );

  /* Set TCDM address reg values */

  // input src_V
  hwpe_src_V_addr_set( (int32_t)src_V_l1 );

  // output dst_V
  hwpe_dst_V_addr_set( (int32_t)dst_V_l1 );

  /* Set user custom registers */
  hwpe_width_set( width_val );
  hwpe_height_set( height_val );

  // Trigger execution
  hwpe_trigger_job();

  // wait for end of computation
  asm volatile ("wfi" ::: "memory");

  /* Clean and disable HWPE */

  hwpe_soft_clear();
  hwpe_cg_disable();

  // error check on dst_V
  for(i=0; i<dst_V_height; i++){
    for(j=0; j<dst_V_width; j++){
      if(dst_V_l1[i*dst_V_width+j] != dst_V_golden_l1[i*dst_V_width+j]) errors++;
    }
  }

  // return errors
  *(int *) 0x80000000 = errors;
  return errors;

}