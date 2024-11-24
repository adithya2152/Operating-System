#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: custom_mv <source> <destination>\n");
        return 1;
    }

    if (rename(argv[1], argv[2]) != 0) {
        perror("custom_mv: Error moving file");
        return 1;
    }

    return 0;
}
