# Task 3 - Sched Counter

## Description
Outputs every minute in the kernel buffer (which can be read with the `dmesg` utility) information about how many keystrokes occurred in the past minute.

Adds `sched_num` into `task_struct` which counts how many times this task is scheduled to execute. You 

it can be accessed via

cat /proc/<pid_id>/sched_num

## Setup

1) Copy `task3_sched_counter.patch` to the folder on the same level as `kernel` (look at README.md with kernel installation).
2) Run
   ```bash
   git apply task3_sched_counter.patch
   ```

3) Install kernel with instruction in repository root (only compilation to /boot).

4) Test
   ```bash
    qemu-system-x86_64 -kernel ./boot/vmlinuz-6.7.4 -initrd initramfs -nographic -append "console=ttyS0"
   cat /proc/1/sched_counter # number always grows by 4/5
   cat /proc/2/sched_counter # number always grows by 4/5
   killall qemu-system-x86_64
   ```
