
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
 *     0  |  0x0040  |  31: 0  |  0xffffffff  ||  IN1_ADDR
 *     1  |  0x0044  |  31: 0  |  0xffffffff  ||  IN2_ADDR
 *     2  |  0x0048  |  31: 0  |  0xffffffff  ||  OUT_R_ADDR

 *     3  |  0x004c  |  31: 0  |  0xffffffff  ||  NB_ITER
 *     4  |  0x0050  |  31: 0  |  0xffffffff  ||  LEN_ITER
 *     5  |  0x0054  |  31:16  |  0xffff0000  ||  SHIFT
 *        |          |   0: 0  |  0x00000001  ||  SIMPLEMUL
 *     6  |  0x0058  |  31: 0  |  0xffffffff  ||  VECTSTRIDE
 *     7  |  0x005c  |  31: 0  |  0xffffffff  ||  VECTSTRIDE2
 *
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
  HWPE_WRITE(value, REG_NB_ITER);
}

static inline void hwpe_linestride_set(unsigned int value) {
  HWPE_WRITE(value, REG_LINESTRIDE);
}

static inline void hwpe_tilestride_set(unsigned int value) {
  HWPE_WRITE(value, REG_TILESTRIDE);
}

static inline void hwpe_len_iter_set_out_r(unsigned int value) {
  HWPE_WRITE(value, REG_CNT_LIMIT_OUT_R);
}

/* custom hal */

/* address generator hal - in1 */
static inline void hwpe_addr_gen_in1(
  unsigned int in1_trans_size,
  unsigned int in1_line_stride,
  unsigned int in1_line_length,
  unsigned int in1_feat_stride,
  unsigned int in1_feat_length,
  unsigned int in1_feat_roll,
  unsigned int in1_loop_outer,
  unsigned int in1_realign_type,
  unsigned int in1_step)
{
  HWPE_WRITE(in1_trans_size,    REG_IN1_TRANS_SIZE  );
  HWPE_WRITE(in1_line_stride,   REG_IN1_LINE_STRIDE );
  HWPE_WRITE(in1_line_length,   REG_IN1_LINE_LENGTH );
  HWPE_WRITE(in1_feat_stride,   REG_IN1_FEAT_STRIDE );
  HWPE_WRITE(in1_feat_length,   REG_IN1_FEAT_LENGTH );
  HWPE_WRITE(in1_feat_roll,     REG_IN1_FEAT_ROLL   );
  HWPE_WRITE(in1_loop_outer,    REG_IN1_LOOP_OUTER  );
  HWPE_WRITE(in1_realign_type,  REG_IN1_REALIGN_TYPE);
  HWPE_WRITE(in1_step,          REG_IN1_STEP        );
}
/* address generator hal - in2 */
static inline void hwpe_addr_gen_in2(
  unsigned int in2_trans_size,
  unsigned int in2_line_stride,
  unsigned int in2_line_length,
  unsigned int in2_feat_stride,
  unsigned int in2_feat_length,
  unsigned int in2_feat_roll,
  unsigned int in2_loop_outer,
  unsigned int in2_realign_type,
  unsigned int in2_step)
{
  HWPE_WRITE(in2_trans_size,    REG_IN2_TRANS_SIZE  );
  HWPE_WRITE(in2_line_stride,   REG_IN2_LINE_STRIDE );
  HWPE_WRITE(in2_line_length,   REG_IN2_LINE_LENGTH );
  HWPE_WRITE(in2_feat_stride,   REG_IN2_FEAT_STRIDE );
  HWPE_WRITE(in2_feat_length,   REG_IN2_FEAT_LENGTH );
  HWPE_WRITE(in2_feat_roll,     REG_IN2_FEAT_ROLL   );
  HWPE_WRITE(in2_loop_outer,    REG_IN2_LOOP_OUTER  );
  HWPE_WRITE(in2_realign_type,  REG_IN2_REALIGN_TYPE);
  HWPE_WRITE(in2_step,          REG_IN2_STEP        );
}
/* address generator hal - out_r */
static inline void hwpe_addr_gen_out_r(
  unsigned int out_r_trans_size,
  unsigned int out_r_line_stride,
  unsigned int out_r_line_length,
  unsigned int out_r_feat_stride,
  unsigned int out_r_feat_length,
  unsigned int out_r_feat_roll,
  unsigned int out_r_loop_outer,
  unsigned int out_r_realign_type,
  unsigned int out_r_step)
{
  HWPE_WRITE(out_r_trans_size,    REG_OUT_R_TRANS_SIZE  );
  HWPE_WRITE(out_r_line_stride,   REG_OUT_R_LINE_STRIDE );
  HWPE_WRITE(out_r_line_length,   REG_OUT_R_LINE_LENGTH );
  HWPE_WRITE(out_r_feat_stride,   REG_OUT_R_FEAT_STRIDE );
  HWPE_WRITE(out_r_feat_length,   REG_OUT_R_FEAT_LENGTH );
  HWPE_WRITE(out_r_feat_roll,     REG_OUT_R_FEAT_ROLL   );
  HWPE_WRITE(out_r_loop_outer,    REG_OUT_R_LOOP_OUTER  );
  HWPE_WRITE(out_r_realign_type,  REG_OUT_R_REALIGN_TYPE);
  HWPE_WRITE(out_r_step,          REG_OUT_R_STEP        );
}

/* basic hal */

static inline void hwpe_trigger_job() {
  HWPE_WRITE(0, REG_TRIGGER);
}

static inline int hwpe_acquire_job() {
  return HWPE_READ(REG_ACQUIRE);
}

static inline unsigned int hwpe_get_status() {
  return HWPE_READ(REG_STATUS);
}

static inline void hwpe_soft_clear() {
  volatile int i;
  HWPE_WRITE(0, REG_SOFT_CLEAR);
}

static inline void hwpe_cg_enable() {
  return;
}

static inline void hwpe_cg_disable() {
  return;
}

static inline void hwpe_bytecode_set(unsigned int offs, unsigned int value) {
  HWPE_WRITE(value, REG_BYTECODE+offs);
}

/* tcdm master port hal */

// input in1
static inline void hwpe_in1_addr_set(int32_t value) {
  HWPE_WRITE(value, REG_IN1_ADDR);
}
// input in2
static inline void hwpe_in2_addr_set(int32_t value) {
  HWPE_WRITE(value, REG_IN2_ADDR);
}

// output out_r
static inline void hwpe_out_r_addr_set(int32_t value) {
  HWPE_WRITE(value, REG_OUT_R_ADDR);
}

#endif /* __HAL_HWPE_H__ */

