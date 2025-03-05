#include "disassembler.h"

int main(int argc, char *argv[]) {

    int fd = open(argv[1], O_RDWR, 644);

    if (!fd) {
        printf("Failed to read file\n");
    }

    u8 inst_buf[2];
    ssize_t bytes_read; 

    out_buf_t *out_buf;

    printf("bits 16\n");

    out_buf->curr_p = malloc(4096); 
    out_buf->start_p = out_buf->curr_p;
    
    while ((bytes_read = read(fd, inst_buf, sizeof(inst_buf))) > 0) {

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

    }

    return 0;
}
