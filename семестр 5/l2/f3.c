#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>

/*Написать программу, в которой процесс-потомок вызывает системный вызов exec(),
 а процесс-предок ждет завершения процесса-потомка.*/

int main()
{
    int wpid;
    int childPID[2];
    int status;
    int is_child = 0;
    
    for (int i = 0; !is_child && i < 2; i++)
    {
        if ((childPID[i] = fork()) == -1){
            perror("Can’t fork.\n");
            exit(1);
        }
        if (childPID[i] == 0)
            is_child=1;
        
    }
    
    if (childPID[0] == 0){
        printf("\nChild 1: childPID = %d, parentID = %d, groupPID = %d\n", getpid(),getppid(),getpgrp());
        if ( execlp("ps", "ps", "-al", 0) == -1 )
        {
            perror( "Child couldn't exec." );
            exit(1);
        }
    }
    if (childPID[1] == 0){
        printf("\nChild 2: childPID = %d, parentID = %d, groupPID = %d\n", getpid(),getppid(),getpgrp());
        if ( execlp("/bin/ls", "ls", "-l", 0) == -1 )
        {
            perror( "Child couldn't exec." );
            exit(1);
        }
    }
    
    printf("Parent: PID = %d, groupPID = %d\n", getpid(), getpgrp());
    
    for (int i = 1; i <= 2; i++){
        wpid = wait(&status);
        if (wpid == -1)
        {
            perror("waitpid");
            exit(EXIT_FAILURE);
        }
        
        if (WIFEXITED(status))
        {
            printf("\tChild exited, status=%d\n", WEXITSTATUS(status));
        }
        else if (WIFSIGNALED(status))
        {
            printf("\tChild killed (signal %d)\n", WTERMSIG(status));
        }
        else if (WIFSTOPPED(status))
        {
            printf("\tChild stopped (signal %d)\n", WSTOPSIG(status));
        }
        else
            printf("\tUnexpected status for Child (0x%x)\n", status);
    }
    exit(0);
}

