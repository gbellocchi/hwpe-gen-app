
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
 *     0  |  0x0040  |  31: 0  |  0xffffffff  ||  INSTREAM0_ADDR
 *     1  |  0x0044  |  31: 0  |  0xffffffff  ||  INSTREAM1_ADDR
 *     2  |  0x0048  |  31: 0  |  0xffffffff  ||  INSTREAM2_ADDR
 *     3  |  0x004c  |  31: 0  |  0xffffffff  ||  OUTSTREAM0_ADDR

 *     4  |  0x0050  |  31: 0  |  0xffffffff  ||  NB_ITER
 *     5  |  0x0054  |  31: 0  |  0xffffffff  ||  LEN_ITER
 *     6  |  0x0058  |  31:16  |  0xffff0000  ||  SHIFT
 *        |          |   0: 0  |  0x00000001  ||  SIMPLEMUL
 *     7  |  0x005c  |  31: 0  |  0xffffffff  ||  VECTSTRIDE
 *     8  |  0x0060  |  31: 0  |  0xffffffff  ||  VECTSTRIDE2

 *     9  |  0x0064  |  31: 0  |  0xffffffff  ||  REG_SIMPLE_MUL

 *     10  |  0x0068  |  31: 0  |  0xffffffff  ||  REG_SHIFT

 *     11  |  0x006c  |  31: 0  |  0xffffffff  ||  REG_LEN
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
   #define REG_INSTREAM0_ADDR           0x40
   #define REG_INSTREAM1_ADDR           0x44
   #define REG_INSTREAM2_ADDR           0x48

// Output master ports
   #define REG_OUTSTREAM0_ADDR           0x4c

/* Standard registers archi */

#define REG_NB_ITER                         0x50

#define REG_LINESTRIDE                0x54

#define REG_TILESTRIDE                0x58

#define REG_CNT_LIMIT_OUTSTREAM0           0x5c

/* Custom registers archi */
#define REG_REG_SIMPLE_MUL           0x60
#define REG_REG_SHIFT           0x64
#define REG_REG_LEN           0x68
#define REG_ID_CONFIGURATION		0x6c

/* Address generator archi */

// Input stream - inStream0 (programmable)
#define REG_INSTREAM0_TRANS_SIZE                  0x70
#define REG_INSTREAM0_LINE_STRIDE                 0x74
#define REG_INSTREAM0_LINE_LENGTH                 0x78
#define REG_INSTREAM0_FEAT_STRIDE                 0x7c
#define REG_INSTREAM0_FEAT_LENGTH                 0x80
#define REG_INSTREAM0_FEAT_ROLL                   0x84
#define REG_INSTREAM0_LOOP_OUTER                  0x88
#define REG_INSTREAM0_REALIGN_TYPE                0x8c
#define REG_INSTREAM0_STEP                        0x90

// Input stream - inStream1 (programmable)
#define REG_INSTREAM1_TRANS_SIZE                  0x94
#define REG_INSTREAM1_LINE_STRIDE                 0x98
#define REG_INSTREAM1_LINE_LENGTH                 0x9c
#define REG_INSTREAM1_FEAT_STRIDE                 0xa0
#define REG_INSTREAM1_FEAT_LENGTH                 0xa4
#define REG_INSTREAM1_FEAT_ROLL                   0xa8
#define REG_INSTREAM1_LOOP_OUTER                  0xac
#define REG_INSTREAM1_REALIGN_TYPE                0xb0
#define REG_INSTREAM1_STEP                        0xb4

// Input stream - inStream2 (programmable)
#define REG_INSTREAM2_TRANS_SIZE                  0xb8
#define REG_INSTREAM2_LINE_STRIDE                 0xbc
#define REG_INSTREAM2_LINE_LENGTH                 0xc0
#define REG_INSTREAM2_FEAT_STRIDE                 0xc4
#define REG_INSTREAM2_FEAT_LENGTH                 0xc8
#define REG_INSTREAM2_FEAT_ROLL                   0xcc
#define REG_INSTREAM2_LOOP_OUTER                  0xd0
#define REG_INSTREAM2_REALIGN_TYPE                0xd4
#define REG_INSTREAM2_STEP                        0xd8

// Input stream - outStream0 (programmable)
#define REG_OUTSTREAM0_TRANS_SIZE                  0xdc
#define REG_OUTSTREAM0_LINE_STRIDE                 0xe0
#define REG_OUTSTREAM0_LINE_LENGTH                 0xe4
#define REG_OUTSTREAM0_FEAT_STRIDE                 0xe8
#define REG_OUTSTREAM0_FEAT_LENGTH                 0xec
#define REG_OUTSTREAM0_FEAT_ROLL                   0xf0
#define REG_OUTSTREAM0_LOOP_OUTER                  0xf4
#define REG_OUTSTREAM0_REALIGN_TYPE                0xf8
#define REG_OUTSTREAM0_STEP                        0xfc

#endif
