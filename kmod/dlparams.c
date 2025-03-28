/*  
 *  chardev.c - The simplest kernel module registering a device.
 */
#include <linux/module.h>	/* Needed by all modules */
#include <linux/kernel.h>	/* Needed for KERN_INFO */
#include <linux/device.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/version.h>

#define DEV_NAME "dlparams"

static int dev_major;
static struct class* dev_class = NULL;
static struct device* dev_device = NULL;

static int     dev_open(struct inode *n, struct file *f) { try_module_get(THIS_MODULE); return 0; }
static int     dev_release(struct inode *n, struct file *f) { module_put(THIS_MODULE); return 0; }

static ssize_t dev_read(struct file *f, char *user_buf, size_t sz, loff_t *off) {
  long vals[2];
  int retval = 0;

  schedule();

  rcu_read_lock();
  struct task_struct *p = current;
  retval = -ESRCH;
  if (!p)
    goto out_unlock;
  if (sz < sizeof(vals))
    goto out_unlock;

  /* if (off != 0) { */
  /*   retval = 0; */
  /*   goto out_unlock; */
  /* } */

  struct sched_dl_entity *dl_se = &p->dl;
  vals[0] = dl_se->runtime;
  vals[1] = dl_se->deadline; // - rq_clock(task_rq(p)) + ktime_get();
  printk("deadline: %llu, ktime: %lld, boottime: %lld, real: %lld, raw: %lld\n", dl_se->deadline, ktime_get(), ktime_get_boottime(), ktime_get_real(), ktime_get_raw());
  if (copy_to_user(user_buf, vals, sizeof(vals)) != 0)
    printk("copy_to_user() != 0\n");
  retval = sizeof(vals);

 out_unlock:
  rcu_read_unlock();
  return retval;
}

static ssize_t dev_write(struct file *f, const char *buf, size_t sz, loff_t *off) {
  printk("Hello, writing\n");
  return  0;
}

struct file_operations fops = {
  .open = dev_open,
  .read = dev_read,
  .write = dev_write,
  .release = dev_release,
};

int init_module(void) {
  printk(KERN_INFO "Registering device %s\n", DEV_NAME);
  dev_major = register_chrdev(0, DEV_NAME, &fops);
  if (dev_major < 0) {
    printk(KERN_ERR "register_chrdev() failed with: %d\n", dev_major);
    return dev_major;
  }
  printk(KERN_INFO "Assigned major: %d\n", dev_major);

#if LINUX_VERSION_CODE >= KERNEL_VERSION(6, 4, 0)
  dev_class = class_create(DEV_NAME);
#else
  dev_class = class_create(THIS_MODULE, DEV_NAME);
#endif
  if (IS_ERR(dev_class)) {
    printk(KERN_ERR "class_create() failed\n");
    unregister_chrdev(dev_major, DEV_NAME);
    return -1;
  }
  dev_device = device_create(dev_class, NULL, MKDEV(dev_major, 0), NULL, DEV_NAME);
  if (IS_ERR(dev_device)) {
    printk(KERN_ERR "device_create() failed\n");
    class_unregister(dev_class);
    class_destroy(dev_class);
    unregister_chrdev(dev_major, DEV_NAME);
    return -1;
  }

  return 0;
}

void cleanup_module(void) {
  printk(KERN_INFO "Destroying device...\n");
  device_destroy(dev_class, MKDEV(dev_major, 0));
  printk(KERN_INFO "Unregistering class...\n");
  class_unregister(dev_class);
  printk(KERN_INFO "Destroying class...\n");
  class_destroy(dev_class);
  printk(KERN_INFO "Unregistering device %s\n", DEV_NAME);
  unregister_chrdev(dev_major, DEV_NAME);
}

MODULE_LICENSE("GPL");
