#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE_LEN 1024

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Usage: custom_grep <pattern> <filename>\n");
        return 1;
    }

    char *pattern = argv[1];
    char *filename = argv[2];
    char line[MAX_LINE_LEN];

    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        perror("custom_grep");
        return 1;
    }

    while (fgets(line, sizeof(line), file)) {
        if (strstr(line, pattern)) {
            printf("%s", line);
        }
    }

    fclose(file);
    return 0;
}

