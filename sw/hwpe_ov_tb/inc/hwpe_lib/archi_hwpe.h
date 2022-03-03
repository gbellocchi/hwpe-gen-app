

/*
 * Copyright (C) 2018-2019 ETH Zurich and University of Bologna
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * Authors:     Francesco Conti <fconti@iis.ee.ethz.ch>
 * Contribute:  Gianluca Bellocchi <gianluca.bellocchi@unimore.it>
 */

#ifndef __ARCHI_HWPE_H__
#define __ARCHI_HWPE_H__

/*
 * Control and generic configuration register layout
 * ================================================================================
 *  # reg |  offset  |  bits   |   bitmask    ||  content
 * -------+----------+---------+--------------++-----------------------------------
 *     0  |  0x0000  |  31: 0  |  0xffffffff  ||  TRIGGER
 *     1  |  0x0004  |  31: 0  |  0xffffffff  ||  ACQUIRE
 *     2  |  0x0008  |  31: 0  |  0xffffffff  ||  EVT_ENABLE
 *     3  |  0x000c  |  31: 0  |  0xffffffff  ||  STATUS
 *     4  |  0x0010  |  31: 0  |  0xffffffff  ||  RUNNING_JOB
 *     5  |  0x0014  |  31: 0  |  0xffffffff  ||  SOFT_CLEAR
 *   6-7  |          |         |              ||  Reserved
 *     8  |  0x0020  |  31: 0  |  0xffffffff  ||  BYTECODE0 [31:0]
 *     9  |  0x0024  |  31: 0  |  0xffffffff  ||  BYTECODE1 [63:32]
 *    10  |  0x0028  |  31: 0  |  0xffffffff  ||  BYTECODE2 [95:64]
 *    11  |  0x002c  |  31: 0  |  0xffffffff  ||  BYTECODE3 [127:96]
 *    12  |  0x0030  |  31: 0  |  0xffffffff  ||  BYTECODE4 [159:128]
 *    13  |  0x0034  |  31:16  |  0xffff0000  ||  LOOPS0    [15:0]
 *        |          |  15: 0  |  0x0000ffff  ||  BYTECODE5 [175:160]
 *    14  |  0x0038  |  31: 0  |  0xffffffff  ||  LOOPS1    [47:16]
 *    15  |          |  31: 0  |  0xffffffff  ||  Reserved
 * ================================================================================
 *
 * Job-dependent registers layout
 * ================================================================================
 *  # reg |  offset  |  bits   |   bitmask    ||  content
 * -------+----------+---------+--------------++-----------------------------------
 *     0  |  0x0040  |  31: 0  |  0xffffffff  ||  A_ADDR
 *     1  |  0x0044  |  31: 0  |  0xffffffff  ||  B_ADDR

 *     2  |  0x0048  |  31: 0  |  0xffffffff  ||  NB_ITER
 *     3  |  0x004c  |  31: 0  |  0xffffffff  ||  LEN_ITER
 *     4  |  0x0050  |  31:16  |  0xffff0000  ||  SHIFT
 *        |          |   0: 0  |  0x00000001  ||  SIMPLEMUL
 *     5  |  0x0054  |  31: 0  |  0xffffffff  ||  VECTSTRIDE
 *     6  |  0x0058  |  31: 0  |  0xffffffff  ||  VECTSTRIDE2
 *
 * ================================================================================
 *
 */

#define ARCHI_CL_EVT_ACC0 0
#define ARCHI_CL_EVT_ACC1 1
#define ARCHI_HWPE_ADDR_BASE 0x1b201000
#define ARCHI_HWPE_EU_OFFSET 12
#define __builtin_bitinsert(a,b,c,d) (a | (((b << (32-c)) >> (32-c)) << d))

/* Basic archi */

#define FIR_128_MDC_REG_TRIGGER                                 0x0

#define FIR_128_MDC_REG_ACQUIRE                                 0x4

#define FIR_128_MDC_REG_FINISHED                                0x8

#define FIR_128_MDC_REG_STATUS                                  0xc

#define FIR_128_MDC_REG_RUNNING_JOB                             0x10

#define FIR_128_MDC_REG_SOFT_CLEAR                              0x14

/* Microcode processor registers archi */

  /* Microcode processor */

#define FIR_128_MDC_REG_BYTECODE                                 0x20

#define FIR_128_MDC_REG_BYTECODE0_OFFS                           0x0

#define FIR_128_MDC_REG_BYTECODE1_OFFS                           0x4

#define FIR_128_MDC_REG_BYTECODE2_OFFS                           0x8

#define FIR_128_MDC_REG_BYTECODE3_OFFS                           0xc

#define FIR_128_MDC_REG_BYTECODE4_OFFS                           0x10

#define FIR_128_MDC_REG_BYTECODE5_LOOPS0_OFFS                    0x14

#define FIR_128_MDC_REG_LOOPS1_OFFS                              0x18

/* TCDM registers archi */

// Input master ports
#define FIR_128_MDC_REG_X_V_ADDR                         0x40

// Output master ports
#define FIR_128_MDC_REG_Y_V_ADDR                        0x44

/* Standard registers archi */

#define FIR_128_MDC_REG_NB_ITER                         0x48

#define FIR_128_MDC_REG_LINESTRIDE                0x4c

#define FIR_128_MDC_REG_TILESTRIDE                0x50

#define FIR_128_MDC_REG_CNT_LIMIT_Y_V                 0x54

/* Custom registers archi */

/* Address generator archi */

// Input stream - x_V (programmable)
#define FIR_128_MDC_REG_X_V_TRANS_SIZE                  0x58
#define FIR_128_MDC_REG_X_V_LINE_STRIDE                 0x5c
#define FIR_128_MDC_REG_X_V_LINE_LENGTH                 0x60
#define FIR_128_MDC_REG_X_V_FEAT_STRIDE                 0x64
#define FIR_128_MDC_REG_X_V_FEAT_LENGTH                 0x68
#define FIR_128_MDC_REG_X_V_FEAT_ROLL                   0x6c
#define FIR_128_MDC_REG_X_V_LOOP_OUTER                  0x70
#define FIR_128_MDC_REG_X_V_REALIGN_TYPE                0x74
#define FIR_128_MDC_REG_X_V_STEP                        0x78

// Input stream - y_V (programmable)
#define FIR_128_MDC_REG_Y_V_TRANS_SIZE                 0x7c
#define FIR_128_MDC_REG_Y_V_LINE_STRIDE                0x80
#define FIR_128_MDC_REG_Y_V_LINE_LENGTH                0x84
#define FIR_128_MDC_REG_Y_V_FEAT_STRIDE                0x88
#define FIR_128_MDC_REG_Y_V_FEAT_LENGTH                0x8c
#define FIR_128_MDC_REG_Y_V_FEAT_ROLL                  0x90
#define FIR_128_MDC_REG_Y_V_LOOP_OUTER                 0x94
#define FIR_128_MDC_REG_Y_V_REALIGN_TYPE               0x98
#define FIR_128_MDC_REG_Y_V_STEP                       0x9c

#endif
