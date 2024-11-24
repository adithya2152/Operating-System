#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: rmdir <directory_name>\n");
        return 1;
    }

    for (int i = 1; i < argc; i++) {
        if (rmdir(argv[i]) == -1) {
            printf("Error removing directory %s: %s\n", 
                   argv[i], strerror(errno));
        } else {
            printf("Directory removed: %s\n", argv[i]);
        }
    }
    return 0;
}
