#include <linux/module.h>
#include <linux/kernel.h> // printk
#include <linux/init.h>   // __init, __exit

#include "md.h"

MODULE_AUTHOR("Mkhitaryan Victoria");
MODULE_DESCRIPTION("Lab LKM Task 2 (MD3)");
MODULE_LICENSE("GPL");

static int __init lkm_init(void)
{
    printk("+MD 3: module loaded\n");
    printk("+MD 3: data string exported from md1: %s\n", md1_data);
    printk("+MD 3: string returned from md1_proc(): %s\n", md1_proc());

    return -1;
}

static void __exit lkm_exit(void)
{
    printk("+MD 3: module unloaded\n");
}

module_init(lkm_init);
module_exit(lkm_exit);