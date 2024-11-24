# Operating Systems Project

## QUESTION 1: System Calls Implementation in xv6

### SYSTEM CALLS IMPLEMENTED

1. **cps()**
   - **Purpose**: Returns the current status of processes in the system.
   - **Details**: This system call lists all the processes currently running, their IDs, states (e.g., running, sleeping), and other relevant information.

2. **thread_create()**
   - **Purpose**: Creates a new thread within a process.
   - **Details**: Allocates a stack for the new thread and invokes the `clone()` system call to set up the thread's execution context. This enables the creation of new threads to perform concurrent operations within the same process.

3. **thread_join()**
   - **Purpose**: Waits for a specific thread to finish its execution.
   - **Details**: When called, it ensures that the parent thread waits until the specified child thread has finished execution before proceeding.

4. **lock_init()**
   - **Purpose**: Initializes a lock structure used for synchronizing access to shared resources among threads.
   - **Details**: This is essential in a multithreaded environment to prevent race conditions and ensure data integrity when multiple threads need to access shared resources.

5. **lock_acquire()**
   - **Purpose**: Acquires the lock to access shared resources.
   - **Details**: A thread attempts to gain exclusive access to the resource protected by the lock. If the lock is already held by another thread, the calling thread will block until it can acquire the lock.

6. **lock_release()**
   - **Purpose**: Releases a previously acquired lock.
   - **Details**: Once a thread has finished using a shared resource, it releases the lock, allowing other threads to acquire it and access the resource.

7. **reverse() system call**
   - **Purpose**: Reverses a given string and returns the reversed version.
   - **Function**:
     - Takes a string as input.
     - Returns the reversed string.

   #### Execution Example:
   - **Original String**: `example`
   - **Reversed String**: `elpmaxe`
   
   #### Output:
   ```c
   Original String: example
   Reversed String: elpmaxe

## `toggle_case()` System Call

### Purpose:
The `toggle_case()` system call toggles the case of each letter in the input string. Uppercase letters are converted to lowercase, and lowercase letters are converted to uppercase. Non-alphabetical characters (e.g., spaces, punctuation) remain unchanged.

### Function:
- **Takes**: A string as input.
- **Performs**: Toggling the case of each letter in the string (converts lowercase letters to uppercase and vice versa).
- **Returns**: The modified string with toggled case.

### Example:

#### Input:
```c
char str[] = "Hi this is AN EXample";
char* result = toggle_case(str);
printf("Toggled Case String: %s\n", result);
```








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
