/* =====================================================================
 * Project:      Verification dataset generator.
 * Title:        gen_stim.c
 * Description:  Generate synthetic stimuli.
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

void gen_stim(uint32_t* stim, uint32_t width, uint32_t height, uint32_t stripe_height)
{
  printf(">> Generating synthetic input stimuli.\n");
  
  for(int i=0; i < width*stripe_height; i++){
      stim[i] = rand() % 255;
  }
}