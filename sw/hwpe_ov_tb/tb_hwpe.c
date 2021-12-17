

/*
 *
 * Authors:     Gianluca Bellocchi <gianluca.bellocchi@unimore.it>
 *
 */

// Standard libs
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

// System
#include <hero-target.h>

// HWPE
#include "inc/hwpe_lib/archi_hwpe.h"
#include "inc/hwpe_lib/hal_hwpe.h"

// Event unit
#include "inc/eu_lib/archi_eu_v3.h"
#include "inc/eu_lib/hal_eu_v3.h"

  // Synthetic stimuli
  #include "inc/stim/src_V.h"

  // Golden results
  #include "inc/stim/dst_V.h"

/* - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / */

/*
 *
 *     HWPE SW test.
 *
 */

int main() {

  printf("Software test application - DUT: conv_mdc\n");

  /* Application-specific parameters. */

  // These parameters have to be set by the user before to compile the application.

  // 1. Workload

  uint32_t width                  = ;
  uint32_t height                 = ;
  uint32_t stripe_height          = ;

  // 2. Accelerator execution

  // Number of engine runs needed to terminate the accelerator job.
  // This is equivalent to the number of 'done' signals that are
  // produced by the engine itself.

  const unsigned engine_runs_dst_V = ;

  // 3. Custom registers
  const unsigned width_val = ;
  const unsigned height_val = ;

  /* General parameters. */

  volatile int errors = 0;
  int i, j;
  int offload_id_tmp, offload_id;

  omp_set_num_threads(1);

  /* Stream-specific parameters. */

  const unsigned src_V_width              = width;
  const unsigned src_V_height             = height;
  const unsigned src_V_stripe_height      = stripe_height;

  const unsigned dst_V_width             = width;
  const unsigned dst_V_height            = height;
  const unsigned dst_V_stripe_height     = stripe_height;

  /* Dataset parameters. */
  const unsigned src_V_stim_dim               = src_V_width * src_V_height;
  const unsigned src_V_stripe_in_len          = src_V_width * src_V_stripe_height;

  const unsigned dst_V_stim_dim              = dst_V_width * dst_V_height;
  const unsigned dst_V_stripe_out_len        = dst_V_width * dst_V_stripe_height;

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

  const unsigned dst_V_trans_size             = dst_V_stripe_height * dst_V_stripe_height + 1;
  const unsigned dst_V_line_stride            = sizeof(uint32_t);
  const unsigned dst_V_line_length            = 1;
  const unsigned dst_V_feat_stride            = dst_V_width * sizeof(uint32_t);
  const unsigned dst_V_feat_length            = dst_V_stripe_height;
  const unsigned dst_V_feat_roll              = dst_V_stripe_height;
  const unsigned dst_V_loop_outer             = 0;
  const unsigned dst_V_realign_type           = 0;
  const unsigned dst_V_step                   = 4;

  printf("Allocation and initialization of L1 stimuli\n");

  /* Allocation of I/O arrays. */

  // Stimuli

  int32_t * src_V_l1 = hero_l1malloc(sizeof(int32_t)*src_V_stripe_in_len);

  // Results

  int32_t * dst_V_l1 = hero_l1malloc(sizeof(int32_t)*dst_V_stripe_out_len);

  // Golden results

  int32_t * dst_V_golden_l1 = hero_l1malloc(sizeof(int32_t)*dst_V_stripe_out_len);

  /* Initialization of I/O arrays. */

  // Stimuli

  for (i = 0; i < src_V_stripe_height; i++){
    for (j = 0; j < src_V_width; j++){
      src_V_l1[i*src_V_width+j] = src_V[i*src_V_width+j];
    }
  }

  // Golden results

  for (i = 0; i < dst_V_stripe_height; i++){
    for (j = 0; j < dst_V_width; j++){
      dst_V_golden_l1[i*dst_V_width+j] = dst_V[i*dst_V_width+j];
    }
  }

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
  hwpe_src_V_addr_set( src_V_l1 );

  // output dst_V
  hwpe_dst_V_addr_set( dst_V_l1 );

  /* Set user custom registers */
  hwpe_width_set( width_val );
  hwpe_height_set( height_val );

  /* HWPE execution */

  // Being RTL simualtion very slow, a single data stripe is processed
  // in order to assess the functionality of the conv_mdc DUT.

  printf("HWPE execution - Start!\n");

  // Trigger execution
  hwpe_trigger_job();

  /* Event unit programming */

  // Set bit of event mask corresponding to the HWPE event.
  // If this change, modify ARCHI_HWPE_EU_OFFSET in archi_hwpe.h
  eu_evt_maskWaitAndClr(1 << ARCHI_HWPE_EU_OFFSET);

  printf("DUT end of execution!\n");

  /* Clean and disable HWPE */

  hwpe_soft_clear();
  hwpe_cg_disable();

  // // /* Error check on L2. */
  // printf("Results check");

  // for (i = 0; i < stripe_height; i++){
  //   for (j = 0; j < stripe_height; j++){
  //     if(y_l1[i*stripe_height+j] != y_golden[i*stripe_height+j]){
  //       printf("[%d]    L1 - y_test:    %d \n",  i*stripe_height+j, y_l1[i*stripe_height+j]);
  //       printf("[%d]    L1 - y_golden:  %d\n\n", i*stripe_height+j, y_golden[i*stripe_height+j]);
  //       errors++;
  //     }
  //   }
  // }

  // /* Return errors */
  // printf("errors: %d\n", errors);
  // printf("end\n");

  return errors;
}