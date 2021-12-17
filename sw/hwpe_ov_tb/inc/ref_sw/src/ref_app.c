/* =====================================================================
 * Project:      Verification dataset generator.
 * Title:        ref_app.c
 * Description:  Reference application to generate golden results. Its
 *               functionality is the same as the integrated hardware
 *               accelerator.
 * 
 * Algorithm:    2D Convolutional Filter.
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

void ref_app(uint32_t* in, uint32_t* out, uint32_t width, uint32_t height)
{
  printf(">> Running reference SW application to generate golden results.\n");

  // Filter dimension

  const int conv_size = UAV_FILTER_DIM;

  // Filter components

  uint32_t coeffs[UAV_FILTER_DIM] = {
    36, 111, 266, 498, 724, 821, 724, 498, 266, 111, 36
  };

  uint32_t in_temp;
  uint32_t out_temp;
  uint32_t out_H[width*height];
  uint32_t out_V[width*height];

  const int border_width = (int)(conv_size / 2);

  // Horizontal convolution

  Clear_out_H:for(int i = 0; i < height * width; i++){
    out_H[i]=0;
  }

  HconvH: for(int col = 0; col < height; col++){
    HconvW: for(int row = border_width; row < width - border_width; row++){
      int pixel = col * width + row;
      Hconv: for(int i = - border_width; i <= border_width; i++){
        out_H[pixel] += in[pixel + i] * coeffs[i + border_width];
      }
    }
  }

  // Vertical convolution

  Clear_out_V:for(int i = 0; i < height * width; i++){
    out_V[i]=0;
  }

  VconvH: for(int col = border_width; col < height - border_width; col++){
    VconvW: for(int row = 0; row < width; row++){
      int pixel = col * width + row;
      Vconv: for(int i = - border_width; i <= border_width; i++){
        int offset = i * width;
        out[pixel] += out_H[pixel + offset] * coeffs[i + border_width];
      }
    }
  }

  // Border pixels

  int border_width_offset = border_width * width;
  int border_height_offset = (height - border_width - 1) * width;

  // Border pixels

  Top_Border:for(int col = 0; col < border_width; col++){
    int offset = col * width;
    Top_Left:for(int row = 0; row < border_width; row++){
      int pixel = offset + row;
      out[pixel] = out[border_width_offset + border_width];
    }
    Top_Row:for(int row = border_width; row < width - border_width; row++){
      int pixel = offset + row;
      out[pixel] = out[border_width_offset + row];
    }
    Top_Right:for(int row = width - border_width; row < width; row++){
      int pixel = offset + row;
      out[pixel] = out[border_width_offset + width - border_width - 1];
    }
  }

  Side_Border:for(int col = border_width; col < height - border_width; col++){
    int offset = col * width;
    for(int row = 0; row < border_width; row++){
      int pixel = offset + row;
      out[pixel] = out[offset + border_width];
    }
    for(int row = width - border_width; row < width; row++){
      int pixel = offset + row;
      out[pixel] = out[offset + width - border_width - 1];
    }
  }

  Bottom_Border:for(int col = height - border_width; col < height; col++){
    int offset = col * width;
    for(int row = 0; row < border_width; row++){
      int pixel = offset + row;
      out[pixel] = out[border_height_offset + border_width];
    }
    for(int row = border_width; row < width - border_width; row++){
      int pixel = offset + row;
      out[pixel] = out[border_height_offset + row];
    }
    for(int row = width - border_width; row < width; row++){
      int pixel = offset + row;
      out[pixel] = out[border_height_offset + width - border_width - 1];
    }
  }
}