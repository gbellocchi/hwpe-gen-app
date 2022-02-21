

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
  #include "inc/stim/r_reqs.h"

  // Golden results
  #include "inc/stim/w_reqs.h"

/* - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / */

/*
 *
 *     HWPE SW test.
 *
 */

int main() {

  printf("Software test application - DUT: traffic_gen\n");

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

  const unsigned engine_runs_w_reqs = ;

  // 3. Custom registers
  const unsigned n_total_reqs_val = ;
  const unsigned t_ck_reqs_val = ;
  const unsigned t_ck_idle_val = ;

  /* General parameters. */

  volatile int errors = 0;
  int i, j;
  int offload_id_tmp, offload_id;

  omp_set_num_threads(1);

  /* Stream-specific parameters. */

  const unsigned r_reqs_width              = width;
  const unsigned r_reqs_height             = height;
  const unsigned r_reqs_stripe_height      = stripe_height;

  const unsigned w_reqs_width             = width;
  const unsigned w_reqs_height            = height;
  const unsigned w_reqs_stripe_height     = stripe_height;

  /* Dataset parameters. */
  const unsigned r_reqs_stim_dim               = r_reqs_width * r_reqs_height;
  const unsigned r_reqs_stripe_in_len          = r_reqs_width * r_reqs_stripe_height;

  const unsigned w_reqs_stim_dim              = w_reqs_width * w_reqs_height;
  const unsigned w_reqs_stripe_out_len        = w_reqs_width * w_reqs_stripe_height;

  /* Address generator (input) - Parameters */

  const unsigned r_reqs_trans_size             = r_reqs_width * r_reqs_stripe_height;
  const unsigned r_reqs_line_stride            = 0;
  const unsigned r_reqs_line_length            = r_reqs_width * r_reqs_stripe_height;
  const unsigned r_reqs_feat_stride            = 0;
  const unsigned r_reqs_feat_length            = 1;
  const unsigned r_reqs_feat_roll              = 0;
  const unsigned r_reqs_loop_outer             = 0;
  const unsigned r_reqs_realign_type           = 0;
  const unsigned r_reqs_step                   = 4;

  /* Address generator (output) - Parameters */

  const unsigned w_reqs_trans_size             = w_reqs_stripe_height * w_reqs_stripe_height + 1;
  const unsigned w_reqs_line_stride            = sizeof(uint32_t);
  const unsigned w_reqs_line_length            = 1;
  const unsigned w_reqs_feat_stride            = w_reqs_width * sizeof(uint32_t);
  const unsigned w_reqs_feat_length            = w_reqs_stripe_height;
  const unsigned w_reqs_feat_roll              = w_reqs_stripe_height;
  const unsigned w_reqs_loop_outer             = 0;
  const unsigned w_reqs_realign_type           = 0;
  const unsigned w_reqs_step                   = 4;

  printf("Allocation and initialization of L1 stimuli\n");

  /* Allocation of I/O arrays. */

  // Stimuli

  int32_t * r_reqs_l1 = hero_l1malloc(sizeof(int32_t)*r_reqs_stripe_in_len);

  // Results

  int32_t * w_reqs_l1 = hero_l1malloc(sizeof(int32_t)*w_reqs_stripe_out_len);

  // Golden results

  int32_t * w_reqs_golden_l1 = hero_l1malloc(sizeof(int32_t)*w_reqs_stripe_out_len);

  /* Initialization of I/O arrays. */

  // Stimuli

  for (i = 0; i < r_reqs_stripe_height; i++){
    for (j = 0; j < r_reqs_width; j++){
      r_reqs_l1[i*r_reqs_width+j] = r_reqs[i*r_reqs_width+j];
    }
  }

  // Golden results

  for (i = 0; i < w_reqs_stripe_height; i++){
    for (j = 0; j < w_reqs_width; j++){
      w_reqs_golden_l1[i*w_reqs_width+j] = w_reqs[i*w_reqs_width+j];
    }
  }

  /* HWPE initialization */

  hwpe_cg_enable();
  while((offload_id_tmp = hwpe_acquire_job()) < 0)

  /* FSM programming */

  hwpe_len_iter_set_w_reqs(engine_runs_w_reqs-1);

  /* Address generator programming */

  // Input r_reqs
  hwpe_addr_gen_r_reqs(
    r_reqs_trans_size,
    r_reqs_line_stride,
    r_reqs_line_length,
    r_reqs_feat_stride,
    r_reqs_feat_length,
    r_reqs_feat_roll,
    r_reqs_loop_outer,
    r_reqs_realign_type,
    r_reqs_step
  );

  // Output w_reqs
  hwpe_addr_gen_w_reqs(
    w_reqs_trans_size,
    w_reqs_line_stride,
    w_reqs_line_length,
    w_reqs_feat_stride,
    w_reqs_feat_length,
    w_reqs_feat_roll,
    w_reqs_loop_outer,
    w_reqs_realign_type,
    w_reqs_step
  );

  /* Set TCDM address reg values */

  // input r_reqs
  hwpe_r_reqs_addr_set( r_reqs_l1 );

  // output w_reqs
  hwpe_w_reqs_addr_set( w_reqs_l1 );

  /* Set user custom registers */
  hwpe_n_total_reqs_set( n_total_reqs_val );
  hwpe_t_ck_reqs_set( t_ck_reqs_val );
  hwpe_t_ck_idle_set( t_ck_idle_val );

  /* HWPE execution */

  // Being RTL simualtion very slow, a single data stripe is processed
  // in order to assess the functionality of the traffic_gen DUT.

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