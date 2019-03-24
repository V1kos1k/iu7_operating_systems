#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>

/*Написать программу, в которой предок и потомок обмениваются
 сообщением через программный канал.*/

int main()
{
    int wpid;
    int childPID[2];
    int status;
    int is_child = 0;
    int fd[2];
    
    char messages[2][64] = {"Message from Child 1", "Message from Child 2"};
    char read_message[64];
    
    if (pipe(fd) == -1){
        exit(1);
    }
    
    for (int i = 0; !is_child && i < 2; i++)
    {
        if ((childPID[i] = fork()) == -1){
            perror("Can’t fork.\n");
            exit(1);
        }
        if (childPID[i] == 0)
            is_child=1;

    }

    for (int i = 0; i < 2; i++){
        if (childPID[i] == 0){
            write(fd[1], messages[i], 64);
	   if (i == 0)
            exit(0);
           else if (i == 1)
	    exit(1);
        }
    }
    
    for (int i = 1; i <= 2; i++){
        read(fd[0], read_message, 64);
        printf("Message to parent %d: %s\n", getpid(),read_message);
    }
    
    for (int i = 1; i <= 2; i++){
        wpid = wait(&status);
        if (wpid == -1)
        {
            perror("waitpid");
            exit(EXIT_FAILURE);
        }

        if (WIFEXITED(status))
        {
            printf("\tChild %d exited, status=%d\n", getpid(), WEXITSTATUS(status));
        }
        else if (WIFSIGNALED(status))
        {
            printf("\tChild %d killed (signal %d)\n", getpid(), WTERMSIG(status));
        }
        else if (WIFSTOPPED(status))
        {
            printf("\tChild %d stopped (signal %d)\n", getpid(), WSTOPSIG(status));
        }
        else
            printf("\tUnexpected status for Child %d (0x%x)\n", getpid(), status);
    }
    exit(0);
}
