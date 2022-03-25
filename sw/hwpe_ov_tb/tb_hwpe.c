
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
#include "inc/stim/inStream0.h""
#include "inc/stim/inStream1.h""
#include "inc/stim/inStream2.h""

// Golden results
#include "inc/stim/outStream0.h"

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

const unsigned engine_runs_outStream0 = ;

  // 3. Custom registers
  const unsigned reg_simple_mul_val = ;
  const unsigned reg_shift_val = ;
  const unsigned reg_len_val = ;
  const unsigned id_val = ;

  /* General parameters. */

  volatile int errors = 0;
  int i, j;
  int offload_id_tmp, offload_id;

  omp_set_num_threads(1);

  /* Stream-specific parameters. */

const unsigned inStream0_width              = width;
const unsigned inStream0_height             = height;
const unsigned inStream0_stripe_height      = stripe_height;

const unsigned inStream1_width              = width;
const unsigned inStream1_height             = height;
const unsigned inStream1_stripe_height      = stripe_height;

const unsigned inStream2_width              = width;
const unsigned inStream2_height             = height;
const unsigned inStream2_stripe_height      = stripe_height;

const unsigned outStream0_width              = width;
const unsigned outStream0_height             = height;
const unsigned outStream0_stripe_height      = stripe_height;

  /* Dataset parameters. */
const unsigned inStream0_stim_dim               = inStream0_width * inStream0_height;
const unsigned inStream0_stripe_in_len          = inStream0_width * inStream0_stripe_height;

const unsigned inStream1_stim_dim               = inStream1_width * inStream1_height;
const unsigned inStream1_stripe_in_len          = inStream1_width * inStream1_stripe_height;

const unsigned inStream2_stim_dim               = inStream2_width * inStream2_height;
const unsigned inStream2_stripe_in_len          = inStream2_width * inStream2_stripe_height;

const unsigned outStream0_stim_dim               = outStream0_width * outStream0_height;
const unsigned outStream0_stripe_out_len          = outStream0_width * outStream0_stripe_height;

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
const unsigned outStream0_trans_size             = outStream0_stripe_height * outStream0_stripe_height + 1;
const unsigned outStream0_line_stride            = sizeof(uint32_t);
const unsigned outStream0_line_length            = 1;
const unsigned outStream0_feat_stride            = outStream0_width * sizeof(uint32_t);
const unsigned outStream0_feat_length            = outStream0_stripe_height;
const unsigned outStream0_feat_roll              = outStream0_stripe_height;
const unsigned outStream0_loop_outer             = 0;
const unsigned outStream0_realign_type           = 0;
const unsigned outStream0_step                   = 4;

  printf("Allocation and initialization of L1 stimuli\n");

  /* Allocation of I/O arrays. */

  // Stimuli

  int32_t * inStream0_l1 = hero_l1malloc(sizeof(int32_t)*inStream0_stripe_in_len);
  int32_t * inStream1_l1 = hero_l1malloc(sizeof(int32_t)*inStream1_stripe_in_len);
  int32_t * inStream2_l1 = hero_l1malloc(sizeof(int32_t)*inStream2_stripe_in_len);

  // Results
  
  int32_t * outStream0_l1 = hero_l1malloc(sizeof(int32_t)*outStream0_stripe_out_len);

  // Golden results

  int32_t * outStream0_golden_l1 = hero_l1malloc(sizeof(int32_t)*outStream0_stripe_out_len);

  /* Initialization of I/O arrays. */

  // Stimuli

  for (i = 0; i < inStream0_stripe_height; i++){
    for (j = 0; j < inStream0_width; j++){
      inStream0_l1[i*inStream0_width+j] = inStream0[i*inStream0_width+j];
    }
  }
  for (i = 0; i < inStream1_stripe_height; i++){
    for (j = 0; j < inStream1_width; j++){
      inStream1_l1[i*inStream1_width+j] = inStream1[i*inStream1_width+j];
    }
  }
  for (i = 0; i < inStream2_stripe_height; i++){
    for (j = 0; j < inStream2_width; j++){
      inStream2_l1[i*inStream2_width+j] = inStream2[i*inStream2_width+j];
    }
  }

  // Golden results

  for (i = 0; i < outStream0_stripe_height; i++){
    for (j = 0; j < outStream0_width; j++){
      outStream0_golden_l1[i*outStream0_width+j] = outStream0[i*outStream0_width+j];
    }
  }

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
  hwpe_inStream0_addr_set( inStream0_l1 );
  // input inStream1
  hwpe_inStream1_addr_set( inStream1_l1 );
  // input inStream2
  hwpe_inStream2_addr_set( inStream2_l1 );

  // output outStream0
  hwpe_outStream0_addr_set( outStream0_l1 );


  /* Set user custom registers */
  hwpe_reg_simple_mul_set( reg_simple_mul_val );
  hwpe_reg_shift_set( reg_shift_val );
  hwpe_reg_len_set( reg_len_val );
  hwpe_ID_configuration_set(id_val);

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
