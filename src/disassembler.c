#include "disassembler.h"

int main(int argc, char *argv[]) {

    int fd = open(argv[1], O_RDWR, 644);

    if (!fd) {
        printf("Failed to read file\n");
    }

    u8 inst_buf[4];
    ssize_t bytes_read; 

    out_buf_t *out_buf;

    printf("bits 16\n");

    int offset = 0;
    int curr_bytes = 0;
    
    while ((bytes_read = read(fd, inst_buf, sizeof(inst_buf))) > 0) {
        curr_bytes += 4; 

        if (inst_buf[0]&RM_REG_mask == 0x88) {

            offset = rm_to_reg(inst_buf);

        } else if (inst_buf[0]&IMM_REG_mask == 0xB0) {
            
            offset = imm_reg(inst_buf);

        } else {
            printf("Misread bytes\n");
        }

        if (offset) {
            lseek(fd, SEEK_SET, curr_bytes - offset);
        }

    }

    return 0;
}

int rm_to_reg(u8 *inst) {

    u8 D = ((u8)inst_buf[0]&D_mask) >> 1;    

    u8 W = (u8)inst_buf[0]&W_mask;

    u8 MOD = ((u8)inst_buf[1]&MOD_mask) >> 6;

    u8 reg = ((u8)inst_buf[1]&reg_mask) >> 3;

    u8 rm = ((u8)inst_buf[1]&rm_mask);

    if (W) {
        printf("mov %s, %s\n", reg_table[rm][W], reg_table[reg][W]); 
    } else {
        printf("mov %s, %s\n", reg_table[reg][W], reg_table[rm][W]); 
    }

    return W;
}

int imm_reg(u8 *inst) {

    u8 W = ((u8)inst[0]&W_imm_mask) >> 3;
    u8 reg = ((u8)inst[0]&reg_imm_mask);

    if (W) {
        s16 data = inst[1];
        data = data << 8;
        data = data|inst[2];
        printf("mov %s, %d\n", reg_table[reg][W], data);
    } else {
        s8 data = inst[1];
        printf("mov %s, %d\n", reg_table[reg][W], data);
    }

    return W;
}

    

    

