#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: mkdir <directory_name>\n");
        return 1;
    }

    for (int i = 1; i < argc; i++) {
        if (mkdir(argv[i], 0777) == -1) {
            printf("Error creating directory %s: %s\n", 
                   argv[i], strerror(errno));
        } else {
            printf("Directory created: %s\n", argv[i]);
        }
    }
    return 0;
}
