

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
 *     2  |  0x0048  |  31: 0  |  0xffffffff  ||  C_ADDR
 *     3  |  0x004c  |  31: 0  |  0xffffffff  ||  D_ADDR

 *     4  |  0x0050  |  31: 0  |  0xffffffff  ||  NB_ITER
 *     5  |  0x0054  |  31: 0  |  0xffffffff  ||  LEN_ITER
 *     6  |  0x0058  |  31:16  |  0xffff0000  ||  SHIFT
 *        |          |   0: 0  |  0x00000001  ||  SIMPLEMUL
 *     7  |  0x005c  |  31: 0  |  0xffffffff  ||  VECTSTRIDE
 *     8  |  0x0060  |  31: 0  |  0xffffffff  ||  VECTSTRIDE2

 *     8  |  0x005c  |  0: 0  |  0xffffffff  ||  HWPE_REG_SIMPLE_MUL

 *     9  |  0x0060  |  7: 0  |  0xffffffff  ||  HWPE_REG_SHIFT

 *     10  |  0x0064  |  15: 0  |  0xffffffff  ||  HWPE_REG_LEN
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

#define MUL_MDC_REG_TRIGGER                                 0x0

#define MUL_MDC_REG_ACQUIRE                                 0x4

#define MUL_MDC_REG_FINISHED                                0x8

#define MUL_MDC_REG_STATUS                                  0xc

#define MUL_MDC_REG_RUNNING_JOB                             0x10

#define MUL_MDC_REG_SOFT_CLEAR                              0x14

/* Microcode processor registers archi */

  /* Microcode processor */

#define MUL_MDC_REG_BYTECODE                                 0x20

#define MUL_MDC_REG_BYTECODE0_OFFS                           0x0

#define MUL_MDC_REG_BYTECODE1_OFFS                           0x4

#define MUL_MDC_REG_BYTECODE2_OFFS                           0x8

#define MUL_MDC_REG_BYTECODE3_OFFS                           0xc

#define MUL_MDC_REG_BYTECODE4_OFFS                           0x10

#define MUL_MDC_REG_BYTECODE5_LOOPS0_OFFS                    0x14

#define MUL_MDC_REG_LOOPS1_OFFS                              0x18

/* TCDM registers archi */

// Input master ports
#define MUL_MDC_REG_A_ADDR                         0x40

#define MUL_MDC_REG_B_ADDR                         0x44

#define MUL_MDC_REG_C_ADDR                         0x48

// Output master ports
#define MUL_MDC_REG_D_ADDR                        0x4c

/* Standard registers archi */

#define MUL_MDC_REG_NB_ITER                         0x50

#define MUL_MDC_REG_LINESTRIDE                0x54

#define MUL_MDC_REG_TILESTRIDE                0x58

#define MUL_MDC_REG_CNT_LIMIT_D                 0x5c

/* Custom registers archi */

// custom regs
#define MUL_MDC_REG_REG_SIMPLE_MUL                0x60

#define MUL_MDC_REG_REG_SHIFT                0x64

#define MUL_MDC_REG_REG_LEN                0x68

/* Address generator archi */

// Input stream - a (programmable)
#define MUL_MDC_REG_A_TRANS_SIZE                  0x6c
#define MUL_MDC_REG_A_LINE_STRIDE                 0x70
#define MUL_MDC_REG_A_LINE_LENGTH                 0x74
#define MUL_MDC_REG_A_FEAT_STRIDE                 0x78
#define MUL_MDC_REG_A_FEAT_LENGTH                 0x7c
#define MUL_MDC_REG_A_FEAT_ROLL                   0x80
#define MUL_MDC_REG_A_LOOP_OUTER                  0x84
#define MUL_MDC_REG_A_REALIGN_TYPE                0x88
#define MUL_MDC_REG_A_STEP                        0x8c
// Input stream - b (programmable)
#define MUL_MDC_REG_B_TRANS_SIZE                  0x90
#define MUL_MDC_REG_B_LINE_STRIDE                 0x94
#define MUL_MDC_REG_B_LINE_LENGTH                 0x98
#define MUL_MDC_REG_B_FEAT_STRIDE                 0x9c
#define MUL_MDC_REG_B_FEAT_LENGTH                 0xa0
#define MUL_MDC_REG_B_FEAT_ROLL                   0xa4
#define MUL_MDC_REG_B_LOOP_OUTER                  0xa8
#define MUL_MDC_REG_B_REALIGN_TYPE                0xac
#define MUL_MDC_REG_B_STEP                        0xb0
// Input stream - c (programmable)
#define MUL_MDC_REG_C_TRANS_SIZE                  0xb4
#define MUL_MDC_REG_C_LINE_STRIDE                 0xb8
#define MUL_MDC_REG_C_LINE_LENGTH                 0xbc
#define MUL_MDC_REG_C_FEAT_STRIDE                 0xc0
#define MUL_MDC_REG_C_FEAT_LENGTH                 0xc4
#define MUL_MDC_REG_C_FEAT_ROLL                   0xc8
#define MUL_MDC_REG_C_LOOP_OUTER                  0xcc
#define MUL_MDC_REG_C_REALIGN_TYPE                0xd0
#define MUL_MDC_REG_C_STEP                        0xd4

// Input stream - d (programmable)
#define MUL_MDC_REG_D_TRANS_SIZE                 0xd8
#define MUL_MDC_REG_D_LINE_STRIDE                0xdc
#define MUL_MDC_REG_D_LINE_LENGTH                0xe0
#define MUL_MDC_REG_D_FEAT_STRIDE                0xe4
#define MUL_MDC_REG_D_FEAT_LENGTH                0xe8
#define MUL_MDC_REG_D_FEAT_ROLL                  0xec
#define MUL_MDC_REG_D_LOOP_OUTER                 0xf0
#define MUL_MDC_REG_D_REALIGN_TYPE               0xf4
#define MUL_MDC_REG_D_STEP                       0xf8

#endif
