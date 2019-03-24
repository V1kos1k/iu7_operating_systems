//
//  main.cpp
//  test
//
//  Created by Виктория Мхитарян on 12/11/2018.
//  Copyright © 2018 Виктория Мхитарян. All rights reserved.
//

#include <unistd.h>
#include <stdio.h>
int main(void)
{
    int childpid, pearentpid;
    if ((childpid = fork())== -1)
    {
        perror("Can’t fork.\n");
        return 1;
    }
    else if (childpid == 0)
    {
        while (1) printf("childpid = %d    ", getpid());
        return 0;
    }
    else
    {
        while(1)  printf("pearentpid = %d\n",getpid());
        return 0;
    }
}
