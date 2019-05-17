#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/sched.h>
#include <linux/proc_fs.h>
#include <linux/init_task.h>

MODULE_AUTHOR("Mkhitaryan Victoria");
MODULE_DESCRIPTION("OS lab4");
MODULE_LICENSE("GPL");

unsigned int MAX_COOKIE_LENGTH = 4096;

#define NEXT_COOKIE(i, len) (i = (i + len) % MAX_COOKIE_LENGTH)

char *cookie_pot;
size_t cookie_index, cookie_end;
struct proc_dir_entry *proc_entry;
struct proc_dir_entry *info_dir;
struct proc_dir_entry *prcs_entry;

static ssize_t read_fortune(struct file *filp, char *buffer, size_t count, loff_t *offp);
static ssize_t write_fortune(struct file *filp, const char __user *buffer, size_t count, loff_t *offp);

static ssize_t read_prcs(struct file *filp, char *buffer, size_t count, loff_t *offp);

struct file_operations fops = 
{
    .owner = THIS_MODULE,
    .read = read_fortune,
    .write = write_fortune
};

struct file_operations prcs_fops = 
{
    .owner = THIS_MODULE,
    .read = read_prcs
};

static ssize_t read_fortune(struct file *filp, char *buffer, size_t count, loff_t *offp)
{
    int length;

    if(cookie_index != cookie_end && *offp == 0)
    {
        length = sprintf(buffer, "%s\n", &cookie_pot[cookie_index]);
        if(*buffer == '\0' && cookie_end < cookie_index)
        {
            cookie_index = 0;
            length = sprintf(buffer, "%s\n", &cookie_pot[cookie_index]);
        }

        *offp = length;
        NEXT_COOKIE(cookie_index, length);
        return length;
    }

    return 0;
}

static ssize_t write_fortune(struct file *filp, const char __user *buffer, size_t length, loff_t *offp)
{
    if(MAX_COOKIE_LENGTH - cookie_end < length)
        cookie_end = 0;

    if(cookie_index > cookie_end && cookie_end + length >= cookie_index)
    {
        printk("+ Cookie pot is full\n");
        return -ENOSPC;
    }

    if(copy_from_user(&cookie_pot[cookie_end], buffer, length))
    {
        return -EFAULT;
    }
    
    cookie_pot[cookie_end + length - 1] = '\0';
    NEXT_COOKIE(cookie_end, length);

    return length;
}

static ssize_t read_prcs(struct file *filp, char *buffer, size_t count, loff_t *offp)
{
    struct task_struct *task;
    buffer[0] = '\0';

    if(*offp == 0)
    {
        int length = 0;

        for_each_process(task) 
        	length += sprintf (
                buffer+length, 
                "\n[\"%s\": PID = %d, Parent -- \"%s\": PPID = %d]", 
                task->comm, 
                task->pid,
                task->parent->comm,
                task->parent->pid
            );
        buffer[length++] = '\n';
        buffer[length] = '\0';
        
        *offp = length;
        return length;
    }

    return 0;
}

static int __init m_init(void)
{
    cookie_index = 0;
    cookie_end = 0;

    cookie_pot = (char*)vmalloc(MAX_COOKIE_LENGTH);
    if(!cookie_pot)
        return -ENOMEM;

    memset(cookie_pot, 0, MAX_COOKIE_LENGTH);
    proc_entry = proc_create_data("fortune", 0666, NULL, &fops, NULL);

    info_dir = proc_mkdir("fortune_info", NULL);
    prcs_entry = proc_create_data("prcs", 0444, info_dir, &prcs_fops, NULL);
    proc_symlink("prcs", NULL, "/proc/fortune_info/prcs");

    return 0;
}

static void __exit m_exit(void)
{
    remove_proc_entry("fortune", NULL);
    remove_proc_entry("prcs", NULL);
    remove_proc_entry("prcs", info_dir);
    remove_proc_entry("fortune_info", NULL);

    if(cookie_pot)
        vfree(cookie_pot);

    printk("+exit()\n");
}

module_init(m_init);
module_exit(m_exit);