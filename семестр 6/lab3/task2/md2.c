#include <linux/module.h>
#include <linux/kernel.h> // printk
#include <linux/init.h>   // __init, __exit

#include "md.h"

MODULE_AUTHOR("Mkhitaryan Victoria");
MODULE_DESCRIPTION("Lab LKM Task 2 (MD2)");
MODULE_LICENSE("GPL");

static int __init lkm_init(void)
{
    printk("+MD 2: module loaded\n");
    printk("+MD 2: data string exported from md1: %s\n", md1_data);
    printk("+MD 2: string returned from md1_proc(): %s\n", md1_proc());
    // printk("+MD 2: string returned from md1_noexport(): %s\n", md1_noexport());
    //printk("+MD 2: string returned from md1_local(): %s\n", md1_local());


    return 0;
}

static void __exit lkm_exit(void)
{
    printk("+MD 2: module unloaded\n");
}

module_init(lkm_init);
module_exit(lkm_exit);