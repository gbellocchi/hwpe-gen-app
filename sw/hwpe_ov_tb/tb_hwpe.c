
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
#include "inc/stim/in1.h""
#include "inc/stim/in2.h""

// Golden results
#include "inc/stim/out_r.h"

/* - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / */

/*
 *
 *     HWPE SW test.
 *
 */			

int main() {

  printf("Software test application - DUT: multi_dataflow\n");

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

const unsigned engine_runs_out_r = ;

  // 3. Custom registers

  /* General parameters. */

  volatile int errors = 0;
  int i, j;
  int offload_id_tmp, offload_id;

  omp_set_num_threads(1);

  /* Stream-specific parameters. */

const unsigned in1_width              = width;
const unsigned in1_height             = height;
const unsigned in1_stripe_height      = stripe_height;

const unsigned in2_width              = width;
const unsigned in2_height             = height;
const unsigned in2_stripe_height      = stripe_height;

const unsigned out_r_width              = width;
const unsigned out_r_height             = height;
const unsigned out_r_stripe_height      = stripe_height;

  /* Dataset parameters. */
const unsigned in1_stim_dim               = in1_width * in1_height;
const unsigned in1_stripe_in_len          = in1_width * in1_stripe_height;

const unsigned in2_stim_dim               = in2_width * in2_height;
const unsigned in2_stripe_in_len          = in2_width * in2_stripe_height;

const unsigned out_r_stim_dim               = out_r_width * out_r_height;
const unsigned out_r_stripe_out_len          = out_r_width * out_r_stripe_height;

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
const unsigned out_r_trans_size             = out_r_stripe_height * out_r_stripe_height + 1;
const unsigned out_r_line_stride            = sizeof(uint32_t);
const unsigned out_r_line_length            = 1;
const unsigned out_r_feat_stride            = out_r_width * sizeof(uint32_t);
const unsigned out_r_feat_length            = out_r_stripe_height;
const unsigned out_r_feat_roll              = out_r_stripe_height;
const unsigned out_r_loop_outer             = 0;
const unsigned out_r_realign_type           = 0;
const unsigned out_r_step                   = 4;

  printf("Allocation and initialization of L1 stimuli\n");

  /* Allocation of I/O arrays. */

  // Stimuli

  int32_t * in1_l1 = hero_l1malloc(sizeof(int32_t)*in1_stripe_in_len);
  int32_t * in2_l1 = hero_l1malloc(sizeof(int32_t)*in2_stripe_in_len);

  // Results
  
  int32_t * out_r_l1 = hero_l1malloc(sizeof(int32_t)*out_r_stripe_out_len);

  // Golden results

  int32_t * out_r_golden_l1 = hero_l1malloc(sizeof(int32_t)*out_r_stripe_out_len);

  /* Initialization of I/O arrays. */

  // Stimuli

  for (i = 0; i < in1_stripe_height; i++){
    for (j = 0; j < in1_width; j++){
      in1_l1[i*in1_width+j] = in1[i*in1_width+j];
    }
  }
  for (i = 0; i < in2_stripe_height; i++){
    for (j = 0; j < in2_width; j++){
      in2_l1[i*in2_width+j] = in2[i*in2_width+j];
    }
  }

  // Golden results

  for (i = 0; i < out_r_stripe_height; i++){
    for (j = 0; j < out_r_width; j++){
      out_r_golden_l1[i*out_r_width+j] = out_r[i*out_r_width+j];
    }
  }

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
  hwpe_in1_addr_set( in1_l1 );
  // input in2
  hwpe_in2_addr_set( in2_l1 );

  // output out_r
  hwpe_out_r_addr_set( out_r_l1 );


  /* Set user custom registers */

  /* HWPE execution */

  // Being RTL simualtion very slow, a single data stripe is processed
  // in order to assess the functionality of the multi_dataflow DUT.

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
