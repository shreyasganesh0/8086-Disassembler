#ifndef DISASSEMBLER_H
#define DISASSEMBLER_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>

typedef uint8_t  u8; 
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

typedef int8_t s8;
typedef int16_t s16;
typedef int32_t s32;
typedef int64_t s64;

typedef int32_t b32;


char reg_table[][2][3] = {
    [0] = {"al", "ax"},
    [1] = {"cl", "cx"},
    [2] = {"dl", "dx"},
    [3] = {"bl", "bx"},
    [4] = {"ah", "sp"},
    [5] = {"ch", "bp"},
    [6] = {"dh", "si"},
    [7] = {"bh", "di"},
};

typedef enum {
    RM_REG,
    IMM_REG,
} inst_name;

typedef struct {
    inst_name type;
    u8 *inst_buf;
} inst_t;


typedef struct {
    char *start_p;
    char *curr_p;
} out_buf_t;

#define BIT(n) (1 << n)

#define D_mask BIT(1)

#define MOD_mask (BIT(7)|BIT(6))

#define reg_mask (BIT(5)|BIT(4)|BIT(3))

#define rm_mask (BIT(2)|BIT(1)|BIT(0))

#define W_mask 1

#define W_imm_mask (BIT(3))

#define REG_imm_mask (BIT(2)|BIT(1)|1)

#define RM_REG_mask (BIT(7)|BIT(3))

#define IMM_REG_mask (BIT(7)|BIT(5)|BIT(4))
#endif
