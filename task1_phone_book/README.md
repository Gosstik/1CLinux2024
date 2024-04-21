# Device

## Setup

1) Install kernel with instruction in repository root.
2) Copy `git_diff_task1.txt` to the folder on the same level as `kernel` (look at README.md with kernel installation).
3) Run
   ```bash
   git apply task1_phone_book.patch
   ```

   Or manually:
    ```bash
    # Copy
    cd kernel/phone_book_module
  
    ABS_PATH_TO_VROOT=<path/to/vroot> KERNEL_VERSION=6.7.4 make clean
    # ABS_PATH_TO_VROOT="/home/ownstreamer/Proga/MIPT/Linux/workspace/kernel/vroot" KERNEL_VERSION=6.7.4 make clean
    ABS_PATH_TO_VROOT=<path/to/vroot> KERNEL_VERSION=6.7.4 make all
    #ABS_PATH_TO_VROOT="/home/ownstreamer/Proga/MIPT/Linux/workspace/kernel/vroot" KERNEL_VERSION=6.7.4 make all
    
    cp phone_book_module.ko ../vroot/lib/modules/6.7.4/
    
    cd ../vroot
    find . | cpio -ov --format=newc | gzip -9 > ../initramfs
    
    # Run qemu
    cd ../
    ```
4) Test
   ```bash
    qemu-system-x86_64 -kernel ./boot/vmlinuz-6.7.4 -initrd initramfs -nographic -append "console=ttyS0"
    ./test_module.sh
   ```

## Write options and format

* Create user
  ```bash
  # Writ
  echo "add name surname age phone email" > /dev/mipt_pb
  echo "add Mike Abbot 18 +7999887766 mike.abbot@gmail.com" > /dev/mipt_pb
  # Read
  cat /dev/mipt_pb # User created.
  # Result: 'User added.' or 'User already exists.'
  ```

* Find user by surname.
  ```bash
  # Write
  echo "get surname" > /dev/mipt_pb
  echo "get Abbot" > /dev/mipt_pb
  # Read
  cat /dev/mipt_pb
  # Result:
  # Name: user
  # Surname: surname
  # Age: age
  # Phone: phone
  # Email: email
  ```

* Delete user by surname.
  ```bash
  # Write
  echo "del surname" > /dev/mipt_pb
  echo "del Abbot" > /dev/mipt_pb
  # Read
  cat /dev/mipt_pb
  # Result: 'User deleted.' or 'User not found.'
  ```

* In case there are some errors in format, `cat` command will print the error.

## Implementation

Device has only one buffer for write and read operations. Therefore, after two write operations where will be accessible only result of the previous operation.

