/* Написать программу, которая создавала бы процесс-демон с помощью функций Demonize, Already running, Main  */ 
// выводить время создание
#include <syslog.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/resource.h>
#include <sys/stat.h> //umask
#include <unistd.h> //setsid
#include <stdio.h> //perror
#include <signal.h> //sidaction
#include <string.h> 
#include <errno.h> 
#include <sys/file.h>
#include <time.h>

#define LOCKFILE "/var/run/daemon.pid"
#define LOCKMODE (S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH) 

int lockfile(int fd)
{
    struct flock fl;
    fl.l_type = F_WRLCK;
    fl.l_start = 0;
    fl.l_whence = SEEK_SET;
    fl.l_len = 0;
    return(fcntl(fd, F_SETLK, &fl));
}

int already_running(void)
{

    syslog(LOG_ERR, "Проверка на многократный запуск!");

    int fd;
    char buf[16];

    fd = open(LOCKFILE, O_RDWR | O_CREAT, LOCKMODE);

    if (fd < 0)
    {
        syslog(LOG_ERR, "невозможно открыть %s: %s!", LOCKFILE, strerror(errno));
        exit(1);
    }

    syslog(LOG_WARNING, "Lock-файл открыт!");

    flock(fd, LOCK_EX | LOCK_UN);
    if (errno == EWOULDBLOCK) {
        syslog(LOG_ERR, "невозможно установить блокировку на %s: %s!", LOCKFILE, strerror(errno));
        close(fd);
        exit(1);
    }

    syslog(LOG_WARNING, "Записываем PID!");

    ftruncate(fd, 0);
    sprintf(buf, "%ld", (long)getpid());
    write(fd, buf, strlen(buf) + 1);

    syslog(LOG_WARNING, "Записали PID!");
     
    return 0;
}

void daemonize(const char *cmd)
{
    int fd0, fd1, fd2;
    pid_t pid;
    struct rlimit rl;
    struct sigaction sa;

    // 1. Сбрасывание маски режима создания файла 
    umask(0);

    // 2. Получение максимального возможного номера дискриптора 
    if (getrlimit(RLIMIT_NOFILE, &rl) < 0)
        perror("Невозможно получить максимальный номер дискриптора!\n");
    
    // 3. Стать лидером новой сессии, чтобы утратить управляющий терминал 
    if ((pid = fork()) < 0)  // чтобы новый процесс не был лидером группы
        perror("Ошибка функции fork!\n");
    else if (pid != 0) //родительский процесс
        exit(0);
    
    setsid();  // создать новую сессию (лидер сессии, группы, TTY = ?)

    // 4. Обеспечение невозможности обретения терминала в будущем 
    sa.sa_handler = SIG_IGN;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    if (sigaction(SIGHUP, &sa, NULL) < 0)
        perror("Невозможно игнорировать сигнал SIGHUP!\n");


    // 5. Назначить корневой каталог текущим рабочим каталогом, 
    // чтобы впоследствии можно было отмонтировать файловую систему 
    if (chdir("/") < 0)
        perror("Невозможно назначить корневой каталог текущим рабочим каталогом!\n");
    
    // 6. Зактрыть все файловые дескрипторы 
    if (rl.rlim_max == RLIM_INFINITY)
        rl.rlim_max = 1024;
    for (int i = 0; i < rl.rlim_max; i++)
        close(i);

    // 7. Присоеденить файловые дескрипторы 0, 1, 2 к /dev/null
    fd0 = open("/dev/null", O_RDWR);
    fd1 = dup(0); //копируем файловый дискриптор
    fd2 = dup(0);

    // 8. Инициализировать файл журнала
    openlog(cmd, LOG_CONS, LOG_DAEMON);
    if (fd0 != 0 || fd1 != 1 || fd2 != 2)
    {
        syslog(LOG_ERR, "ошибочные файловые дескрипторы %d %d %d\n", fd0, fd1, fd2);
        exit(1);
    }

    syslog(LOG_WARNING, "Демон запущен!");
    
}

int main() 
{
    daemonize("lab1");
    long int ttime;
    
    // 9. Блокировка файла для одной существующей копии демона 
    if (already_running() != 0)
    {
        syslog(LOG_ERR, "Демон уже запущен!\n");  // Ошибка
        exit(1);
    }

    syslog(LOG_WARNING, "Проверка пройдена!");  // Предупреждение
    while(1) 
    {
        ttime = time(NULL);
        syslog(LOG_INFO, "Время: %s\n", ctime (&ttime) );  // Информационное сообщение

        sleep(5);
    }


}