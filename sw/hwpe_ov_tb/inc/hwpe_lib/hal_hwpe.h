
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

static inline void hwpe_len_iter_set_chiped_text(unsigned int value) {
  HWPE_WRITE(value, REG_CNT_LIMIT_CHIPED_TEXT);
}

/* custom hal */

/* address generator hal - text */
static inline void hwpe_addr_gen_text(
  unsigned int text_trans_size,
  unsigned int text_line_stride,
  unsigned int text_line_length,
  unsigned int text_feat_stride,
  unsigned int text_feat_length,
  unsigned int text_feat_roll,
  unsigned int text_loop_outer,
  unsigned int text_realign_type,
  unsigned int text_step)
{
  HWPE_WRITE(text_trans_size,    REG_TEXT_TRANS_SIZE  );
  HWPE_WRITE(text_line_stride,   REG_TEXT_LINE_STRIDE );
  HWPE_WRITE(text_line_length,   REG_TEXT_LINE_LENGTH );
  HWPE_WRITE(text_feat_stride,   REG_TEXT_FEAT_STRIDE );
  HWPE_WRITE(text_feat_length,   REG_TEXT_FEAT_LENGTH );
  HWPE_WRITE(text_feat_roll,     REG_TEXT_FEAT_ROLL   );
  HWPE_WRITE(text_loop_outer,    REG_TEXT_LOOP_OUTER  );
  HWPE_WRITE(text_realign_type,  REG_TEXT_REALIGN_TYPE);
  HWPE_WRITE(text_step,          REG_TEXT_STEP        );
}
/* address generator hal - key */
static inline void hwpe_addr_gen_key(
  unsigned int key_trans_size,
  unsigned int key_line_stride,
  unsigned int key_line_length,
  unsigned int key_feat_stride,
  unsigned int key_feat_length,
  unsigned int key_feat_roll,
  unsigned int key_loop_outer,
  unsigned int key_realign_type,
  unsigned int key_step)
{
  HWPE_WRITE(key_trans_size,    REG_KEY_TRANS_SIZE  );
  HWPE_WRITE(key_line_stride,   REG_KEY_LINE_STRIDE );
  HWPE_WRITE(key_line_length,   REG_KEY_LINE_LENGTH );
  HWPE_WRITE(key_feat_stride,   REG_KEY_FEAT_STRIDE );
  HWPE_WRITE(key_feat_length,   REG_KEY_FEAT_LENGTH );
  HWPE_WRITE(key_feat_roll,     REG_KEY_FEAT_ROLL   );
  HWPE_WRITE(key_loop_outer,    REG_KEY_LOOP_OUTER  );
  HWPE_WRITE(key_realign_type,  REG_KEY_REALIGN_TYPE);
  HWPE_WRITE(key_step,          REG_KEY_STEP        );
}
/* address generator hal - rc */
static inline void hwpe_addr_gen_rc(
  unsigned int rc_trans_size,
  unsigned int rc_line_stride,
  unsigned int rc_line_length,
  unsigned int rc_feat_stride,
  unsigned int rc_feat_length,
  unsigned int rc_feat_roll,
  unsigned int rc_loop_outer,
  unsigned int rc_realign_type,
  unsigned int rc_step)
{
  HWPE_WRITE(rc_trans_size,    REG_RC_TRANS_SIZE  );
  HWPE_WRITE(rc_line_stride,   REG_RC_LINE_STRIDE );
  HWPE_WRITE(rc_line_length,   REG_RC_LINE_LENGTH );
  HWPE_WRITE(rc_feat_stride,   REG_RC_FEAT_STRIDE );
  HWPE_WRITE(rc_feat_length,   REG_RC_FEAT_LENGTH );
  HWPE_WRITE(rc_feat_roll,     REG_RC_FEAT_ROLL   );
  HWPE_WRITE(rc_loop_outer,    REG_RC_LOOP_OUTER  );
  HWPE_WRITE(rc_realign_type,  REG_RC_REALIGN_TYPE);
  HWPE_WRITE(rc_step,          REG_RC_STEP        );
}
/* address generator hal - chiped_text */
static inline void hwpe_addr_gen_chiped_text(
  unsigned int chiped_text_trans_size,
  unsigned int chiped_text_line_stride,
  unsigned int chiped_text_line_length,
  unsigned int chiped_text_feat_stride,
  unsigned int chiped_text_feat_length,
  unsigned int chiped_text_feat_roll,
  unsigned int chiped_text_loop_outer,
  unsigned int chiped_text_realign_type,
  unsigned int chiped_text_step)
{
  HWPE_WRITE(chiped_text_trans_size,    REG_CHIPED_TEXT_TRANS_SIZE  );
  HWPE_WRITE(chiped_text_line_stride,   REG_CHIPED_TEXT_LINE_STRIDE );
  HWPE_WRITE(chiped_text_line_length,   REG_CHIPED_TEXT_LINE_LENGTH );
  HWPE_WRITE(chiped_text_feat_stride,   REG_CHIPED_TEXT_FEAT_STRIDE );
  HWPE_WRITE(chiped_text_feat_length,   REG_CHIPED_TEXT_FEAT_LENGTH );
  HWPE_WRITE(chiped_text_feat_roll,     REG_CHIPED_TEXT_FEAT_ROLL   );
  HWPE_WRITE(chiped_text_loop_outer,    REG_CHIPED_TEXT_LOOP_OUTER  );
  HWPE_WRITE(chiped_text_realign_type,  REG_CHIPED_TEXT_REALIGN_TYPE);
  HWPE_WRITE(chiped_text_step,          REG_CHIPED_TEXT_STEP        );
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

// input text
static inline void hwpe_text_addr_set(uint32_t value) {
  HWPE_WRITE(value, REG_TEXT_ADDR);
}
// input key
static inline void hwpe_key_addr_set(uint32_t value) {
  HWPE_WRITE(value, REG_KEY_ADDR);
}
// input rc
static inline void hwpe_rc_addr_set(uint32_t value) {
  HWPE_WRITE(value, REG_RC_ADDR);
}

// output chiped_text
static inline void hwpe_chiped_text_addr_set(uint32_t value) {
  HWPE_WRITE(value, REG_CHIPED_TEXT_ADDR);
}

#endif /* __HAL_HWPE_H__ */

