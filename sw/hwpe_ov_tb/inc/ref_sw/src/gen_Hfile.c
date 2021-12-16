/* =====================================================================
 * Project:      Verification dataset generator.
 * Title:        gen_Hfile.c
 * Description:  Generate output header file.
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

void gen_Hfile(char* val_name, uint32_t* synth_data, uint32_t array_length)
{
  printf(">> Export synthetic %s to header file.\n", val_name);

  char filename[100];
  char h_body[1000];

  // Create file
  strcpy(filename, val_name);
  strcat(filename, ".h");

  FILE *fp = fopen(filename, "w+");

  // Generate header file
  strcpy(h_body, "__attribute__((aligned(32))) int32_t ");
  strcat(h_body, val_name);
  strcat(h_body, "[] = {\n");
  fprintf(fp, "%s", h_body);

  for (int ii = 0; ii < array_length; ii++) {
    if(ii==array_length-1)
      fprintf(fp, "\t0x%lx\n", synth_data[ii]);
    else
      fprintf(fp, "\t0x%lx,\n", synth_data[ii]);
  }

  fprintf(fp, "};");

  // Close file
  fclose(fp);
}