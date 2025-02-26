#include <stdio.h>

int main(int argc, char *argv[]) {

    FILE *fs = fopen(argv[1], "rw+");

    if (!fs) {
        printf("Failed to read file\n");
    }

    char inst_buf[2];

    size_t bytes_read = fread(inst_buf, sizeof(inst_buf), 1, fs);

    if (bytes_read) {

        printf("Failed to read bytes %d\n", bytes_read);
        feof(bytes_read);
    }
    

    return 0;
}
