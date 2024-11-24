# Custom UNIX Utilities Implementation

This project implements simplified versions of common UNIX utilities, including a custom shell to run them. These are lightweight versions of common commands like cat, ls, pwd, mkdir, rmdir, and wc. Each utility has been implemented from scratch in C.

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

## Features

### Shell Features
- Interactive command prompt
- Command parsing and execution
- Process management using fork() and execv()
- Error handling and reporting
- Support for multiple arguments
- Clean exit handling

### Utility Features
- Basic functionality of standard UNIX commands
- Error handling and appropriate error messages
- Support for multiple files/arguments where applicable
- Standard input processing when appropriate

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

## Limitations

1. Basic Command Implementation
   - No support for command flags/options
   - Limited functionality compared to standard UNIX utilities
   - No support for wildcards or pattern matching

2. Shell Limitations
   - No support for pipes (|)
   - No support for redirections (>, >>, <)
   - No command history
   - No command line editing
   - No environment variables

3. General Limitations
   - Basic error handling
   - No support for symbolic links
   - No support for file permissions management
   - No support for recursive operations

## Error Handling

- All commands include basic error checking
- Error messages are displayed for:
  - File not found
  - Permission denied
  - Invalid arguments
  - Directory creation/removal failures
  - Command execution failures

## Future Improvements

Possible enhancements for future versions:
1. Add support for command flags and options
2. Implement pipe and redirection support
3. Add command history and command line editing
4. Support for wildcard characters
5. Enhanced error handling and reporting
6. Support for more UNIX commands
7. Add support for environment variables
8. Implement recursive operations for relevant commands

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

## Contributing

Feel free to contribute to this project by:
1. Adding new features
2. Implementing more UNIX utilities
3. Improving error handling
4. Adding command line options
5. Fixing bugs

## Author

[Your Name]

## License

This project is open source and available under the MIT License.