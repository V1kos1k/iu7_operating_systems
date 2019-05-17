#include <linux/module.h>
#include <linux/kernel.h> // printk
#include <linux/init.h>   // __init, __exit
#include <linux/sched.h>


MODULE_AUTHOR("Mkhitaryan Victoria");
MODULE_DESCRIPTION("Lab Hello LKM");
MODULE_LICENSE("GPL");

static int __init lkm_init(void)
{
    printk("+Hello LKM: module loaded\n");
    printk("+Hello LKM: current PID: %i, name: %s\n", current->pid, current->comm);
    return 0;
}

static void __exit lkm_exit(void)
{
    printk("+Hello LKM: module unloaded\n");
    printk("+Hello LKM: current PID: %i, name: %s\n", current->pid, current->comm);
}

module_init(lkm_init);
module_exit(lkm_exit);