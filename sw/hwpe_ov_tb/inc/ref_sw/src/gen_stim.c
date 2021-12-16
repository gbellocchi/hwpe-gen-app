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

void gen_stim(uint32_t* stim, uint32_t width, uint32_t height)
{
  printf(">> Generating synthetic input stimuli.\n");

  /* Algorithm parameters declaration. */
    
  const int chkr_size = 5;
  const unsigned max_pix_val = 255;
  const unsigned min_pix_val = 0;

  /* Generate synthetic stimuli. */

  for (int i = 0; i < IM_UAV_ROWS; i++) {
    unsigned chkr_pair_val[2];
    if ((i / chkr_size) % 2 == 0) {
      chkr_pair_val[0] = max_pix_val; chkr_pair_val[1] = min_pix_val;
    } else {
      chkr_pair_val[0] = min_pix_val; chkr_pair_val[1] = max_pix_val;
    }
    for (int j = 0; j < IM_UAV_COLS; j++) {
      unsigned pix_val = chkr_pair_val[(j / chkr_size) % 2];
      stim[i * IM_UAV_COLS + j] = pix_val;
    }
  }
}