#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <signal.h>

#define WAIT_TIME 5
#define BUF_SIZE 128

/*В программу с программным каналом включить собственный обработчик сигнала. 
Использовать сигнал для изменения хода выполнения программы.*/

static char buf[BUF_SIZE];
static int  fd[2];
static int  is_catched = 0;

void catch_sigint(int sig_num)
{
    is_catched = 1;
}

int main()
{
    signal(SIGINT, catch_sigint);

    int status;
    int childPID[2];
    int wpid;

    char message[] = "Secret Message: I'm child №";

    if(pipe(fd) == -1)
        exit(1);

    for(int i = 0; i < 2; ++i)
    {
        if((childPID[i] = fork()) == -1)
        {
            perror("Fork error");
            exit(EXIT_FAILURE);
        }

        if(childPID[i] == 0)
        {
            sleep(WAIT_TIME);

            if(is_catched)
            {
                message[26] = '0'+i+1;
                close(fd[0]);
                write(fd[1], message, BUF_SIZE);
            }

            exit(0);
        }
    }

    sleep(WAIT_TIME);

    close(fd[1]);
    for(int i = 0; is_catched && i < 2; ++i)
    {
        read(fd[0], buf, BUF_SIZE);
        printf("Message from child: %s\n", buf);
    }

    for(int i = 0; i < 2; ++i)
    {
        if((wpid = wait(&status)) == -1)
        {
            perror("waitpid");
            exit(EXIT_FAILURE);
        }

        if(WIFEXITED(status))
            printf("child exit, status=%d\n", WEXITSTATUS(status));
        else if(WIFSIGNALED(status))
            printf("child kill (signal %d)\n", WTERMSIG(status));
        else if(WIFSTOPPED(status))
            printf("child stop (signal %d)\n", WSTOPSIG(status));
        else
            printf("child unexpected status: 0x%x\n", status);
    }

    printf("Done\n");
    return 0;
}
