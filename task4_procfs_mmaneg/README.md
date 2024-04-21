# Task 4 - Procfs Mmaneg

## Description
Kernel module that registers an entry in `procfs` `/proc/maneg`. Using this entry, the module can accept the following commands:
- `listva` &mdash; display all VMAs of the current process
- `find page addr` &mdash; find the va->pa address translation in the mm context of the current process and display it
- `writeval addr val` &mdash; change the contents of the unsigned long size for the current process to val

All output is available in `dmesg`.

## Setup

1) Install kernel with instruction in repository root.
2) Copy `task4_procfs_mmaneg.patch` to the folder on the same level as `kernel` (look at README.md with kernel installation).
3) Run
   ```bash
   git apply task4_procfs_mmaneg.patch
   ```

   Or manually:
    ```bash
    # Copy
    cd kernel/procfs_mmaneg_module/
  
    ABS_PATH_TO_VROOT=<path/to/vroot> KERNEL_VERSION=6.7.4 make clean
    # ABS_PATH_TO_VROOT="/home/ownstreamer/Proga/MIPT/Linux/workspace/kernel/vroot" KERNEL_VERSION=6.7.4 make clean
    ABS_PATH_TO_VROOT=<path/to/vroot> KERNEL_VERSION=6.7.4 make all
    # ABS_PATH_TO_VROOT="/home/ownstreamer/Proga/MIPT/Linux/workspace/kernel/vroot" KERNEL_VERSION=6.7.4 make all
    
    cp procfs_mmaneg_module.ko ../vroot/lib/modules/6.7.4/
    
    cd ../vroot
    find . | cpio -ov --format=newc | gzip -9 > ../initramfs
    
    # Run qemu
    cd ../
    ```
4) Test
   ```bash
    qemu-system-x86_64 -kernel ./boot/vmlinuz-6.7.4 -initrd initramfs -nographic -append "console=ttyS0"
   insmod /lib/modules/6.7.4/procfs_mmaneg_module.ko # or add it to 'init'
   ./test_module.sh
   ```

Actually, test only check the module correct creation and initialisation, as well as the basic communication. Correctness of concurrent communication can be seen in the code (it is quite primitive).
