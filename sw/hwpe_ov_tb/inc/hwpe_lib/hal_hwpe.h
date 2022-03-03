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

#ifndef __HAL_HWPE_H__
#define __HAL_HWPE_H__

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
 * ================================================================================
 *
 */

#define HWPE_ADDR_BASE ARCHI_FC_HWPE_ADDR
#define HWPE_ADDR_SPACE 0x00000100

// For all the following functions we use __builtin_pulp_OffsetedWrite and __builtin_pulp_OffsetedRead
// instead of classic load/store because otherwise the compiler is not able to correctly factorize
// the HWPE base in case several accesses are done, ending up with twice more code

// #define HWPE_WRITE(value, offset) *(volatile int *)(ARCHI_HWPE_ADDR_BASE + offset) = value
// #define HWPE_READ(offset) *(volatile int *)(ARCHI_HWPE_ADDR_BASE + offset)

#define hwpe_write32(add, val_) (*(volatile unsigned int *)(long)(add) = val_)

static inline uint32_t hwpe_read32(uint32_t add)
{
  __asm__ __volatile__ ("" : : : "memory");
  uint32_t result = *(volatile uint32_t *)add;
  asm volatile("nop;");
  __asm__ __volatile__ ("" : : : "memory");
  return result;
}

#define HWPE_WRITE(value, offset) hwpe_write32(ARCHI_HWPE_ADDR_BASE + (offset), (value))
#define HWPE_READ(offset) hwpe_read32(ARCHI_HWPE_ADDR_BASE + (offset))

/* uloop hal */

static inline void hwpe_nb_iter_set(unsigned int value) {
  HWPE_WRITE(value, FIR_128_MDC_REG_NB_ITER);
}

static inline void hwpe_linestride_set(unsigned int value) {
  HWPE_WRITE(value, FIR_128_MDC_REG_LINESTRIDE);
}

static inline void hwpe_tilestride_set(unsigned int value) {
  HWPE_WRITE(value, FIR_128_MDC_REG_TILESTRIDE);
}

static inline void hwpe_len_iter_set_y_V(unsigned int value) {
  HWPE_WRITE(value, FIR_128_MDC_REG_CNT_LIMIT_Y_V);
}

/* address generator hal - inputs */
static inline void hwpe_addr_gen_x_V(
  unsigned int x_V_trans_size,
  unsigned int x_V_line_stride,
  unsigned int x_V_line_length,
  unsigned int x_V_feat_stride,
  unsigned int x_V_feat_length,
  unsigned int x_V_feat_roll,
  unsigned int x_V_loop_outer,
  unsigned int x_V_realign_type,
  unsigned int x_V_step)
{
  HWPE_WRITE(x_V_trans_size,    FIR_128_MDC_REG_X_V_TRANS_SIZE  );
  HWPE_WRITE(x_V_line_stride,   FIR_128_MDC_REG_X_V_LINE_STRIDE );
  HWPE_WRITE(x_V_line_length,   FIR_128_MDC_REG_X_V_LINE_LENGTH );
  HWPE_WRITE(x_V_feat_stride,   FIR_128_MDC_REG_X_V_FEAT_STRIDE );
  HWPE_WRITE(x_V_feat_length,   FIR_128_MDC_REG_X_V_FEAT_LENGTH );
  HWPE_WRITE(x_V_feat_roll,     FIR_128_MDC_REG_X_V_FEAT_ROLL   );
  HWPE_WRITE(x_V_loop_outer,    FIR_128_MDC_REG_X_V_LOOP_OUTER  );
  HWPE_WRITE(x_V_realign_type,  FIR_128_MDC_REG_X_V_REALIGN_TYPE);
  HWPE_WRITE(x_V_step,          FIR_128_MDC_REG_X_V_STEP        );
}

/* address generator hal - outputs */
static inline void hwpe_addr_gen_y_V(
  unsigned int  y_V_trans_size,
  unsigned int  y_V_line_stride,
  unsigned int  y_V_line_length,
  unsigned int  y_V_feat_stride,
  unsigned int  y_V_feat_length,
  unsigned int  y_V_feat_roll,
  unsigned int  y_V_loop_outer,
  unsigned int  y_V_realign_type,
  unsigned int  y_V_step)
{
  HWPE_WRITE(y_V_trans_size,    FIR_128_MDC_REG_Y_V_TRANS_SIZE  );
  HWPE_WRITE(y_V_line_stride,   FIR_128_MDC_REG_Y_V_LINE_STRIDE );
  HWPE_WRITE(y_V_line_length,   FIR_128_MDC_REG_Y_V_LINE_LENGTH );
  HWPE_WRITE(y_V_feat_stride,   FIR_128_MDC_REG_Y_V_FEAT_STRIDE );
  HWPE_WRITE(y_V_feat_length,   FIR_128_MDC_REG_Y_V_FEAT_LENGTH );
  HWPE_WRITE(y_V_feat_roll,     FIR_128_MDC_REG_Y_V_FEAT_ROLL   );
  HWPE_WRITE(y_V_loop_outer,    FIR_128_MDC_REG_Y_V_LOOP_OUTER  );
  HWPE_WRITE(y_V_realign_type,  FIR_128_MDC_REG_Y_V_REALIGN_TYPE);
  HWPE_WRITE(y_V_step,          FIR_128_MDC_REG_Y_V_STEP        );
}

/* basic hal */

static inline void hwpe_trigger_job() {
  HWPE_WRITE(0, FIR_128_MDC_REG_TRIGGER);
}

static inline int hwpe_acquire_job() {
  return HWPE_READ(FIR_128_MDC_REG_ACQUIRE);
}

static inline unsigned int hwpe_get_status() {
  return HWPE_READ(FIR_128_MDC_REG_STATUS);
}

static inline void hwpe_soft_clear() {
  volatile int i;
  HWPE_WRITE(0, FIR_128_MDC_REG_SOFT_CLEAR);
}

static inline void hwpe_cg_enable() {
  return;
}

static inline void hwpe_cg_disable() {
  return;
}

static inline void hwpe_bytecode_set(unsigned int offs, unsigned int value) {
  HWPE_WRITE(value, FIR_128_MDC_REG_BYTECODE+offs);
}

/* tcdm master port hal */

// input x_V
static inline void hwpe_x_V_addr_set(int32_t value) {
  HWPE_WRITE(value, FIR_128_MDC_REG_X_V_ADDR);
}

// output y_V
static inline void hwpe_y_V_addr_set(int32_t value) {
  HWPE_WRITE(value, FIR_128_MDC_REG_Y_V_ADDR);
}

#endif /* __HAL_HWPE_H__ */

