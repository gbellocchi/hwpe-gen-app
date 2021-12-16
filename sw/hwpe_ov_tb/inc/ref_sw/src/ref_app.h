/* =====================================================================
 * Project:      Verification dataset generator.
 * Title:        ref_app.c
 * Description:  Reference application libraries and defintions.
 *
 * $Date:        14.11.2021
 * ===================================================================== */
/*
 * Copyright (C) 2021 University of Modena and Reggio Emilia..
 *
 * Author: Gianluca Bellocchi, University of Modena and Reggio Emilia.
 *
 */

/* Libraries. */

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <errno.h>

/* Parameters. */

#define ARRAY_LENGTH 1024

#define SIMPLE_MUL 1

/* Functions declaration. */

void ref_app(uint32_t* a, uint32_t* b, uint32_t* c, uint32_t* d, unsigned array_length, unsigned simple_mul);
void gen_stim(uint32_t* stim, uint32_t array_length);
void gen_Hfile(char* val_name, uint32_t* synth_data, uint32_t array_length);