/* =====================================================================
 * Project:      Verification dataset generator.
 * Title:        ref_app.c
 * Description:  Reference application to generate golden results. Its
 *               functionality is the same as the integrated hardware
 *               accelerator.
 * 
 * Algorithm:    MAC.
 *
 * $Date:        13.12.2021
 * ===================================================================== */
/*
 * Copyright (C) 2021 University of Modena and Reggio Emilia..
 *
 * Author: Gianluca Bellocchi, University of Modena and Reggio Emilia.
 *
 */

#include "ref_app.h"

void ref_app(uint32_t* a, uint32_t* b, uint32_t* c, uint32_t* d, unsigned array_length, unsigned simple_mul)
{

  if(simple_mul==1){ 
    printf(">> Running reference SW application to generate golden results -> Element-wise product\n");
    for (uint32_t ii = 0; ii < array_length; ii++){
      d[ii] = a[ii] * b[ii];
    }
  } else { 
    printf(">> Running reference SW application to generate golden results -> Dot product\n");
    for (uint32_t ii = 0; ii < array_length; ii++){
        d[0] += a[ii] * b[ii];
    }
  }
}