# Operating Systems Project

## QUESTION 1

## QUESTION 2

## Custom UNIX Utilities Implementation

This project implements simplified versions of common UNIX utilities from scratch in C.

## Project Structure

```
.
├── shell.c         # Main shell program
├── custom_cat.c    # Cat utility implementation
├── custom_ls.c     # Ls utility implementation
├── custom_pwd.c    # Pwd utility implementation
├── custom_mkdir.c  # Mkdir utility implementation
├── custom_rmdir.c  # Rmdir utility implementation
├── custom_wc.c     # Wc utility implementation
├── Makefile       # Build configuration
└── README.md      # This file
```

## Building the Project

To build all utilities, run:
```bash
make
```

To clean build files:
```bash
make clean
```

This will create the following executables:
- custom_shell
- custom_cat
- custom_ls
- custom_pwd
- custom_mkdir
- custom_rmdir
- custom_wc

## Running the Shell

Start the custom shell:
```bash
./custom_shell
```

## Available Commands

1. `cat [file1] [file2] ...`
   - Display contents of files
   - Reads from standard input if no file is specified
   - Can read multiple files sequentially

2. `ls [directory]`
   - Lists files in the specified directory
   - Lists current directory if no argument is provided
   - Skips hidden files (starting with '.')

3. `pwd`
   - Prints the current working directory
   - Shows absolute path

4. `mkdir <directory_name> [directory_name2] ...`
   - Creates new directories
   - Can create multiple directories in one command
   - Sets default permissions to 0777
   - Shows error if directory already exists

5. `rmdir <directory_name> [directory_name2] ...`
   - Removes empty directories
   - Can remove multiple directories in one command
   - Shows error if directory is not empty or doesn't exist

6. `wc [file1] [file2] ...`
   - Counts lines, words, and characters in files
   - Can process multiple files
   - Shows totals when processing multiple files
   - Reads from standard input if no file is specified
   - Output format: lines words chars filename

7. `exit`
   - Exits the shell

## Implementation Details

### Shell Implementation
- Uses fork() and execv() for command execution
- Implements basic command parsing
- Handles process cleanup
- Provides error messages for unknown commands

### File Operations
- Uses standard C file operations (fopen, fgets, etc.)
- Directory operations using dirent.h
- Error handling using errno and perror()

### Memory Management
- Proper allocation and deallocation of resources
- Clean process management
- Memory leak prevention

## Error Handling

- All commands include basic error checking
- Error messages are displayed for:
  - File not found
  - Permission denied
  - Invalid arguments
  - Directory creation/removal failures
  - Command execution failures

## Running Tests

To test the utilities:

1. Test cat:
```bash
echo "Hello World" > test.txt
cat test.txt
```

2. Test ls:
```bash
ls
ls /home
```

3. Test pwd:
```bash
pwd
```

4. Test mkdir and rmdir:
```bash
mkdir test_dir
ls
rmdir test_dir
```

5. Test wc:
```bash
echo "Hello World\nTest" > test.txt
wc test.txt
```
