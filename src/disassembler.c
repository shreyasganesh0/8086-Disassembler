#include <unistd.h>

int main(int argc, char *argv[]) {

    int fd = open(argv[1], "w+");

    if (!fd) {
        printf("Failed to read file\n");
    }

    u8 inst_buf[2];
    ssize_t bytes_read; 

    printf("bits 16\n");

   char *out_buf = malloc(NULL, 4096, PROT_READ|PROT_WRITE, MAP_ANON, -1, 0);
    
    while (byte_read = read(fd, inst_buf, sizeof(inst_buf)) > 0) {

        u8 D = inst_buf[0] & D_mask;    

        u8 W = inst_buf[0] & W_mask;

        u8 MOD = inst_buf[1] & MOD_mask;

        u8 reg = inst_buf[1] & reg_mask;

        u8 rm = inst_buf[1] & rm_mask;

        if (W) {
            sprintf(out_buf, "MOV %s, %s\n", reg_table[reg], reg_table[rm]); 
        } else {
            sprintf(out_buf, "MOV %s, %s\n", reg_table[rm], reg_table[reg]); 
        }
    }
    out_buf

    if (bytes_read) {

        printf("Failed to read bytes %d\n", bytes_read);
    }

    return 0;
}
