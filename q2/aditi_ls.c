#include<stdio.h>
#include<stdlib.h>
#include<dirent.h>
#include<grp.h>
#include<time.h>
#include<errno.h>
#include<pwd.h>
#include<sys/stat.h>
#include<string.h>

#define RED "\033[31m"
#define GREEN "\033[32m"
#define YELLOW "\033[33m"
#define BLUE "\033[34m"
#define RESET "\033[0m"

void print(const char *n, const struct stat *i)
{
    if(S_ISDIR(i->st_mode))
        printf("%s%-20s%s\n", BLUE, n, RESET);
    else if(i->st_mode & S_IXUSR)
        printf("%s%-20s%s\n", GREEN, n, RESET);
    else
        printf("%-20s\n", n);      
    

    struct passwd *pw=getpwuid(i->st_uid);
    struct group *g=getgrgid(i->st_gid);

    printf("%-10s %-10s %8ld", pw?pw->pw_name:"unknown", g ? g->gr_name:"unknown", (long)i->st_size);
    char time[20];
    strftime(time, sizeof(time), "%b %d %H:%M", localtime(&i->st_mtime));
    printf("%s ", time);
    printf("%c%c%c%c%c%c%c%c%c%c\t", S_ISDIR(i->st_mode) ? 'd' : '-',
        i->st_mode &S_IRUSR ? 'r' : '-',
        i->st_mode & S_IWUSR ? 'w' : '-',
        i->st_mode & S_IXUSR ? 'x' : '-',
        i->st_mode & S_IRGRP ? 'r' : '-',
        i->st_mode & S_IWGRP ? 'w' : '-',
        i->st_mode & S_IXGRP ? 'x' : '-',
        i->st_mode & S_IROTH ? 'r' : '-',
        i->st_mode & S_IWOTH ? 'w' : '-',
        i->st_mode & S_IXOTH ? 'x' : '-');
     
}

int main(int argc, char *argv[])
{
    DIR *dir;
    struct dirent *entry;
    char *p=".";
    struct stat file;
    char f[1024];
    if(argc>1)
        p=argv[1];
    dir=opendir(p);
    if(dir==NULL)
    {
        fprintf(stderr, "%sError: Cannot opend directiry '%s'- %s%s\n", RED, p, strerror(errno), RESET);
        return 1;
    }

    // printf("total %d\n", 0);
    printf("Name\tOwner\tGroup\tSize\tTime\t\t\tPermissions\n");
    while((entry=readdir(dir))!=NULL)
    {
        if(entry->d_name[0]!='.')
        {
            snprintf(f, sizeof(f),"%s/%s", p, entry->d_name);
            if (stat(f, &file) == 0) {
                print(entry->d_name, &file);

        }
    }
    }
    closedir(dir);
    return 0;
}
