#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#define RED "\033[31m"
#define YELLOW "\033[33m"
#define RESET "\033[0m"

#define BUFFER_SIZE 4096

void print_line_numbers(int line_num) {
    printf("%s%6d │%s ", YELLOW, line_num, RESET);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        // Interactive mode with line numbers
        char buffer[BUFFER_SIZE];
        int line_num = 1;
        
        while (fgets(buffer, sizeof(buffer), stdin) != NULL) {
            print_line_numbers(line_num++);
            printf("%s", buffer);
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

        int line_num = 1;
        char buffer[BUFFER_SIZE];
        
        // Print filename if multiple files
        if (argc > 2) {
            printf("\n%s==> %s <==%s\n", YELLOW, argv[i], RESET);
        }
        
        while (fgets(buffer, sizeof(buffer), file) != NULL) {
            print_line_numbers(line_num++);
            printf("%s", buffer);
        }

        if (ferror(file)) {
            fprintf(stderr, "%sError reading file '%s' - %s%s\n",
                    RED, argv[i], strerror(errno), RESET);
        }

        fclose(file);
    }
    return 0;
}