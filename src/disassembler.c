#include <stdio.h>

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

int main(int argc, char *argv[]) {

    FILE *fs = fopen(argv[1], "w+");

    if (!fs) {
        printf("Failed to read file\n");
    }

    u8 inst_buf[2];

    size_t bytes_read = fread(inst_buf, sizeof(inst_buf), 1, fs);

    if (bytes_read) {

        printf("Failed to read bytes %d\n", bytes_read);
        feof(bytes_read);
    }

    
    

    return 0;
}
