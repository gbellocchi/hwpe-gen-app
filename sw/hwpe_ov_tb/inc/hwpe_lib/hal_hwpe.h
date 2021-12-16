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
  HWPE_WRITE(value, MUL_MDC_REG_NB_ITER);
}

static inline void hwpe_linestride_set(unsigned int value) {
  HWPE_WRITE(value, MUL_MDC_REG_LINESTRIDE);
}

static inline void hwpe_tilestride_set(unsigned int value) {
  HWPE_WRITE(value, MUL_MDC_REG_TILESTRIDE);
}

static inline void hwpe_len_iter_set_d(unsigned int value) {
  HWPE_WRITE(value, MUL_MDC_REG_CNT_LIMIT_D);
}

/* custom hal */
static inline void hwpe_reg_simple_mul_set(int value) {
  HWPE_WRITE(value, MUL_MDC_REG_REG_SIMPLE_MUL );
}
static inline void hwpe_reg_shift_set(int8_t value) {
  HWPE_WRITE(value, MUL_MDC_REG_REG_SHIFT );
}
static inline void hwpe_reg_len_set(int16_t value) {
  HWPE_WRITE(value, MUL_MDC_REG_REG_LEN );
}

/* address generator hal - inputs */
static inline void hwpe_addr_gen_a(
  unsigned int a_trans_size,
  unsigned int a_line_stride,
  unsigned int a_line_length,
  unsigned int a_feat_stride,
  unsigned int a_feat_length,
  unsigned int a_feat_roll,
  unsigned int a_loop_outer,
  unsigned int a_realign_type,
  unsigned int a_step)
{
  HWPE_WRITE(a_trans_size,    MUL_MDC_REG_A_TRANS_SIZE  );
  HWPE_WRITE(a_line_stride,   MUL_MDC_REG_A_LINE_STRIDE );
  HWPE_WRITE(a_line_length,   MUL_MDC_REG_A_LINE_LENGTH );
  HWPE_WRITE(a_feat_stride,   MUL_MDC_REG_A_FEAT_STRIDE );
  HWPE_WRITE(a_feat_length,   MUL_MDC_REG_A_FEAT_LENGTH );
  HWPE_WRITE(a_feat_roll,     MUL_MDC_REG_A_FEAT_ROLL   );
  HWPE_WRITE(a_loop_outer,    MUL_MDC_REG_A_LOOP_OUTER  );
  HWPE_WRITE(a_realign_type,  MUL_MDC_REG_A_REALIGN_TYPE);
  HWPE_WRITE(a_step,          MUL_MDC_REG_A_STEP        );
}
/* address generator hal - inputs */
static inline void hwpe_addr_gen_b(
  unsigned int b_trans_size,
  unsigned int b_line_stride,
  unsigned int b_line_length,
  unsigned int b_feat_stride,
  unsigned int b_feat_length,
  unsigned int b_feat_roll,
  unsigned int b_loop_outer,
  unsigned int b_realign_type,
  unsigned int b_step)
{
  HWPE_WRITE(b_trans_size,    MUL_MDC_REG_B_TRANS_SIZE  );
  HWPE_WRITE(b_line_stride,   MUL_MDC_REG_B_LINE_STRIDE );
  HWPE_WRITE(b_line_length,   MUL_MDC_REG_B_LINE_LENGTH );
  HWPE_WRITE(b_feat_stride,   MUL_MDC_REG_B_FEAT_STRIDE );
  HWPE_WRITE(b_feat_length,   MUL_MDC_REG_B_FEAT_LENGTH );
  HWPE_WRITE(b_feat_roll,     MUL_MDC_REG_B_FEAT_ROLL   );
  HWPE_WRITE(b_loop_outer,    MUL_MDC_REG_B_LOOP_OUTER  );
  HWPE_WRITE(b_realign_type,  MUL_MDC_REG_B_REALIGN_TYPE);
  HWPE_WRITE(b_step,          MUL_MDC_REG_B_STEP        );
}
/* address generator hal - inputs */
static inline void hwpe_addr_gen_c(
  unsigned int c_trans_size,
  unsigned int c_line_stride,
  unsigned int c_line_length,
  unsigned int c_feat_stride,
  unsigned int c_feat_length,
  unsigned int c_feat_roll,
  unsigned int c_loop_outer,
  unsigned int c_realign_type,
  unsigned int c_step)
{
  HWPE_WRITE(c_trans_size,    MUL_MDC_REG_C_TRANS_SIZE  );
  HWPE_WRITE(c_line_stride,   MUL_MDC_REG_C_LINE_STRIDE );
  HWPE_WRITE(c_line_length,   MUL_MDC_REG_C_LINE_LENGTH );
  HWPE_WRITE(c_feat_stride,   MUL_MDC_REG_C_FEAT_STRIDE );
  HWPE_WRITE(c_feat_length,   MUL_MDC_REG_C_FEAT_LENGTH );
  HWPE_WRITE(c_feat_roll,     MUL_MDC_REG_C_FEAT_ROLL   );
  HWPE_WRITE(c_loop_outer,    MUL_MDC_REG_C_LOOP_OUTER  );
  HWPE_WRITE(c_realign_type,  MUL_MDC_REG_C_REALIGN_TYPE);
  HWPE_WRITE(c_step,          MUL_MDC_REG_C_STEP        );
}

/* address generator hal - outputs */
static inline void hwpe_addr_gen_d(
  unsigned int  d_trans_size,
  unsigned int  d_line_stride,
  unsigned int  d_line_length,
  unsigned int  d_feat_stride,
  unsigned int  d_feat_length,
  unsigned int  d_feat_roll,
  unsigned int  d_loop_outer,
  unsigned int  d_realign_type,
  unsigned int  d_step)
{
  HWPE_WRITE(d_trans_size,    MUL_MDC_REG_D_TRANS_SIZE  );
  HWPE_WRITE(d_line_stride,   MUL_MDC_REG_D_LINE_STRIDE );
  HWPE_WRITE(d_line_length,   MUL_MDC_REG_D_LINE_LENGTH );
  HWPE_WRITE(d_feat_stride,   MUL_MDC_REG_D_FEAT_STRIDE );
  HWPE_WRITE(d_feat_length,   MUL_MDC_REG_D_FEAT_LENGTH );
  HWPE_WRITE(d_feat_roll,     MUL_MDC_REG_D_FEAT_ROLL   );
  HWPE_WRITE(d_loop_outer,    MUL_MDC_REG_D_LOOP_OUTER  );
  HWPE_WRITE(d_realign_type,  MUL_MDC_REG_D_REALIGN_TYPE);
  HWPE_WRITE(d_step,          MUL_MDC_REG_D_STEP        );
}

/* basic hal */

static inline void hwpe_trigger_job() {
  HWPE_WRITE(0, MUL_MDC_REG_TRIGGER);
}

static inline int hwpe_acquire_job() {
  return HWPE_READ(MUL_MDC_REG_ACQUIRE);
}

static inline unsigned int hwpe_get_status() {
  return HWPE_READ(MUL_MDC_REG_STATUS);
}

static inline void hwpe_soft_clear() {
  volatile int i;
  HWPE_WRITE(0, MUL_MDC_REG_SOFT_CLEAR);
}

static inline void hwpe_cg_enable() {
  return;
}

static inline void hwpe_cg_disable() {
  return;
}

static inline void hwpe_bytecode_set(unsigned int offs, unsigned int value) {
  HWPE_WRITE(value, MUL_MDC_REG_BYTECODE+offs);
}

/* tcdm master port hal */

// input a
static inline void hwpe_a_addr_set(int32_t value) {
  HWPE_WRITE(value, MUL_MDC_REG_A_ADDR);
}
// input b
static inline void hwpe_b_addr_set(int32_t value) {
  HWPE_WRITE(value, MUL_MDC_REG_B_ADDR);
}
// input c
static inline void hwpe_c_addr_set(int32_t value) {
  HWPE_WRITE(value, MUL_MDC_REG_C_ADDR);
}

// output d
static inline void hwpe_d_addr_set(int32_t value) {
  HWPE_WRITE(value, MUL_MDC_REG_D_ADDR);
}

#endif /* __HAL_HWPE_H__ */

