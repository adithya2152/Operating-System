#include "kernel/types.h"
#include "user.h"

void
strcat_custom(char *dest, const char *src)
{
    // Find the end of the destination string
    while (*dest != '\0') {
        dest++;
    }

    // Copy the source string to the destination
    while (*src != '\0') {
        *dest = *src;
        dest++;
        src++;
    }

    // Null-terminate the result
    *dest = '\0';
}

int
main(int argc, char *argv[])
{
    if (argc < 2) {
        printf("Usage: toggle_case <string>\n");
        exit(0);
    }

    char str[100] = {0};  // Buffer to hold the concatenated string

    // Concatenate all arguments into one string with spaces
    for (int i = 1; i < argc; i++) {
        strcat_custom(str, argv[i]);
        if (i < argc - 1) {
            strcat_custom(str, " ");
        }
    }

    printf("Original String: %s\n", str);

    // Call the toggle_case system call
    toggle_case(str);

    printf("Modified String: %s\n", str);
    exit(0);
}
