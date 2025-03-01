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

        u8 D = (int)inst_buf[0]&D_mask;    

        u8 W = (int)inst_buf[0]&W_mask;

        u8 MOD = (int)inst_buf[1]&MOD_mask;

        u8 reg = (int)inst_buf[1]&reg_mask;

        u8 rm = (int)inst_buf[1]&rm_mask;

        if (W) {
            sprintf(out_buf->curr_p, "MOV %s, %s\n", reg_table[reg][W], reg_table[rm][W]); 
        } else {
            sprintf(out_buf->curr_p, "MOV %s, %s\n", reg_table[rm][W], reg_table[reg][W]); 
        }

        out_buf->curr_p += 11;
    }

    out_buf->curr_p = '\0';
    int size = out_buf->curr_p - out_buf->start_p;
    
    write(1, out_buf->start_p, size); 
    return 0;
}
