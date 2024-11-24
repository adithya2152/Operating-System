#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Usage: custom_cp <source_file> <destination_file>\n");
        return 1;
    }

    char *src = argv[1];
    char *dest = argv[2];

    FILE *src_file = fopen(src, "r");
    if (src_file == NULL) {
        perror("custom_cp");
        return 1;
    }

    FILE *dest_file = fopen(dest, "w");
    if (dest_file == NULL) {
        perror("custom_cp");
        fclose(src_file);
        return 1;
    }

    char buffer[1024];
    size_t bytes;
    while ((bytes = fread(buffer, 1, sizeof(buffer), src_file)) > 0) {
        fwrite(buffer, 1, bytes, dest_file);
    }

    fclose(src_file);
    fclose(dest_file);

    printf("File copied successfully from %s to %s\n", src, dest);
    return 0;
}

