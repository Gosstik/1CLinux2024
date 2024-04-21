# Task 5 - Process fifo

## Description
Implements driver for fifo communication between processes. Driver create character device `fifo_proc`. Each process can write and read from it one byte for syscall. Queue for read/write is bounded to `256 bytes`.

## Setup

1) Install kernel with instruction in repository root.
2) Copy `task5_process_fifo.patch` to the folder on the same level as `kernel` (look at README.md with kernel installation).
3) Run
   ```bash
   git apply task5_process_fifo.patch
   ```

   Or manually:
    ```bash
    # Copy
    cd kernel/process_fifo_module/
  
    ABS_PATH_TO_VROOT=<path/to/vroot> KERNEL_VERSION=6.7.4 make clean
    # ABS_PATH_TO_VROOT="/home/ownstreamer/Proga/MIPT/Linux/workspace/kernel/vroot" KERNEL_VERSION=6.7.4 make clean
    ABS_PATH_TO_VROOT=<path/to/vroot> KERNEL_VERSION=6.7.4 make all
    # ABS_PATH_TO_VROOT="/home/ownstreamer/Proga/MIPT/Linux/workspace/kernel/vroot" KERNEL_VERSION=6.7.4 make all
    
    cp process_fifo_module.ko ../vroot/lib/modules/6.7.4/
    
    cd ../vroot
    find . | cpio -ov --format=newc | gzip -9 > ../initramfs
    
    # Run qemu
    cd ../
    ```
4) Test
   ```bash
    qemu-system-x86_64 -kernel ./boot/vmlinuz-6.7.4 -initrd initramfs -nographic -append "console=ttyS0"
   insmod /lib/modules/6.7.4/process_fifo_module.ko # or add it to 'init'
   ./test_module.sh
   ```
   
Actually, test only check the module correct creation and initialisation, as well as the basic communication. Correctness of concurrent communication can be seen in the code (it is quite primitive).
