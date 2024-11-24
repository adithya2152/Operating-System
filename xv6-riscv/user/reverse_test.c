#include "user.h"

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: reverse_test <string>\n");
        exit(1);
    }

    char str[128];
    strcpy(str, argv[1]); // Use xv6's `strcpy` function to copy the input string

    printf("Original string: %s\n", str);
    if (reverse(str) == 0) {
        printf("Reversed string: %s\n", str);
    } else {
        printf("Failed to reverse the string.\n");
    }

    exit(0);
}

