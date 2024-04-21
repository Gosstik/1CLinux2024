# Kernel Modules

* Modules are located in `/lib/modules/`.
* `.ko` &mdash; module extension.


### Creating simple module

1) Inside `kernel` directory run
   ```bash
   mkdir module_impl
   cd mudule_impl
   ```
   
2) Create `Makefile`
   ```makefile
   obj-m += example.o

   all:
       #make -C "/usr/src/linux-headers-6.5.0-25-generic/build" M="/home/ownstreamer/Proga/MIPT/Linux/module_impl" modules
       make -C "/lib/modules/$(shell unsmae -r)/build" M=$(PWD) modules
   clean:
       make -C "/lib/modules/$(shell unsmae -r)/build" M=$(PWD) clean
   ```
   **Before make directives there should be `tabs` instead of `spaces`**

3) Build module.
   ```bash
   make all
   ```
   
4) Enable module, check logs, disable module.
   ```bash
   sudo modprob ./example.ko
   ```

5) Check work
   ```bash
   dmesg
   ```
   


# Rebuild kernel

```bash
cd kernel/vroot/lib
mkdir modules

# Generate module binary.
cd <path_to_module_makefile> # kernel/module_impl
ABS_PATH_TO_VROOT="/home/ownstreamer/Proga/MIPT/Linux/workspace/kernel/vroot" KERNEL_VERSION=6.7.4 make all

# copy phone_book.ko to kernel/vroot/lib/modules/6.7.4/
cp phone_book.ko ../vroot/lib/modules/6.7.4/

# Rebuild initramfs
cd ../vroot
find . | cpio -ov --format=newc | gzip -9 > ../initramfs

# Run qemu
cd ../
qemu-system-x86_64 -kernel ./boot/vmlinuz-6.7.4 -initrd initramfs -nographic -append "console=ttyS0" 

# Stop qemu.
killall qemu-system-x86_64

# Enable
insmod /lib/modules/6.7.4/phone_book.ko

# Check
dmesg
lsmod
# Author info.
modinfo phone_book.ko 

# Disable
rmmod phone_book.ko

# Modules must be binary compatible, so 
```


* Добавить в `vroot/init` новую строку. Тогда всё его содержимое:
  ```bash
   #!/bin/sh
   
   mount -t devtmpfs devtmpfs /dev
   mount -t tmpfs tmpfs /tmp
   mount -t proc proc /proc
   mount -t sysfs sysfs /sys
   
   echo 0 > /proc/sys/kernel/printk
   
   insmod /lib/modules/6.7.4/phone_book_module.ko
   
   exec setsid sh -c 'exec sh </dev/ttyS0 >/dev/ttyS0 2>&1'
   ```


kfifo - homework

Info: https://tldp.org/LDP/khg/HyperNews/get/devices/basics.html
* Creation of character devices: https://embetronicx.com/tutorials/linux/device-drivers/device-file-creation-for-character-drivers/

* Reading/Writing from character device: https://embetronicx.com/tutorials/linux/device-drivers/device-file-creation-for-character-drivers/

* Kernel module with clion: https://gitlab.com/phip1611/cmake-kernel-module/-/tree/ubuntu-clion-ide?ref_type=heads
