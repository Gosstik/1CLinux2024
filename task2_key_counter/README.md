# Task 2 - Key Counter

## Description
Outputs every minute in the kernel buffer (which can be read with the `dmesg` utility) information about how many keystrokes occurred in the past minute.

## Setup

1) Install kernel with instruction in repository root.
2) Copy `task2_key_counter.patch` to the folder on the same level as `kernel` (look at README.md with kernel installation).
3) Run
   ```bash
   git apply task2_key_counter.patch
   ```

   Or manually:
    ```bash
    # Copy
    cd kernel/key_counter_module/
  
    ABS_PATH_TO_VROOT=<path/to/vroot> KERNEL_VERSION=6.7.4 make clean
    # ABS_PATH_TO_VROOT="/home/ownstreamer/Proga/MIPT/Linux/workspace/kernel/vroot" KERNEL_VERSION=6.7.4 make clean
    ABS_PATH_TO_VROOT=<path/to/vroot> KERNEL_VERSION=6.7.4 make all
    # ABS_PATH_TO_VROOT="/home/ownstreamer/Proga/MIPT/Linux/workspace/kernel/vroot" KERNEL_VERSION=6.7.4 make all
    
    cp key_counter_module.ko ../vroot/lib/modules/6.7.4/
    
    cd ../vroot
    find . | cpio -ov --format=newc | gzip -9 > ../initramfs
    
    # Run qemu
    cd ../
    ```
4) Test
   ```bash
    qemu-system-x86_64 -kernel ./boot/vmlinuz-6.7.4 -initrd initramfs -nographic -append "console=ttyS0"
   insmod /lib/modules/6.7.4/key_counter_module.ko # or add it to 'init'
   ```
   