
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
#include "inc/stim/text.h""
#include "inc/stim/key.h""
#include "inc/stim/rc.h""

// Golden results
#include "inc/stim/chiped_text.h"

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

const unsigned engine_runs_chiped_text = ;

  // 3. Custom registers

  /* General parameters. */

  volatile int errors = 0;
  int i, j;
  int offload_id_tmp, offload_id;

  omp_set_num_threads(1);

  /* Stream-specific parameters. */

const unsigned text_width              = width;
const unsigned text_height             = height;
const unsigned text_stripe_height      = stripe_height;

const unsigned key_width              = width;
const unsigned key_height             = height;
const unsigned key_stripe_height      = stripe_height;

const unsigned rc_width              = width;
const unsigned rc_height             = height;
const unsigned rc_stripe_height      = stripe_height;

const unsigned chiped_text_width              = width;
const unsigned chiped_text_height             = height;
const unsigned chiped_text_stripe_height      = stripe_height;

  /* Dataset parameters. */
const unsigned text_stim_dim               = text_width * text_height;
const unsigned text_stripe_in_len          = text_width * text_stripe_height;

const unsigned key_stim_dim               = key_width * key_height;
const unsigned key_stripe_in_len          = key_width * key_stripe_height;

const unsigned rc_stim_dim               = rc_width * rc_height;
const unsigned rc_stripe_in_len          = rc_width * rc_stripe_height;

const unsigned chiped_text_stim_dim               = chiped_text_width * chiped_text_height;
const unsigned chiped_text_stripe_out_len          = chiped_text_width * chiped_text_stripe_height;

  /* Address generator (input) - Parameters */
const unsigned text_trans_size             = text_width * text_stripe_height;
const unsigned text_line_stride            = 0;
const unsigned text_line_length            = text_width * text_stripe_height;
const unsigned text_feat_stride            = 0;
const unsigned text_feat_length            = 1;
const unsigned text_feat_roll              = 0;
const unsigned text_loop_outer             = 0;
const unsigned text_realign_type           = 0;
const unsigned text_step                   = 4;

const unsigned key_trans_size             = key_width * key_stripe_height;
const unsigned key_line_stride            = 0;
const unsigned key_line_length            = key_width * key_stripe_height;
const unsigned key_feat_stride            = 0;
const unsigned key_feat_length            = 1;
const unsigned key_feat_roll              = 0;
const unsigned key_loop_outer             = 0;
const unsigned key_realign_type           = 0;
const unsigned key_step                   = 4;

const unsigned rc_trans_size             = rc_width * rc_stripe_height;
const unsigned rc_line_stride            = 0;
const unsigned rc_line_length            = rc_width * rc_stripe_height;
const unsigned rc_feat_stride            = 0;
const unsigned rc_feat_length            = 1;
const unsigned rc_feat_roll              = 0;
const unsigned rc_loop_outer             = 0;
const unsigned rc_realign_type           = 0;
const unsigned rc_step                   = 4;

  /* Address generator (output) - Parameters */
const unsigned chiped_text_trans_size             = chiped_text_stripe_height * chiped_text_stripe_height + 1;
const unsigned chiped_text_line_stride            = sizeof(uint32_t);
const unsigned chiped_text_line_length            = 1;
const unsigned chiped_text_feat_stride            = chiped_text_width * sizeof(uint32_t);
const unsigned chiped_text_feat_length            = chiped_text_stripe_height;
const unsigned chiped_text_feat_roll              = chiped_text_stripe_height;
const unsigned chiped_text_loop_outer             = 0;
const unsigned chiped_text_realign_type           = 0;
const unsigned chiped_text_step                   = 4;

  printf("Allocation and initialization of L1 stimuli\n");

  /* Allocation of I/O arrays. */

  // Stimuli

  int32_t * text_l1 = hero_l1malloc(sizeof(int32_t)*text_stripe_in_len);
  int32_t * key_l1 = hero_l1malloc(sizeof(int32_t)*key_stripe_in_len);
  int32_t * rc_l1 = hero_l1malloc(sizeof(int32_t)*rc_stripe_in_len);

  // Results
  
  int32_t * chiped_text_l1 = hero_l1malloc(sizeof(int32_t)*chiped_text_stripe_out_len);

  // Golden results

  int32_t * chiped_text_golden_l1 = hero_l1malloc(sizeof(int32_t)*chiped_text_stripe_out_len);

  /* Initialization of I/O arrays. */

  // Stimuli

  for (i = 0; i < text_stripe_height; i++){
    for (j = 0; j < text_width; j++){
      text_l1[i*text_width+j] = text[i*text_width+j];
    }
  }
  for (i = 0; i < key_stripe_height; i++){
    for (j = 0; j < key_width; j++){
      key_l1[i*key_width+j] = key[i*key_width+j];
    }
  }
  for (i = 0; i < rc_stripe_height; i++){
    for (j = 0; j < rc_width; j++){
      rc_l1[i*rc_width+j] = rc[i*rc_width+j];
    }
  }

  // Golden results

  for (i = 0; i < chiped_text_stripe_height; i++){
    for (j = 0; j < chiped_text_width; j++){
      chiped_text_golden_l1[i*chiped_text_width+j] = chiped_text[i*chiped_text_width+j];
    }
  }

  /* HWPE initialization */

  hwpe_cg_enable();
  while((offload_id_tmp = hwpe_acquire_job()) < 0)

  /* FSM programming */

  hwpe_len_iter_set_chiped_text(engine_runs_chiped_text-1);

  /* Address generator programming */

  // Input text
  hwpe_addr_gen_text(
    text_trans_size,
    text_line_stride,
    text_line_length,
    text_feat_stride,
    text_feat_length,
    text_feat_roll,
    text_loop_outer,
    text_realign_type,
    text_step
  );
  // Input key
  hwpe_addr_gen_key(
    key_trans_size,
    key_line_stride,
    key_line_length,
    key_feat_stride,
    key_feat_length,
    key_feat_roll,
    key_loop_outer,
    key_realign_type,
    key_step
  );
  // Input rc
  hwpe_addr_gen_rc(
    rc_trans_size,
    rc_line_stride,
    rc_line_length,
    rc_feat_stride,
    rc_feat_length,
    rc_feat_roll,
    rc_loop_outer,
    rc_realign_type,
    rc_step
  );

  // Output chiped_text
  hwpe_addr_gen_chiped_text(
    chiped_text_trans_size,
    chiped_text_line_stride,
    chiped_text_line_length,
    chiped_text_feat_stride,
    chiped_text_feat_length,
    chiped_text_feat_roll,
    chiped_text_loop_outer,
    chiped_text_realign_type,
    chiped_text_step
  );

  /* Set TCDM address reg values */			

  // input text
  hwpe_text_addr_set( text_l1 );
  // input key
  hwpe_key_addr_set( key_l1 );
  // input rc
  hwpe_rc_addr_set( rc_l1 );

  // output chiped_text
  hwpe_chiped_text_addr_set( chiped_text_l1 );


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
