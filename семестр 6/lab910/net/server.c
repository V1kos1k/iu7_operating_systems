#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <arpa/inet.h>
#include <netdb.h>

#include "info.h"

#define MAX_CLIENTS 10
int clients[MAX_CLIENTS] = { 0 };


void manageConnection(unsigned int fd)
{
    struct sockaddr_in client_addr;
    int addrSize = sizeof(client_addr);

    int incom = accept(fd, (struct sockaddr*) &client_addr, (socklen_t*) &addrSize);
    if (incom < 0)
    {
        perror("Error in accept(): ");
        exit(-1);
    }

    printf("\nNew connection: \nfd = %d \nip = %s:%d\n", incom, 
                            inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));

    for (int i = 0; i < MAX_CLIENTS; i++)
    {
        if (clients[i] == 0)
        {
            clients[i] = incom;
            printf("Managed as client #%d\n", i);
            break;
        }
    }

}

void manageClient(unsigned int fd, unsigned int client_id)
{
    char msg[MSG_LEN];
    memset(msg, 0, MSG_LEN);

    struct sockaddr_in client_addr;
    int addrSize = sizeof(client_addr);

    int recvSize = recv(fd, msg, MSG_LEN, 0);
    if (recvSize == 0)
    {
        getpeername(fd, (struct sockaddr*) &client_addr, (socklen_t*) &addrSize);
        printf("User %d disconnected %s:%d \n", client_id, inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));
        close(fd);
        clients[client_id] = 0;
    }
    else
    {
        msg[recvSize] = '\0';
        printf("Message from client: %s\n", msg);
    }
}


int main(void)
{
    int my_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (my_socket < 0)
    {
        perror("Error in sock(): ");
        return my_socket;
    }

    struct sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(SOCK_PORT);
    server_addr.sin_addr.s_addr = INADDR_ANY; // чтобы могли принимать соединения с любого адреса

    if (bind(my_socket, (struct sockaddr*) &server_addr, sizeof(server_addr)) < 0)
    {
        perror("Error in bind():");
        return -1;
    }
    printf("Server is listening on the %d port...\n", SOCK_PORT);

    if (listen(my_socket, 3) < 0)
    {
        perror("Error in listen(): ");
        return -1;
    }
    printf("Waiting for the connections...\n");

    for (;;)
    {
        fd_set readfds; // набор файловых дескрипторов, которые будут контролировать select()
        int max_fd;  // cамый большой файловый дескриптор в наборе
        int ac; //количество сокетов, для которых select () имеет фиксированную активность

        FD_ZERO(&readfds);
        FD_SET(my_socket, &readfds);
        max_fd = my_socket;

        //добавить в набор всех уже подключенных клиентов
        for (int i = 0; i < MAX_CLIENTS; i++)
        {
            int fd = clients[i];

            if (fd > 0)
            {
                FD_SET(fd, &readfds);
            }

            max_fd = (fd > max_fd) ? (fd) : (max_fd);
        }

        ac = pselect(max_fd + 1, &readfds, NULL, NULL, NULL, NULL);

        if (ac < 0 && (errno != EINTR))
        {
            perror("Error in select():");
            return ac;
        }

        if (FD_ISSET(my_socket, &readfds))
        {
            manageConnection(my_socket);
        }

        // проверить, была ли активность на одном из клиентов
        for (int i = 0; i < MAX_CLIENTS; i++)
        {
            int fd = clients[i];
            if ((fd > 0) && FD_ISSET(fd, &readfds))
            {
                manageClient(fd, i);
            }
        }
    }

    return 0;
}
