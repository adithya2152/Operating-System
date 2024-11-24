#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#define RED "\033[31m"
#define RESET "\033[0m"

int main(int argc, char *argv[]) {
    if (argc < 2) {
        char ch;
        while ((ch = getchar()) != EOF) {
            putchar(ch);
        }
        return 0;
    }

    for (int i = 1; i < argc; i++) {
        FILE *file = fopen(argv[i], "r");
        if (file == NULL) {
            fprintf(stderr, "%sError: Cannot open file '%s' - %s%s\n", 
                    RED, argv[i], strerror(errno), RESET);
            continue;
        }

        char buffer[4096];
        size_t bytes;
        while ((bytes = fread(buffer, 1, sizeof(buffer), file)) > 0) {
            fwrite(buffer, 1, bytes, stdout);
        }

        if (ferror(file)) {
            fprintf(stderr, "%sError reading file '%s' - %s%s\n", 
                    RED, argv[i], strerror(errno), RESET);
        }

        fclose(file);
    }
    return 0;
}