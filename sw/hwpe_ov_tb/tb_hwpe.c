
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
#include "inc/stim/in_pel.h""
#include "inc/stim/in_size.h""

// Golden results
#include "inc/stim/out_pel.h"

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

const unsigned engine_runs_out_pel = ;

  // 3. Custom registers

  /* General parameters. */

  volatile int errors = 0;
  int i, j;
  int offload_id_tmp, offload_id;

  omp_set_num_threads(1);

  /* Stream-specific parameters. */

const unsigned in_pel_width              = width;
const unsigned in_pel_height             = height;
const unsigned in_pel_stripe_height      = stripe_height;

const unsigned in_size_width              = width;
const unsigned in_size_height             = height;
const unsigned in_size_stripe_height      = stripe_height;

const unsigned out_pel_width              = width;
const unsigned out_pel_height             = height;
const unsigned out_pel_stripe_height      = stripe_height;

  /* Dataset parameters. */
const unsigned in_pel_stim_dim               = in_pel_width * in_pel_height;
const unsigned in_pel_stripe_in_len          = in_pel_width * in_pel_stripe_height;

const unsigned in_size_stim_dim               = in_size_width * in_size_height;
const unsigned in_size_stripe_in_len          = in_size_width * in_size_stripe_height;

const unsigned out_pel_stim_dim               = out_pel_width * out_pel_height;
const unsigned out_pel_stripe_out_len          = out_pel_width * out_pel_stripe_height;

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
const unsigned out_pel_trans_size             = out_pel_stripe_height * out_pel_stripe_height + 1;
const unsigned out_pel_line_stride            = sizeof(uint32_t);
const unsigned out_pel_line_length            = 1;
const unsigned out_pel_feat_stride            = out_pel_width * sizeof(uint32_t);
const unsigned out_pel_feat_length            = out_pel_stripe_height;
const unsigned out_pel_feat_roll              = out_pel_stripe_height;
const unsigned out_pel_loop_outer             = 0;
const unsigned out_pel_realign_type           = 0;
const unsigned out_pel_step                   = 4;

  printf("Allocation and initialization of L1 stimuli\n");

  /* Allocation of I/O arrays. */

  // Stimuli

  int32_t * in_pel_l1 = hero_l1malloc(sizeof(int32_t)*in_pel_stripe_in_len);
  int32_t * in_size_l1 = hero_l1malloc(sizeof(int32_t)*in_size_stripe_in_len);

  // Results
  
  int32_t * out_pel_l1 = hero_l1malloc(sizeof(int32_t)*out_pel_stripe_out_len);

  // Golden results

  int32_t * out_pel_golden_l1 = hero_l1malloc(sizeof(int32_t)*out_pel_stripe_out_len);

  /* Initialization of I/O arrays. */

  // Stimuli

  for (i = 0; i < in_pel_stripe_height; i++){
    for (j = 0; j < in_pel_width; j++){
      in_pel_l1[i*in_pel_width+j] = in_pel[i*in_pel_width+j];
    }
  }
  for (i = 0; i < in_size_stripe_height; i++){
    for (j = 0; j < in_size_width; j++){
      in_size_l1[i*in_size_width+j] = in_size[i*in_size_width+j];
    }
  }

  // Golden results

  for (i = 0; i < out_pel_stripe_height; i++){
    for (j = 0; j < out_pel_width; j++){
      out_pel_golden_l1[i*out_pel_width+j] = out_pel[i*out_pel_width+j];
    }
  }

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
  hwpe_in_pel_addr_set( in_pel_l1 );
  // input in_size
  hwpe_in_size_addr_set( in_size_l1 );

  // output out_pel
  hwpe_out_pel_addr_set( out_pel_l1 );


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
