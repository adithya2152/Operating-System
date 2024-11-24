#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <errno.h>
#include <time.h>

#define MAX_INPUT_SIZE 1024
#define MAX_TOKEN_SIZE 64
#define MAX_NUM_TOKENS 64

#define GREEN "\033[32m"
#define BLUE "\033[34m"
#define YELLOW "\033[33m"
#define RED "\033[31m"
#define BOLD "\033[1m"
#define RESET "\033[0m"

char **tokenize(char *line) {
    char **tokens = malloc(MAX_NUM_TOKENS * sizeof(char*));
    char *token = strtok(line, " \t\n");
    int i = 0;
    
    while (token != NULL && i < MAX_NUM_TOKENS) {
        tokens[i] = strdup(token);
        token = strtok(NULL, " \t\n");
        i++;
    }
    tokens[i] = NULL;
    return tokens;
}

void print_prompt() {
    char hostname[1024];
    char cwd[1024];
    gethostname(hostname, sizeof(hostname));
    getcwd(cwd, sizeof(cwd));
    
    printf("%s%s@%s%s:%s%s%s$ ", 
           GREEN, getenv("USER"), hostname, 
           BLUE, BOLD, cwd, RESET);
}

void execute_command(char **tokens) {
    if (tokens[0] == NULL) return;

    if (strcmp(tokens[0], "exit") == 0) {
        printf("%sGoodbye!%s\n", YELLOW, RESET);
        exit(0);
    }

    pid_t pid = fork();
    
    if (pid < 0) {
        printf("%sError: Fork failed%s\n", RED, RESET);
        return;
    }
    
    if (pid == 0) {
        char executable[256];
        snprintf(executable, sizeof(executable), "./custom_%s", tokens[0]);
        
        execv(executable, tokens);
        
        printf("%sError: Command '%s' failed - %s%s\n", 
               RED, tokens[0], strerror(errno), RESET);
        exit(1);
    } else {
        int status;
        waitpid(pid, &status, 0);
    }
}

void print_welcome() {
    printf("\n%s%s=== WELCOME TO OUR OS PROJECT ===%s\n\n", BOLD, RED, RESET);
    printf("\n%s%s=== By Aditi\nRishika\nAdithya\nNeelima ===%s\n\n", BOLD, RED, RESET);
    printf("\n%s%s=== Custom Shell ===%s\n", BOLD, BLUE, RESET);
    printf("Available commands:\n");
    printf("  %s• custom_ls%s [path]    - List files in directory\n", YELLOW, RESET);
    printf("  %s• custom_pwd%s         - Print working directory\n", YELLOW, RESET);
    printf("  %s• custom_cat%s [file]   - Display file contents\n", YELLOW, RESET);
    printf("  %s• custom_mkdir%s        - Create a directory\n", YELLOW, RESET);
    printf("  %s• custom_rmdir%s        - Remove a directory\n", YELLOW, RESET);
    printf("  %s• custom_mv%s        - Move file from source to destination\n", YELLOW, RESET);
    printf("  %s• custom_grep%s        - Searching a char/word/line in file\n", YELLOW, RESET);
    printf("  %s• custom_cp%s        - Copy file \n", YELLOW, RESET);
    printf("  %s• custom_wc%s        - displays the number of lines, words, and bytes\n", YELLOW, RESET);
    printf("  %s• exit%s        - Exit the shell\n", YELLOW, RESET);
    printf("\n");
}

int main() {
    char input[MAX_INPUT_SIZE];
    char **tokens;
    
    print_welcome();

    while (1) {
        print_prompt();
        fflush(stdout);
        
        if (fgets(input, MAX_INPUT_SIZE, stdin) == NULL) {
            printf("\n%sGoodbye!%s\n", YELLOW, RESET);
            break;
        }
        
        size_t len = strlen(input);
        if (len > 0 && input[len-1] == '\n') {
            input[len-1] = '\0';
        }
        
        if (strlen(input) == 0) continue;
        
        tokens = tokenize(input);
        execute_command(tokens);
        
        for (int i = 0; tokens[i] != NULL; i++) {
            free(tokens[i]);
        }
        free(tokens);
    }
    return 0;
}
