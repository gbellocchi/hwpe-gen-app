
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
 *     0  |  0x0040  |  31: 0  |  0xffffffff  ||  TEXT_ADDR
 *     1  |  0x0044  |  31: 0  |  0xffffffff  ||  KEY_ADDR
 *     2  |  0x0048  |  31: 0  |  0xffffffff  ||  RC_ADDR
 *     3  |  0x004c  |  31: 0  |  0xffffffff  ||  CHIPED_TEXT_ADDR

 *     4  |  0x0050  |  31: 0  |  0xffffffff  ||  NB_ITER
 *     5  |  0x0054  |  31: 0  |  0xffffffff  ||  LEN_ITER
 *     6  |  0x0058  |  31:16  |  0xffff0000  ||  SHIFT
 *        |          |   0: 0  |  0x00000001  ||  SIMPLEMUL
 *     7  |  0x005c  |  31: 0  |  0xffffffff  ||  VECTSTRIDE
 *     8  |  0x0060  |  31: 0  |  0xffffffff  ||  VECTSTRIDE2
 *
 * ================================================================================
 *
 */

#define ARCHI_CL_EVT_ACC0 0
#define ARCHI_CL_EVT_ACC1 1
#define ARCHI_HWPE_ADDR_BASE 0x100000			
#define ARCHI_HWPE_EU_OFFSET 12
#define __builtin_bitinsert(a,b,c,d) (a | (((b << (32-c)) >> (32-c)) << d))

/* Basic archi */

#define REG_TRIGGER          0x00

#define REG_ACQUIRE          0x04

#define REG_FINISHED         0x08

#define REG_STATUS           0x0c

#define REG_RUNNING_JOB      0x10

#define REG_SOFT_CLEAR       0x14

/* Microcode processor registers archi */

/* Microcode processor */

#define REG_BYTECODE         0x20

#define REG_BYTECODE0_OFFS        0x00

#define REG_BYTECODE1_OFFS        0x04

#define REG_BYTECODE2_OFFS        0x08

#define REG_BYTECODE3_OFFS        0x0c

#define REG_BYTECODE4_OFFS        0x10

#define REG_BYTECODE5_LOOPS0_OFFS 0x14

#define REG_LOOPS1_OFFS           0x18

/* TCDM registers archi */

// Input master ports
   #define REG_TEXT_ADDR           0x40
   #define REG_KEY_ADDR           0x44
   #define REG_RC_ADDR           0x48

// Output master ports
   #define REG_CHIPED_TEXT_ADDR           0x4c

/* Standard registers archi */

#define REG_NB_ITER                         0x50

#define REG_LINESTRIDE                0x54

#define REG_TILESTRIDE                0x58

#define REG_CNT_LIMIT_CHIPED_TEXT           0x5c

/* Custom registers archi */

/* Address generator archi */

// Input stream - text (programmable)
#define REG_TEXT_TRANS_SIZE                  0x60
#define REG_TEXT_LINE_STRIDE                 0x64
#define REG_TEXT_LINE_LENGTH                 0x68
#define REG_TEXT_FEAT_STRIDE                 0x6c
#define REG_TEXT_FEAT_LENGTH                 0x70
#define REG_TEXT_FEAT_ROLL                   0x74
#define REG_TEXT_LOOP_OUTER                  0x78
#define REG_TEXT_REALIGN_TYPE                0x7c
#define REG_TEXT_STEP                        0x80

// Input stream - key (programmable)
#define REG_KEY_TRANS_SIZE                  0x84
#define REG_KEY_LINE_STRIDE                 0x88
#define REG_KEY_LINE_LENGTH                 0x8c
#define REG_KEY_FEAT_STRIDE                 0x90
#define REG_KEY_FEAT_LENGTH                 0x94
#define REG_KEY_FEAT_ROLL                   0x98
#define REG_KEY_LOOP_OUTER                  0x9c
#define REG_KEY_REALIGN_TYPE                0xa0
#define REG_KEY_STEP                        0xa4

// Input stream - rc (programmable)
#define REG_RC_TRANS_SIZE                  0xa8
#define REG_RC_LINE_STRIDE                 0xac
#define REG_RC_LINE_LENGTH                 0xb0
#define REG_RC_FEAT_STRIDE                 0xb4
#define REG_RC_FEAT_LENGTH                 0xb8
#define REG_RC_FEAT_ROLL                   0xbc
#define REG_RC_LOOP_OUTER                  0xc0
#define REG_RC_REALIGN_TYPE                0xc4
#define REG_RC_STEP                        0xc8

// Input stream - chiped_text (programmable)
#define REG_CHIPED_TEXT_TRANS_SIZE                  0xcc
#define REG_CHIPED_TEXT_LINE_STRIDE                 0xd0
#define REG_CHIPED_TEXT_LINE_LENGTH                 0xd4
#define REG_CHIPED_TEXT_FEAT_STRIDE                 0xd8
#define REG_CHIPED_TEXT_FEAT_LENGTH                 0xdc
#define REG_CHIPED_TEXT_FEAT_ROLL                   0xe0
#define REG_CHIPED_TEXT_LOOP_OUTER                  0xe4
#define REG_CHIPED_TEXT_REALIGN_TYPE                0xe8
#define REG_CHIPED_TEXT_STEP                        0xec

#endif
