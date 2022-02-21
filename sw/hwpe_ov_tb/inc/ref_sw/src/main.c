/* =====================================================================
 * Project:      Verification dataset generator.
 * Title:        main.c
 * Description:  Main function recalling components to generate 
 *               stimuli and golden results for RTL simulation.
 *
 * $Date:        14.11.2021
 * ===================================================================== */
/*
 * Copyright (C) 2021 University of Modena and Reggio Emilia..
 *
 * Author: Gianluca Bellocchi, University of Modena and Reggio Emilia.
 *
 */

#include "ref_app.h"

int main(int argc, char *argv[])
{
  /* Stimuli dimension. */

  unsigned width          = WIDTH;
  unsigned height         = HEIGHT;
  unsigned stripe_height  = STRIPE_HEIGHT;

  /* Allocate I/O arrays. */

  uint32_t* stream_in_V = (uint32_t*)malloc(width*height*sizeof(uint32_t));
  uint32_t* stream_out_V_dut = (uint32_t*)malloc(width*height*sizeof(uint32_t)); 
  uint32_t* stream_out_V_ref = (uint32_t*)malloc(width*height*sizeof(uint32_t)); 

  /* Additional parameters. */

  const unsigned stripe_len = width*stripe_height;

  /* Generate synthetic stimuli. */

  gen_stim(stream_in_V, width, height, stripe_height);
  memset(stream_out_V_dut, 0, width*stripe_height);

  /* Generate golden results. */

  ref_app(stream_in_V, stream_out_V_dut, width, height, stripe_height);

  /* Create output header files. */

  gen_Hfile("stream_in_V", stream_in_V, width, height);
  gen_Hfile("stream_out_V_dut", stream_out_V_dut, width, height);
  gen_Hfile("stream_out_V_ref", stream_out_V_ref, width, height);

  /* Cleanup. */  

  free(stream_in_V);
  free(stream_out_V_dut);
  free(stream_out_V_ref);

  return 0;
}
