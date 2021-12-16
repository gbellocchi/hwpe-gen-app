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

  unsigned array_length         = ARRAY_LENGTH;

  /* Algorithm parameters. */

  unsigned simple_mul           = SIMPLE_MUL;

  /* Allocate I/O arrays. */

  uint32_t* a = (uint32_t*)malloc(array_length*sizeof(uint32_t));
  uint32_t* b = (uint32_t*)malloc(array_length*sizeof(uint32_t)); 
  uint32_t* c = (uint32_t*)malloc(array_length*sizeof(uint32_t)); 

  uint32_t* d_dut = (uint32_t*)malloc(array_length*sizeof(uint32_t));;
  uint32_t* d_ref = (uint32_t*)malloc(array_length*sizeof(uint32_t));;

  /* Generate synthetic stimuli. */

  gen_stim(a, array_length);
  gen_stim(b, array_length);
  gen_stim(c, array_length);

  memset(d_dut, 0, array_length);

  /* Generate golden results. */

  ref_app(a, b, c, d_ref, array_length, simple_mul);

  /* Create output header files. */

  gen_Hfile("a", a, array_length);
  gen_Hfile("b", b, array_length);
  gen_Hfile("c", c, array_length);
  gen_Hfile("d_dut", d_dut, array_length);
  gen_Hfile("d_ref", d_ref, array_length);

  /* Cleanup. */  

  free(a);
  free(b);
  free(c);
  free(d_dut);
  free(d_ref);

  return 0;
}
