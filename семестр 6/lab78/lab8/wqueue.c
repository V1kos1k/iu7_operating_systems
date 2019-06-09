#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/interrupt.h>
#include <linux/workqueue.h>
#include <linux/slab.h>

#include <linux/init.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>

#include <asm/atomic.h>

#define HANDLED_IRQ 12
#define BUFFER 1024

char my_work_data[]="my_work data";
static unsigned long counter = 0;

char *buf1[BUFFER];
long buf2[BUFFER];
long pos = 0;

static int show(struct seq_file *m, void *v)
{
	int i;
	for(i = 0; i < pos; i++){
    		seq_printf(m, "work: %ld,     data: %s\n",buf2[i],buf1[i]);
	}
    	return 0;
}
static int ct_open(struct inode *inode, struct file *file) {
     	return single_open(file, show, NULL);
};

static struct file_operations ct_file_ops = {
     .owner   = THIS_MODULE,
     .open    = ct_open,
     .read    = seq_read,
     .llseek  = seq_lseek,
     .release = seq_release
};

struct workqueue_struct *my_wq;

void my_work_function(struct work_struct *work);

//DECLARE_WORK( my_work, my_work_function);
typedef struct {
  struct work_struct my_work;
  char *x;
} my_work_t;

my_work_t *my_work;

/* Bottom Half Function */
void my_work_function(struct work_struct *work) {
	//char* data = (char*) atomic_long_read(&work->data);
	my_work_t *my_work_tmp = (my_work_t *)work;
	counter++;
    	printk(KERN_INFO "+ work: %ld data: %s\n",counter,my_work_tmp->x);

	buf1[pos] = my_work_tmp->x;
	buf2[pos] = counter;	
	pos++;

    	return;
}

static irqreturn_t irq_handler( int irq, void *dev_id ) {
	if (irq == HANDLED_IRQ)
	{
		//atomic_long_set(&(my_work.data),(long int)my_work_data);
		queue_work( my_wq, (struct work_struct *)my_work );
		return IRQ_HANDLED;
	}
   	else
   		return IRQ_NONE; 
}


static int __init work_int_init(void)
{
	if (request_irq(HANDLED_IRQ,(irq_handler_t)irq_handler,IRQF_SHARED,"mouse_irq_handler",(void*)(irq_handler)))
	{
		return -1;
	} else {
		proc_create("wq_info", 0, NULL, &ct_file_ops);
		my_wq = create_workqueue("my_queue");
		if(!my_wq)
		{
			return -1;
		}
		my_work = (my_work_t*)kmalloc(sizeof(my_work_t),GFP_KERNEL);
		if (!my_work)
		{
			return 0;
		}	
		INIT_WORK((struct work_struct *)my_work, my_work_function );
		my_work->x = my_work_data;
		printk(KERN_INFO "+ Module loaded.");
		return 0;
	}
}

static void __exit work_int_exit(void)
{
	remove_proc_entry("wq_info", NULL);
	printk(KERN_INFO "+ Module unloaded.");
	flush_workqueue( my_wq );
	destroy_workqueue( my_wq );
	free_irq( HANDLED_IRQ, (void*)(irq_handler));
}	

module_init(work_int_init);
module_exit(work_int_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Author");

