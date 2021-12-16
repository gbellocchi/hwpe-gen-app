

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
  #include "inc/stim/a.h"
  #include "inc/stim/b.h"
  #include "inc/stim/c.h"

  // Golden results
  #include "inc/stim/d.h"

/* - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / - / */

/*
 *
 *     HWPE SW test.
 *
 */

int main() {

  printf("Software test application - DUT: mul_mdc\n");

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

  const unsigned engine_runs_d = ;

  // 3. Custom registers
  const unsigned reg_simple_mul_val = ;
  const unsigned reg_shift_val = ;
  const unsigned reg_len_val = ;

  /* General parameters. */

  volatile int errors = 0;
  int i, j;
  int offload_id_tmp, offload_id;

  omp_set_num_threads(1);

  /* Stream-specific parameters. */

  const unsigned a_width              = width;
  const unsigned a_height             = height;
  const unsigned a_stripe_height      = stripe_height;
  const unsigned b_width              = width;
  const unsigned b_height             = height;
  const unsigned b_stripe_height      = stripe_height;
  const unsigned c_width              = width;
  const unsigned c_height             = height;
  const unsigned c_stripe_height      = stripe_height;

  const unsigned d_width             = width;
  const unsigned d_height            = height;
  const unsigned d_stripe_height     = stripe_height;

  /* Dataset parameters. */
  const unsigned a_stim_dim               = a_width * a_height;
  const unsigned a_stripe_in_len          = a_width * a_stripe_height;
  const unsigned b_stim_dim               = b_width * b_height;
  const unsigned b_stripe_in_len          = b_width * b_stripe_height;
  const unsigned c_stim_dim               = c_width * c_height;
  const unsigned c_stripe_in_len          = c_width * c_stripe_height;

  const unsigned d_stim_dim              = d_width * d_height;
  const unsigned d_stripe_out_len        = d_width * d_stripe_height;

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

  const unsigned d_trans_size             = d_stripe_height * d_stripe_height + 1;
  const unsigned d_line_stride            = sizeof(uint32_t);
  const unsigned d_line_length            = 1;
  const unsigned d_feat_stride            = d_width * sizeof(uint32_t);
  const unsigned d_feat_length            = d_stripe_height;
  const unsigned d_feat_roll              = d_stripe_height;
  const unsigned d_loop_outer             = 0;
  const unsigned d_realign_type           = 0;
  const unsigned d_step                   = 4;

  printf("Allocation and initialization of L1 stimuli\n");

  /* Allocation of I/O arrays. */

  // Stimuli

  int32_t * a_l1 = hero_l1malloc(sizeof(int32_t)*a_stripe_in_len);
  int32_t * b_l1 = hero_l1malloc(sizeof(int32_t)*b_stripe_in_len);
  int32_t * c_l1 = hero_l1malloc(sizeof(int32_t)*c_stripe_in_len);

  // Results

  int32_t * d_l1 = hero_l1malloc(sizeof(int32_t)*d_stripe_out_len);

  // Golden results

  int32_t * d_golden_l1 = hero_l1malloc(sizeof(int32_t)*d_stripe_out_len);

  /* Initialization of I/O arrays. */

  // Stimuli

  for (i = 0; i < a_stripe_height; i++){
    for (j = 0; j < a_width; j++){
      a_l1[i*a_width+j] = a[i*a_width+j];
    }
  }
  for (i = 0; i < b_stripe_height; i++){
    for (j = 0; j < b_width; j++){
      b_l1[i*b_width+j] = b[i*b_width+j];
    }
  }
  for (i = 0; i < c_stripe_height; i++){
    for (j = 0; j < c_width; j++){
      c_l1[i*c_width+j] = c[i*c_width+j];
    }
  }

  // Golden results

  for (i = 0; i < d_stripe_height; i++){
    for (j = 0; j < d_width; j++){
      d_golden_l1[i*d_width+j] = d[i*d_width+j];
    }
  }

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
  hwpe_a_addr_set( a_l1 );
  // input b
  hwpe_b_addr_set( b_l1 );
  // input c
  hwpe_c_addr_set( c_l1 );

  // output d
  hwpe_d_addr_set( d_l1 );

  /* Set user custom registers */
  hwpe_reg_simple_mul_set( reg_simple_mul_val );
  hwpe_reg_shift_set( reg_shift_val );
  hwpe_reg_len_set( reg_len_val );

  /* HWPE execution */

  // Being RTL simualtion very slow, a single data stripe is processed
  // in order to assess the functionality of the mul_mdc DUT.

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