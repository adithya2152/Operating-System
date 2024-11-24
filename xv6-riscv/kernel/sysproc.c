#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

 
int toggle_case(void)
{
  	 char str[100];          // Buffer for the string
    uint64 user_addr;       // Address of the string in user space

    // Get the user-space address of the string
    argaddr(0, &user_addr);  // Simply call argaddr; don't use it in an if condition.

    // Check if the user address is valid (basic sanity check)
    if (user_addr == 0)
        return -1;

    // Copy the string from user space to kernel space
    if (copyin(myproc()->pagetable, str, user_addr, sizeof(str)) < 0)
        return -1;

    // Toggle the case of each character in the string
    for (int i = 0; str[i] != '\0'; i++) {
        if (str[i] >= 'a' && str[i] <= 'z') {
            str[i] -= 32;  // Convert lowercase to uppercase
        } else if (str[i] >= 'A' && str[i] <= 'Z') {
            str[i] += 32;  // Convert uppercase to lowercase
        }
    }

    // Copy the modified string back to user space
    if (copyout(myproc()->pagetable, user_addr, str, strlen(str) + 1) < 0)
        return -1;

    return 0;
}


