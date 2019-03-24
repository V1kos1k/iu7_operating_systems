#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>

/*Написать программу, запускающую новый процесс системным вызовом fork(). 
В предке вывести собственный идентификатор ( функция getpid()), 
идентификатор группы ( функция getpgrp()) и идентификатор потомка. 
В процессе-потомке вывести собственный идентификатор, идентификатор 
предка ( функция getppid()) и идентификатор группы. Убедиться, 
что при завершении процесса-предка потомок получает идентификатор предка (PPID), 
равный 1.*/

int main()
{
    int pearentPID;
    int childPID[2];
    int is_child = 0;
    
    for (int i = 0; !is_child && i < 2; i++){
        if ((childPID[i] = fork()) == -1)
        {
            perror("Can’t fork.\n");
            exit(1);
        }
        if (childPID[i] == 0) // potomok 
            is_child=1;
    }
    
    
    if (childPID[0] == 0){
        sleep(2);
        printf("\nChild 1: childPID = %d, parentID = %d, groupPID = %d\n", getpid(),getppid(),getpgrp());
        exit(0);
    }
    if (childPID[1] == 0){
        sleep(2);
        printf("\nChild 2: childPID = %d, parentID = %d, groupPID = %d\n", getpid(),getppid(),getpgrp());
        exit(0);
    }
    if (childPID[0] > 0 && childPID[1] > 0){
        printf("Parent: PID = %d, groupPID = %d\n", getpid(), getpgrp());
    }
    
    return 0;
}
