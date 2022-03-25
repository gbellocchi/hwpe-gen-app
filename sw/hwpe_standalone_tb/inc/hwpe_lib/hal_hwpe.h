
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

static inline void hwpe_len_iter_set_outStream0(unsigned int value) {
  HWPE_WRITE(value, REG_CNT_LIMIT_OUTSTREAM0);
}

/* custom hal */
static inline void hwpe_reg_simple_mul_set(int32_t value) {
  HWPE_WRITE(value, REG_REG_SIMPLE_MUL );
}
static inline void hwpe_reg_shift_set(int8_t value) {
  HWPE_WRITE(value, REG_REG_SHIFT );
}
static inline void hwpe_reg_len_set(int16_t value) {
  HWPE_WRITE(value, REG_REG_LEN );
}
static inline void hwpe_ID_configuration_set(uint8_t value) {
  HWPE_WRITE(value, REG_ID_CONFIGURATION );
}

/* address generator hal - inStream0 */
static inline void hwpe_addr_gen_inStream0(
  unsigned int inStream0_trans_size,
  unsigned int inStream0_line_stride,
  unsigned int inStream0_line_length,
  unsigned int inStream0_feat_stride,
  unsigned int inStream0_feat_length,
  unsigned int inStream0_feat_roll,
  unsigned int inStream0_loop_outer,
  unsigned int inStream0_realign_type,
  unsigned int inStream0_step)
{
  HWPE_WRITE(inStream0_trans_size,    REG_INSTREAM0_TRANS_SIZE  );
  HWPE_WRITE(inStream0_line_stride,   REG_INSTREAM0_LINE_STRIDE );
  HWPE_WRITE(inStream0_line_length,   REG_INSTREAM0_LINE_LENGTH );
  HWPE_WRITE(inStream0_feat_stride,   REG_INSTREAM0_FEAT_STRIDE );
  HWPE_WRITE(inStream0_feat_length,   REG_INSTREAM0_FEAT_LENGTH );
  HWPE_WRITE(inStream0_feat_roll,     REG_INSTREAM0_FEAT_ROLL   );
  HWPE_WRITE(inStream0_loop_outer,    REG_INSTREAM0_LOOP_OUTER  );
  HWPE_WRITE(inStream0_realign_type,  REG_INSTREAM0_REALIGN_TYPE);
  HWPE_WRITE(inStream0_step,          REG_INSTREAM0_STEP        );
}
/* address generator hal - inStream1 */
static inline void hwpe_addr_gen_inStream1(
  unsigned int inStream1_trans_size,
  unsigned int inStream1_line_stride,
  unsigned int inStream1_line_length,
  unsigned int inStream1_feat_stride,
  unsigned int inStream1_feat_length,
  unsigned int inStream1_feat_roll,
  unsigned int inStream1_loop_outer,
  unsigned int inStream1_realign_type,
  unsigned int inStream1_step)
{
  HWPE_WRITE(inStream1_trans_size,    REG_INSTREAM1_TRANS_SIZE  );
  HWPE_WRITE(inStream1_line_stride,   REG_INSTREAM1_LINE_STRIDE );
  HWPE_WRITE(inStream1_line_length,   REG_INSTREAM1_LINE_LENGTH );
  HWPE_WRITE(inStream1_feat_stride,   REG_INSTREAM1_FEAT_STRIDE );
  HWPE_WRITE(inStream1_feat_length,   REG_INSTREAM1_FEAT_LENGTH );
  HWPE_WRITE(inStream1_feat_roll,     REG_INSTREAM1_FEAT_ROLL   );
  HWPE_WRITE(inStream1_loop_outer,    REG_INSTREAM1_LOOP_OUTER  );
  HWPE_WRITE(inStream1_realign_type,  REG_INSTREAM1_REALIGN_TYPE);
  HWPE_WRITE(inStream1_step,          REG_INSTREAM1_STEP        );
}
/* address generator hal - inStream2 */
static inline void hwpe_addr_gen_inStream2(
  unsigned int inStream2_trans_size,
  unsigned int inStream2_line_stride,
  unsigned int inStream2_line_length,
  unsigned int inStream2_feat_stride,
  unsigned int inStream2_feat_length,
  unsigned int inStream2_feat_roll,
  unsigned int inStream2_loop_outer,
  unsigned int inStream2_realign_type,
  unsigned int inStream2_step)
{
  HWPE_WRITE(inStream2_trans_size,    REG_INSTREAM2_TRANS_SIZE  );
  HWPE_WRITE(inStream2_line_stride,   REG_INSTREAM2_LINE_STRIDE );
  HWPE_WRITE(inStream2_line_length,   REG_INSTREAM2_LINE_LENGTH );
  HWPE_WRITE(inStream2_feat_stride,   REG_INSTREAM2_FEAT_STRIDE );
  HWPE_WRITE(inStream2_feat_length,   REG_INSTREAM2_FEAT_LENGTH );
  HWPE_WRITE(inStream2_feat_roll,     REG_INSTREAM2_FEAT_ROLL   );
  HWPE_WRITE(inStream2_loop_outer,    REG_INSTREAM2_LOOP_OUTER  );
  HWPE_WRITE(inStream2_realign_type,  REG_INSTREAM2_REALIGN_TYPE);
  HWPE_WRITE(inStream2_step,          REG_INSTREAM2_STEP        );
}
/* address generator hal - outStream0 */
static inline void hwpe_addr_gen_outStream0(
  unsigned int outStream0_trans_size,
  unsigned int outStream0_line_stride,
  unsigned int outStream0_line_length,
  unsigned int outStream0_feat_stride,
  unsigned int outStream0_feat_length,
  unsigned int outStream0_feat_roll,
  unsigned int outStream0_loop_outer,
  unsigned int outStream0_realign_type,
  unsigned int outStream0_step)
{
  HWPE_WRITE(outStream0_trans_size,    REG_OUTSTREAM0_TRANS_SIZE  );
  HWPE_WRITE(outStream0_line_stride,   REG_OUTSTREAM0_LINE_STRIDE );
  HWPE_WRITE(outStream0_line_length,   REG_OUTSTREAM0_LINE_LENGTH );
  HWPE_WRITE(outStream0_feat_stride,   REG_OUTSTREAM0_FEAT_STRIDE );
  HWPE_WRITE(outStream0_feat_length,   REG_OUTSTREAM0_FEAT_LENGTH );
  HWPE_WRITE(outStream0_feat_roll,     REG_OUTSTREAM0_FEAT_ROLL   );
  HWPE_WRITE(outStream0_loop_outer,    REG_OUTSTREAM0_LOOP_OUTER  );
  HWPE_WRITE(outStream0_realign_type,  REG_OUTSTREAM0_REALIGN_TYPE);
  HWPE_WRITE(outStream0_step,          REG_OUTSTREAM0_STEP        );
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

// input inStream0
static inline void hwpe_inStream0_addr_set(uint32_t value) {
  HWPE_WRITE(value, REG_INSTREAM0_ADDR);
}
// input inStream1
static inline void hwpe_inStream1_addr_set(uint32_t value) {
  HWPE_WRITE(value, REG_INSTREAM1_ADDR);
}
// input inStream2
static inline void hwpe_inStream2_addr_set(uint32_t value) {
  HWPE_WRITE(value, REG_INSTREAM2_ADDR);
}

// output outStream0
static inline void hwpe_outStream0_addr_set(uint32_t value) {
  HWPE_WRITE(value, REG_OUTSTREAM0_ADDR);
}

#endif /* __HAL_HWPE_H__ */

