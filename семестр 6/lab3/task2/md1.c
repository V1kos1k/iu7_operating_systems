#include <linux/module.h>
#include <linux/kernel.h> // printk
#include <linux/init.h>   // __init, __exit

MODULE_AUTHOR("Mkhitaryan Victoria");
MODULE_DESCRIPTION("Lab LKM Task 2 (MD1)");
MODULE_LICENSE("GPL");

char *md1_data = "Здравствуй!";

extern char *md1_proc(void)
{
    return md1_data;
}

static char *md1_local(void)
{
    return md1_data;
}

extern char *md1_noexport(void)
{
    return md1_data;
}

EXPORT_SYMBOL(md1_data);
EXPORT_SYMBOL(md1_proc);

static int __init lkm_init(void)
{
    printk("+MD 1: module loaded\n");
    return 0;
}

static void __exit lkm_exit(void)
{
    printk("+MD 1: module unloaded\n");
}

module_init(lkm_init);
module_exit(lkm_exit);