#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/time.h>

MODULE_AUTHOR("Victoria Mkhitaryan");
MODULE_DESCRIPTION("OS lab6");
MODULE_LICENSE("GPL");

#define LABFS_MAGIC 0x5643ABBA

struct inode *labfs_get_inode(struct super_block *sb, const struct inode *dir, umode_t mode, dev_t dev);

static struct inode_operations labfs_dir_ops = 
{
    .lookup = simple_lookup,
    .link = simple_link,
    .unlink = simple_unlink,
};

struct inode *labfs_get_inode(struct super_block *sb, const struct inode *dir, umode_t mode,dev_t dev)
//размещает новую структуру inode (new_inode), заполняет её значениями
{
    struct inode *inode;


    printk(KERN_INFO "+LABFS: creating inode\n");
    inode = new_inode(sb);

    if(inode)
    {
        inode->i_ino = get_next_ino();
    
        //mode определяет права доступа к файлу, тип (регулярный или каталог)
        inode_init_owner(inode, dir, mode);
        
        inode->i_size = PAGE_SIZE;
        inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
        inode->i_op = &simple_dir_inode_operations;
        inode->i_fop = &simple_dir_operations;

        printk(KERN_INFO "+LABFS: inode filled\n");
    }

    printk(KERN_INFO "+LABFS: return inode\n");

    return inode;
}

static void labfs_put_super(struct super_block *sb)
{
    printk(KERN_INFO "+LABFS: superblock destroyed\n");
}

static struct super_operations labfs_ops = 
{
    .statfs     = simple_statfs,
    .drop_inode = generic_delete_inode,
    .put_super  = labfs_put_super  // деструктор суперблока
};

//инициализация суперблока
static int labfs_fill_sb(struct super_block *sb, void *data, int silent)
{
    struct inode *inode;
    
    //создается inode для фс
    // NULL - разрешение на создоваемый файл
    //S_IFDIR - маска, говорит, что мы создаем каталог
    inode = labfs_get_inode(sb, NULL, S_IFDIR, 0);
    if(!inode)
        return -ENOMEM;

    sb->s_blocksize = PAGE_SIZE;
    sb->s_blocksize_bits = PAGE_SHIFT;
    sb->s_magic = LABFS_MAGIC; //число, по кот драйвер фс может проверить, что на диске хранится 
    //именно та самая фс
    sb->s_op = &labfs_ops;
    sb->s_root = d_make_root(inode);  // точка монтирования файловой системы

    printk(KERN_INFO "+LABFS: superblock filled\n");

    return 0;    
}


//должна примонтировать устройство
//вернуть структуру, описывающую корневой каталог файловой системы
struct dentry *labfs_mount(struct file_system_type *fs_type, int flags, const char *dev_name, void* data)
{
    printk(KERN_INFO "+LABFS: mounting...\n");
    //labfs_fill_sb - указатель на функцию, которая инициализирует суперблок
    return mount_nodev(fs_type, flags, data, labfs_fill_sb);
}


//"описывает" файловую систему
static struct file_system_type labfs = 
{
    .owner    = THIS_MODULE, //счетчик ссылок на модуль, чтобы нельзя было случайно выгрузить
    .name     = "labfs",
    //поля , хранящие указатели на функции 1 - монтирование, 2 - размонтирование
    .mount    = labfs_mount,
    .kill_sb  = kill_litter_super,
    .fs_flags = FS_USERNS_MOUNT
};

static int __init m_init(void)
{
    printk(KERN_INFO "+LABFS: loaded\n");
    //подается указатель на структуру file_system_type
    return register_filesystem(&labfs);
}

static void __exit m_exit(void)
{
    int err;

    err = unregister_filesystem(&labfs);
    if(err)
        printk(KERN_ERR "+LABFS: cannot unregister filesystem\n");

    printk(KERN_INFO "+LABFS: unloaded\n");
}

module_init(m_init);
module_exit(m_exit);