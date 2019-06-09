#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/interrupt.h>

#include <linux/init.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>

#include <asm/atomic.h>

#define HANDLED_IRQ 12
#define BUFFER 1024

char my_tasklet_data[]="my_tasklet data";
static unsigned long counter = 0;

//буфферы для хранения информации для вывода через seq_file
char *buf1[BUFFER];
long buf2[BUFFER];
long buf3[BUFFER];
int buf4[BUFFER];

long pos = 0;

//функция, которая показывает содержимое виртуального файла 
static int show(struct seq_file *m, void *v)
{
	int i;
	for(i = 0; i < pos; i++){
		//seq_printf - функция которая записывает в файл seq_file строку (т. е. выводит в пространство пользователя)
    		seq_printf(m, "interrupt %ld)  -  state: %ld, count %d, data:%s\n", buf2[i], buf3[i], buf4[i], buf1[i] );
	}
    	return 0;
}

//функция открытия файла seq_file
static int ct_open(struct inode *inode, struct file *file) {
	//single_open один раз выполняет функцию show над файлом seq_file file 
     	return single_open(file, show, NULL);
};

//регистрация операций
static struct file_operations ct_file_ops = {
     .owner   = THIS_MODULE,
     .open    = ct_open,
};


void my_tasklet_function( unsigned long data );

DECLARE_TASKLET( my_tasklet, my_tasklet_function, (unsigned long) &my_tasklet_data );

/* Bottom Half Function */
void my_tasklet_function( unsigned long data ) 
{
	counter++;
	
	buf1[pos] = (char *)data;
	buf2[pos] = counter;
	buf3[pos] = my_tasklet.state;
	buf4[pos] = atomic_read(&my_tasklet.count);
	pos++;

	printk(KERN_INFO "+ interrupt %ld) - state: %ld, count %d, data:%s\n", counter, my_tasklet.state, atomic_read(&my_tasklet.count), (char *)data );
	return; 
}

static irqreturn_t irq_handler( int irq, void *dev_id ) {
	if (irq == HANDLED_IRQ)
	{
		tasklet_schedule( &my_tasklet );
		return IRQ_HANDLED;
	}
   	else
   		return IRQ_NONE; 
}


static int __init tasklet_int_init(void)
{
	proc_create("tasklet_info", 0, NULL, &ct_file_ops);
	printk(KERN_INFO "+ Module loaded.");
    	return request_irq(HANDLED_IRQ,(irq_handler_t)irq_handler,IRQF_SHARED,"mouse_irq_handler",(void*)(irq_handler));
}

static void __exit tasklet_int_exit(void)
{
	remove_proc_entry("tasklet_info", NULL);
	printk(KERN_INFO "+ Module unloaded.");
	tasklet_kill(&my_tasklet);
	free_irq( HANDLED_IRQ, (void*)(irq_handler));
}	

module_init(tasklet_int_init);
module_exit(tasklet_int_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Author");

