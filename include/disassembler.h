#ifndef DISASSEMBLER_H
#define DISASSEMBLER_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>

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
    [0b000] = {"AL", "AX"},
    [0b001] = {"CL", "CX"},
    [0b010] = {"DL", "DX"},
    [0b011] = {"BL", "BX"},
    [0b100] = {"AH", "SP"},
    [0b101] = {"CH", "BP"},
    [0b110] = {"DH", "SI"},
    [0b111] = {"BH", "DI"},
};

#define BIT(n) (1U << n)

#define D_mask BIT(2)

#define MOD_mask (BIT(8)|BIT(7))

#define reg_mask (BIT(6)|BIT(5)|BIT(4))

#define rm_mask (BIT(3)|BIT(2)|BIT(1))

#define W_mask 1
#endif
